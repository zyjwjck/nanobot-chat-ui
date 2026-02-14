#!/bin/bash

echo "============================"
echo "nanobot-chat-ui 启动脚本 (macOS/Linux)"
echo "============================"

# 检查虚拟环境是否存在
if [ ! -d "Agent/.venv" ]; then
    echo "错误: 虚拟环境不存在"
    echo "请先运行 ./install-mac.sh 安装依赖"
    exit 1
fi

# 激活虚拟环境
echo "激活虚拟环境..."
source Agent/.venv/bin/activate
if [ $? -ne 0 ]; then
    echo "错误: 激活虚拟环境失败"
    exit 1
fi

# 检查 nanobot 配置
if [ ! -f "$HOME/.nanobot/config.json" ]; then
    echo "警告: nanobot 配置文件不存在"
    echo "请运行 'nanobot onboard' 并配置 API 密钥"
fi

# 启动后端 API 服务器
echo "启动后端 API 服务器..."
echo "后端服务将在 http://localhost:5678 上运行"
python3 Agent/mian_api.py &
BACKEND_PID=$!

# 等待后端服务启动
echo "等待后端服务启动..."
sleep 5

# 启动前端开发服务器
echo "启动前端开发服务器..."
echo "前端服务将在 http://localhost:3000 上运行"
cd chatbot-webui
npm run dev &
FRONTEND_PID=$!
cd ..

echo "============================"
echo "服务启动完成！"
echo "============================"
echo "后端 API: http://localhost:5678"
echo "前端界面: http://localhost:3000"
echo "============================"
echo "按 Ctrl+C 停止所有服务..."

# 等待用户输入，然后停止服务
wait $BACKEND_PID $FRONTEND_PID

# 清理
echo "清理服务..."
kill $BACKEND_PID 2>/dev/null
kill $FRONTEND_PID 2>/dev/null
echo "服务已停止"
