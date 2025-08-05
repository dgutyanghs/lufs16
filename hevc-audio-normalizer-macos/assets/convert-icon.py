#!/usr/bin/env python3
"""
将SVG图标转换为PNG格式
需要安装: pip install Pillow cairosvg
"""

import os
import sys

def convert_svg_to_png():
    try:
        import cairosvg
        from PIL import Image
        import io
        
        # 读取SVG文件
        svg_path = 'icon.svg'
        png_path = 'icon.png'
        
        if not os.path.exists(svg_path):
            print(f"❌ 未找到SVG文件: {svg_path}")
            return False
        
        # 转换SVG到PNG
        print("🔄 正在转换SVG到PNG...")
        png_data = cairosvg.svg2png(url=svg_path, output_width=512, output_height=512)
        
        # 保存PNG文件
        with open(png_path, 'wb') as f:
            f.write(png_data)
        
        print(f"✅ 图标转换完成: {png_path}")
        return True
        
    except ImportError:
        print("⚠️  缺少依赖库，尝试安装:")
        print("pip install Pillow cairosvg")
        return False
    except Exception as e:
        print(f"❌ 转换失败: {e}")
        return False

def create_simple_png():
    """创建一个简单的PNG图标作为备选方案"""
    try:
        from PIL import Image, ImageDraw, ImageFont
        
        # 创建512x512的图像
        img = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # 绘制圆角矩形背景
        draw.rounded_rectangle([50, 50, 462, 462], radius=50, fill='#4facfe')
        
        # 绘制视频播放图标
        draw.rounded_rectangle([150, 180, 362, 332], radius=8, fill='white')
        draw.polygon([(220, 220), (220, 292), (280, 256)], fill='#4facfe')
        
        # 添加文字
        try:
            # 尝试使用系统字体
            font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', 24)
        except:
            try:
                font = ImageFont.truetype('arial.ttf', 24)
            except:
                font = ImageFont.load_default()
        
        # 绘制HEVC文字
        text = 'HEVC'
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        x = (512 - text_width) // 2
        draw.text((x, 380), text, fill='white', font=font)
        
        # 保存图像
        img.save('icon.png')
        print('✅ 简单PNG图标创建完成: icon.png')
        return True
        
    except ImportError:
        print("⚠️  PIL库不可用，请安装: pip install Pillow")
        return False
    except Exception as e:
        print(f"❌ 创建PNG失败: {e}")
        return False

if __name__ == '__main__':
    print("🎨 创建应用图标...")
    
    # 首先尝试转换SVG
    if not convert_svg_to_png():
        print("🔄 尝试创建简单PNG图标...")
        if not create_simple_png():
            print("❌ 无法创建图标文件")
            print("请手动创建 icon.png 文件 (512x512像素)")
            sys.exit(1)
    
    print("🎉 图标准备完成！")