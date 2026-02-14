@echo off
chcp 65001 > nul
echo ================================
echo nanobot-chat-ui Start Script (Windows)
echo ================================

:: Check if virtual environment exists
if not exist "Agent\.venv" (
    echo Error: Virtual environment not found
    echo Please run install-win.bat first
    pause
    exit /b 1
)

:: Activate virtual environment
echo Activating virtual environment...
call "Agent\.venv\Scripts\activate"
if %errorlevel% neq 0 (
    echo Error: Failed to activate virtual environment
    pause
    exit /b 1
)

:: Check nanobot configuration
if not exist "%USERPROFILE%\.nanobot\config.json" (
    echo Warning: nanobot configuration file not found
    echo Please run 'nanobot onboard' to configure API keys
    pause
)

:: Start backend API server
echo Starting backend API server...
echo Backend will run on http://localhost:5678
start "nanobot API" python "Agent\mian_api.py"

:: Wait for backend to start
echo Waiting for backend to start...
ping 127.0.0.1 -n 5 > nul

:: Start frontend development server
echo Starting frontend development server...
echo Frontend will run on http://localhost:3000
cd "chatbot-webui"
start "nanobot Web UI" npm run dev
cd ..

echo ================================
echo Services started successfully!
echo ================================
echo Backend API: http://localhost:5678
echo Frontend UI: http://localhost:3000
echo ================================
echo Press any key to exit...
pause > nul
