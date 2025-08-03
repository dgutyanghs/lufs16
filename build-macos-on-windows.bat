@echo off
echo ========================================
echo HEVC视频音频响度调节器 - Windows上构建macOS版本
echo ========================================
echo.

echo [1/6] 检查Node.js环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到Node.js
    echo 请先安装Node.js: https://nodejs.org/
    pause
    exit /b 1
)
echo ✅ Node.js已安装

echo.
echo [2/6] 检查npm环境...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: npm不可用
    pause
    exit /b 1
)
echo ✅ npm可用

echo.
echo [3/6] 清理之前的构建...
if exist dist rmdir /s /q dist
if exist node_modules\.cache rmdir /s /q node_modules\.cache
echo ✅ 清理完成

echo.
echo [4/6] 安装项目依赖...
echo 这可能需要几分钟时间，请耐心等待...
npm install
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    echo 请检查网络连接
    pause
    exit /b 1
)
echo ✅ 依赖安装完成

echo.
echo [5/6] 准备构建资源...
if not exist assets mkdir assets
if not exist assets\icon.png (
    echo ⚠️  警告: 未找到图标文件 assets\icon.png
    echo 将使用默认图标
)

echo.
echo [6/6] 构建macOS应用...
echo 正在构建Intel ^(x64^) 和 Apple Silicon ^(arm64^) 版本...
echo 注意: 在Windows上无法生成DMG文件，将生成ZIP和TAR.GZ格式
echo 这可能需要10-15分钟，请耐心等待...
echo.

npm run build-mac

if %errorlevel% equ 0 (
    echo.
    echo 🎉 构建成功！
    echo.
    echo 构建文件位置:
    echo 📁 dist\
    dir dist\ /b
    echo.
    echo 📦 macOS用户安装说明:
    echo 1. 下载对应的ZIP文件:
    echo    - Intel Mac: HEVC音频响度调节器-1.0.0-x64.zip
    echo    - Apple Silicon Mac: HEVC音频响度调节器-1.0.0-arm64.zip
    echo.
    echo 2. 解压ZIP文件
    echo 3. 将 .app 文件拖拽到 Applications 文件夹
    echo 4. 从启动台或应用程序文件夹启动
    echo.
    echo 💡 提示: 首次启动可能需要在系统偏好设置中允许运行
    echo.
) else (
    echo ❌ 构建失败
    echo 请检查错误信息并重试
    pause
    exit /b 1
)

pause