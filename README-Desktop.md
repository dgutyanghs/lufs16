# HEVC 视频音频响度调节器 - 桌面版

## 🚀 功能特点

### ✅ 完美解决浏览器限制

- **保持 HEVC 编码** - 视频流直接复制，零质量损失
- **保持 MP4 格式** - 输出与输入格式完全一致
- **专业 FFmpeg 处理** - 使用原生 FFmpeg，无 CDN 依赖
- **桌面级性能** - 充分利用系统资源，处理速度快

### 🎯 专业音频处理

- **EBU R128 标准** - 基于国际广播标准的 LUFS 计算
- **流复制模式** - 仅重编码音频，视频保持不变
- **精确响度控制** - 支持自定义目标 LUFS、峰值限制
- **批量处理** - 支持多文件批量标准化

## 📦 安装和运行

### 开发环境运行

```bash
# 安装依赖
npm install

# 开发模式运行
npm run dev

# 正式模式运行
npm start
```

### 构建可执行文件

```bash
# 构建Windows版本
npm run build-win

# 构建macOS版本
npm run build-mac

# 构建Linux版本
npm run build-linux

# 构建所有平台
npm run build
```

## 🔧 技术架构

### 核心技术栈

- **Electron** - 跨平台桌面应用框架
- **FFmpeg** - 专业音视频处理引擎
- **fluent-ffmpeg** - Node.js FFmpeg 包装器
- **ffmpeg-static** - 静态编译的 FFmpeg 二进制文件

### 关键特性

- **原生 FFmpeg 集成** - 内置静态编译的 FFmpeg
- **IPC 通信** - 主进程和渲染进程安全通信
- **进度反馈** - 实时处理进度显示
- **错误处理** - 完善的错误捕获和用户提示

## 🎬 使用流程

### 1. 文件选择

- 拖拽视频文件到应用窗口
- 或点击"选择文件"按钮
- 支持 MP4、MOV、MKV、AVI 等格式

### 2. 音频分析

- 点击"开始分析"按钮
- 系统使用 FFmpeg loudnorm 滤镜分析音频
- 显示当前 LUFS、峰值电平、响度范围等参数

### 3. 处理设置

- 目标响度：默认-16 LUFS（广播标准）
- 峰值限制：默认-1.5 dBTP
- 响度范围：默认 11 LU
- 处理模式：流复制（保持视频编码）

### 4. 开始处理

- 选择输出文件位置
- 实时显示处理进度
- 完成后可直接打开或在文件夹中显示

## 📊 FFmpeg 命令示例

应用内部使用的核心 FFmpeg 命令：

```bash
ffmpeg -i input.mp4 \
  -af "loudnorm=I=-16:TP=-1.5:LRA=11:linear=true" \
  -c:v copy \          # 视频流复制，保持HEVC
  -c:a aac \           # 音频重编码为AAC
  -b:a 192k \          # 音频比特率
  -movflags +faststart \ # 优化MP4结构
  output.mp4
```

## 🔍 技术优势对比

| 特性      | 桌面版        | 浏览器版    |
| --------- | ------------- | ----------- |
| HEVC 支持 | ✅ 完美支持   | ❌ 限制     |
| MP4 输出  | ✅ 原生支持   | ❌ 仅 WebM  |
| 处理速度  | ✅ 原生性能   | 🔶 受限     |
| 文件大小  | ✅ 无限制     | ❌ 内存限制 |
| 离线使用  | ✅ 完全离线   | ❌ 需要 CDN |
| 批量处理  | ✅ 高效批处理 | 🔶 有限支持 |

## 📁 项目结构

```
hevc-audio-normalizer/
├── main.js              # Electron主进程
├── preload.js           # 预加载脚本（安全桥接）
├── index.html           # 用户界面
├── styles.css           # 样式文件
├── renderer.js          # 渲染进程逻辑
├── package.json         # 项目配置
├── assets/              # 应用图标资源
└── README-Desktop.md    # 桌面版说明文档
```

## 🛠️ 开发说明

### 主要模块

- **main.js** - 窗口管理、文件对话框、FFmpeg 调用
- **renderer.js** - 用户界面逻辑、状态管理
- **preload.js** - 安全的 API 暴露层

### IPC 通信接口

- `select-video-file` - 选择视频文件
- `get-video-info` - 获取视频信息
- `analyze-audio-loudness` - 分析音频响度
- `process-video` - 处理视频文件
- `batch-process-videos` - 批量处理

### 安全考虑

- 使用 contextIsolation 隔离上下文
- 通过 preload.js 安全暴露 API
- 禁用 nodeIntegration 防止安全风险

## 🎯 使用场景

### 专业制作

- 视频后期制作音频标准化
- 广播电视内容合规处理
- 流媒体平台内容准备

### 个人用户

- 家庭视频音频优化
- 社交媒体内容标准化
- 录屏内容音频调节

## 📋 系统要求

### 最低要求

- Windows 10 / macOS 10.14 / Ubuntu 18.04
- 4GB RAM
- 1GB 可用磁盘空间

### 推荐配置

- 8GB+ RAM（处理大文件）
- SSD 存储（提升处理速度）
- 多核 CPU（并行处理）

## 🔧 故障排除

### 常见问题

1. **FFmpeg 不可用** - 检查防病毒软件是否阻止
2. **处理失败** - 确认输入文件格式支持
3. **内存不足** - 处理大文件时关闭其他应用

### 日志查看

开发模式下按 F12 打开开发者工具查看详细日志。

## 📄 许可证

MIT License - 可自由使用、修改和分发。
