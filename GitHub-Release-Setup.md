# 🚀 GitHub Release 自动化设置完成

## 📋 已完成的配置

### ✅ GitHub Actions 工作流更新

- **文件**: `.github/workflows/build-macos.yml`
- **新增功能**: 自动创建 Release 并上传构建文件
- **触发条件**:
  - 推送到 main/master 分支（创建预发布版本）
  - 推送标签 `v*`（创建正式发布版本）
  - 手动触发

### ✅ Release 创建脚本

- **`create-release-tag.bat`** - Windows 批处理脚本
- **`create-release-tag.ps1`** - PowerShell 脚本
- **功能**: 自动创建 Git 标签并推送，触发 Release 构建

## 🎯 工作流程说明

### 自动 Release 流程

1. **构建阶段** (`build-macos` job)

   - 在 macOS 环境中构建应用
   - 生成 ZIP、DMG、TAR.GZ 文件
   - 创建安装指南
   - 上传构建产物为 Artifacts

2. **发布阶段** (`create-release` job)
   - 下载构建产物
   - 自动生成版本号
   - 创建 GitHub Release
   - 上传所有文件到 Release

### 版本号规则

- **标签推送**: 使用标签名作为版本号 (如 `v1.0.0`)
- **分支推送**: 自动生成 `v2025.01.03-abc1234` 格式

## 🚀 如何创建 Release

### 方法 1: 使用脚本（推荐）

```bash
# Windows
.\create-release-tag.bat

# PowerShell
.\create-release-tag.ps1
```

### 方法 2: 手动创建标签

```bash
# 创建标签
git tag -a v1.0.0 -m "Release v1.0.0: HEVC音频响度调节器"

# 推送标签
git push origin v1.0.0
```

### 方法 3: 直接推送代码

```bash
# 推送到主分支会创建预发布版本
git push origin main
```

## 📦 Release 内容

### 自动包含的文件

- **Intel Mac**: `*-x64.zip`
- **Apple Silicon Mac**: `*-arm64.zip`
- **DMG 文件**: `*.dmg` (如果生成)
- **TAR.GZ 文件**: `*.tar.gz` (如果生成)
- **安装指南**: `macOS-Installation-Guide.md`

### Release 描述

自动生成包含以下内容的 Release 说明：

- 核心功能介绍
- 下载文件说明
- 安装步骤
- 系统要求
- 构建信息

## 🔧 配置详情

### 触发条件

```yaml
on:
  push:
    branches: [main, master]
    tags: ["v*"]
  pull_request:
    branches: [main, master]
  workflow_dispatch:
```

### Release 类型

- **正式发布**: 推送 `v*` 标签时
- **预发布**: 推送到主分支时
- **草稿**: 不会创建草稿版本

### 权限要求

- 使用 `GITHUB_TOKEN` 自动权限
- 无需额外配置 secrets

## 📊 Release 示例

### 正式发布 (v1.0.0)

- **标题**: HEVC 音频响度调节器 v1.0.0
- **标签**: v1.0.0
- **类型**: 正式发布
- **触发**: 推送 `v1.0.0` 标签

### 预发布 (开发版本)

- **标题**: HEVC 音频响度调节器 v2025.01.03-abc1234
- **标签**: v2025.01.03-abc1234
- **类型**: 预发布
- **触发**: 推送到 main 分支

## 🎉 使用步骤

### 1. 准备发布

```bash
# 确保代码已提交
git add .
git commit -m "feat: 准备发布新版本"
git push origin main
```

### 2. 创建 Release

```bash
# 使用脚本（推荐）
.\create-release-tag.ps1

# 或手动创建标签
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 3. 等待构建

- 访问 GitHub Actions 页面查看构建进度
- 构建完成后自动创建 Release

### 4. 验证 Release

- 访问项目的 Releases 页面
- 确认文件已正确上传
- 测试下载和安装

## 🔍 故障排除

### 构建失败

- 检查 GitHub Actions 日志
- 确认 `package.json` 中的构建脚本正确
- 验证依赖安装是否成功

### Release 未创建

- 确认推送了标签或主分支
- 检查 `create-release` job 是否执行
- 验证 `GITHUB_TOKEN` 权限

### 文件未上传

- 检查构建产物是否生成
- 确认文件路径匹配 `./artifacts/*` 模式
- 查看上传步骤的日志

## 📞 获取帮助

如果遇到问题：

1. 查看 GitHub Actions 运行日志
2. 检查 Release 页面是否有错误信息
3. 确认仓库权限设置正确

---

**🎉 现在你的项目已经配置了完整的自动化 Release 流程！**
