@echo off
echo 🪟 构建Windows版HEVC音频响度调节器
echo =====================================

REM 检查环境
echo 📋 检查构建环境...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js未安装，请先安装Node.js
    pause
    exit /b 1
)

npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm未安装
    pause
    exit /b 1
)

REM 清理旧的构建文件
echo 🧹 清理旧的构建文件...
if exist "dist" (
    rmdir /s /q "dist"
    echo ✅ 已清理dist目录
)

REM 安装依赖
echo 📦 安装/更新依赖...
npm install
if %errorlevel% neq 0 (
    echo ❌ 依赖安装失败
    pause
    exit /b 1
)

REM 检查图标
echo 🎨 检查应用图标...
if not exist "assets" mkdir assets
if not exist "assets\icon.ico" (
    if exist "assets\icon.png" (
        echo ✅ 发现PNG图标，构建时将自动处理
    ) else (
        echo ⚠️  未找到图标文件，将使用默认图标
    )
) else (
    echo ✅ Windows ICO图标已准备就绪
)

REM 开始构建
echo 🔨 开始构建Windows应用...
echo 这可能需要几分钟时间，请耐心等待...
echo.

npm run build-win

if %errorlevel% eq 0 (
    echo.
    echo 🎉 构建成功！
    echo.
    echo 📦 构建产物:
    if exist "dist" (
        dir "dist" /b
        echo.
        echo 📊 文件大小:
        for %%f in (dist\*) do (
            echo   %%~nxf: %%~zf bytes
        )
    )
    echo.
    echo 📁 构建文件位置: %CD%\dist\
    echo.
    echo 🚀 安装说明:
    echo   1. 找到 .exe 安装程序
    echo   2. 右键选择"以管理员身份运行"
    echo   3. 按照向导完成安装
    echo   4. 从开始菜单启动应用
    echo.
    
    REM 询问是否打开构建目录
    set /p OPEN_DIR="是否打开构建目录? (y/n): "
    if /i "%OPEN_DIR%"=="y" (
        explorer "dist"
    )
    
) else (
    echo.
    echo ❌ 构建失败！
    echo.
    echo 🔧 可能的解决方案:
    echo   1. 确保已安装Visual Studio Build Tools
    echo   2. 检查网络连接（需要下载依赖）
    echo   3. 尝试删除node_modules后重新安装
    echo   4. 检查磁盘空间是否充足
    echo.
    echo 💡 获取帮助:
    echo   - 查看上方的错误信息
    echo   - 检查package.json中的构建配置
    echo   - 确认所有依赖都已正确安装
    echo.
)

pause