@echo off
echo ========================================
echo HEVC视频音频响度调节器 - 桌面版安装脚本
echo ========================================
echo.

:: 检查Node.js
echo [1/4] 检查Node.js环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到Node.js
    echo 请先安装Node.js: https://nodejs.org/
    echo.
    pause
    exit /b 1
)
echo ✅ Node.js已安装

:: 检查npm
echo.
echo [2/4] 检查npm环境...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: npm不可用
    pause
    exit /b 1
)
echo ✅ npm可用

:: 安装依赖
echo.
echo [3/4] 安装项目依赖...
echo 这可能需要几分钟时间，请耐心等待...
npm install
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    echo 请检查网络连接或尝试使用国内镜像:
    echo npm config set registry https://registry.npmmirror.com
    pause
    exit /b 1
)
echo ✅ 依赖安装完成

:: 启动应用
echo.
echo [4/4] 启动应用...
echo 正在启动HEVC视频音频响度调节器...
echo.
npm start

echo.
echo 应用已关闭
pause