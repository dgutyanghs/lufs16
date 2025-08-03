# 📦 macOS 系统传输说明

## 🎯 已打包完成

✅ **压缩包**: `hevc-audio-normalizer-for-macos.zip` (约 79KB)
✅ **文件夹**: `hevc-audio-normalizer-macos/`

## 🚀 传输到 macOS 系统

### 方法 1: 直接复制压缩包

1. 将 `hevc-audio-normalizer-for-macos.zip` 复制到 macOS 系统
2. 双击解压缩
3. 进入解压后的文件夹

### 方法 2: 使用文件夹

1. 将整个 `hevc-audio-normalizer-macos/` 文件夹复制到 macOS 系统
2. 直接使用

## 🍎 在 macOS 系统上的安装步骤

### 快速安装（推荐）

```bash
# 进入项目目录
cd hevc-audio-normalizer-macos

# 给安装脚本执行权限
chmod +x setup-macos.sh

# 运行安装脚本
./setup-macos.sh
```

### 手动安装

```bash
# 进入项目目录
cd hevc-audio-normalizer-macos

# 安装Node.js依赖
npm install

# 开发模式运行
npm run dev

# 或构建macOS应用
npm run build-mac
```

## 📋 包含的文件

### 核心应用文件

- `package.json` - 项目配置
- `main.js` - Electron 主进程
- `preload.js` - 安全桥接层
- `renderer.js` - 渲染进程
- `index.html` - 用户界面
- `styles.css` - 样式文件
- `ffmpeg-processor.js` - FFmpeg 处理器
- `app.js` - 应用逻辑

### 配置文件

- `.gitignore` - Git 忽略规则
- `package-lock.json` - 依赖锁定

### 脚本文件

- `setup-macos.sh` - 自动安装脚本
- `build-macos.sh` - 构建脚本
- `install-and-run.sh` - 安装运行脚本
- `start-server.sh` - 服务器启动脚本
- `verify-build.sh` - 构建验证脚本

### 文档文件

- `README.md` - 主要说明文档
- `README-macOS-Install.md` - macOS 安装说明
- `BUILD-macOS-Solutions.md` - 构建解决方案
- `INSTALL-macOS.md` - 详细安装指南

### 资源文件

- `assets/` - 应用资源（图标等）
- `.github/workflows/` - GitHub Actions 配置

## 🔧 系统要求

### 必需

- macOS 10.14 (Mojave) 或更高版本
- Node.js 18+
- npm

### 推荐

- Xcode Command Line Tools
- Python3 + PIL (用于图标生成)

## 🎬 使用流程

1. **安装**: 运行 `./setup-macos.sh` 或 `npm install`
2. **开发**: `npm run dev`
3. **构建**: `npm run build-mac`
4. **使用**: 拖拽 HEVC 视频文件到应用窗口

## 🆘 如遇问题

1. **权限问题**: 运行 `chmod +x *.sh` 给脚本执行权限
2. **依赖问题**: 确保 Node.js 版本 18+
3. **构建问题**: 安装 Xcode Command Line Tools
4. **图标问题**: 安装 Python3 和 PIL 库

## 📞 获取帮助

- 查看 `README-macOS-Install.md` 详细说明
- 查看 `BUILD-macOS-Solutions.md` 构建问题解决方案
- 查看 `INSTALL-macOS.md` 完整安装指南

---

**🎉 享受在 macOS 上的开发体验！**
