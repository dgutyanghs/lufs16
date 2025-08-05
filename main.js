const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron');
const path = require('path');
const fs = require('fs');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const ffprobeStatic = require('ffprobe-static');

// 设置FFmpeg路径 - 处理打包后的路径问题
function setupFFmpegPaths() {
    try {
        let ffmpegPath, ffprobePath;
        
        if (app.isPackaged) {
            // 打包后的路径
            const resourcesPath = process.resourcesPath;
            ffmpegPath = path.join(resourcesPath, 'ffmpeg-static', 'ffmpeg');
            
            // FFprobe路径需要根据平台和架构确定
            const platform = process.platform;
            const arch = process.arch;
            ffprobePath = path.join(resourcesPath, 'ffprobe-static', 'bin', platform, arch, 'ffprobe');
            
            // macOS下需要添加可执行权限
            if (process.platform === 'darwin') {
                try {
                    fs.chmodSync(ffmpegPath, '755');
                    fs.chmodSync(ffprobePath, '755');
                } catch (chmodErr) {
                    console.warn('无法设置FFmpeg可执行权限:', chmodErr.message);
                }
            }
        } else {
            // 开发环境路径
            ffmpegPath = ffmpegStatic;
            ffprobePath = ffprobeStatic.path;
        }
        
        console.log('FFmpeg路径:', ffmpegPath);
        console.log('FFprobe路径:', ffprobePath);
        
        ffmpeg.setFfmpegPath(ffmpegPath);
        ffmpeg.setFfprobePath(ffprobePath);
        
        return { ffmpegPath, ffprobePath };
    } catch (error) {
        console.error('FFmpeg路径设置失败:', error);
        // 回退到默认路径
        ffmpeg.setFfmpegPath(ffmpegStatic);
        ffmpeg.setFfprobePath(ffprobeStatic.path);
        return { ffmpegPath: ffmpegStatic, ffprobePath: ffprobeStatic.path };
    }
}

let mainWindow;

// 创建主窗口
function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1200,
        height: 800,
        minWidth: 800,
        minHeight: 600,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        },
        icon: path.join(__dirname, 'assets', 'icon.png'),
        title: 'HEVC视频音频响度调节器',
        show: false
    });

    mainWindow.loadFile('index.html');

    // 窗口准备好后显示
    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
    });

    // 开发模式下打开开发者工具
    if (process.argv.includes('--dev')) {
        mainWindow.webContents.openDevTools();
    }

    mainWindow.on('closed', () => {
        mainWindow = null;
    });
}

// 应用准备就绪
app.whenReady().then(() => {
    // 设置FFmpeg路径
    setupFFmpegPaths();
    createWindow();
});

// 所有窗口关闭时退出应用 (macOS除外)
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// macOS上点击dock图标重新创建窗口
app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

// IPC处理程序

// 选择视频文件
ipcMain.handle('select-video-file', async () => {
    const result = await dialog.showOpenDialog(mainWindow, {
        title: '选择视频文件',
        filters: [
            { name: '视频文件', extensions: ['mp4', 'mov', 'mkv', 'avi', 'wmv', 'm4v'] },
            { name: 'MP4文件', extensions: ['mp4'] },
            { name: 'MOV文件', extensions: ['mov'] },
            { name: 'MKV文件', extensions: ['mkv'] },
            { name: '所有文件', extensions: ['*'] }
        ],
        properties: ['openFile']
    });

    if (!result.canceled && result.filePaths.length > 0) {
        return result.filePaths[0];
    }
    return null;
});

// 选择输出文件
ipcMain.handle('select-output-file', async (event, inputPath) => {
    const inputFile = path.parse(inputPath);
    const defaultName = `${inputFile.name}_normalized${inputFile.ext}`;

    const result = await dialog.showSaveDialog(mainWindow, {
        title: '保存处理后的视频',
        defaultPath: defaultName,
        filters: [
            { name: '视频文件', extensions: ['mp4', 'mov', 'mkv'] },
            { name: 'MP4文件', extensions: ['mp4'] },
            { name: 'MOV文件', extensions: ['mov'] },
            { name: 'MKV文件', extensions: ['mkv'] },
            { name: '所有文件', extensions: ['*'] }
        ]
    });

    if (!result.canceled) {
        return result.filePath;
    }
    return null;
});

// 获取视频信息
ipcMain.handle('get-video-info', async (event, filePath) => {
    return new Promise((resolve, reject) => {
        ffmpeg.ffprobe(filePath, (err, metadata) => {
            if (err) {
                reject(err);
                return;
            }

            const videoStream = metadata.streams.find(stream => stream.codec_type === 'video');
            const audioStream = metadata.streams.find(stream => stream.codec_type === 'audio');

            const info = {
                duration: metadata.format.duration,
                size: metadata.format.size,
                bitRate: metadata.format.bit_rate,
                format: metadata.format.format_name,
                video: videoStream ? {
                    codec: videoStream.codec_name,
                    profile: videoStream.profile,
                    width: videoStream.width,
                    height: videoStream.height,
                    frameRate: eval(videoStream.r_frame_rate),
                    bitRate: videoStream.bit_rate
                } : null,
                audio: audioStream ? {
                    codec: audioStream.codec_name,
                    sampleRate: audioStream.sample_rate,
                    channels: audioStream.channels,
                    bitRate: audioStream.bit_rate
                } : null
            };

            resolve(info);
        });
    });
});

// 分析音频响度
ipcMain.handle('analyze-audio-loudness', async (event, filePath) => {
    return new Promise((resolve, reject) => {
        let analysisOutput = '';

        const command = ffmpeg(filePath)
            .audioFilters('loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json')
            .format('null')
            .output('-')
            .on('stderr', (stderrLine) => {
                analysisOutput += stderrLine + '\n';
            })
            .on('end', () => {
                try {
                    // 解析loudnorm的JSON输出
                    const jsonMatch = analysisOutput.match(/\{[\s\S]*\}/);
                    if (jsonMatch) {
                        const analysisData = JSON.parse(jsonMatch[0]);
                        resolve({
                            inputLUFS: parseFloat(analysisData.input_i) || -23,
                            inputTP: parseFloat(analysisData.input_tp) || -6,
                            inputLRA: parseFloat(analysisData.input_lra) || 7,
                            inputThresh: parseFloat(analysisData.input_thresh) || -33,
                            targetOffset: parseFloat(analysisData.target_offset) || 0
                        });
                    } else {
                        // 如果JSON解析失败，尝试从文本中提取
                        const lufsMatch = analysisOutput.match(/Input Integrated:\s*([-\d.]+)\s*LUFS/i);
                        const tpMatch = analysisOutput.match(/Input True Peak:\s*([-\d.]+)\s*dBTP/i);
                        const lraMatch = analysisOutput.match(/Input LRA:\s*([-\d.]+)\s*LU/i);

                        resolve({
                            inputLUFS: lufsMatch ? parseFloat(lufsMatch[1]) : -23,
                            inputTP: tpMatch ? parseFloat(tpMatch[1]) : -6,
                            inputLRA: lraMatch ? parseFloat(lraMatch[1]) : 7,
                            inputThresh: -33,
                            targetOffset: 0
                        });
                    }
                } catch (error) {
                    reject(new Error('无法解析音频分析结果: ' + error.message));
                }
            })
            .on('error', (err) => {
                reject(new Error('音频分析失败: ' + err.message));
            });

        command.run();
    });
});

// 处理视频 - 保持视频编码，仅处理音频
ipcMain.handle('process-video', async (event, inputPath, outputPath, options = {}) => {
    return new Promise((resolve, reject) => {
        const targetLUFS = options.targetLUFS || -16;
        const targetTP = options.targetTP || -1.5;
        const targetLRA = options.targetLRA || 11;

        // 构建FFmpeg命令
        const command = ffmpeg(inputPath)
            .audioFilters(`loudnorm=I=${targetLUFS}:TP=${targetTP}:LRA=${targetLRA}:linear=true`)
            .videoCodec('copy')  // 关键：视频流复制，保持原始编码
            .audioCodec('aac')   // 音频重新编码为AAC
            .audioBitrate('192k') // 音频比特率
            .outputOptions([
                '-movflags', '+faststart',  // 优化MP4文件结构
                '-avoid_negative_ts', 'make_zero'  // 避免时间戳问题
            ])
            .output(outputPath);

        // 进度回调
        command.on('progress', (progress) => {
            mainWindow.webContents.send('processing-progress', {
                percent: progress.percent || 0,
                currentTime: progress.timemark,
                targetSize: progress.targetSize
            });
        });

        // 处理完成
        command.on('end', () => {
            resolve({
                success: true,
                outputPath: outputPath,
                message: '视频处理完成'
            });
        });

        // 处理错误
        command.on('error', (err) => {
            reject(new Error('视频处理失败: ' + err.message));
        });

        // 开始处理
        command.run();
    });
});

// 批量处理视频
ipcMain.handle('batch-process-videos', async (event, files, outputDir, options = {}) => {
    const results = [];
    const totalFiles = files.length;

    for (let i = 0; i < totalFiles; i++) {
        const inputFile = files[i];
        const parsedPath = path.parse(inputFile);
        const outputFile = path.join(outputDir, `${parsedPath.name}_normalized${parsedPath.ext}`);

        try {
            mainWindow.webContents.send('batch-progress', {
                currentFile: i + 1,
                totalFiles: totalFiles,
                fileName: parsedPath.base,
                status: 'processing'
            });

            const result = await new Promise((resolve, reject) => {
                const command = ffmpeg(inputFile)
                    .audioFilters(`loudnorm=I=${options.targetLUFS || -16}:TP=${options.targetTP || -1.5}:LRA=${options.targetLRA || 11}:linear=true`)
                    .videoCodec('copy')
                    .audioCodec('aac')
                    .audioBitrate('192k')
                    .outputOptions(['-movflags', '+faststart'])
                    .output(outputFile)
                    .on('end', () => resolve({ success: true, outputFile }))
                    .on('error', (err) => reject(err));

                command.run();
            });

            results.push({
                inputFile: inputFile,
                outputFile: outputFile,
                success: true
            });

        } catch (error) {
            results.push({
                inputFile: inputFile,
                outputFile: null,
                success: false,
                error: error.message
            });
        }
    }

    return results;
});

// 打开文件所在文件夹
ipcMain.handle('show-file-in-folder', async (event, filePath) => {
    shell.showItemInFolder(filePath);
});

// 获取应用版本信息
ipcMain.handle('get-app-info', async () => {
    return {
        name: app.getName(),
        version: app.getVersion(),
        electronVersion: process.versions.electron,
        nodeVersion: process.versions.node,
        platform: process.platform,
        arch: process.arch
    };
});

// 检查FFmpeg可用性
ipcMain.handle('check-ffmpeg', async () => {
    return new Promise((resolve) => {
        ffmpeg.getAvailableFormats((err, formats) => {
            if (err) {
                resolve({ available: false, error: err.message });
            } else {
                const paths = setupFFmpegPaths();
                resolve({
                    available: true,
                    ffmpegPath: paths.ffmpegPath,
                    ffprobePath: paths.ffprobePath,
                    formatsCount: Object.keys(formats).length
                });
            }
        });
    });
});