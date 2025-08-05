Write-Host "正在为macOS系统打包项目..." -ForegroundColor Green

# 创建打包目录
$packageDir = "hevc-audio-normalizer-macos"
if (Test-Path $packageDir) {
    Remove-Item $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir | Out-Null

# 复制核心文件
$coreFiles = @(
    "package.json", "main.js", "preload.js", "renderer.js", 
    "index.html", "styles.css", "ffmpeg-processor.js", "app.js",
    ".gitignore", "README.md", "setup-macos.sh"
)

foreach ($file in $coreFiles) {
    if (Test-Path $file) {
        Copy-Item $file "$packageDir\" -Force
        Write-Host "复制: $file" -ForegroundColor Green
    }
}

# 复制GitHub Actions
New-Item -ItemType Directory -Path "$packageDir\.github\workflows" -Force | Out-Null
if (Test-Path ".github\workflows\build-macos.yml") {
    Copy-Item ".github\workflows\build-macos.yml" "$packageDir\.github\workflows\" -Force
}

# 复制资源文件
if (Test-Path "assets") {
    Copy-Item "assets" "$packageDir\" -Recurse -Force
}

# 复制脚本文件
$scripts = @("build-macos.sh", "install-and-run.sh", "start-server.sh", "verify-build.sh")
foreach ($script in $scripts) {
    if (Test-Path $script) {
        Copy-Item $script "$packageDir\" -Force
    }
}

# 复制文档
$docs = @("BUILD-macOS-Solutions.md", "INSTALL-macOS.md", "README-macOS.md", "使用说明.md")
foreach ($doc in $docs) {
    if (Test-Path $doc) {
        Copy-Item $doc "$packageDir\" -Force
    }
}

# 复制package-lock.json
if (Test-Path "package-lock.json") {
    Copy-Item "package-lock.json" "$packageDir\" -Force
}

# 创建macOS安装说明
$readme = @"
# macOS系统安装说明

## 快速开始
1. 确保已安装Node.js (推荐18+版本)
2. 运行: chmod +x setup-macos.sh
3. 运行: ./setup-macos.sh
4. 或手动: npm install
5. 开发: npm run dev
6. 构建: npm run build-mac

## 依赖要求
- Node.js 18+
- npm
- Xcode Command Line Tools
- Python3 + PIL (可选，用于图标生成)

## 构建说明
- npm run build-mac 构建macOS版本
- 支持Intel和Apple Silicon Mac
- 构建产物在dist/目录

## 注意事项
- 首次运行需要允许应用权限
- 如遇权限问题请查看INSTALL-macOS.md
"@

Set-Content -Path "$packageDir\README-macOS-Install.md" -Value $readme -Encoding UTF8

# 创建压缩包
Write-Host "创建压缩包..." -ForegroundColor Yellow
$zipPath = "hevc-audio-normalizer-for-macos.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path "$packageDir\*" -DestinationPath $zipPath -Force

Write-Host ""
Write-Host "打包完成!" -ForegroundColor Green
Write-Host "生成文件:" -ForegroundColor Cyan
Write-Host "- hevc-audio-normalizer-for-macos.zip" -ForegroundColor White
Write-Host "- hevc-audio-normalizer-macos\" -ForegroundColor White

if (Test-Path $zipPath) {
    $size = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
    Write-Host "压缩包大小: $size MB" -ForegroundColor Magenta
}

Write-Host ""
Write-Host "接下来:" -ForegroundColor Cyan
Write-Host "1. 将zip文件复制到macOS系统" -ForegroundColor White
Write-Host "2. 解压缩" -ForegroundColor White  
Write-Host "3. 运行: chmod +x setup-macos.sh" -ForegroundColor White
Write-Host "4. 运行: ./setup-macos.sh" -ForegroundColor White
Write-Host "5. 开始开发: npm run dev" -ForegroundColor White