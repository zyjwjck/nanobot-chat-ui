@echo off
chcp 65001 > nul
echo ================================
echo nanobot-chat-ui 启动脚本 (Windows)
echo ================================

:: 检查虚拟环境是否存在
if not exist "Agent\.venv" (
    echo 错误: 虚拟环境不存在
    echo 请先运行 install-win.bat 安装依赖
    pause
    exit /b 1
)

:: 激活虚拟环境
echo 激活虚拟环境...
Agent\.venv\Scripts\activate
if %errorlevel% neq 0 (
    echo 错误: 激活虚拟环境失败
    pause
    exit /b 1
)

:: 检查 nanobot 配置
if not exist "%USERPROFILE%\.nanobot\config.json" (
    echo 警告: nanobot 配置文件不存在
    echo 请运行 'nanobot onboard' 并配置 API 密钥
    pause
)

:: 启动后端 API 服务器
echo 启动后端 API 服务器...
echo 后端服务将在 http://localhost:5678 上运行
start "nanobot API" python Agent\mian_api.py

:: 等待后端服务启动
echo 等待后端服务启动...
ping 127.0.0.1 -n 5 > nul

:: 启动前端开发服务器
echo 启动前端开发服务器...
echo 前端服务将在 http://localhost:3000 上运行
cd chatbot-webui
start "nanobot Web UI" npm run dev
cd ..

echo ================================
echo 服务启动完成！
echo ================================
echo 后端 API: http://localhost:5678
echo 前端界面: http://localhost:3000
echo ================================
echo 按任意键退出...
pause > nul