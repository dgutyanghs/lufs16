const { contextBridge, ipcRenderer } = require('electron');

// 暴露安全的API给渲染进程
contextBridge.exposeInMainWorld('electronAPI', {
    // 文件操作
    selectVideoFile: () => ipcRenderer.invoke('select-video-file'),
    selectOutputFile: (inputPath) => ipcRenderer.invoke('select-output-file', inputPath),
    showFileInFolder: (filePath) => ipcRenderer.invoke('show-file-in-folder', filePath),

    // 视频处理
    getVideoInfo: (filePath) => ipcRenderer.invoke('get-video-info', filePath),
    analyzeAudioLoudness: (filePath) => ipcRenderer.invoke('analyze-audio-loudness', filePath),
    processVideo: (inputPath, outputPath, options) => ipcRenderer.invoke('process-video', inputPath, outputPath, options),
    batchProcessVideos: (files, outputDir, options) => ipcRenderer.invoke('batch-process-videos', files, outputDir, options),

    // 系统信息
    getAppInfo: () => ipcRenderer.invoke('get-app-info'),
    checkFFmpeg: () => ipcRenderer.invoke('check-ffmpeg'),

    // 事件监听
    onProcessingProgress: (callback) => {
        ipcRenderer.on('processing-progress', (event, data) => callback(data));
    },
    onBatchProgress: (callback) => {
        ipcRenderer.on('batch-progress', (event, data) => callback(data));
    },

    // 移除事件监听
    removeAllListeners: (channel) => {
        ipcRenderer.removeAllListeners(channel);
    }
});