@echo off
echo 正在为macOS系统打包项目...

REM 创建打包目录
if exist "hevc-audio-normalizer-macos" rmdir /s /q "hevc-audio-normalizer-macos"
mkdir "hevc-audio-normalizer-macos"

REM 复制核心文件
echo 复制核心应用文件...
copy "package.json" "hevc-audio-normalizer-macos\"
copy "main.js" "hevc-audio-normalizer-macos\"
copy "preload.js" "hevc-audio-normalizer-macos\"
copy "renderer.js" "hevc-audio-normalizer-macos\"
copy "index.html" "hevc-audio-normalizer-macos\"
copy "styles.css" "hevc-audio-normalizer-macos\"
copy "ffmpeg-processor.js" "hevc-audio-normalizer-macos\"
copy "app.js" "hevc-audio-normalizer-macos\"

REM 复制配置文件
echo 复制配置文件...
copy ".gitignore" "hevc-audio-normalizer-macos\"
copy "README.md" "hevc-audio-normalizer-macos\"

REM 复制GitHub Actions配置
echo 复制GitHub Actions配置...
mkdir "hevc-audio-normalizer-macos\.github"
mkdir "hevc-audio-normalizer-macos\.github\workflows"
copy ".github\workflows\build-macos.yml" "hevc-audio-normalizer-macos\.github\workflows\"

REM 复制资源文件
echo 复制资源文件...
mkdir "hevc-audio-normalizer-macos\assets"
if exist "assets\*" copy "assets\*" "hevc-audio-normalizer-macos\assets\"

REM 复制脚本文件
echo 复制构建脚本...
copy "build-macos.sh" "hevc-audio-normalizer-macos\"
copy "install-and-run.sh" "hevc-audio-normalizer-macos\"
copy "start-server.sh" "hevc-audio-normalizer-macos\"
copy "verify-build.sh" "hevc-audio-normalizer-macos\"

REM 复制文档
echo 复制文档文件...
copy "BUILD-macOS-Solutions.md" "hevc-audio-normalizer-macos\"
copy "INSTALL-macOS.md" "hevc-audio-normalizer-macos\"
copy "README-macOS.md" "hevc-audio-normalizer-macos\"
copy "使用说明.md" "hevc-audio-normalizer-macos\"

REM 创建macOS专用的安装说明
echo 创建macOS安装说明...
(
echo # macOS系统安装说明
echo.
echo ## 快速开始
echo 1. 确保已安装Node.js ^(推荐18+版本^)
echo 2. 在终端中运行: npm install
echo 3. 开发模式运行: npm run dev
echo 4. 构建应用: npm run build-mac
echo.
echo ## 依赖安装
echo ```bash
echo # 安装Node.js依赖
echo npm install
echo.
echo # 如果需要创建图标，安装Python依赖
echo pip3 install Pillow
echo ```
echo.
echo ## 构建说明
echo - 使用 `npm run build-mac` 构建macOS版本
echo - 构建产物在 `dist/` 目录下
echo - 支持Intel和Apple Silicon Mac
echo.
echo ## 注意事项
echo - 确保Xcode Command Line Tools已安装
echo - 首次运行可能需要允许应用权限
echo - 如遇到权限问题，请查看INSTALL-macOS.md
) > "hevc-audio-normalizer-macos\README-macOS-Install.md"

REM 创建package-lock.json的简化版本（避免文件过大）
echo 创建依赖锁定文件...
copy "package-lock.json" "hevc-audio-normalizer-macos\"

REM 创建压缩包
echo 创建压缩包...
powershell -command "Compress-Archive -Path 'hevc-audio-normalizer-macos\*' -DestinationPath 'hevc-audio-normalizer-for-macos.zip' -Force"

echo.
echo ✅ 打包完成！
echo.
echo 📦 生成的文件:
echo - hevc-audio-normalizer-for-macos.zip ^(压缩包^)
echo - hevc-audio-normalizer-macos\ ^(文件夹^)
echo.
echo 🚀 接下来的步骤:
echo 1. 将 hevc-audio-normalizer-for-macos.zip 复制到macOS系统
echo 2. 解压缩文件
echo 3. 在终端中运行: npm install
echo 4. 开始开发或构建应用
echo.
pause