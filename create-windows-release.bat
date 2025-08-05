@echo off
echo 🪟 创建Windows版本Release标签
echo ===============================

REM 获取当前版本号
for /f "tokens=2 delims=:" %%i in ('findstr "version" package.json') do (
    set VERSION_LINE=%%i
)
REM 清理版本号（去除引号和逗号）
set VERSION=%VERSION_LINE:"=%
set VERSION=%VERSION:,=%
set VERSION=%VERSION: =%

echo 📦 当前版本: %VERSION%
echo.

REM 询问是否使用当前版本
set /p USE_CURRENT="使用当前版本 %VERSION% 创建Windows Release? (y/n): "
if /i "%USE_CURRENT%"=="n" (
    set /p VERSION="请输入新版本号 (例如: 1.0.1): "
)

REM 添加v前缀和windows后缀
set TAG_NAME=v%VERSION%-windows

echo.
echo 🏷️  将创建Windows专用标签: %TAG_NAME%
echo 📝 Release说明:
echo    - HEVC音频响度调节器 Windows版本
echo    - 支持Windows 10/11 (64位)
echo    - 保持HEVC编码和MP4格式
echo    - 内置FFmpeg，无需额外安装
echo    - 原生Windows集成和硬件加速
echo.

set /p CONFIRM="确认创建Windows Release? (y/n): "
if /i "%CONFIRM%" neq "y" (
    echo ❌ 已取消
    pause
    exit /b 1
)

REM 检查Git状态
git status --porcelain > temp_status.txt
for /f %%i in (temp_status.txt) do (
    echo ⚠️  发现未提交的更改，建议先提交
    set /p CONTINUE="继续创建标签? (y/n): "
    if /i "!CONTINUE!" neq "y" (
        echo ❌ 已取消
        del temp_status.txt
        pause
        exit /b 1
    )
    goto :continue
)
:continue
del temp_status.txt 2>nul

REM 创建标签
echo 🏷️  创建本地Windows标签...
git tag -a %TAG_NAME% -m "Release %TAG_NAME%: HEVC音频响度调节器 Windows版本"

if %errorlevel% neq 0 (
    echo ❌ 标签创建失败
    pause
    exit /b 1
)

echo ✅ 本地标签创建成功

REM 推送标签
echo 📤 推送Windows标签到GitHub...
git push origin %TAG_NAME%

if %errorlevel% neq 0 (
    echo ❌ 标签推送失败
    echo 💡 你可以稍后手动推送: git push origin %TAG_NAME%
    pause
    exit /b 1
)

echo ✅ Windows标签推送成功

echo.
echo 🎉 Windows Release标签创建完成！
echo.
echo 📋 接下来会发生什么:
echo   1. GitHub Actions会自动触发Windows构建
echo   2. 构建完成后会自动创建Windows专用Release
echo   3. Windows安装程序和便携版会自动上传
echo.
echo 🔗 查看进度:
echo   - Actions: https://github.com/%USERNAME%/%REPO%/actions
echo   - Releases: https://github.com/%USERNAME%/%REPO%/releases
echo.
echo 💡 Windows版本特性:
echo   - .exe安装程序（推荐）
echo   - .zip便携版本
echo   - Windows 10/11原生支持
echo   - 硬件加速支持
echo   - 开始菜单和桌面快捷方式
echo.
pause