#!/bin/bash

# 创建简单的PNG图标文件
# 这个脚本会创建一个基本的图标，实际使用时建议替换为专业设计的图标

echo "创建应用图标..."

# 检查是否有ImageMagick或其他图像处理工具
if command -v convert &> /dev/null; then
    # 使用ImageMagick创建图标
    convert -size 512x512 xc:transparent \
        -fill "#4facfe" \
        -draw "roundrectangle 50,50 462,462 50,50" \
        -fill white \
        -pointsize 200 \
        -gravity center \
        -annotate +0+0 "🎬" \
        icon.png
    echo "✅ 图标创建完成: icon.png"
elif command -v sips &> /dev/null; then
    # macOS系统自带的sips工具
    echo "使用系统默认方法创建图标..."
    # 创建一个简单的彩色方块作为临时图标
    python3 -c "
from PIL import Image, ImageDraw, ImageFont
import os

# 创建512x512的图像
img = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# 绘制圆角矩形背景
draw.rounded_rectangle([50, 50, 462, 462], radius=50, fill='#4facfe')

# 添加文字
try:
    font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', 200)
except:
    font = ImageFont.load_default()

# 绘制emoji或文字
text = '🎬'
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
x = (512 - text_width) // 2
y = (512 - text_height) // 2
draw.text((x, y), text, fill='white', font=font)

img.save('icon.png')
print('✅ 图标创建完成: icon.png')
" 2>/dev/null || echo "⚠️  请手动创建 icon.png 文件"
else
    echo "⚠️  未找到图像处理工具，请手动创建 icon.png 文件"
    echo "建议尺寸: 512x512 像素"
fi