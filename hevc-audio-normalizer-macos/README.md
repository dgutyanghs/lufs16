# 视频音频响度调节器 (FFmpeg.js 版本)

一个基于浏览器的专业级视频音频响度调节工具，使用 FFmpeg.js 实现精确的 LUFS 分析和调节到-16 LUFS 标准。

## 功能特点

- 🎵 **专业 LUFS 分析**: 使用 FFmpeg 的 loudnorm 滤镜进行精确的响度分析
- 🎚️ **智能响度标准化**: 自动将音频响度调节到广播标准的-16 LUFS
- 📊 **详细音频信息**: 显示 LUFS、峰值电平、动态范围等专业参数
- 🎬 **完整视频处理**: 保持视频质量的同时处理音频
- 🖱️ **拖拽上传**: 支持拖拽文件上传，操作简便
- 💾 **本地处理**: 所有处理都在浏览器本地完成，保护隐私
- 🔄 **批量处理**: 支持多文件批量处理功能

## 技术实现

### 核心技术栈

- **FFmpeg.js**: 专业级音视频处理引擎
- **WebAssembly**: 高性能计算支持
- **File API**: 文件读取和处理
- **Blob API**: 二进制数据处理

### 主要组件

#### FFmpegAudioProcessor 类

- `analyzeAudio()`: 使用 FFmpeg loudnorm 滤镜分析音频
- `processVideo()`: 完整的视频音频处理流程
- `parseLoudnormOutput()`: 解析 FFmpeg 输出的 LUFS 数据
- `getVideoInfo()`: 获取详细的视频文件信息
- `processBatch()`: 批量处理多个视频文件

#### VideoAudioNormalizer 类

- 用户界面控制和交互
- 文件上传和验证处理
- 实时进度显示
- 处理结果展示和下载

## 使用方法

1. 在现代浏览器中打开 `index.html`
2. 拖拽视频文件到上传区域或点击选择文件
3. 系统自动使用 FFmpeg 分析音频响度
4. 应用 loudnorm 滤镜将响度调节到-16 LUFS
5. 显示详细的处理结果和音频参数
6. 下载处理后的视频文件

## 支持的格式

### 输入格式

- **视频**: MP4, AVI, MOV, MKV, WebM, FLV 等 FFmpeg 支持的所有格式
- **音频编码**: AAC, MP3, AC3, PCM 等
- **视频编码**: H.264, H.265, VP8, VP9 等

### 输出格式

- **容器**: MP4 (推荐)
- **视频编码**: 保持原始编码 (copy 模式)
- **音频编码**: AAC 192kbps

### 文件大小限制

- 最大支持 1GB 文件 (受浏览器内存限制)

## 浏览器兼容性

### 推荐浏览器

- ✅ Chrome 88+ (推荐)
- ✅ Firefox 85+
- ✅ Safari 14+
- ✅ Edge 88+

### 必需功能

- **WebAssembly**: FFmpeg.js 运行必需
- **SharedArrayBuffer**: 提升性能 (需要 HTTPS 和正确的头部设置)
- **File API**: 文件读取支持
- **Blob API**: 二进制数据处理

## 技术详解

### LUFS 标准化流程

1. **音频分析阶段**

   ```
   ffmpeg -i input.mp4 -af "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json" -f null -
   ```

   - 分析输入音频的 LUFS、峰值和动态范围
   - 使用 EBU R128 标准进行测量

2. **响度标准化阶段**
   ```
   ffmpeg -i input.mp4 -af "loudnorm=I=-16:TP=-1.5:LRA=11:linear=true" -c:v copy -c:a aac output.mp4
   ```
   - 应用 loudnorm 滤镜进行响度标准化
   - 保持视频流不变，重新编码音频

### 关键参数说明

- **I=-16**: 目标积分响度 (LUFS)
- **TP=-1.5**: 真峰值限制 (dBTP)
- **LRA=11**: 响度范围目标 (LU)
- **linear=true**: 使用线性模式获得更好的质量

### 性能优化

- **内存管理**: 自动清理 FFmpeg 虚拟文件系统
- **进度反馈**: 实时显示处理进度
- **错误处理**: 完善的错误捕获和用户提示
- **资源清理**: 及时释放 Blob URL 和内存

## 部署说明

### 本地开发

```bash
# 使用本地HTTP服务器
python -m http.server 8000
# 或
npx serve .
```

### 生产部署

#### 必需的 HTTP 头部 (用于 SharedArrayBuffer 支持)

```
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

#### Nginx 配置示例

```nginx
location / {
    add_header Cross-Origin-Opener-Policy same-origin;
    add_header Cross-Origin-Embedder-Policy require-corp;
}
```

## 限制和注意事项

### 当前限制

1. **文件大小**: 受浏览器内存限制，建议 1GB 以内
2. **处理时间**: 大文件处理时间较长，请耐心等待
3. **浏览器支持**: 需要现代浏览器的 WebAssembly 支持

### 性能建议

1. **使用 HTTPS**: 启用 SharedArrayBuffer 以获得更好性能
2. **充足内存**: 确保浏览器有足够可用内存
3. **稳定网络**: 首次加载需要下载 FFmpeg 核心文件

## 扩展功能

### 可添加的功能

- 多种响度标准支持 (-23 LUFS for streaming, -14 LUFS for podcasts)
- 音频均衡器调节
- 批量处理界面
- 音频波形可视化
- 处理历史记录

### 高级用法

```javascript
// 自定义响度目标
const processor = new FFmpegAudioProcessor();
processor.targetLUFS = -23; // 流媒体标准

// 批量处理
const results = await processor.processBatch(files, progressCallback);
```

## 许可证

MIT License - 可自由使用、修改和分发。

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个工具。

## 技术支持

如遇到问题，请检查：

1. 浏览器是否支持 WebAssembly
2. 是否通过 HTTPS 访问 (用于 SharedArrayBuffer)
3. 文件格式是否被 FFmpeg 支持
4. 浏览器控制台是否有错误信息
