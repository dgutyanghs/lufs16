# HEVC 视频音频响度调节器 - 桌面版

专业级的视频音频响度标准化工具，支持 Windows 和 macOS 系统，基于 Electron 和 FFmpeg 构建。

## 🎯 核心功能

- **保持 HEVC 编码** - 视频流直接复制，零质量损失
- **保持 MP4 格式** - 输出与输入格式完全一致
- **专业 LUFS 分析** - 基于 EBU R128 标准的精确响度计算
- **内置 FFmpeg** - 无需预装任何软件，开箱即用
- **跨平台支持** - Windows 10+、macOS 10.14+全平台支持
- **批量处理** - 支持多文件批量标准化

## 🖥️ 平台支持

### Windows 版本

- **系统要求**: Windows 10 (1903) 或更高版本 (64 位)
- **特色功能**:
  - 原生 Windows 集成
  - 硬件加速支持
  - 开始菜单和桌面快捷方式
  - Windows 通知系统集成

### macOS 版本

- **系统要求**: macOS 10.14 (Mojave) 或更高版本
- **特色功能**:
  - 支持 Intel 和 Apple Silicon Mac
  - 原生 macOS 界面
  - Dock 集成
  - macOS 通知中心支持

## 📦 下载安装

### 预构建版本

访问[Releases 页面](../../releases)下载对应平台的文件：

#### Windows

- **安装版**: `HEVC音频响度调节器 Setup.exe` (推荐)
- **便携版**: `HEVC音频响度调节器-win.zip`

#### macOS

- **Intel Mac**: `HEVC音频响度调节器-x64.zip`
- **Apple Silicon Mac**: `HEVC音频响度调节器-arm64.zip`

### 自动构建

本项目使用 GitHub Actions 自动构建所有平台版本：

- 每次推送代码都会自动构建
- 支持 Windows 和 macOS 双平台
- 生成安装程序、便携版等多种格式

## 🚀 快速开始

### Windows 用户

1. **下载**: 从 Releases 页面下载 Windows 安装程序
2. **安装**: 右键选择"以管理员身份运行"
3. **启动**: 从开始菜单或桌面快捷方式启动
4. **使用**: 拖拽 HEVC 视频文件到应用窗口

### macOS 用户

1. **下载**: 选择适合你 Mac 的版本下载
2. **安装**: 解压 ZIP 文件，拖拽到应用程序文件夹
3. **启动**: 从启动台或应用程序文件夹启动
4. **使用**: 拖拽 HEVC 视频文件到应用窗口

## 🎬 使用方法

### 基本流程

1. **启动应用** - 双击可执行文件或从应用程序启动
2. **选择视频** - 拖拽 HEVC 视频文件到应用窗口
3. **分析音频** - 点击"开始分析"查看当前响度信息
4. **设置参数** - 调整目标响度（默认-16 LUFS）
5. **开始处理** - 选择输出位置并开始处理
6. **完成下载** - 处理完成后直接打开或在文件夹中显示

### 支持的格式

- **输入**: MP4, MOV, MKV, AVI, M4V, WMV, FLV 等
- **输出**: 与输入格式相同，保持 HEVC 编码
- **音频**: 重新编码为 AAC 192kbps 高质量音频

## 🔧 开发环境

### 环境要求

- Node.js 18+
- npm 或 yarn
- **Windows**: Visual Studio Build Tools
- **macOS**: Xcode Command Line Tools

### 快速安装

#### Windows

```bash
# 自动安装（推荐）
.\install-and-run-windows.bat

# 手动安装
npm install
npm run dev
```

#### macOS

```bash
# 自动安装（推荐）
chmod +x setup-macos.sh && ./setup-macos.sh

# 手动安装
npm install
npm run dev
```

### 构建应用

#### Windows 构建

```bash
# 使用脚本（推荐）
.\build-windows.bat

# 手动构建
npm run build-win
```

#### macOS 构建

```bash
# 手动构建
npm run build-mac

# 构建目录版本（开发用）
npm run build-mac-dir
```

#### 跨平台构建

```bash
# 构建所有平台
npm run build

# 仅构建Windows和Linux
npm run build-all
```

## 📊 性能参考

| 平台    | 配置                    | 1080p 视频 | 4K 视频    | 内存使用 |
| ------- | ----------------------- | ---------- | ---------- | -------- |
| Windows | Intel i7 + GTX 1060     | ~3x 实时   | ~1.2x 实时 | ~600MB   |
| Windows | AMD Ryzen 5 + RX 6700XT | ~3.5x 实时 | ~1.3x 实时 | ~550MB   |
| macOS   | Intel i7 MacBook Pro    | ~2.8x 实时 | ~1x 实时   | ~500MB   |
| macOS   | M1 MacBook Air          | ~4x 实时   | ~1.8x 实时 | ~400MB   |
| macOS   | M2 MacBook Pro          | ~5x 实时   | ~2.2x 实时 | ~450MB   |

## 🛠️ 技术架构

### 核心技术

- **Electron** - 跨平台桌面应用框架
- **FFmpeg** - 专业音视频处理引擎
- **fluent-ffmpeg** - Node.js FFmpeg 包装器
- **ffmpeg-static** - 静态编译的 FFmpeg 二进制文件

### 关键特性

- **流复制模式** - 使用`-c:v copy`保持视频编码不变
- **专业响度分析** - 使用 FFmpeg 的`loudnorm`滤镜
- **IPC 通信** - 主进程和渲染进程安全通信
- **进度反馈** - 实时处理进度显示

### 项目结构

```
hevc-audio-normalizer/
├── main.js              # Electron主进程
├── preload.js           # 安全桥接层
├── renderer.js          # 渲染进程逻辑
├── index.html           # 用户界面
├── styles.css           # 样式文件
├── ffmpeg-processor.js  # FFmpeg处理器
├── package.json         # 项目配置
├── .github/workflows/   # GitHub Actions配置
├── assets/              # 应用资源
├── README-Windows.md    # Windows专用文档
└── README-macOS.md      # macOS专用文档
```

## 🚀 Release 管理

### 创建 Release

#### 统一 Release（推荐）

```bash
# PowerShell
.\create-release-tag.ps1

# 或批处理
.\create-release-tag.bat
```

#### Windows 专用 Release

```bash
.\create-windows-release.bat
```

### 自动化构建

- 推送标签 `v*` 触发正式发布
- 推送到主分支触发预发布版本
- 支持手动触发构建

## 🔒 安全考虑

### Windows

- 首次运行可能出现 Windows Defender 警告
- 点击"更多信息" → "仍要运行"
- 应用程序是安全的，警告是由于未签名可执行文件

### macOS

- 首次运行可能出现安全警告
- 前往"系统偏好设置" → "安全性与隐私" → "仍要打开"
- 或使用右键菜单"打开"

### 通用安全

- 使用`contextIsolation`隔离上下文
- 通过`preload.js`安全暴露 API
- 禁用`nodeIntegration`防止安全风险
- 所有文件处理在本地完成，保护隐私

## 🎯 使用场景

### 专业制作

- 视频后期制作音频标准化
- 广播电视内容合规处理
- 流媒体平台内容准备
- 企业培训视频制作

### 个人用户

- 家庭视频音频优化
- 社交媒体内容标准化
- 录屏内容音频调节
- 游戏录像后期处理

## 🔧 故障排除

### Windows 常见问题

1. **应用无法启动** - 确保 Windows 10+，安装 VC++ Redistributable
2. **处理失败** - 确认文件格式支持，检查磁盘空间
3. **性能问题** - 关闭其他视频软件，使用 SSD 存储

### macOS 常见问题

1. **应用无法打开** - 检查系统版本，允许未知开发者应用
2. **权限问题** - 在安全设置中允许应用运行
3. **性能问题** - 确保充足内存，关闭其他应用

### 获取帮助

- 查看平台专用文档 (`README-Windows.md`, `README-macOS.md`)
- 检查[Issues 页面](../../issues)
- 查看构建日志和错误信息

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个工具！

### 开发流程

1. Fork 本仓库
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request

### 构建测试

- 确保 Windows 和 macOS 版本都能正常构建
- 测试核心功能在两个平台上的表现
- 验证安装程序和便携版本

## 📄 许可证

MIT License - 可自由使用、修改和分发。

## 🙏 致谢

- [Electron](https://electronjs.org/) - 跨平台桌面应用框架
- [FFmpeg](https://ffmpeg.org/) - 强大的音视频处理工具
- [fluent-ffmpeg](https://github.com/fluent-ffmpeg/node-fluent-ffmpeg) - Node.js FFmpeg 包装器

---

**🎬 享受专业级的跨平台视频音频处理体验！**
