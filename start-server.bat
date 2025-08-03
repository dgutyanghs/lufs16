@echo off
echo 启动视频音频响度调节器服务器...
echo.
echo 正在检查Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到Node.js
    echo 请先安装Node.js: https://nodejs.org/
    pause
    exit /b 1
)

echo Node.js已安装
echo 启动服务器...
echo.
echo 服务器将在 http://localhost:8080 运行
echo 按 Ctrl+C 停止服务器
echo.

node server-headers.js
pause