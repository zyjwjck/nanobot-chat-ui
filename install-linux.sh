#!/bin/bash

echo "============================"
echo "nanobot-chat-ui 安装脚本 (Linux)"
echo "============================"

# 检查 Python 是否安装
echo "检查 Python 版本..."
if ! command -v python3 &> /dev/null; then
    echo "错误: Python 未安装或不在 PATH 中"
    echo "请安装 Python 3.11 或更高版本"
    exit 1
fi

# 检查 Node.js 是否安装
echo "检查 Node.js 版本..."
if ! command -v node &> /dev/null; then
    echo "错误: Node.js 未安装或不在 PATH 中"
    echo "请安装 Node.js 18 或更高版本"
    exit 1
fi

# 创建虚拟环境
echo "创建虚拟环境..."
python3 -m venv Agent/.venv
if [ $? -ne 0 ]; then
    echo "错误: 创建虚拟环境失败"
    exit 1
fi

# 激活虚拟环境
echo "激活虚拟环境..."
source Agent/.venv/bin/activate
if [ $? -ne 0 ]; then
    echo "错误: 激活虚拟环境失败"
    exit 1
fi

# 升级 pip
echo "升级 pip..."
pip install --upgrade pip

# 安装依赖
echo "安装 Python 依赖..."
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "错误: 安装 Python 依赖失败"
    exit 1
fi

# 初始化 nanobot
echo "初始化 nanobot..."
nanobot onboard
if [ $? -ne 0 ]; then
    echo "警告: nanobot 初始化失败"
    echo "请手动运行 'nanobot onboard' 并配置 API 密钥"
fi

# 安装前端依赖
echo "安装前端依赖..."
cd chatbot-webui
npm ci
if [ $? -ne 0 ]; then
    echo "错误: 安装前端依赖失败"
    cd ..
    exit 1
fi

cd ..

echo "============================"
echo "安装完成！"
echo "============================"
echo "接下来你需要:"
echo "1. 配置 nanobot API 密钥 (编辑 ~/.nanobot/config.json)"
echo "2. 运行 ./start-linux.sh 启动服务"
echo "============================"