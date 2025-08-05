#!/bin/bash

echo "🍎 HEVC音频响度调节器 - macOS安装脚本"
echo "========================================"

# 检查Node.js
echo "检查Node.js安装..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js未安装"
    echo "请先安装Node.js: https://nodejs.org/"
    echo "推荐使用Homebrew: brew install node"
    exit 1
fi

NODE_VERSION=$(node --version)
echo "✅ Node.js版本: $NODE_VERSION"

# 检查npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm未安装"
    exit 1
fi

NPM_VERSION=$(npm --version)
echo "✅ npm版本: $NPM_VERSION"

# 安装依赖
echo ""
echo "📦 安装项目依赖..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ 依赖安装成功"
else
    echo "❌ 依赖安装失败"
    exit 1
fi

# 检查Python（用于图标生成）
echo ""
echo "🐍 检查Python环境..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "✅ Python版本: $PYTHON_VERSION"
    
    # 尝试安装PIL
    echo "安装PIL图像处理库..."
    pip3 install Pillow 2>/dev/null || echo "⚠️  PIL安装失败，将跳过图标生成"
else
    echo "⚠️  Python3未安装，将跳过图标生成"
fi

# 检查Xcode Command Line Tools
echo ""
echo "🔧 检查开发工具..."
if xcode-select -p &> /dev/null; then
    echo "✅ Xcode Command Line Tools已安装"
else
    echo "⚠️  Xcode Command Line Tools未安装"
    echo "运行以下命令安装: xcode-select --install"
fi

# 创建图标（如果可能）
echo ""
echo "🎨 创建应用图标..."
mkdir -p assets

if [ ! -f "assets/icon.png" ]; then
    if command -v python3 &> /dev/null && python3 -c "import PIL" 2>/dev/null; then
        python3 -c "
from PIL import Image, ImageDraw, ImageFont
import os

# 创建512x512的图标
img = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# 绘制背景圆角矩形
draw.rounded_rectangle([50, 50, 462, 462], radius=50, fill='#4facfe')

# 绘制播放按钮背景
draw.rounded_rectangle([150, 180, 362, 332], radius=8, fill='white')

# 绘制播放三角形
draw.polygon([(220, 220), (220, 292), (280, 256)], fill='#4facfe')

# 添加文字
try:
    font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', 24)
except:
    font = ImageFont.load_default()

text = 'HEVC'
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
x = (512 - text_width) // 2
draw.text((x, 380), text, fill='white', font=font)

# 保存图标
img.save('assets/icon.png')
print('✅ 图标创建成功')
" 2>/dev/null && echo "✅ 图标创建成功" || echo "⚠️  图标创建失败，将使用默认图标"
    else
        echo "⚠️  跳过图标创建（缺少PIL库）"
    fi
else
    echo "✅ 图标已存在"
fi

echo ""
echo "🎉 安装完成！"
echo ""
echo "📋 可用命令:"
echo "  npm run dev          - 开发模式运行"
echo "  npm start            - 正式模式运行"
echo "  npm run build-mac    - 构建macOS应用"
echo "  npm run build        - 构建所有平台"
echo ""
echo "🚀 开始使用:"
echo "  npm run dev"
echo ""