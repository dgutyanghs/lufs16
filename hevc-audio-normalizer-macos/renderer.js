// 渲染进程主脚本
class HEVCVideoNormalizer {
    constructor() {
        this.currentFilePath = null;
        this.currentVideoInfo = null;
        this.currentAnalysis = null;
        this.outputPath = null;
        this.isBatchMode = false;
        this.batchFiles = [];

        this.initializeApp();
    }

    async initializeApp() {
        this.setupEventListeners();
        await this.checkFFmpegStatus();
        await this.loadAppInfo();
        this.updateStatus('就绪');
    }

    setupEventListeners() {
        // 文件选择
        document.getElementById('selectFileBtn').addEventListener('click', () => {
            this.selectVideoFile();
        });

        // 拖拽支持
        const dropZone = document.getElementById('fileDropZone');
        dropZone.addEventListener('dragover', (e) => {
            e.preventDefault();
            dropZone.classList.add('dragover');
        });

        dropZone.addEventListener('dragleave', () => {
            dropZone.classList.remove('dragover');
        });

        dropZone.addEventListener('drop', (e) => {
            e.preventDefault();
            dropZone.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                this.handleFileSelection(files[0].path);
            }
        });

        // 分析按钮
        document.getElementById('analyzeBtn').addEventListener('click', () => {
            this.analyzeAudio();
        });

        // 处理按钮 (动态创建)
        document.addEventListener('click', (e) => {
            if (e.target.id === 'processBtn') {
                this.processVideo();
            }
        });

        // 结果操作按钮
        document.getElementById('openOutputBtn').addEventListener('click', () => {
            if (this.outputPath) {
                window.electronAPI.showFileInFolder(this.outputPath);
            }
        });

        document.getElementById('showInFolderBtn').addEventListener('click', () => {
            if (this.outputPath) {
                window.electronAPI.showFileInFolder(this.outputPath);
            }
        });

        document.getElementById('processAnotherBtn').addEventListener('click', () => {
            this.resetInterface();
        });

        // 模态对话框
        document.getElementById('aboutBtn').addEventListener('click', () => {
            this.showAboutModal();
        });

        document.querySelector('.modal-close').addEventListener('click', () => {
            this.hideModal();
        });

        document.getElementById('aboutModal').addEventListener('click', (e) => {
            if (e.target.id === 'aboutModal') {
                this.hideModal();
            }
        });

        // 批量处理
        document.getElementById('toggleBatchBtn').addEventListener('click', () => {
            this.toggleBatchMode();
        });

        // 进度监听
        window.electronAPI.onProcessingProgress((data) => {
            this.updateProgress(data);
        });

        window.electronAPI.onBatchProgress((data) => {
            this.updateBatchProgress(data);
        });
    }

    async selectVideoFile() {
        try {
            const filePath = await window.electronAPI.selectVideoFile();
            if (filePath) {
                await this.handleFileSelection(filePath);
            }
        } catch (error) {
            this.showError('文件选择失败', error.message);
        }
    }

    async handleFileSelection(filePath) {
        try {
            this.updateStatus('正在加载文件信息...');
            this.currentFilePath = filePath;

            // 获取视频信息
            const videoInfo = await window.electronAPI.getVideoInfo(filePath);
            this.currentVideoInfo = videoInfo;

            // 显示文件信息
            this.displayFileInfo(filePath, videoInfo);

            // 显示分析区域
            this.showSection('analysisSection');
            this.updateStatus('文件已加载，可以开始分析');

        } catch (error) {
            this.showError('文件加载失败', error.message);
        }
    }

    displayFileInfo(filePath, videoInfo) {
        const fileName = filePath.split(/[\\/]/).pop();
        const fileSize = this.formatFileSize(videoInfo.size);
        const duration = this.formatDuration(videoInfo.duration);

        document.getElementById('fileName').textContent = fileName;
        document.getElementById('fileSize').textContent = fileSize;
        document.getElementById('fileDuration').textContent = duration;
        document.getElementById('videoCodec').textContent =
            `${videoInfo.video?.codec || '未知'} ${videoInfo.video?.profile ? `(${videoInfo.video.profile})` : ''}`;
        document.getElementById('videoResolution').textContent =
            videoInfo.video ? `${videoInfo.video.width}x${videoInfo.video.height}` : '未知';
        document.getElementById('audioCodec').textContent =
            videoInfo.audio ? `${videoInfo.audio.codec} (${videoInfo.audio.channels}ch, ${videoInfo.audio.sampleRate}Hz)` : '未知';

        this.showSection('fileInfo');
    }

    async analyzeAudio() {
        if (!this.currentFilePath) {
            this.showError('错误', '请先选择视频文件');
            return;
        }

        try {
            this.updateStatus('正在分析音频响度...');
            document.getElementById('analyzeBtn').disabled = true;
            document.getElementById('analyzeBtn').textContent = '分析中...';

            const analysis = await window.electronAPI.analyzeAudioLoudness(this.currentFilePath);
            this.currentAnalysis = analysis;

            // 显示分析结果
            this.displayAnalysisResults(analysis);

            // 显示设置区域
            this.showSection('settingsSection');

            // 添加处理按钮
            this.addProcessButton();

            this.updateStatus('音频分析完成');

        } catch (error) {
            this.showError('音频分析失败', error.message);
        } finally {
            document.getElementById('analyzeBtn').disabled = false;
            document.getElementById('analyzeBtn').textContent = '重新分析';
        }
    }

    displayAnalysisResults(analysis) {
        const targetLUFS = -16;
        const adjustmentNeeded = targetLUFS - analysis.inputLUFS;

        document.getElementById('currentLUFS').textContent = analysis.inputLUFS.toFixed(1);
        document.getElementById('peakLevel').textContent = analysis.inputTP.toFixed(1);
        document.getElementById('loudnessRange').textContent = analysis.inputLRA.toFixed(1);
        document.getElementById('adjustmentNeeded').textContent =
            `${adjustmentNeeded > 0 ? '+' : ''}${adjustmentNeeded.toFixed(1)} dB`;

        // 状态判断
        const statusElement = document.getElementById('analysisStatus');
        if (Math.abs(adjustmentNeeded) < 0.5) {
            statusElement.textContent = '已达标';
            statusElement.className = 'status optimal';
        } else {
            statusElement.textContent = '需要调节';
            statusElement.className = 'status needs-adjustment';
        }

        this.showSection('analysisResults');
    }

    addProcessButton() {
        // 检查是否已存在处理按钮
        if (document.getElementById('processBtn')) {
            return;
        }

        const settingsSection = document.getElementById('settingsSection');
        const processButton = document.createElement('button');
        processButton.id = 'processBtn';
        processButton.className = 'btn btn-success';
        processButton.innerHTML = '🚀 开始处理';
        processButton.style.marginTop = '20px';
        processButton.style.width = '100%';
        processButton.style.fontSize = '16px';
        processButton.style.padding = '15px';

        settingsSection.appendChild(processButton);
    }

    async processVideo() {
        if (!this.currentFilePath || !this.currentAnalysis) {
            this.showError('错误', '请先选择文件并完成分析');
            return;
        }

        try {
            // 选择输出文件
            const outputPath = await window.electronAPI.selectOutputFile(this.currentFilePath);
            if (!outputPath) {
                return; // 用户取消了保存
            }

            this.outputPath = outputPath;

            // 获取处理设置
            const options = {
                targetLUFS: parseFloat(document.getElementById('targetLUFS').value),
                targetTP: parseFloat(document.getElementById('targetTP').value),
                targetLRA: parseFloat(document.getElementById('targetLRA').value)
            };

            // 显示进度区域
            this.showSection('progressSection');
            this.updateStatus('正在处理视频...');

            // 禁用处理按钮
            document.getElementById('processBtn').disabled = true;
            document.getElementById('processBtn').textContent = '处理中...';

            // 开始处理
            const result = await window.electronAPI.processVideo(
                this.currentFilePath,
                outputPath,
                options
            );

            // 处理完成
            this.showSection('resultSection');
            this.updateStatus('处理完成');

        } catch (error) {
            this.showError('视频处理失败', error.message);
        } finally {
            const processBtn = document.getElementById('processBtn');
            if (processBtn) {
                processBtn.disabled = false;
                processBtn.textContent = '🚀 开始处理';
            }
        }
    }

    updateProgress(data) {
        const progressFill = document.getElementById('progressFill');
        const progressPercent = document.getElementById('progressPercent');
        const progressTime = document.getElementById('progressTime');
        const progressStatus = document.getElementById('progressStatus');

        const percent = Math.round(data.percent || 0);
        progressFill.style.width = `${percent}%`;
        progressPercent.textContent = `${percent}%`;
        progressTime.textContent = data.currentTime || '--:--';
        progressStatus.textContent = `正在处理... ${data.currentTime || ''}`;
    }

    toggleBatchMode() {
        this.isBatchMode = !this.isBatchMode;
        const batchSection = document.getElementById('batchSection');
        const toggleBtn = document.getElementById('toggleBatchBtn');

        if (this.isBatchMode) {
            this.showSection('batchSection');
            toggleBtn.textContent = '切换到单文件模式';
        } else {
            this.hideSection('batchSection');
            toggleBtn.textContent = '切换到批量模式';
        }
    }

    updateBatchProgress(data) {
        const progressList = document.getElementById('batchProgressList');
        // 更新批量处理进度显示
        progressList.innerHTML = `
            <div class="batch-item">
                <span>正在处理: ${data.fileName}</span>
                <span>${data.currentFile}/${data.totalFiles}</span>
            </div>
        `;
    }

    async showAboutModal() {
        const appInfo = await window.electronAPI.getAppInfo();

        document.getElementById('aboutVersion').textContent = appInfo.version;
        document.getElementById('electronVersion').textContent = appInfo.electronVersion;
        document.getElementById('nodeVersion').textContent = appInfo.nodeVersion;
        document.getElementById('platformInfo').textContent = `${appInfo.platform} (${appInfo.arch})`;

        document.getElementById('aboutModal').classList.remove('hidden');
    }

    hideModal() {
        document.getElementById('aboutModal').classList.add('hidden');
    }

    async checkFFmpegStatus() {
        try {
            const ffmpegInfo = await window.electronAPI.checkFFmpeg();
            const statusElement = document.getElementById('ffmpegStatus');

            if (ffmpegInfo.available) {
                statusElement.textContent = 'FFmpeg: 就绪';
                statusElement.className = 'text-success';
            } else {
                statusElement.textContent = 'FFmpeg: 不可用';
                statusElement.className = 'text-danger';
                this.showError('FFmpeg错误', ffmpegInfo.error);
            }
        } catch (error) {
            document.getElementById('ffmpegStatus').textContent = 'FFmpeg: 检查失败';
        }
    }

    async loadAppInfo() {
        try {
            const appInfo = await window.electronAPI.getAppInfo();
            document.getElementById('appVersion').textContent = `v${appInfo.version}`;
        } catch (error) {
            console.error('获取应用信息失败:', error);
        }
    }

    showSection(sectionId) {
        document.getElementById(sectionId).classList.remove('hidden');
        document.getElementById(sectionId).classList.add('fade-in');
    }

    hideSection(sectionId) {
        document.getElementById(sectionId).classList.add('hidden');
    }

    updateStatus(message) {
        document.getElementById('appStatus').textContent = message;
    }

    showError(title, message) {
        // 简单的错误显示，可以后续改为更美观的模态框
        alert(`${title}: ${message}`);
        console.error(title, message);
    }

    resetInterface() {
        // 重置所有状态
        this.currentFilePath = null;
        this.currentVideoInfo = null;
        this.currentAnalysis = null;
        this.outputPath = null;

        // 隐藏所有区域
        this.hideSection('fileInfo');
        this.hideSection('analysisSection');
        this.hideSection('analysisResults');
        this.hideSection('settingsSection');
        this.hideSection('progressSection');
        this.hideSection('resultSection');

        // 移除处理按钮
        const processBtn = document.getElementById('processBtn');
        if (processBtn) {
            processBtn.remove();
        }

        // 重置分析按钮
        document.getElementById('analyzeBtn').textContent = '开始分析';

        this.updateStatus('就绪');
    }

    formatFileSize(bytes) {
        if (!bytes) return '未知';
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(1024));
        return `${(bytes / Math.pow(1024, i)).toFixed(1)} ${sizes[i]}`;
    }

    formatDuration(seconds) {
        if (!seconds) return '未知';
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        const secs = Math.floor(seconds % 60);

        if (hours > 0) {
            return `${hours}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
        } else {
            return `${minutes}:${secs.toString().padStart(2, '0')}`;
        }
    }
}

// 初始化应用
document.addEventListener('DOMContentLoaded', () => {
    new HEVCVideoNormalizer();
});