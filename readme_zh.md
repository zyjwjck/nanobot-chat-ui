# nanobot-chat-ui 🐈🦙

nanobot-chat-ui 是一个综合 AI 助手平台，结合了 [nanobot](https://github.com/HKUDS/nanobot) 的轻量级强大功能和 [ollama-webui-lite](https://github.com/ollama-webui/ollama-webui-lite)（源自 [Ollama Web UI](https://github.com/ollama-webui/ollama-webui)）的用户友好界面。

## 📋 项目概述

本项目弥合了 nanobot 强大的后端功能与现代、直观的 Web 界面之间的差距。nanobot 以其轻量级设计提供核心 AI 功能，而 ollama-webui-lite 则提供了一个干净、用户友好的前端界面，用于与 AI 助手交互。

## ✨ 主要功能

### 来自 nanobot：
- **超轻量级**：核心代理代码仅约 4,000 行 — 比传统 AI 助手小 99%
- **多提供商支持**：与 OpenAI、Anthropic、Google Gemini、DeepSeek、Moonshot/Kimi 等兼容
- **本地模型支持**：使用 vLLM 或任何兼容 OpenAI 的服务器运行自己的本地模型
- **多渠道集成**：通过 Telegram、Discord、WhatsApp 和飞书连接
- **研究就绪**：干净、可读的代码，易于理解、修改和扩展
- **快速性能**：最小的占用空间意味着更快的启动、更低的资源使用和更快的迭代

### 来自 ollama-webui-lite：
- **直观的 Web 界面**：干净、现代的 UI，便于与 AI 模型交互
- **对话管理**：与一个或多个模型进行对话
- **聊天导入/导出**：保存和加载聊天历史
- **模型管理**：轻松拉取和删除模型
- **基于 TypeScript**：完全迁移到 TypeScript，提高代码可靠性
- **模块化架构**：组织良好的代码库，便于维护和扩展

## 🏗️ 架构

nanobot-chat-ui 结合了两个强大的组件：

1. **nanobot 后端**：提供核心 AI 代理功能、LLM 集成和工具执行能力
2. **ollama-webui-lite 前端**：提供用户友好的 Web 界面，用于与 AI 助手交互

后端公开了一个 API，前端使用该 API 与 AI 代理通信，创造无缝的用户体验。

## 🚀 安装

### 先决条件
- Node.js 和 npm
- Python ≥ 3.11
- Git（用于克隆仓库）

### 选项 1：一键安装（推荐）

我们提供了针对不同操作系统的便捷一键安装和启动脚本：

#### Windows
```bash
# 克隆仓库
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui

# 运行安装脚本
install-win.bat

# 运行启动脚本
start-win.bat
```

#### macOS
```bash
# 克隆仓库
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui

# 使脚本可执行
chmod +x install-mac.sh start-mac.sh

# 运行安装脚本
./install-mac.sh

# 运行启动脚本
./start-mac.sh
```

#### Linux
```bash
# 克隆仓库
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui

# 使脚本可执行
chmod +x install-linux.sh start-linux.sh

# 运行安装脚本
./install-linux.sh

# 运行启动脚本
./start-linux.sh
```

### 选项 2：手动安装

#### 步骤 1：克隆仓库

```bash
git clone https://github.com/zyjwjck/nanobot-chat-ui.git
cd nanobot-chat-ui
```

#### 步骤 2：设置虚拟环境

```bash
# 创建虚拟环境
python -m venv Agent/.venv

# 激活虚拟环境
# Windows 系统
Agent\.venv\Scripts\activate
# macOS/Linux 系统
# source Agent/.venv/bin/activate

# 安装依赖项
pip install -r requirements.txt
```

#### 步骤 3：安装 nanobot

```bash
# 以可编辑模式安装 nanobot（已在 requirements.txt 中配置）

# 初始化 nanobot
nanobot onboard

# 配置 nanobot 并添加 API 密钥（编辑 ~/.nanobot/config.json）
```

#### 步骤 4：安装 ollama-webui-lite

```bash
# 安装前端依赖项
cd chatbot-webui
npm ci
cd ..
```

#### 步骤 5：配置应用程序

##### 后端配置（nanobot）
编辑 `~/.nanobot/config.json` 设置 LLM 提供商：

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

##### 前端配置
编辑 `chatbot-webui/.env` 配置前端设置：

```env
# nanobot 的 API 端点
NEXT_PUBLIC_API_BASE_URL=http://localhost:5678
```

### 步骤 6：运行应用程序

#### 选项 1：使用一键启动脚本

##### Windows
```bash
# 运行启动脚本
start-win.bat
```

##### macOS
```bash
# 运行启动脚本
./start-mac.sh
```

##### Linux
```bash
# 运行启动脚本
./start-linux.sh
```

#### 选项 2：手动启动

##### 启动后端 API
在一个终端中运行：

```bash
# 激活虚拟环境（如果尚未激活）
# Windows 系统
Agent\.venv\Scripts\activate
# macOS/Linux 系统
# source Agent/.venv/bin/activate

# 启动后端 API 服务器
python Agent/mian_api.py
```

##### 启动前端
在另一个终端中运行：

```bash
# 导航到前端目录
cd chatbot-webui

# 启动前端开发服务器
npm run dev
cd ..
```

应用程序现在应该可以在 http://localhost:3000 访问

后端 API 可以在 http://localhost:5678 访问

## 📁 项目结构

```
nanobot-chat-ui/
├── Agent/            # 🧠 nanobot 后端（核心 AI 功能）
│   ├── nanobot/      # nanobot 核心代码
│   ├── tests/        # 测试文件
│   ├── workspace/    # 代理数据工作区
│   ├── .venv/        # 虚拟环境
│   ├── mian_api.py   # 后端 API 服务器
│   └── 其他配置文件
├── chatbot-webui/    # 🎨 ollama-webui-lite 前端（用户界面）
├── README.md         # 📖 英文文档
├── readme_zh.md      # 📖 中文文档（本文件）
├── requirements.txt  # Python 依赖项
└── .gitignore        # Git 忽略配置
```

## 🔧 配置

### nanobot 配置
编辑 `~/.nanobot/config.json` 设置 LLM 提供商和渠道：

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

### 前端配置
编辑 `chatbot-webui/.env` 配置前端设置：

```env
# nanobot 的 API 端点
NEXT_PUBLIC_API_BASE_URL=http://localhost:18790/api
```

## 🤝 致谢

nanobot-chat-ui 的实现离不开以下项目的优秀工作：

### 核心组件：
- **[nanobot](https://github.com/HKUDS/nanobot)**：由 HKUDS 开发的超轻量级个人 AI 助手
- **[ollama-webui-lite](https://github.com/ollama-webui/ollama-webui-lite)**：Ollama Web UI 的精简版本
- **[Ollama Web UI](https://github.com/ollama-webui/ollama-webui)**：Ollama 的原始 Web 界面

### LLM 提供商：
- OpenAI
- Anthropic
- Google Gemini
- DeepSeek
- Moonshot/Kimi
- Groq
- 以及更多...

## 📄 许可证

本项目采用 MIT 许可证。有关更多详细信息，请参阅 nanobot 和 ollama-webui-lite 目录中的相应许可证文件。

## 🤗 贡献

欢迎贡献！请随时打开问题或提交拉取请求，帮助改进此项目。

## 📞 支持

如果您有任何问题或需要帮助，请参考原始项目的文档：
- [nanobot 文档](https://github.com/HKUDS/nanobot)
- [ollama-webui-lite 文档](https://github.com/ollama-webui/ollama-webui-lite)
- [Ollama Web UI 文档](https://github.com/ollama-webui/ollama-webui)

---

[English Documentation](README.md) | [中文文档](readme_zh.md)