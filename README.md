# MCP_1

This repo bundles two MCP servers you can use with Claude Desktop on Windows:

- mcp-puppeteer — Chromium automation via Puppeteer
- mcp-playwright — Multi-browser automation via Playwright (Chromium/Firefox/WebKit)

## Contents
- servers/mcp-puppeteer
- servers/mcp-playwright
- scripts/setup-all.ps1 — one-shot setup on a new machine
- examples/claude_desktop_config.example.json — ready-to-copy Claude MCP config

## Quick Start (Windows)
```powershell
# 1) Clone and open
cd C:\DevWorkspace
git clone https://github.com/<you>/MCP_1.git
cd MCP_1

# 2) Run setup
Set-ExecutionPolicy Bypass -Scope Process -Force
./scripts/setup-all.ps1

# 3) Restart Claude Desktop and use tools:
#    mcp-puppeteer.navigate, mcp-puppeteer.screenshot, mcp-puppeteer.getContent
#    mcp-playwright.navigate, mcp-playwright.screenshot, mcp-playwright.getContent
```

## Dependencies
- Node.js 18+
- Internet connectivity (downloads managed Chromium/Firefox/WebKit for Playwright; Chromium for Puppeteer unless you point to Chrome/Edge)

## Troubleshooting
- Enterprise networks may block browser downloads:
  - Puppeteer: set PUPPETEER_EXECUTABLE_PATH to installed Chrome/Edge
  - Playwright: set PLAYWRIGHT_CHANNEL=msedge (default in setup) or use executablePath
- If Claude can’t launch servers, ensure %APPDATA%\Claude\claude_desktop_config.json has correct absolute Node path
