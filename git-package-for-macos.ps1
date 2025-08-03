Write-Host "🍎 使用Git Archive打包项目到macOS..." -ForegroundColor Green
Write-Host ""

# 检查是否在git仓库中
try {
    $gitStatus = git status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 错误: 当前目录不是Git仓库" -ForegroundColor Red
        Write-Host "请确保在Git仓库根目录下运行此脚本" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "❌ 错误: Git未安装或不可用" -ForegroundColor Red
    exit 1
}

# 检查Git状态
Write-Host "📋 检查Git状态..." -ForegroundColor Yellow
$statusOutput = git status --porcelain
if ($statusOutput) {
    Write-Host "⚠️  发现未提交的更改:" -ForegroundColor Yellow
    $statusOutput | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    Write-Host "继续打包将只包含已提交的文件" -ForegroundColor Yellow
    Write-Host ""
}

# 获取当前分支
$currentBranch = git branch --show-current
Write-Host "📦 当前分支: $currentBranch" -ForegroundColor Cyan

# 使用git archive创建压缩包
Write-Host "🗜️  创建Git Archive压缩包..." -ForegroundColor Yellow
$zipFile = "hevc-audio-normalizer-for-macos.zip"

# 删除已存在的压缩包
if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

# 创建git archive
git archive --format=zip --output=$zipFile HEAD

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Git Archive创建成功" -ForegroundColor Green
}
else {
    Write-Host "❌ Git Archive创建失败" -ForegroundColor Red
    exit 1
}

# 显示文件信息
if (Test-Path $zipFile) {
    $fileInfo = Get-Item $zipFile
    $sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    Write-Host "📊 压缩包大小: $($fileInfo.Length) bytes ($sizeMB MB)" -ForegroundColor Magenta
}
else {
    Write-Host "❌ 压缩包创建失败" -ForegroundColor Red
    exit 1
}

# 显示包含的文件列表
Write-Host ""
Write-Host "📋 压缩包包含的主要文件:" -ForegroundColor Cyan
$files = git ls-tree -r --name-only HEAD | Where-Object { 
    $_ -notmatch "node_modules" -and 
    $_ -notmatch "dist/" -and 
    $_ -notmatch "\.git" -and
    $_ -notmatch "hevc-audio-normalizer-macos"
}

$coreFiles = $files | Where-Object { 
    $_ -match "\.(js|html|css|json|md|sh|yml|py|txt|svg|png)$" -or
    $_ -eq ".gitignore"
} | Sort-Object

$coreFiles | ForEach-Object { 
    Write-Host "   $_" -ForegroundColor White 
}

Write-Host ""
Write-Host "🎉 Git Archive打包完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📦 生成的文件:" -ForegroundColor Cyan
Write-Host "   - $zipFile" -ForegroundColor White
Write-Host ""
Write-Host "🚀 接下来的步骤:" -ForegroundColor Cyan
Write-Host "   1. 将zip文件复制到macOS系统" -ForegroundColor White
Write-Host "   2. 解压缩: unzip $zipFile" -ForegroundColor White
Write-Host "   3. 进入目录: cd hevc-audio-normalizer-*" -ForegroundColor White
Write-Host "   4. 安装依赖: npm install" -ForegroundColor White
Write-Host "   5. 开发模式: npm run dev" -ForegroundColor White
Write-Host "   6. 构建应用: npm run build-mac" -ForegroundColor White
Write-Host ""
Write-Host "✨ Git Archive的优势:" -ForegroundColor Cyan
Write-Host "   - 自动遵循.gitignore规则" -ForegroundColor White
Write-Host "   - 只包含版本控制中的文件" -ForegroundColor White
Write-Host "   - 文件结构完整" -ForegroundColor White
Write-Host "   - 体积最小化" -ForegroundColor White
Write-Host "   - 不包含.git目录" -ForegroundColor White
Write-Host ""