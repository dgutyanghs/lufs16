@echo off
echo 🍎 使用Git Archive打包项目到macOS...
echo.

REM 检查是否在git仓库中
git status >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 当前目录不是Git仓库
    echo 请确保在Git仓库根目录下运行此脚本
    pause
    exit /b 1
)

REM 确保所有文件都已提交或暂存
echo 📋 检查Git状态...
git status --porcelain > temp_status.txt
if exist temp_status.txt (
    for /f %%i in (temp_status.txt) do (
        echo ⚠️  发现未提交的更改，建议先提交或暂存
        echo 继续打包将只包含已提交的文件
        goto :continue
    )
)
:continue
del temp_status.txt 2>nul

REM 获取当前分支名
for /f "tokens=*" %%i in ('git branch --show-current') do set BRANCH=%%i
echo 📦 当前分支: %BRANCH%

REM 使用git archive创建压缩包
echo 🗜️  创建Git Archive压缩包...
git archive --format=zip --output=hevc-audio-normalizer-for-macos.zip HEAD

if %errorlevel% eq 0 (
    echo ✅ Git Archive创建成功
) else (
    echo ❌ Git Archive创建失败
    pause
    exit /b 1
)

REM 显示文件信息
if exist hevc-audio-normalizer-for-macos.zip (
    for %%A in (hevc-audio-normalizer-for-macos.zip) do (
        set size=%%~zA
        set /a sizeMB=!size!/1024/1024
        echo 📊 压缩包大小: %%~zA bytes ^(!sizeMB! MB^)
    )
) else (
    echo ❌ 压缩包创建失败
    pause
    exit /b 1
)

REM 显示包含的文件列表
echo.
echo 📋 压缩包包含的文件:
git ls-tree -r --name-only HEAD | findstr /v "node_modules" | findstr /v "dist/" | findstr /v ".git"

echo.
echo 🎉 Git Archive打包完成！
echo.
echo 📦 生成的文件:
echo   - hevc-audio-normalizer-for-macos.zip
echo.
echo 🚀 接下来的步骤:
echo   1. 将zip文件复制到macOS系统
echo   2. 解压缩: unzip hevc-audio-normalizer-for-macos.zip
echo   3. 进入目录: cd hevc-audio-normalizer-*
echo   4. 安装依赖: npm install
echo   5. 开发模式: npm run dev
echo   6. 构建应用: npm run build-mac
echo.
echo ✨ 优势:
echo   - 自动遵循.gitignore规则
echo   - 只包含版本控制中的文件
echo   - 文件结构完整
echo   - 体积最小化
echo.
pause