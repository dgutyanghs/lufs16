#!/bin/bash

echo "启动视频音频响度调节器服务器..."
echo

# 检查Node.js是否安装
if ! command -v node &> /dev/null; then
    echo "错误: 未找到Node.js"
    echo "请先安装Node.js: https://nodejs.org/"
    exit 1
fi

echo "Node.js已安装"
echo "启动服务器..."
echo
echo "服务器将在 http://localhost:8080 运行"
echo "按 Ctrl+C 停止服务器"
echo

node server-headers.js