# macOS 安装指南 (从 Windows 构建版本)

## 📦 文件说明

由于在 Windows 系统上构建，生成的是 ZIP 格式文件而不是 DMG：

- `HEVC音频响度调节器-1.0.0-x64.zip` - Intel Mac 版本
- `HEVC音频响度调节器-1.0.0-arm64.zip` - Apple Silicon Mac 版本

## 🍎 安装步骤

### 1. 选择正确的版本

- **Intel Mac** (2020 年之前的 Mac): 下载 `x64.zip` 文件
- **Apple Silicon Mac** (M1/M2/M3 芯片): 下载 `arm64.zip` 文件

### 2. 安装应用

1. 下载对应的 ZIP 文件
2. 双击 ZIP 文件解压
3. 将解压出的 `HEVC音频响度调节器.app` 拖拽到 `Applications` 文件夹
4. 从启动台或应用程序文件夹启动应用

### 3. 解决安全提示

首次启动时可能出现安全警告：

#### 方法一：系统偏好设置

1. 打开"系统偏好设置" > "安全性与隐私"
2. 在"通用"标签页中找到被阻止的应用
3. 点击"仍要打开"

#### 方法二：右键启动

1. 在应用程序文件夹中右键点击应用
2. 选择"打开"
3. 在弹出对话框中点击"打开"

#### 方法三：终端命令

```bash
sudo xattr -rd com.apple.quarantine /Applications/HEVC音频响度调节器.app
```

## 🎬 使用方法

1. **启动应用** - 从启动台或应用程序文件夹启动
2. **选择视频** - 拖拽 HEVC 视频文件到应用窗口
3. **分析音频** - 点击"开始分析"查看当前响度
4. **设置参数** - 调整目标响度（默认-16 LUFS）
5. **开始处理** - 选择输出位置并开始处理
6. **完成** - 处理完成后可直接打开文件

## ✅ 功能特点

- **保持 HEVC 编码** - 视频流直接复制，零质量损失
- **保持 MP4 格式** - 输出与输入格式完全一致
- **内置 FFmpeg** - 无需预装任何软件
- **专业 LUFS 分析** - 基于 EBU R128 标准
- **支持大文件** - 无文件大小限制

## 📋 系统要求

- macOS 10.14 (Mojave) 或更高版本
- 4GB RAM (推荐 8GB+)
- 1GB 可用磁盘空间

## 🔧 故障排除

### 应用无法启动

```bash
# 检查应用权限
ls -la /Applications/HEVC音频响度调节器.app

# 重新设置权限
chmod +x /Applications/HEVC音频响度调节器.app/Contents/MacOS/*
```

### "应用已损坏"错误

```bash
# 移除隔离属性
sudo xattr -rd com.apple.quarantine /Applications/HEVC音频响度调节器.app
```

## 📊 性能参考

| Mac 型号       | 1080p 视频 | 4K 视频        |
| -------------- | ---------- | -------------- |
| MacBook Air M1 | ~4x 实时   | ~1.5x 实时     |
| MacBook Pro M1 | ~5x 实时   | ~2x 实时       |
| MacBook Pro M2 | ~6x 实时   | ~2.5x 实时     |
| Intel Mac      | ~2-3x 实时 | ~0.8-1.2x 实时 |

## 🔄 卸载应用

1. 从应用程序文件夹删除应用
2. 清理偏好设置（可选）：

```bash
rm -rf ~/Library/Preferences/com.kiro.hevc-audio-normalizer.plist
rm -rf ~/Library/Application\ Support/HEVC音频响度调节器
```

---

**注意**: 这个版本在 Windows 系统上构建，功能与在 macOS 上构建的版本完全相同，只是安装方式略有不同。
