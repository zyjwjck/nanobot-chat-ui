@echo off
chcp 65001 > nul
echo ================================
echo nanobot-chat-ui 安装脚本 (Windows)
echo ================================

:: 检查 Python 是否安装
echo 检查 Python 版本...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: Python 未安装或不在 PATH 中
    echo 请安装 Python 3.11 或更高版本
    pause
    exit /b 1
)

:: 检查 Node.js 是否安装
echo 检查 Node.js 版本...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: Node.js 未安装或不在 PATH 中
    echo 请安装 Node.js 18 或更高版本
    pause
    exit /b 1
)

:: 创建虚拟环境
echo 创建虚拟环境...
python -m venv Agent\.venv
if %errorlevel% neq 0 (
    echo 错误: 创建虚拟环境失败
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

:: 升级 pip
echo 升级 pip...
pip install --upgrade pip

:: 安装依赖
echo 安装 Python 依赖...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo 错误: 安装 Python 依赖失败
    pause
    exit /b 1
)

:: 初始化 nanobot
echo 初始化 nanobot...
nanobot onboard
if %errorlevel% neq 0 (
    echo 警告: nanobot 初始化失败
    echo 请手动运行 'nanobot onboard' 并配置 API 密钥
)

:: 安装前端依赖
echo 安装前端依赖...
cd chatbot-webui
npm ci
if %errorlevel% neq 0 (
    echo 错误: 安装前端依赖失败
    cd ..
    pause
    exit /b 1
)

cd ..

echo ================================
echo 安装完成！
echo ================================
echo 接下来你需要:
echo 1. 配置 nanobot API 密钥 (编辑 ~/.nanobot/config.json)
echo 2. 运行 start-win.bat 启动服务
echo ================================
pause