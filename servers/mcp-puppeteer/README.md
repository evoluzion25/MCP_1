# mcp-puppeteer

Tools: navigate, screenshot, getContent

Install
```powershell
cd servers\mcp-puppeteer
npm install
```

Health check
```powershell
npm run health
```

Claude config snippet
```json
{
  "mcpServers": {
    "mcp-puppeteer": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": ["C:\\DevWorkspace\\MCP_1\\servers\\mcp-puppeteer\\src\\server.js"]
    }
  }
}
```

Notes
- Set PUPPETEER_EXECUTABLE_PATH to installed Chrome/Edge to skip Chromium download.
