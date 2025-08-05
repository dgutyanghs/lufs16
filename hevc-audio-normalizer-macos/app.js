class VideoAudioNormalizer {
    constructor() {
        this.ffmpegProcessor = null;
        this.currentFile = null;
        this.isInitialized = false;
        this.initializeApp();
    }

    async initializeApp() {
        try {
            const loadingStatus = document.getElementById('loadingStatus');
            const loadingText = document.getElementById('loadingText');

            loadingText.textContent = '正在初始化FFmpeg处理器...';

            this.ffmpegProcessor = new FFmpegAudioProcessor();

            loadingText.textContent = '正在设置事件监听器...';
            this.initializeEventListeners();

            loadingText.textContent = '初始化完成！';

            // 隐藏加载状态
            setTimeout(() => {
                loadingStatus.style.display = 'none';
            }, 1000);

            this.isInitialized = true;
            console.log('应用初始化完成');

        } catch (error) {
            console.error('应用初始化失败:', error);
            const loadingText = document.getElementById('loadingText');
            loadingText.textContent = '初始化失败: ' + error.message;
            loadingText.style.color = 'red';
        }
    }

    initializeEventListeners() {
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');

        // 文件拖拽处理
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });

        uploadArea.addEventListener('dragleave', () => {
            uploadArea.classList.remove('dragover');
        });

        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                this.handleFileSelect(files[0]);
            }
        });

        // 文件选择处理
        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                this.handleFileSelect(e.target.files[0]);
            }
        });
    }

    async handleFileSelect(file) {
        if (!this.isInitialized) {
            alert('应用尚未初始化完成，请稍候再试');
            return;
        }

        // 验证文件类型
        if (!file.type.startsWith('video/')) {
            alert('请选择视频文件');
            return;
        }

        // 检查文件大小 (限制为1GB，FFmpeg.js可以处理更大的文件)
        if (file.size > 1000 * 1024 * 1024) {
            alert('文件太大，请选择小于1GB的视频文件');
            return;
        }

        this.currentFile = file;
        this.showProcessingPanel();

        try {
            await this.processVideo();
        } catch (error) {
            console.error('处理错误:', error);
            alert(`处理失败: ${error.message}\n\n请检查浏览器控制台获取更多信息。`);
            this.resetInterface();
        }
    }

    showProcessingPanel() {
        document.getElementById('processingPanel').classList.remove('hidden');
        document.getElementById('resultPanel').classList.add('hidden');
    }

    updateProgress(percentage, status) {
        const progressBar = document.getElementById('progressBar');
        const statusText = document.getElementById('statusText');

        progressBar.style.width = `${percentage}%`;
        statusText.textContent = status;
    }

    async processVideo() {
        const result = await this.ffmpegProcessor.processVideo(
            this.currentFile,
            (progress, status) => this.updateProgress(progress, status)
        );

        // 显示音频信息
        this.displayAudioInfo(result);

        // 显示结果
        this.showResult(result.processedVideo);
    }

    displayAudioInfo(result) {
        const audioInfo = document.getElementById('audioInfo');
        const originalLUFSElement = document.getElementById('originalLUFS');
        const gainAdjustmentElement = document.getElementById('gainAdjustment');
        const peakLevelElement = document.getElementById('peakLevel');
        const dynamicRangeElement = document.getElementById('dynamicRange');

        originalLUFSElement.textContent = result.originalLUFS.toFixed(1);
        gainAdjustmentElement.textContent = result.gainAdjustment > 0 ?
            `+${result.gainAdjustment.toFixed(1)}` : result.gainAdjustment.toFixed(1);
        peakLevelElement.textContent = result.peakLevel.toFixed(1);
        dynamicRangeElement.textContent = result.dynamicRange.toFixed(1);

        audioInfo.classList.remove('hidden');
    }

    showResult(processedVideoBlob) {
        const resultPanel = document.getElementById('resultPanel');
        const resultVideoElement = document.getElementById('resultVideo');
        const downloadBtn = document.getElementById('downloadBtn');

        // 显示处理后的视频
        const videoURL = URL.createObjectURL(processedVideoBlob);
        resultVideoElement.src = videoURL;

        // 存储blob用于下载
        this.processedVideoBlob = processedVideoBlob;

        // 设置下载功能
        downloadBtn.onclick = () => this.downloadProcessedVideo();

        resultPanel.classList.remove('hidden');
    }

    downloadProcessedVideo() {
        if (!this.processedVideoBlob) {
            alert('没有可下载的处理后视频');
            return;
        }

        // 创建下载链接
        const link = document.createElement('a');
        const fileName = this.currentFile.name.replace(/\.[^/.]+$/, '_normalized.mp4');

        const url = URL.createObjectURL(this.processedVideoBlob);
        link.href = url;
        link.download = fileName;

        // 触发下载
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        // 清理URL对象
        setTimeout(() => URL.revokeObjectURL(url), 1000);
    }

    resetInterface() {
        document.getElementById('processingPanel').classList.add('hidden');
        document.getElementById('resultPanel').classList.add('hidden');
        document.getElementById('audioInfo').classList.add('hidden');
        document.getElementById('progressBar').style.width = '0%';
        document.getElementById('statusText').textContent = '准备中...';

        // 清理资源
        if (this.processedVideoBlob) {
            URL.revokeObjectURL(this.processedVideoBlob);
            this.processedVideoBlob = null;
        }

        this.currentFile = null;
    }
}

// 初始化应用函数
function initializeApp() {
    try {
        // 检查必要的全局变量是否存在
        if (typeof FFmpegWASM === 'undefined') {
            throw new Error('FFmpeg.js库未加载。请检查网络连接或CDN可用性。');
        }

        if (typeof FFmpegUtil === 'undefined') {
            throw new Error('FFmpeg Util库未加载。请检查网络连接或CDN可用性。');
        }

        console.log('开始初始化应用...');
        new VideoAudioNormalizer();
        console.log('应用初始化成功');
        return true;
    } catch (error) {
        console.error('应用初始化失败:', error);
        const loadingText = document.getElementById('loadingText');
        if (loadingText) {
            loadingText.textContent = '应用初始化失败: ' + error.message;
            loadingText.style.color = 'red';
        }
        return false;
    }
}

// 错误处理
window.addEventListener('error', (e) => {
    console.error('应用错误:', e.error);
    console.error('错误详情:', e);

    // 提供更详细的错误信息
    let errorMessage = '应用出现错误：\n';
    if (e.error && e.error.message) {
        errorMessage += e.error.message + '\n';
    }
    if (e.filename) {
        errorMessage += '文件: ' + e.filename + '\n';
    }
    if (e.lineno) {
        errorMessage += '行号: ' + e.lineno + '\n';
    }

    errorMessage += '\n请检查浏览器控制台获取更多信息，或刷新页面重试。';
    alert(errorMessage);
});

// 处理未捕获的Promise错误
window.addEventListener('unhandledrejection', (e) => {
    console.error('未处理的Promise错误:', e.reason);
    console.error('错误详情:', e);

    let errorMessage = 'Promise错误：\n';
    if (e.reason && e.reason.message) {
        errorMessage += e.reason.message;
    } else {
        errorMessage += e.reason;
    }

    alert(errorMessage + '\n\n请检查浏览器控制台获取更多信息。');
});

// 检查浏览器兼容性
function checkBrowserSupport() {
    const features = {
        'WebAssembly': typeof WebAssembly !== 'undefined',
        'SharedArrayBuffer': typeof SharedArrayBuffer !== 'undefined',
        'File API': window.File && window.FileReader && window.FileList && window.Blob,
        'URL.createObjectURL': typeof URL !== 'undefined' && typeof URL.createObjectURL === 'function'
    };

    const unsupported = Object.entries(features)
        .filter(([, supported]) => !supported)
        .map(([name]) => name);

    // 检查关键功能
    const criticalFeatures = ['WebAssembly', 'File API', 'URL.createObjectURL'];
    const criticalUnsupported = unsupported.filter(name => criticalFeatures.includes(name));

    if (criticalUnsupported.length > 0) {
        alert(`您的浏览器不支持以下关键功能，无法正常使用：\n${criticalUnsupported.join(', ')}\n\n请使用最新版本的Chrome、Firefox、Safari或Edge浏览器。`);
        return false;
    }

    // 检查SharedArrayBuffer的特殊情况
    if (typeof SharedArrayBuffer === 'undefined') {
        const isLocalhost = location.hostname === 'localhost' || location.hostname === '127.0.0.1';
        const isHTTPS = location.protocol === 'https:';

        let message = '⚠️ SharedArrayBuffer不可用，这会影响处理性能但不影响功能。\n\n';

        if (!isHTTPS && !isLocalhost) {
            message += '建议解决方案：\n';
            message += '1. 使用HTTPS访问此页面\n';
            message += '2. 或者下载到本地运行\n\n';
        } else if (isLocalhost) {
            message += '建议解决方案：\n';
            message += '1. 运行 start-server.bat (Windows) 或 start-server.sh (Mac/Linux)\n';
            message += '2. 然后访问 http://localhost:8080\n\n';
        }

        message += '当前仍可正常使用，只是处理速度会较慢。';

        // 显示信息但不阻止使用
        console.warn(message);

        // 在页面上显示提示
        showSharedArrayBufferWarning(message);
    }

    return true;
}

// 显示SharedArrayBuffer警告
function showSharedArrayBufferWarning(message) {
    const warningDiv = document.createElement('div');
    warningDiv.style.cssText = `
        background-color: #fff3cd;
        border: 1px solid #ffeaa7;
        color: #856404;
        padding: 15px;
        margin: 10px 0;
        border-radius: 5px;
        font-size: 14px;
        line-height: 1.4;
    `;
    warningDiv.innerHTML = `
        <strong>性能提示:</strong><br>
        SharedArrayBuffer不可用，处理速度会较慢但功能正常。<br>
        <details style="margin-top: 10px;">
            <summary style="cursor: pointer; font-weight: bold;">查看解决方案</summary>
            <div style="margin-top: 10px; padding-left: 10px;">
                ${message.replace(/\n/g, '<br>')}
            </div>
        </details>
    `;

    const container = document.querySelector('.container');
    container.insertBefore(warningDiv, container.firstChild);
}

// 页面加载时检查浏览器支持
if (!checkBrowserSupport()) {
    // 如果关键功能不支持，禁用上传功能
    document.getElementById('uploadArea').style.display = 'none';
    document.getElementById('fileInput').disabled = true;
}
// 添加批量处
理功能
class BatchProcessor {
    constructor(ffmpegProcessor) {
        this.ffmpegProcessor = ffmpegProcessor;
        this.setupBatchUI();
    }

    setupBatchUI() {
        // 可以在这里添加批量处理的UI逻辑
        // 例如多文件选择、批量进度显示等
    }

    async processBatch(files, progressCallback) {
        return await this.ffmpegProcessor.processBatch(files, progressCallback);
    }
}

// 添加视频信息显示功能
async function displayVideoInfo(file, ffmpegProcessor) {
    try {
        const info = await ffmpegProcessor.getVideoInfo(file);
        console.log('视频信息:', info);

        // 可以在UI中显示这些信息
        const infoText = `
            时长: ${Math.floor(info.duration / 60)}:${(info.duration % 60).toFixed(0).padStart(2, '0')}
            分辨率: ${info.resolution}
            视频编码: ${info.videoCodec}
            音频编码: ${info.audioCodec}
            采样率: ${info.sampleRate} Hz
        `;

        return infoText;
    } catch (error) {
        console.error('获取视频信息失败:', error);
        return '无法获取视频信息';
    }
}