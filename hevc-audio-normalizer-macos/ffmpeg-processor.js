class FFmpegAudioProcessor {
    constructor() {
        this.ffmpeg = null;
        this.isLoaded = false;
        this.targetLUFS = -16;
    }

    async initFFmpeg() {
        if (this.isLoaded) return;

        const { FFmpeg } = FFmpegWASM;
        const { toBlobURL } = FFmpegUtil;

        this.ffmpeg = new FFmpeg();

        // 加载FFmpeg核心文件
        const baseURL = 'https://unpkg.com/@ffmpeg/core@0.12.4/dist/umd';
        this.ffmpeg.on('log', ({ message }) => {
            console.log('FFmpeg:', message);
        });

        try {
            // 检查SharedArrayBuffer支持
            const hasSharedArrayBuffer = typeof SharedArrayBuffer !== 'undefined';
            console.log(`SharedArrayBuffer支持: ${hasSharedArrayBuffer ? '是' : '否'}`);

            if (hasSharedArrayBuffer) {
                // 使用多线程版本
                console.log('使用多线程版本的FFmpeg');
                await this.ffmpeg.load({
                    coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
                    wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm'),
                    workerURL: await toBlobURL(`${baseURL}/ffmpeg-core.worker.js`, 'text/javascript'),
                });
            } else {
                // 使用单线程版本
                console.log('使用单线程版本的FFmpeg (性能可能较慢)');
                await this.ffmpeg.load({
                    coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
                    wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm'),
                });
            }
        } catch (error) {
            console.error('FFmpeg加载失败:', error);

            // 提供更详细的错误信息
            let errorMessage = `FFmpeg初始化失败: ${error.message}`;

            if (error.message.includes('fetch')) {
                errorMessage += '\n\n可能的原因：\n1. 网络连接问题\n2. CDN不可用\n3. 防火墙阻止';
            } else if (error.message.includes('WebAssembly')) {
                errorMessage += '\n\n请确保浏览器支持WebAssembly';
            } else if (error.message.includes('SharedArrayBuffer')) {
                errorMessage += '\n\n请使用本地服务器或HTTPS访问';
            }

            throw new Error(errorMessage);
        }

        this.isLoaded = true;
        console.log('FFmpeg初始化成功');
    }

    // 分析音频的LUFS、峰值和动态范围
    async analyzeAudio(videoFile, progressCallback) {
        await this.initFFmpeg();

        progressCallback(10, '准备分析音频...');

        // 将文件写入FFmpeg虚拟文件系统
        const { fetchFile } = FFmpegUtil;
        const inputFileName = 'input.mp4';
        await this.ffmpeg.writeFile(inputFileName, await fetchFile(videoFile));

        progressCallback(30, '提取音频信息...');

        // 使用FFmpeg的loudnorm滤镜分析音频
        const analysisArgs = [
            '-i', inputFileName,
            '-af', 'loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json',
            '-f', 'null',
            '-'
        ];

        let analysisOutput = '';
        this.ffmpeg.on('log', ({ message }) => {
            analysisOutput += message + '\n';
        });

        await this.ffmpeg.exec(analysisArgs);

        progressCallback(50, '解析分析结果...');

        // 解析loudnorm的JSON输出
        const analysisResult = this.parseLoudnormOutput(analysisOutput);

        // 获取峰值信息
        const peakArgs = [
            '-i', inputFileName,
            '-af', 'astats=metadata=1:reset=1',
            '-f', 'null',
            '-'
        ];

        let peakOutput = '';
        this.ffmpeg.on('log', ({ message }) => {
            peakOutput += message + '\n';
        });

        await this.ffmpeg.exec(peakArgs);

        const peakInfo = this.parsePeakOutput(peakOutput);

        return {
            inputLUFS: parseFloat(analysisResult.input_i) || -23,
            inputTP: parseFloat(analysisResult.input_tp) || -6,
            inputLRA: parseFloat(analysisResult.input_lra) || 7,
            peakLevel: peakInfo.peak || -6,
            dynamicRange: parseFloat(analysisResult.input_lra) || 7
        };
    }

    // 解析loudnorm滤镜的输出
    parseLoudnormOutput(output) {
        const jsonMatch = output.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            try {
                return JSON.parse(jsonMatch[0]);
            } catch (e) {
                console.error('解析loudnorm输出失败:', e);
            }
        }

        // 如果JSON解析失败，尝试从文本中提取信息
        const lufsMatch = output.match(/Input Integrated:\s*([-\d.]+)\s*LUFS/i);
        const tpMatch = output.match(/Input True Peak:\s*([-\d.]+)\s*dBTP/i);
        const lraMatch = output.match(/Input LRA:\s*([-\d.]+)\s*LU/i);

        return {
            input_i: lufsMatch ? lufsMatch[1] : '-23',
            input_tp: tpMatch ? tpMatch[1] : '-6',
            input_lra: lraMatch ? lraMatch[1] : '7'
        };
    }

    // 解析峰值信息
    parsePeakOutput(output) {
        const peakMatch = output.match(/Peak level dB:\s*([-\d.]+)/i);
        return {
            peak: peakMatch ? parseFloat(peakMatch[1]) : -6
        };
    }

    // 处理视频，调节音频响度到目标LUFS
    async processVideo(videoFile, progressCallback) {
        try {
            progressCallback(5, '初始化FFmpeg...');
            await this.initFFmpeg();

            // 分析原始音频
            const analysisResult = await this.analyzeAudio(videoFile, progressCallback);

            progressCallback(60, '计算音频处理参数...');

            // 计算所需的增益调节
            const gainAdjustment = this.targetLUFS - analysisResult.inputLUFS;

            progressCallback(70, '应用音频响度标准化...');

            const inputFileName = 'input.mp4';
            const outputFileName = 'output.mp4';

            // 确保文件已写入
            const { fetchFile } = FFmpegUtil;
            await this.ffmpeg.writeFile(inputFileName, await fetchFile(videoFile));

            // 使用loudnorm滤镜进行两遍处理以获得最佳结果
            const processArgs = [
                '-i', inputFileName,
                '-af', `loudnorm=I=${this.targetLUFS}:TP=-1.5:LRA=11:linear=true`,
                '-c:v', 'copy', // 保持视频不变
                '-c:a', 'aac',  // 重新编码音频
                '-b:a', '192k', // 音频比特率
                outputFileName
            ];

            await this.ffmpeg.exec(processArgs);

            progressCallback(90, '生成输出文件...');

            // 读取处理后的文件
            const outputData = await this.ffmpeg.readFile(outputFileName);
            const outputBlob = new Blob([outputData.buffer], { type: 'video/mp4' });

            // 清理临时文件
            await this.ffmpeg.deleteFile(inputFileName);
            await this.ffmpeg.deleteFile(outputFileName);

            progressCallback(100, '处理完成!');

            return {
                originalLUFS: analysisResult.inputLUFS,
                originalTP: analysisResult.inputTP,
                originalLRA: analysisResult.inputLRA,
                peakLevel: analysisResult.peakLevel,
                dynamicRange: analysisResult.dynamicRange,
                gainAdjustment: gainAdjustment,
                processedVideo: outputBlob
            };

        } catch (error) {
            console.error('FFmpeg处理错误:', error);
            throw new Error(`音频处理失败: ${error.message}`);
        }
    }

    // 批量处理多个视频文件
    async processBatch(videoFiles, progressCallback) {
        const results = [];
        const totalFiles = videoFiles.length;

        for (let i = 0; i < totalFiles; i++) {
            const file = videoFiles[i];
            progressCallback(
                (i / totalFiles) * 100,
                `处理文件 ${i + 1}/${totalFiles}: ${file.name}`
            );

            try {
                const result = await this.processVideo(file, (progress, status) => {
                    const overallProgress = ((i + progress / 100) / totalFiles) * 100;
                    progressCallback(overallProgress, status);
                });

                results.push({
                    fileName: file.name,
                    success: true,
                    result: result
                });
            } catch (error) {
                results.push({
                    fileName: file.name,
                    success: false,
                    error: error.message
                });
            }
        }

        return results;
    }

    // 获取视频信息
    async getVideoInfo(videoFile) {
        await this.initFFmpeg();

        const { fetchFile } = FFmpegUtil;
        const inputFileName = 'input.mp4';
        await this.ffmpeg.writeFile(inputFileName, await fetchFile(videoFile));

        const infoArgs = [
            '-i', inputFileName,
            '-f', 'null',
            '-'
        ];

        let infoOutput = '';
        this.ffmpeg.on('log', ({ message }) => {
            infoOutput += message + '\n';
        });

        try {
            await this.ffmpeg.exec(infoArgs);
        } catch (e) {
            // FFmpeg在获取信息时会返回错误码，但输出是正常的
        }

        await this.ffmpeg.deleteFile(inputFileName);

        return this.parseVideoInfo(infoOutput);
    }

    // 解析视频信息
    parseVideoInfo(output) {
        const durationMatch = output.match(/Duration: (\d{2}):(\d{2}):(\d{2}\.\d{2})/);
        const videoMatch = output.match(/Video: ([^,]+).*?(\d+x\d+)/);
        const audioMatch = output.match(/Audio: ([^,]+).*?(\d+) Hz/);

        let duration = 0;
        if (durationMatch) {
            const hours = parseInt(durationMatch[1]);
            const minutes = parseInt(durationMatch[2]);
            const seconds = parseFloat(durationMatch[3]);
            duration = hours * 3600 + minutes * 60 + seconds;
        }

        return {
            duration: duration,
            videoCodec: videoMatch ? videoMatch[1] : 'unknown',
            resolution: videoMatch ? videoMatch[2] : 'unknown',
            audioCodec: audioMatch ? audioMatch[1] : 'unknown',
            sampleRate: audioMatch ? parseInt(audioMatch[2]) : 0
        };
    }

    // 清理资源
    async cleanup() {
        if (this.ffmpeg && this.isLoaded) {
            // FFmpeg.js 会自动清理资源
            this.isLoaded = false;
        }
    }
}