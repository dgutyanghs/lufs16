#!/bin/bash

echo "========================================"
echo "HEVC视频音频响度调节器 - macOS构建脚本"
echo "========================================"
echo

# 检查Node.js
echo "[1/6] 检查Node.js环境..."
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到Node.js"
    echo "请先安装Node.js: https://nodejs.org/"
    exit 1
fi
echo "✅ Node.js已安装: $(node --version)"

# 检查npm
echo
echo "[2/6] 检查npm环境..."
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: npm不可用"
    exit 1
fi
echo "✅ npm可用: $(npm --version)"

# 清理之前的构建
echo
echo "[3/6] 清理之前的构建..."
rm -rf dist/
rm -rf node_modules/.cache/
echo "✅ 清理完成"

# 安装依赖
echo
echo "[4/6] 安装项目依赖..."
echo "这可能需要几分钟时间，请耐心等待..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    echo "请检查网络连接"
    exit 1
fi
echo "✅ 依赖安装完成"

# 创建图标文件
echo
echo "[5/6] 准备构建资源..."
mkdir -p assets
cd assets

if [ ! -f "icon.png" ]; then
    echo "🎨 创建应用图标..."
    
    # 尝试使用Python创建图标
    if command -v python3 &> /dev/null; then
        python3 convert-icon.py
    else
        echo "⚠️  未找到Python3，跳过图标创建"
    fi
    
    # 如果仍然没有图标，创建一个简单的占位符
    if [ ! -f "icon.png" ]; then
        echo "📝 创建占位符图标..."
        # 创建一个简单的彩色方块作为临时图标
        if command -v convert &> /dev/null; then
            convert -size 512x512 xc:"#4facfe" \
                -fill white -pointsize 100 -gravity center \
                -annotate +0+0 "HEVC" icon.png
            echo "✅ 使用ImageMagick创建了基本图标"
        else
            echo "⚠️  无法创建图标，将使用默认图标"
        fi
    fi
else
    echo "✅ 找到现有图标文件"
fi

cd ..

# 构建macOS版本
echo
echo "[6/6] 构建macOS应用..."
echo "正在构建Intel (x64) 和 Apple Silicon (arm64) 版本..."
echo "这可能需要10-15分钟，请耐心等待..."
echo

npm run build-mac

if [ $? -eq 0 ]; then
    echo
    echo "🎉 构建成功！"
    echo
    echo "构建文件位置:"
    echo "📁 dist/"
    ls -la dist/
    echo
    echo "安装说明:"
    echo "1. Intel Mac: 使用 HEVC音频响度调节器-1.0.0-x64.dmg"
    echo "2. Apple Silicon Mac: 使用 HEVC音频响度调节器-1.0.0-arm64.dmg"
    echo "3. 通用版本: 使用 HEVC音频响度调节器-1.0.0-universal.dmg (如果生成)"
    echo
    echo "使用方法:"
    echo "1. 双击 .dmg 文件"
    echo "2. 将应用拖拽到 Applications 文件夹"
    echo "3. 从启动台或应用程序文件夹启动"
    echo
else
    echo "❌ 构建失败"
    echo "请检查错误信息并重试"
    exit 1
fi