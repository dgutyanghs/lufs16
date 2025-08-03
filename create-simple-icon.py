#!/usr/bin/env python3
"""
创建简单的应用图标
"""

def create_icon():
    try:
        from PIL import Image, ImageDraw, ImageFont
        import os
        
        # 创建512x512的图像
        img = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
        draw = ImageDraw.Draw(img)
        
        # 绘制圆角矩形背景
        draw.rounded_rectangle([50, 50, 462, 462], radius=50, fill='#4facfe')
        
        # 绘制视频播放图标
        draw.rounded_rectangle([150, 180, 362, 332], radius=8, fill='white')
        draw.polygon([(220, 220), (220, 292), (280, 256)], fill='#4facfe')
        
        # 添加HEVC文字
        try:
            # 尝试使用系统字体
            font = ImageFont.truetype('C:/Windows/Fonts/arial.ttf', 24)
        except:
            try:
                font = ImageFont.truetype('arial.ttf', 24)
            except:
                font = ImageFont.load_default()
        
        text = 'HEVC'
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        x = (512 - text_width) // 2
        draw.text((x, 380), text, fill='white', font=font)
        
        # 确保assets目录存在
        if not os.path.exists('assets'):
            os.makedirs('assets')
        
        # 保存图像
        img.save('assets/icon.png')
        print('✅ 图标创建完成: assets/icon.png')
        return True
        
    except ImportError:
        print('⚠️  PIL库不可用')
        print('请安装: pip install Pillow')
        return False
    except Exception as e:
        print(f'❌ 创建图标失败: {e}')
        return False

if __name__ == '__main__':
    print('🎨 创建应用图标...')
    if create_icon():
        print('🎉 图标准备完成！')
    else:
        print('❌ 图标创建失败，构建时将使用默认图标')