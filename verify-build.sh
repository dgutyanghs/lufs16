#!/bin/bash

echo "========================================"
echo "HEVC视频音频响度调节器 - 构建验证脚本"
echo "========================================"
echo

# 检查构建输出
echo "[1/4] 检查构建输出..."
if [ ! -d "dist" ]; then
    echo "❌ 未找到构建输出目录 dist/"
    echo "请先运行构建脚本: ./build-macos.sh"
    exit 1
fi

echo "📁 构建输出目录内容:"
ls -la dist/
echo

# 检查DMG文件
echo "[2/4] 验证DMG文件..."
dmg_files=(dist/*.dmg)
if [ ${#dmg_files[@]} -eq 0 ] || [ ! -f "${dmg_files[0]}" ]; then
    echo "❌ 未找到DMG文件"
    exit 1
fi

for dmg in "${dmg_files[@]}"; do
    if [ -f "$dmg" ]; then
        echo "✅ 找到DMG文件: $(basename "$dmg")"
        
        # 检查DMG文件大小
        size=$(du -h "$dmg" | cut -f1)
        echo "   文件大小: $size"
        
        # 验证DMG文件完整性
        if hdiutil verify "$dmg" >/dev/null 2>&1; then
            echo "   ✅ DMG文件完整性验证通过"
        else
            echo "   ⚠️  DMG文件完整性验证失败"
        fi
    fi
done
echo

# 检查应用结构
echo "[3/4] 验证应用结构..."
# 挂载第一个DMG文件进行检查
first_dmg="${dmg_files[0]}"
mount_point="/tmp/hevc_verify_$$"
mkdir -p "$mount_point"

if hdiutil attach "$first_dmg" -mountpoint "$mount_point" -quiet; then
    app_path="$mount_point/HEVC音频响度调节器.app"
    
    if [ -d "$app_path" ]; then
        echo "✅ 应用包结构正确"
        
        # 检查关键文件
        if [ -f "$app_path/Contents/MacOS/HEVC音频响度调节器" ]; then
            echo "   ✅ 主执行文件存在"
        else
            echo "   ❌ 主执行文件缺失"
        fi
        
        if [ -f "$app_path/Contents/Info.plist" ]; then
            echo "   ✅ Info.plist存在"
            
            # 检查版本信息
            version=$(plutil -extract CFBundleShortVersionString raw "$app_path/Contents/Info.plist" 2>/dev/null)
            if [ -n "$version" ]; then
                echo "   📋 应用版本: $version"
            fi
        else
            echo "   ❌ Info.plist缺失"
        fi
        
        # 检查FFmpeg资源
        if [ -d "$app_path/Contents/Resources/ffmpeg-static" ]; then
            echo "   ✅ FFmpeg资源已包含"
        else
            echo "   ⚠️  FFmpeg资源可能缺失"
        fi
        
    else
        echo "❌ 应用包结构不正确"
    fi
    
    # 卸载DMG
    hdiutil detach "$mount_point" -quiet
else
    echo "❌ 无法挂载DMG文件进行验证"
fi

rm -rf "$mount_point"
echo

# 生成安装说明
echo "[4/4] 生成安装说明..."
cat > "dist/安装说明.txt" << EOF
HEVC视频音频响度调节器 - macOS版安装说明

📦 文件说明:
$(for dmg in "${dmg_files[@]}"; do
    if [ -f "$dmg" ]; then
        basename "$dmg" | sed 's/^/- /'
        if [[ "$dmg" == *"x64"* ]]; then
            echo "  (适用于Intel Mac)"
        elif [[ "$dmg" == *"arm64"* ]]; then
            echo "  (适用于Apple Silicon Mac)"
        fi
    fi
done)

🚀 安装步骤:
1. 选择适合您Mac的DMG文件
2. 双击DMG文件
3. 将应用拖拽到Applications文件夹
4. 从启动台或应用程序文件夹启动

🔒 安全提示:
如果出现"无法验证开发者"警告:
1. 打开"系统偏好设置" > "安全性与隐私"
2. 点击"仍要打开"按钮

📋 系统要求:
- macOS 10.14 或更高版本
- 4GB RAM (推荐8GB+)
- 1GB 可用磁盘空间

🎬 功能特点:
- 保持HEVC编码和MP4格式
- 专业级音频响度标准化
- 内置FFmpeg，无需额外安装
- 支持Intel和Apple Silicon Mac

构建时间: $(date)
EOF

echo "✅ 安装说明已生成: dist/安装说明.txt"
echo

echo "🎉 构建验证完成！"
echo
echo "📦 可分发文件:"
for dmg in "${dmg_files[@]}"; do
    if [ -f "$dmg" ]; then
        echo "   - $(basename "$dmg")"
    fi
done
echo "   - 安装说明.txt"
echo
echo "🚀 现在可以分发这些文件给macOS用户使用！"