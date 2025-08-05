Write-Host "🍎 正在为macOS系统打包项目..." -ForegroundColor Green

# 创建打包目录
$packageDir = "hevc-audio-normalizer-macos"
if (Test-Path $packageDir) {
    Remove-Item $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir | Out-Null

Write-Host "📁 复制核心应用文件..." -ForegroundColor Yellow

# 核心文件列表
$coreFiles = @(
    "package.json",
    "main.js", 
    "preload.js",
    "renderer.js",
    "index.html",
    "styles.css",
    "ffmpeg-processor.js",
    "app.js",
    ".gitignore",
    "README.md"
)

foreach ($file in $coreFiles) {
    if (Test-Path $file) {
        Copy-Item $file "$packageDir\" -Force
        Write-Host "  ✅ $file" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  $file (不存在)" -ForegroundColor Yellow
    }
}

Write-Host "📁 复制GitHub Actions配置..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "$packageDir\.github\workflows" -Force | Out-Null
if (Test-Path ".github\workflows\build-macos.yml") {
    Copy-Item ".github\workflows\build-macos.yml" "$packageDir\.github\workflows\" -Force
    Write-Host "  ✅ GitHub Actions配置" -ForegroundColor Green
}

Write-Host "📁 复制资源文件..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "$packageDir\assets" -Force | Out-Null
if (Test-Path "assets") {
    Copy-Item "assets\*" "$packageDir\assets\" -Force -Recurse
    Write-Host "  ✅ 资源文件" -ForegroundColor Green
}

Write-Host "📁 复制脚本文件..." -ForegroundColor Yellow
$scriptFiles = @(
    "build-macos.sh",
    "install-and-run.sh", 
    "start-server.sh",
    "verify-build.sh",
    "setup-macos.sh"
)

foreach ($file in $scriptFiles) {
    if (Test-Path $file) {
        Copy-Item $file "$packageDir\" -Force
        Write-Host "  ✅ $file" -ForegroundColor Green
    }
}

Write-Host "📁 复制文档文件..." -ForegroundColor Yellow
$docFiles = @(
    "BUILD-macOS-Solutions.md",
    "INSTALL-macOS.md", 
    "README-macOS.md",
    "使用说明.md"
)

foreach ($file in $docFiles) {
    if (Test-Path $file) {
        Copy-Item $file "$packageDir\" -Force
        Write-Host "  ✅ $file" -ForegroundColor Green
    }
}

Write-Host "📝 创建macOS安装说明..." -ForegroundColor Yellow
$macosReadme = @"
# macOS系统安装说明

## 快速开始
1. 确保已安装Node.js (推荐18+版本)
2. 运行安装脚本: `chmod +x setup-macos.sh && ./setup-macos.sh`
3. 或手动安装: `npm install`
4. 开发模式运行: `npm run dev`
5. 构建应用: `npm run build-mac`

## 依赖安装
```bash
# 安装Node.js依赖
npm install

# 如果需要创建图标，安装Python依赖
pip3 install Pillow
```

## 构建说明
- 使用 `npm run build-mac` 构建macOS版本
- 构建产物在 `dist/` 目录下
- 支持Intel和Apple Silicon Mac

## 注意事项
- 确保Xcode Command Line Tools已安装
- 首次运行可能需要允许应用权限
- 如遇到权限问题，请查看INSTALL-macOS.md

## 快速命令
```bash
# 一键安装和运行
chmod +x setup-macos.sh && ./setup-macos.sh

# 开发模式
npm run dev

# 构建应用
npm run build-mac
```
"@

Set-Content -Path "$packageDir\README-macOS-Install.md" -Value $macosReadme -Encoding UTF8

Write-Host "📦 复制依赖锁定文件..." -ForegroundColor Yellow
if (Test-Path "package-lock.json") {
    Copy-Item "package-lock.json" "$packageDir\" -Force
    Write-Host "  ✅ package-lock.json" -ForegroundColor Green
}

Write-Host "🗜️  创建压缩包..." -ForegroundColor Yellow
$zipPath = "hevc-audio-normalizer-for-macos.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

try {
    Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath -Force
    Write-Host "  ✅ 压缩包创建成功" -ForegroundColor Green
}
catch {
    Write-Host "  ❌ 压缩包创建失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 打包完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📦 生成的文件:" -ForegroundColor Cyan
Write-Host "  - hevc-audio-normalizer-for-macos.zip (压缩包)" -ForegroundColor White
Write-Host "  - hevc-audio-normalizer-macos\ (文件夹)" -ForegroundColor White
Write-Host ""
Write-Host "🚀 接下来的步骤:" -ForegroundColor Cyan
Write-Host "  1. 将 hevc-audio-normalizer-for-macos.zip 复制到macOS系统" -ForegroundColor White
Write-Host "  2. 解压缩文件" -ForegroundColor White
Write-Host "  3. 在终端中运行: chmod +x setup-macos.sh; ./setup-macos.sh" -ForegroundColor White
Write-Host "  4. 或手动运行: npm install" -ForegroundColor White
Write-Host "  5. 开始开发: npm run dev" -ForegroundColor White
Write-Host ""

# 显示文件大小
if (Test-Path $zipPath) {
    $zipSize = (Get-Item $zipPath).Length
    $zipSizeMB = [math]::Round($zipSize / 1MB, 2)
    Write-Host "📊 压缩包大小: $zipSizeMB MB" -ForegroundColor Magenta
}

Write-Host "按任意键继续..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")