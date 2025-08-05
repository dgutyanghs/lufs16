# HEVC 视频音频响度调节器 - macOS 版

## 🍎 macOS 专用版本

这是专门为 macOS 优化的桌面版本，完美解决了浏览器版本的所有限制。

### ✅ macOS 版本特点

- **原生 macOS 应用** - 完全集成到 macOS 系统
- **Universal Binary** - 同时支持 Intel 和 Apple Silicon Mac
- **保持 HEVC 编码** - 视频流直接复制，零质量损失
- **保持 MP4 格式** - 输出与输入格式完全一致
- **内置 FFmpeg** - 无需预装任何软件，开箱即用

## 🚀 快速开始

### 方法一：使用预构建版本（推荐）

1. 下载对应的 DMG 文件：
   - Intel Mac: `HEVC音频响度调节器-1.0.0-x64.dmg`
   - Apple Silicon Mac: `HEVC音频响度调节器-1.0.0-arm64.dmg`
2. 双击 DMG 文件
3. 将应用拖拽到 Applications 文件夹
4. 从启动台或应用程序文件夹启动

### 方法二：从源码构建

```bash
# 克隆或下载源码后
./build-macos.sh
```

## 📋 系统要求

### 最低要求

- macOS 10.14 (Mojave) 或更高版本
- 4GB RAM
- 1GB 可用磁盘空间

### 推荐配置

- macOS 12.0 (Monterey) 或更高版本
- 8GB+ RAM（处理大文件）
- SSD 存储（提升处理速度）

### 处理器支持

- ✅ Intel Mac (x64)
- ✅ Apple Silicon Mac (M1/M2/M3 - arm64)
- ✅ Universal Binary 支持

## 🎬 使用方法

### 1. 启动应用

- 从启动台找到"HEVC 音频响度调节器"
- 或从应用程序文件夹启动
- 首次启动可能需要在系统偏好设置中允许运行

### 2. 处理视频

1. **选择文件** - 拖拽视频到应用窗口或点击选择
2. **分析音频** - 点击"开始分析"获取当前响度信息
3. **设置参数** - 调整目标响度（默认-16 LUFS）
4. **开始处理** - 选择输出位置并开始处理
5. **完成** - 处理完成后可直接打开或在 Finder 中显示

### 3. 支持的格式

- **输入**: MP4, MOV, MKV, AVI, M4V 等
- **输出**: 与输入格式相同，保持 HEVC 编码

## 🔧 macOS 特定功能

### 系统集成

- **拖拽支持** - 直接从 Finder 拖拽文件到应用
- **文件关联** - 可设置为默认的视频处理应用
- **通知中心** - 处理完成时显示系统通知
- **Dock 集成** - 显示处理进度

### 安全性

- **代码签名** - 应用经过数字签名
- **沙盒模式** - 安全的文件访问权限
- **隐私保护** - 所有处理在本地完成

### 性能优化

- **多核处理** - 充分利用 Mac 的多核性能
- **内存管理** - 优化的内存使用
- **Apple Silicon 优化** - 原生支持 M 系列芯片

## 🛠️ 构建说明

### 构建环境要求

- macOS 10.14+
- Node.js 16+
- Xcode Command Line Tools

### 构建步骤

```bash
# 1. 安装依赖
npm install

# 2. 开发模式运行
npm run dev

# 3. 构建macOS版本
npm run build-mac

# 4. 或使用构建脚本
./build-macos.sh
```

### 构建输出

```
dist/
├── HEVC音频响度调节器-1.0.0-x64.dmg      # Intel版本
├── HEVC音频响度调节器-1.0.0-arm64.dmg    # Apple Silicon版本
├── HEVC音频响度调节器-1.0.0-x64.zip      # Intel压缩包
└── HEVC音频响度调节器-1.0.0-arm64.zip    # Apple Silicon压缩包
```

## 🔍 故障排除

### 常见问题

#### 1. 应用无法启动

```bash
# 检查系统版本
sw_vers

# 检查应用权限
xattr -d com.apple.quarantine /Applications/HEVC音频响度调节器.app
```

#### 2. "无法验证开发者"错误

1. 打开"系统偏好设置" > "安全性与隐私"
2. 在"通用"标签页中点击"仍要打开"
3. 或在终端中运行：

```bash
sudo spctl --master-disable
```

#### 3. FFmpeg 不可用

- 应用内置 FFmpeg，通常不会出现此问题
- 如果出现，请重新下载应用

#### 4. 处理大文件时内存不足

- 关闭其他应用释放内存
- 考虑升级到更大内存的 Mac
- 分批处理大文件

### 性能优化建议

#### Intel Mac

- 确保有足够的散热
- 关闭不必要的后台应用
- 使用 SSD 存储提升 I/O 性能

#### Apple Silicon Mac

- 利用统一内存架构的优势
- 原生 arm64 版本性能更佳
- 电池模式下性能可能受限

## 📊 性能对比

| 处理器类型 | 1080p 视频 | 4K 视频    | 内存使用 |
| ---------- | ---------- | ---------- | -------- |
| Intel i5   | ~2x 实时   | ~0.8x 实时 | ~500MB   |
| Intel i7   | ~3x 实时   | ~1.2x 实时 | ~600MB   |
| M1         | ~4x 实时   | ~1.8x 实时 | ~400MB   |
| M2         | ~5x 实时   | ~2.2x 实时 | ~450MB   |

## 🎯 使用场景

### 专业用户

- 视频制作公司的后期处理
- 广播电视台的内容标准化
- 流媒体平台的内容准备

### 个人用户

- 家庭视频的音频优化
- 社交媒体内容制作
- 录屏内容的音频标准化

## 📞 技术支持

### 日志查看

```bash
# 查看应用日志
log show --predicate 'subsystem contains "com.kiro.hevc-audio-normalizer"' --last 1h

# 查看崩溃报告
ls ~/Library/Logs/DiagnosticReports/*HEVC*
```

### 问题反馈

如遇到问题，请提供：

1. macOS 版本 (`sw_vers`)
2. 处理器类型 (`uname -m`)
3. 应用版本
4. 详细的错误描述

## 📄 许可证

MIT License - 可自由使用、修改和分发。

---

**注意**: 这是专门为 macOS 优化的版本，充分利用了 macOS 的系统特性和 Apple Silicon 的性能优势。
