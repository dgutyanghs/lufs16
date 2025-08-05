# 在 Windows 上构建 macOS 版本的解决方案

## ❌ 问题说明

Windows 系统无法直接构建 macOS 的 DMG 文件，因为：

- 缺少 macOS 特有的工具（如`hdiutil`）
- 缺少 Apple 的代码签名工具
- electron-builder 在 Windows 上无法生成 DMG 格式

## ✅ 解决方案

### 方案一：GitHub Actions 自动构建（推荐）

我已经为你创建了 GitHub Actions 配置文件 `.github/workflows/build-macos.yml`

**使用步骤：**

1. 将代码推送到 GitHub 仓库
2. GitHub Actions 会自动在 macOS 环境中构建
3. 从 Actions 页面下载构建好的文件

**优势：**

- ✅ 完全免费
- ✅ 自动构建 DMG 和 ZIP 文件
- ✅ 支持 Intel 和 Apple Silicon
- ✅ 包含代码签名（如果配置）

### 方案二：使用在线构建服务

#### AppVeyor

```yaml
# appveyor.yml
image: macOS
build_script:
  - npm install
  - npm run build-mac
artifacts:
  - path: dist/*.dmg
  - path: dist/*.zip
```

#### CircleCI

```yaml
# .circleci/config.yml
version: 2.1
jobs:
  build-macos:
    macos:
      xcode: 14.0
    steps:
      - checkout
      - run: npm install
      - run: npm run build-mac
```

### 方案三：本地虚拟机

1. **安装 VMware/VirtualBox**
2. **创建 macOS 虚拟机**
3. **在虚拟机中构建**

**注意：** 这可能违反 Apple 的许可协议，仅供学习使用。

### 方案四：租用 macOS 云服务器

#### MacStadium

- 专业的 macOS 云服务
- 按小时计费
- 完整的 macOS 环境

#### AWS EC2 Mac 实例

- Amazon 提供的 macOS 实例
- 适合 CI/CD 集成

### 方案五：找有 Mac 的朋友帮忙构建

1. 将代码发送给有 Mac 的朋友
2. 他们运行 `./build-macos.sh`
3. 发送构建好的文件给你

## 🚀 推荐流程（GitHub Actions）

### 1. 创建 GitHub 仓库

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/yourusername/hevc-audio-normalizer.git
git push -u origin main
```

### 2. 触发构建

推送代码后，GitHub Actions 会自动开始构建：

- 访问你的仓库页面
- 点击"Actions"标签
- 查看构建进度

### 3. 下载构建结果

构建完成后：

- 在 Actions 页面找到成功的构建
- 下载"macos-builds"和"installation-guide"文件
- 解压获得 macOS 应用文件

## 📦 构建输出说明

成功构建后会得到：

- `HEVC音频响度调节器-1.0.0-x64.zip` - Intel Mac 版本
- `HEVC音频响度调节器-1.0.0-arm64.zip` - Apple Silicon 版本
- `HEVC音频响度调节器-1.0.0-x64.dmg` - Intel Mac DMG（如果支持）
- `HEVC音频响度调节器-1.0.0-arm64.dmg` - Apple Silicon DMG（如果支持）
- `macOS-Installation-Guide.md` - 安装指南

## 🎯 当前可用的构建

由于你在 Windows 系统上，我建议：

1. **立即可用：** 先构建 Windows 版本测试功能

   ```bash
   npm run build-win
   ```

2. **获取 macOS 版本：** 使用 GitHub Actions 方案

   - 创建 GitHub 仓库
   - 推送代码
   - 等待自动构建完成

3. **分发给用户：** 提供构建好的文件和安装说明

## 💡 临时解决方案

如果急需 macOS 版本，可以：

1. 使用我提供的混合版本 `index-hybrid.html`
2. 虽然不能保持 HEVC 格式，但功能完整
3. 等待获得真正的 macOS 构建版本后再升级

---

**总结：** GitHub Actions 是最佳选择，免费、自动、专业。创建仓库并推送代码即可获得完整的 macOS 版本！
