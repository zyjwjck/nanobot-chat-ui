# nanobot-chat-ui 🐈🦙

nanobot-chat-ui is a comprehensive AI assistant platform that combines the ultra-lightweight power of [nanobot](https://github.com/HKUDS/nanobot) with the user-friendly interface of [ollama-webui-lite](https://github.com/ollama-webui/ollama-webui-lite) (derived from [Ollama Web UI](https://github.com/ollama-webui/ollama-webui)).

## 📋 Project Overview

This project bridges the gap between nanobot's powerful backend capabilities and a modern, intuitive web interface. nanobot provides the core AI functionality with its lightweight design, while ollama-webui-lite offers a clean, user-friendly frontend for interacting with the AI assistant.

## ✨ Key Features

### From nanobot:
- **Ultra-Lightweight**: Just ~4,000 lines of core agent code — 99% smaller than traditional AI assistants
- **Multi-Provider Support**: Works with OpenAI, Anthropic, Google Gemini, DeepSeek, Moonshot/Kimi, and more
- **Local Model Support**: Run with your own local models using vLLM or any OpenAI-compatible server
- **Multi-Channel Integration**: Connect via Telegram, Discord, WhatsApp, and Feishu
- **Research-Ready**: Clean, readable code that's easy to understand, modify, and extend
- **Fast Performance**: Minimal footprint means faster startup, lower resource usage, and quicker iterations

### From ollama-webui-lite:
- **Intuitive Web Interface**: Clean, modern UI for easy interaction with AI models
- **Conversation Management**: Engage in conversations with one or multiple models
- **Chat Import/Export**: Save and load your chat histories
- **Model Management**: Pull and delete models with ease
- **TypeScript-Based**: Fully migrated to TypeScript for better code reliability
- **Modular Architecture**: Well-organized codebase for easier maintenance and extension

## 🏗️ Architecture

nanobot-chat-ui combines two powerful components:

1. **nanobot Backend**: Provides the core AI agent functionality, LLM integration, and tool execution capabilities
2. **ollama-webui-lite Frontend**: Offers a user-friendly web interface for interacting with the AI assistant

The backend exposes an API that the frontend uses to communicate with the AI agent, creating a seamless user experience.

## 🚀 Installation

### Prerequisites
- Node.js and npm
- Python ≥ 3.11
- Git (for cloning repositories)

### Option 1: One-Click Installation (Recommended)

We provide convenient one-click installation and start scripts for different operating systems:

#### Windows
```bash
# Clone the repository
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui

# Run the installation script
install-win.bat

# Run the start script
start-win.bat
```

#### macOS
```bash
# Clone the repository
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui

# Make scripts executable
chmod +x install-mac.sh start-mac.sh

# Run the installation script
./install-mac.sh

# Run the start script
./start-mac.sh
```

#### Linux
```bash
# Clone the repository
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui

# Make scripts executable
chmod +x install-linux.sh start-linux.sh

# Run the installation script
./install-linux.sh

# Run the start script
./start-linux.sh
```

### Option 2: Manual Installation

#### Step 1: Clone the Repository

```bash
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui
```

#### Step 2: Set Up Virtual Environment

```bash
# Create virtual environment
python -m venv Agent/.venv

# Activate virtual environment
# On Windows
Agent\.venv\Scripts\activate
# On macOS/Linux
# source Agent/.venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Step 3: Install nanobot

```bash
# Install nanobot in editable mode (already configured in requirements.txt)

# Initialize nanobot
nanobot onboard

# Configure nanobot with your API keys (edit ~/.nanobot/config.json)
```

#### Step 4: Install ollama-webui-lite

```bash
# Install frontend dependencies
cd chatbot-webui
npm ci
cd ..
```

#### Step 5: Configure the Application

##### Backend Configuration (nanobot)
Edit `~/.nanobot/config.json` to set up your LLM providers:

```json
{
  "providers": {
    "openrouter": {
      "apiKey": "sk-or-v1-xxx"
    }
  },
  "agents": {
    "defaults": {
      "model": "anthropic/claude-opus-4-5"
    }
  }
}
```

##### Frontend Configuration
Edit `chatbot-webui/.env` to configure the frontend settings:

```env
# API endpoint for nanobot
NEXT_PUBLIC_API_BASE_URL=http://localhost:5678
```

### Step 6: Run the Application

#### Option 1: Use One-Click Start Scripts

##### Windows
```bash
# Run the start script
start-win.bat
```

##### macOS
```bash
# Run the start script
./start-mac.sh
```

##### Linux
```bash
# Run the start script
./start-linux.sh
```

#### Option 2: Manual Start

##### Start the Backend API
In a terminal, run:

```bash
# Activate virtual environment if not already activated
# On Windows
Agent\.venv\Scripts\activate
# On macOS/Linux
# source Agent/.venv/bin/activate

# Start the backend API server
python Agent/mian_api.py
```

##### Start the Frontend
In a separate terminal, run:

```bash
# Navigate to frontend directory
cd chatbot-webui

# Start the frontend development server
npm run dev
cd ..
```

The application should now be available at http://localhost:3000

The backend API is available at http://localhost:5678

## 📁 Project Structure

```
nanobot-chat-ui/
├── Agent/            # 🧠 nanobot backend (core AI functionality)
│   ├── nanobot/      # nanobot core code
│   ├── tests/        # test files
│   ├── workspace/    # workspace for agent data
│   ├── .venv/        # virtual environment
│   ├── mian_api.py   # backend API server
│   └── other config files
├── chatbot-webui/    # 🎨 ollama-webui-lite frontend (user interface)
├── README.md         # 📖 English documentation (this file)
├── readme_zh.md      # 📖 Chinese documentation
├── requirements.txt  # Python dependencies
└── .gitignore        # Git ignore configuration
```

## 🔧 Configuration

### nanobot Configuration
Edit `~/.nanobot/config.json` to set up your LLM providers and channels:

```json
{
  "providers": {
    "openrouter": {
      "apiKey": "sk-or-v1-xxx"
    }
  },
  "agents": {
    "defaults": {
      "model": "anthropic/claude-opus-4-5"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "YOUR_BOT_TOKEN",
      "allowFrom": ["YOUR_USER_ID"]
    }
  }
}
```

### Frontend Configuration
Edit `chatbot-webui/.env` to configure the frontend settings:

```env
# API endpoint for nanobot
NEXT_PUBLIC_API_BASE_URL=http://localhost:18790/api
```

## 🤝 Credits and Acknowledgements

nanobot-chat-ui would not be possible without the excellent work of the following projects:

### Core Components:
- **[nanobot](https://github.com/HKUDS/nanobot)**: Ultra-lightweight personal AI assistant developed by HKUDS
- **[ollama-webui-lite](https://github.com/ollama-webui/ollama-webui-lite)**: Streamlined version of Ollama Web UI
- **[Ollama Web UI](https://github.com/ollama-webui/ollama-webui)**: Original web interface for Ollama

### LLM Providers:
- OpenAI
- Anthropic
- Google Gemini
- DeepSeek
- Moonshot/Kimi
- Groq
- And many more...

## 📄 License

This project is licensed under the MIT License. See the respective license files in the nanobot and ollama-webui-lite directories for more details.

## 🤗 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to help improve this project.

## 📞 Support

If you have any questions or need assistance, please refer to the documentation of the original projects:
- [nanobot Documentation](https://github.com/HKUDS/nanobot)
- [ollama-webui-lite Documentation](https://github.com/ollama-webui/ollama-webui-lite)
- [Ollama Web UI Documentation](https://github.com/ollama-webui/ollama-webui)
- some of the icons are from [remixicon.com](https://remixicon.com/)

---

[中文文档](readme_zh.md) | [English Documentation](README.md)