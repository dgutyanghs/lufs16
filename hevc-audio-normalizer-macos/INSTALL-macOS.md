# macOS 安装指南

## 🍎 系统要求

- macOS 10.14 (Mojave) 或更高版本
- 4GB RAM (推荐 8GB+)
- 1GB 可用磁盘空间
- Intel Mac 或 Apple Silicon Mac

## 📦 安装方法

### 方法一：使用预构建的 DMG 文件（推荐）

1. **下载对应版本**：

   - Intel Mac: `HEVC音频响度调节器-1.0.0-x64.dmg`
   - Apple Silicon Mac: `HEVC音频响度调节器-1.0.0-arm64.dmg`

2. **安装步骤**：

   ```
   1. 双击下载的 .dmg 文件
   2. 在打开的窗口中，将应用图标拖拽到 Applications 文件夹
   3. 等待复制完成
   4. 弹出DMG文件（右键点击桌面上的DMG图标 > 推出）
   ```

3. **首次启动**：
   ```
   1. 从启动台或应用程序文件夹找到"HEVC音频响度调节器"
   2. 双击启动
   3. 如果出现安全提示，请参考下面的"安全设置"部分
   ```

### 方法二：从源码构建

1. **准备环境**：

   ```bash
   # 确保已安装 Node.js
   node --version  # 应该显示 v16+ 版本

   # 确保已安装 Xcode Command Line Tools
   xcode-select --install
   ```

2. **构建应用**：

   ```bash
   # 进入项目目录
   cd hevc-audio-normalizer

   # 运行构建脚本
   ./build-macos.sh
   ```

3. **安装构建的应用**：

   ```bash
   # 构建完成后，在 dist/ 目录找到 DMG 文件
   open dist/

   # 双击 DMG 文件进行安装
   ```

## 🔒 安全设置

### 解决"无法验证开发者"问题

如果启动时出现安全警告：

#### 方法一：通过系统偏好设置

1. 打开"系统偏好设置" > "安全性与隐私"
2. 在"通用"标签页中，找到被阻止的应用
3. 点击"仍要打开"按钮

#### 方法二：通过终端命令

```bash
# 移除隔离属性
sudo xattr -rd com.apple.quarantine /Applications/HEVC音频响度调节器.app

# 或者临时禁用Gatekeeper（不推荐）
sudo spctl --master-disable
```

#### 方法三：右键启动

1. 在应用程序文件夹中找到应用
2. 右键点击应用图标
3. 选择"打开"
4. 在弹出的对话框中点击"打开"

## 🚀 使用指南

### 基本使用流程

1. **启动应用**

   - 从启动台或应用程序文件夹启动

2. **选择视频文件**

   - 拖拽视频文件到应用窗口
   - 或点击"选择文件"按钮

3. **分析音频**

   - 点击"开始分析"按钮
   - 等待分析完成，查看当前响度信息

4. **设置参数**

   - 目标响度：-16 LUFS（广播标准）
   - 峰值限制：-1.5 dBTP
   - 响度范围：11 LU

5. **开始处理**
   - 点击"开始处理"按钮
   - 选择输出文件位置
   - 等待处理完成

### 支持的文件格式

- **输入格式**：MP4, MOV, MKV, AVI, M4V
- **输出格式**：与输入格式相同
- **视频编码**：保持原始编码（包括 HEVC/H.265）
- **音频编码**：重新编码为 AAC 192kbps

## 🔧 故障排除

### 常见问题及解决方案

#### 1. 应用无法启动

**症状**：双击应用图标没有反应

**解决方案**：

```bash
# 检查应用权限
ls -la /Applications/HEVC音频响度调节器.app

# 重新设置权限
chmod +x /Applications/HEVC音频响度调节器.app/Contents/MacOS/*
```

#### 2. "应用已损坏"错误

**症状**：提示应用已损坏，无法打开

**解决方案**：

```bash
# 移除隔离属性
sudo xattr -rd com.apple.quarantine /Applications/HEVC音频响度调节器.app

# 重新验证应用
codesign --verify --deep --strict /Applications/HEVC音频响度调节器.app
```

#### 3. FFmpeg 不可用

**症状**：应用显示"FFmpeg: 不可用"

**解决方案**：

- 重新下载并安装应用
- 确保应用完整性
- 检查系统权限设置

#### 4. 处理大文件时崩溃

**症状**：处理大视频文件时应用崩溃

**解决方案**：

- 关闭其他占用内存的应用
- 重启 Mac 释放内存
- 考虑分段处理大文件

#### 5. 处理速度很慢

**症状**：视频处理速度异常缓慢

**解决方案**：

- 确保 Mac 有足够的散热
- 连接电源适配器（笔记本电脑）
- 关闭不必要的后台应用
- 检查存储空间是否充足

## 📊 性能参考

### 不同 Mac 型号的处理性能

| Mac 型号       | 1080p 视频 | 4K 视频    | 内存使用 |
| -------------- | ---------- | ---------- | -------- |
| MacBook Air M1 | ~4x 实时   | ~1.5x 实时 | ~400MB   |
| MacBook Pro M1 | ~5x 实时   | ~2x 实时   | ~450MB   |
| MacBook Pro M2 | ~6x 实时   | ~2.5x 实时 | ~500MB   |
| iMac Intel i5  | ~2x 实时   | ~0.8x 实时 | ~600MB   |
| Mac Pro Intel  | ~3x 实时   | ~1.2x 实时 | ~700MB   |

_注：实际性能可能因视频编码、系统负载等因素而异_

## 🔄 更新和卸载

### 更新应用

1. 下载新版本的 DMG 文件
2. 按照安装步骤覆盖安装
3. 重启应用

### 卸载应用

1. 从应用程序文件夹删除应用
2. 清理偏好设置文件（可选）：
   ```bash
   rm -rf ~/Library/Preferences/com.kiro.hevc-audio-normalizer.plist
   rm -rf ~/Library/Application\ Support/HEVC音频响度调节器
   ```

## 📞 技术支持

### 获取帮助

- 查看应用内的"关于"页面获取版本信息
- 检查系统日志：
  ```bash
  log show --predicate 'subsystem contains "com.kiro.hevc-audio-normalizer"' --last 1h
  ```

### 报告问题

如需报告问题，请提供：

1. macOS 版本：`sw_vers`
2. 处理器类型：`uname -m`
3. 应用版本
4. 详细的错误描述和重现步骤

---

**享受专业级的视频音频处理体验！** 🎬
