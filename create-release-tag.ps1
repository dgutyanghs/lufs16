Write-Host "🏷️  创建Release标签..." -ForegroundColor Green
Write-Host ""

# 获取当前版本号
try {
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    $currentVersion = $packageJson.version
    Write-Host "📦 当前版本: $currentVersion" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ 无法读取package.json中的版本号" -ForegroundColor Red
    $currentVersion = "1.0.0"
}

Write-Host ""

# 询问是否使用当前版本
$useCurrentVersion = Read-Host "使用当前版本 $currentVersion 创建Release? (y/n)"
if ($useCurrentVersion -eq "n") {
    $version = Read-Host "请输入新版本号 (例如: 1.0.1)"
}
else {
    $version = $currentVersion
}

# 添加v前缀
$tagName = "v$version"

Write-Host ""
Write-Host "🏷️  将创建标签: $tagName" -ForegroundColor Yellow
Write-Host "📝 Release说明:" -ForegroundColor Cyan
Write-Host "   - HEVC音频响度调节器 macOS版本" -ForegroundColor White
Write-Host "   - 支持Intel和Apple Silicon Mac" -ForegroundColor White
Write-Host "   - 保持HEVC编码和MP4格式" -ForegroundColor White
Write-Host "   - 内置FFmpeg，无需额外安装" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "确认创建Release? (y/n)"
if ($confirm -ne "y") {
    Write-Host "❌ 已取消" -ForegroundColor Red
    exit 1
}

# 检查Git状态
Write-Host "🔍 检查Git状态..." -ForegroundColor Yellow
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  发现未提交的更改:" -ForegroundColor Yellow
    $gitStatus | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    $continue = Read-Host "继续创建标签? (y/n)"
    if ($continue -ne "y") {
        Write-Host "❌ 已取消" -ForegroundColor Red
        exit 1
    }
}

# 创建标签
Write-Host "🏷️  创建本地标签..." -ForegroundColor Yellow
git tag -a $tagName -m "Release $tagName`: HEVC音频响度调节器 macOS版本"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 标签创建失败" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 本地标签创建成功" -ForegroundColor Green

# 推送标签
Write-Host "📤 推送标签到GitHub..." -ForegroundColor Yellow
git push origin $tagName

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 标签推送失败" -ForegroundColor Red
    Write-Host "💡 你可以稍后手动推送: git push origin $tagName" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ 标签推送成功" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Release标签创建完成！" -ForegroundColor Green
Write-Host ""
Write-Host "📋 接下来会发生什么:" -ForegroundColor Cyan
Write-Host "  1. GitHub Actions会自动触发构建" -ForegroundColor White
Write-Host "  2. 构建完成后会自动创建Release" -ForegroundColor White
Write-Host "  3. 所有构建文件会自动上传到Release" -ForegroundColor White
Write-Host ""
Write-Host "🔗 查看进度:" -ForegroundColor Cyan
Write-Host "  - Actions: https://github.com/[你的用户名]/[仓库名]/actions" -ForegroundColor White
Write-Host "  - Releases: https://github.com/[你的用户名]/[仓库名]/releases" -ForegroundColor White
Write-Host ""
Write-Host "💡 提示:" -ForegroundColor Cyan
Write-Host "  - 如果是第一次创建Release，可能需要几分钟" -ForegroundColor White
Write-Host "  - 构建完成后Release会自动出现在项目页面" -ForegroundColor White
Write-Host "  - 标签推送会触发正式Release（非预发布）" -ForegroundColor White
Write-Host ""