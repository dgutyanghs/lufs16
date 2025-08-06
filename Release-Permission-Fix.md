# 🔧 GitHub Release 权限问题修复

## 问题描述

在 GitHub Actions 中创建 Release 时遇到 403 Forbidden 错误：

```
⚠️ GitHub release failed with status: 403
❌ Too many retries. Aborting...
Error: Too many retries.
```

## 根本原因

1. **权限不足**: GitHub Actions 需要明确的权限才能创建 Release
2. **文件模式匹配失败**: 尝试上传不存在的文件类型（.dmg, .tar.gz, .msi）
3. **GITHUB_TOKEN 权限限制**: 默认 token 权限可能不足

## 解决方案

### ✅ 1. 添加明确的权限配置

在所有工作流文件中添加：

```yaml
permissions:
  contents: write # 允许创建Release和上传文件
  actions: read # 允许读取Actions状态
```

### ✅ 2. 修复文件模式匹配

#### 问题文件类型

- `.dmg` - macOS DMG 文件（当前构建不生成）
- `.tar.gz` - 压缩包（当前构建不生成）
- `.msi` - Windows MSI 安装包（当前构建不生成）

#### 修复后的文件模式

```yaml
# 跨平台构建
files: ./release-files/*

# macOS专用
files: |
  ./artifacts/*.zip
  ./artifacts/macOS-Installation-Guide.md

# Windows专用
files: |
  ./windows-artifacts/*.exe
  ./windows-artifacts/*.zip
  ./windows-artifacts/Windows-Installation-Guide.md
```

### ✅ 3. 智能文件准备

添加了文件准备步骤，只复制实际存在的文件：

```yaml
- name: Prepare release files
  run: |
    mkdir -p ./release-files
    find ./artifacts -name "*.exe" -exec cp {} ./release-files/ \; 2>/dev/null || echo "No .exe files found"
    find ./artifacts -name "*.zip" -exec cp {} ./release-files/ \; 2>/dev/null || echo "No .zip files found"
    # ... 其他文件类型
```

## 当前构建产物

### Windows 构建

- ✅ `*.exe` - NSIS 安装程序
- ✅ `*.zip` - 便携版压缩包
- ❌ `*.msi` - 未配置 MSI 构建

### macOS 构建

- ✅ `*.zip` - 应用程序压缩包
- ❌ `*.dmg` - 未配置 DMG 构建
- ❌ `*.tar.gz` - 未配置 TAR.GZ 构建

## 权限配置详解

### contents: write

- 允许创建和编辑 Release
- 允许上传文件到 Release
- 允许修改仓库内容

### actions: read

- 允许读取 Actions 运行状态
- 允许访问 Artifacts
- 允许下载构建产物

## 验证修复

修复后的 Release 创建应该：

1. ✅ 成功获取必要权限
2. ✅ 只上传实际存在的文件
3. ✅ 创建 Release 成功
4. ✅ 正确显示 Release 内容

## 可选的未来改进

### 添加 DMG 支持（macOS）

```json
"mac": {
  "target": [
    {"target": "zip", "arch": ["x64"]},
    {"target": "dmg", "arch": ["x64"]}
  ]
}
```

### 添加 MSI 支持（Windows）

```json
"win": {
  "target": [
    {"target": "nsis", "arch": ["x64"]},
    {"target": "msi", "arch": ["x64"]}
  ]
}
```

## 相关文件

- `.github/workflows/build-all-platforms.yml` - 跨平台构建
- `.github/workflows/build-macos.yml` - macOS 构建
- `.github/workflows/build-windows.yml` - Windows 构建
- `package.json` - 构建配置

---

**🎉 现在 Release 创建应该可以正常工作了！**
