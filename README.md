# MCP_1 - Complete MCP Server Suite

This repo provides a complete MCP server setup for **Claude Desktop**, **LM Studio**, and **AnythingLLM** on Windows with 8 powerful servers:

## 🎯 Core MCP Servers (Local)
- **mcp-puppeteer** — Chromium automation via Puppeteer
- **mcp-playwright** — Multi-browser automation via Playwright (Chromium/Firefox/WebKit)

## 🌐 API-Based MCP Servers (NPM Global)
- **@modelcontextprotocol/server-filesystem** — Secure file operations with access controls
- **@modelcontextprotocol/server-memory** — Knowledge graph-based persistent memory
- **@modelcontextprotocol/server-brave-search** — Web search capabilities (requires API key)
- **@modelcontextprotocol/server-sequential-thinking** — Dynamic problem-solving through thought sequences
- **exa-mcp-server** — AI-powered search engine (requires API key)
- **@taazkareem/clickup-mcp-server** — ClickUp task management (requires API token & Team ID)

## 📁 Contents
- servers/mcp-puppeteer — Local Puppeteer server
- servers/mcp-playwright — Local Playwright server
- scripts/setup-all.ps1 — Complete setup script for all 8 servers
- scripts/install-global-servers.ps1 — Install NPM-based servers
- scripts/sync-mcp-configs.ps1 — **Centralized config management script** (NEW!)
- config/master-mcp-config.json — **Master configuration file** (NEW!)
- **QUICK_START_CONFIG.md** — **Quick reference for config management** (NEW!)
- examples/claude_desktop_config.complete.json — Complete Claude MCP config
- examples/lm_studio_mcp.json — LM Studio configuration
- examples/anythingllm_mcp_servers.json — AnythingLLM configuration
- docs/CONFIG_MANAGEMENT.md — **How to manage configs across all platforms** (NEW!)
- docs/LM_STUDIO_SETUP.md — Complete LM Studio setup guide
- docs/ANYTHINGLLM_VS_LMSTUDIO.md — Platform comparison guide
- docs/BEST_MODELS_FOR_AUTOMATION.md — Model recommendations for automation tasks

## 🤖 Choosing the Right Model

Not sure which LLM model to use for automation? See our complete guide:

**📘 [Best Models for Automation & Data Collection](docs/BEST_MODELS_FOR_AUTOMATION.md)**

**Quick picks:**
- **Best Overall:** DeepSeek R1 14B - Complex reasoning & multi-step automation
- **Best Tool Use:** Qwen 2.5 14B - Excellent function calling & data extraction
- **Best Lightweight:** Llama 3.1 8B - Fast & efficient for simple tasks
- **Best If You Have Power:** Llama 3.3 70B - Maximum capability

## Quick Start (Windows)

### Prerequisites
- Node.js 18+ installed ([download here](https://nodejs.org/))
- Git installed ([download here](https://git-scm.com/))

### 1) Clone the Repository
```powershell
# Create workspace directory if needed
New-Item -ItemType Directory -Force -Path C:\DevWorkspace

# Clone the repository
cd C:\DevWorkspace
git clone https://github.com/evoluzion25/MCP_1.git
cd MCP_1
```

### 2) Set Up API Keys (Optional but Recommended)
Create a `.env` file in your workspace root with your API keys:

```bash
# Required for Brave Search
BRAVE_API_KEY=your_brave_api_key_here

# Required for Exa Search
EXA_API_KEY=your_exa_api_key_here

# Required for ClickUp
CLICKUP_API_TOKEN=your_clickup_token_here
CLICKUP_TEAM_ID=your_team_id_here
```

See `examples/.env.example` for a template with detailed instructions.

**Getting API Keys:**
- **Brave Search**: [https://brave.com/search/api/](https://brave.com/search/api/)
- **Exa Search**: [https://exa.ai/](https://exa.ai/)
- **ClickUp**: Settings → Apps → API Token

### 3) Run the Setup Script
```powershell
# Allow script execution for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Run the complete setup (installs all 8 servers)
.\scripts\setup-all.ps1 -PlaywrightInstallBrowsers
```

This will:
- Install dependencies for local servers (Puppeteer & Playwright)
- Download Chromium, Firefox, and WebKit browsers for Playwright
- Install 6 NPM-based servers globally (filesystem, memory, brave-search, sequential-thinking, exa-search, clickup)

### 4) Configure Claude Desktop
The script will prompt you to apply the configuration to Claude Desktop. If you choose "y", it will update `%APPDATA%\Claude\claude_desktop_config.json`.

Alternatively, manually copy `examples/claude_desktop_config.complete.json` to `%APPDATA%\Claude\claude_desktop_config.json` and update the paths and API keys.

### 5) Restart Claude Desktop
Close and restart Claude Desktop to load the MCP servers.

### 6) Verify Installation
In Claude Desktop, you should now see these tools available:
- **Browser Automation**: navigate, screenshot, getContent, click, fill, evaluate
- **File Operations**: read_file, write_file, list_directory
- **Memory**: create_entities, create_relations, search_nodes
- **Search**: brave_web_search, exa_search
- **Task Management**: clickup tools (list_tasks, create_task, etc.)
- **Problem Solving**: sequential_thinking

## 🖥️ Using with LM Studio

Want to use these MCP servers with local models in LM Studio? See the complete guide:

**📘 [LM Studio Setup Guide](docs/LM_STUDIO_SETUP.md)**

Quick start:
1. Install LM Studio 0.3.17+ from [lmstudio.ai](https://lmstudio.ai/download)
2. Run the setup script above (same as Claude Desktop)
3. Copy `examples/lm_studio_mcp.json` content to LM Studio's MCP config
   - Open LM Studio → Program tab → Install → Edit mcp.json
4. Restart LM Studio

**Use Cases:**
- ✅ Login to websites and download PDFs/documents (100% local & private)
- ✅ Automate form filling and data extraction
- ✅ Web scraping and content retrieval
- ✅ Task management integration
- ✅ Everything stays on your machine!

## 🎨 Using with AnythingLLM

Want document management + RAG + AI agents with your MCP servers?

**📘 [AnythingLLM vs LM Studio Comparison](docs/ANYTHINGLLM_VS_LMSTUDIO.md)**

Quick start:
1. Install AnythingLLM 1.9.0+ from [useanything.com](https://anythingllm.com/download)
2. Run the setup script above (same as Claude Desktop)
3. Copy `examples/anythingllm_mcp_servers.json` to AnythingLLM's plugins directory
   - Windows: `%APPDATA%\anythingllm-desktop\storage\plugins\anythingllm_mcp_servers.json`
4. Restart AnythingLLM

**AnythingLLM Advantages:**
- 📚 Built-in vector database for document RAG
- 🗂️ Workspace organization (like Notion)
- 🤖 Visual AI agent workflows
- 🎨 Better MCP server management UI
- 🔄 Can use LM Studio as the model backend!

**Recommended:** Use **LM Studio** to host models + **AnythingLLM** for document workflows = Best of both worlds!

## Dependencies
- Node.js 18+
- Internet connectivity (downloads managed Chromium/Firefox/WebKit for Playwright; Chromium for Puppeteer unless you point to Chrome/Edge)

## Troubleshooting

### Browser Download Issues
Enterprise networks may block browser downloads:
- **Puppeteer**: Set `PUPPETEER_EXECUTABLE_PATH` environment variable to installed Chrome/Edge path
- **Playwright**: Set `PLAYWRIGHT_CHANNEL=msedge` or use `executablePath` in config

### Claude Can't Launch Servers
Ensure `%APPDATA%\Claude\claude_desktop_config.json` has:
- Correct absolute path to Node.js executable (`node.exe`)
- Correct absolute paths to local server files
- Valid API keys in environment variables

### API Keys Not Working
- Verify keys are correctly added to `.env` file or system environment variables
- Check for extra spaces or quotes around keys
- Restart Claude Desktop after updating environment variables

### NPM Installation Fails
If global installation fails:
```powershell
# Clear npm cache
npm cache clean --force

# Try installing with elevated permissions (Run PowerShell as Administrator)
npm install -g @modelcontextprotocol/server-filesystem
```

### Server Not Appearing in Claude
1. Check Claude Desktop logs: `%APPDATA%\Claude\logs\`
2. Verify server is in config file
3. Ensure Node.js is in system PATH
4. Try restarting Claude Desktop (completely quit and reopen)

### Finding Your Configuration
- **Claude Config**: `C:\Users\<YourUsername>\AppData\Roaming\Claude\claude_desktop_config.json`
- **Node.js Path**: Run `Get-Command node` in PowerShell
- **Installed Browsers**: `%LOCALAPPDATA%\ms-playwright\` (Playwright) or project's `.local-chromium\` (Puppeteer)

## Architecture

### Local Servers (Node.js Process)
- **mcp-puppeteer** and **mcp-playwright** run as separate Node.js processes
- Claude Desktop launches them using the `node.exe` path specified in config
- They communicate via stdio (standard input/output)

### NPM Global Servers
- Installed globally via `npm install -g`
- Launched by Claude Desktop using `npx -y <package-name>`
- Also communicate via stdio

### API Key Management
- Keys can be stored in `.env` file (for development)
- Or set as system environment variables (for production)
- Referenced in Claude config's `env` section per server

## 🔧 Configuration Management (NEW!)

**📘 [Quick Start Guide](QUICK_START_CONFIG.md)** - Essential commands and workflows

### Centralized Config System

Instead of manually editing configs for each platform, use our **centralized configuration system**:

```powershell
# Sync all platforms from master config
cd C:\DevWorkspace\MCP_1\scripts
.\sync-mcp-configs.ps1

# Sync specific platform only
.\sync-mcp-configs.ps1 -Platform claude
.\sync-mcp-configs.ps1 -Platform lmstudio
.\sync-mcp-configs.ps1 -Platform anythingllm

# Preview changes without applying
.\sync-mcp-configs.ps1 -DryRun
```

### Master Configuration File

**`config/master-mcp-config.json`** is the single source of truth for all MCP servers across all platforms.

**Benefits:**
- ✅ Edit once, sync everywhere
- ✅ Automatic API key substitution from `.env`
- ✅ Automatic backups before updates
- ✅ Platform-specific filtering (Claude, LM Studio, AnythingLLM)
- ✅ Version controlled and easily shareable

### How It Works

1. **Edit master config**: Update `config/master-mcp-config.json`
2. **Run sync script**: `.\scripts\sync-mcp-configs.ps1`
3. **Restart apps**: Close and reopen Claude/LM Studio/AnythingLLM
4. **Commit changes**: 
   ```powershell
   git add config\ examples\
   git commit -m "Update MCP server configurations"
   git push origin main
   ```

### Complete Documentation

📘 **[Configuration Management Guide](docs/CONFIG_MANAGEMENT.md)**

Learn how to:
- Add new MCP servers to all platforms at once
- Update existing server configurations
- Manage API keys securely
- Create automated sync workflows
- Troubleshoot config issues
- Set up config backups and version control

### Git Workflow for Updates

```powershell
# Pull latest configs
git pull origin main

# Sync to apply updates
.\scripts\sync-mcp-configs.ps1

# Make changes to master config
code config\master-mcp-config.json

# Sync all platforms
.\scripts\sync-mcp-configs.ps1

# Test and commit
git add config\ examples\ docs\
git commit -m "Update MCP configurations"
git push origin main
```

## Contributing
Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

## License
MIT License - see LICENSE file for details

## Resources
- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [Claude Desktop MCP Setup Guide](https://docs.anthropic.com/claude/docs/model-context-protocol)
- [Puppeteer Documentation](https://pptr.dev/)
- [Playwright Documentation](https://playwright.dev/)
