// 下载FFmpeg.js文件到本地的脚本
const https = require('https');
const fs = require('fs');
const path = require('path');

// 要下载的文件列表
const files = [
    {
        url: 'https://unpkg.com/@ffmpeg/ffmpeg@0.12.7/dist/umd/ffmpeg.js',
        path: 'libs/ffmpeg.js'
    },
    {
        url: 'https://unpkg.com/@ffmpeg/util@0.12.1/dist/util.js',
        path: 'libs/util.js'
    },
    {
        url: 'https://unpkg.com/@ffmpeg/core@0.12.4/dist/umd/ffmpeg-core.js',
        path: 'libs/ffmpeg-core.js'
    },
    {
        url: 'https://unpkg.com/@ffmpeg/core@0.12.4/dist/umd/ffmpeg-core.wasm',
        path: 'libs/ffmpeg-core.wasm'
    },
    {
        url: 'https://unpkg.com/@ffmpeg/core@0.12.4/dist/umd/ffmpeg-core.worker.js',
        path: 'libs/ffmpeg-core.worker.js'
    }
];

// 下载文件的函数
function downloadFile(url, filePath) {
    return new Promise((resolve, reject) => {
        console.log(`正在下载: ${url}`);

        const file = fs.createWriteStream(filePath);

        https.get(url, (response) => {
            if (response.statusCode !== 200) {
                reject(new Error(`HTTP ${response.statusCode}: ${url}`));
                return;
            }

            response.pipe(file);

            file.on('finish', () => {
                file.close();
                console.log(`✅ 下载完成: ${filePath}`);
                resolve();
            });

        }).on('error', (err) => {
            fs.unlink(filePath, () => { }); // 删除部分下载的文件
            reject(err);
        });
    });
}

// 主下载函数
async function downloadAllFiles() {
    console.log('开始下载FFmpeg.js文件...\n');

    // 确保libs目录存在
    if (!fs.existsSync('libs')) {
        fs.mkdirSync('libs');
    }

    try {
        for (const file of files) {
            await downloadFile(file.url, file.path);
        }

        console.log('\n🎉 所有文件下载完成！');
        console.log('现在可以使用 index-local-ffmpeg.html 来运行完整版本');

    } catch (error) {
        console.error('\n❌ 下载失败:', error.message);
        console.log('\n备选方案:');
        console.log('1. 检查网络连接');
        console.log('2. 使用VPN或代理');
        console.log('3. 手动下载文件到libs目录');
        console.log('4. 使用简化版本 index-local.html');
    }
}

// 运行下载
downloadAllFiles();