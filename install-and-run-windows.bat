@echo off
echo 🪟 HEVC音频响度调节器 - Windows安装脚本
echo ==========================================

REM 检查Node.js
echo 检查Node.js安装...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js未安装
    echo 请先安装Node.js: https://nodejs.org/
    echo 推荐下载LTS版本
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo ✅ Node.js版本: %NODE_VERSION%

REM 检查npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm未安装
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo ✅ npm版本: %NPM_VERSION%

REM 安装依赖
echo.
echo 📦 安装项目依赖...
npm install

if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)

echo ✅ 依赖安装成功

REM 检查Python（用于图标生成）
echo.
echo 🐍 检查Python环境...
python --version >nul 2>&1
if %errorlevel% eq 0 (
    for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
    echo ✅ Python版本: %PYTHON_VERSION%
    
    REM 尝试安装PIL
    echo 安装PIL图像处理库...
    pip install Pillow >nul 2>&1
    if %errorlevel% eq 0 (
        echo ✅ PIL安装成功
    ) else (
        echo ⚠️  PIL安装失败，将跳过图标生成
    )
) else (
    echo ⚠️  Python未安装，将跳过图标生成
)

REM 检查Visual Studio Build Tools
echo.
echo 🔧 检查构建工具...
where cl >nul 2>&1
if %errorlevel% eq 0 (
    echo ✅ Visual Studio Build Tools已安装
) else (
    echo ⚠️  Visual Studio Build Tools未检测到
    echo 如果构建失败，请安装Visual Studio Build Tools
    echo 下载地址: https://visualstudio.microsoft.com/visual-cpp-build-tools/
)

REM 创建图标（如果可能）
echo.
echo 🎨 创建应用图标...
if not exist "assets" mkdir assets

if not exist "assets\icon.ico" (
    if exist "assets\icon.png" (
        echo ✅ 发现PNG图标，构建时将自动转换
    ) else (
        echo 创建默认图标...
        REM 这里可以添加图标创建逻辑
        echo ⚠️  未找到图标文件，将使用默认图标
    )
) else (
    echo ✅ ICO图标已存在
)

echo.
echo 🎉 安装完成！
echo.
echo 📋 可用命令:
echo   npm run dev          - 开发模式运行
echo   npm start            - 正式模式运行
echo   npm run build-win    - 构建Windows应用
echo   npm run build        - 构建所有平台
echo.
echo 🚀 开始使用:
echo   npm run dev
echo.

REM 询问是否立即运行
set /p RUN_NOW="是否立即运行应用? (y/n): "
if /i "%RUN_NOW%"=="y" (
    echo 🚀 启动应用...
    npm run dev
)

pause