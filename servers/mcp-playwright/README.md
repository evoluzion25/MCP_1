# mcp-playwright

Tools: navigate, screenshot, getContent

Install
```powershell
cd servers\mcp-playwright
npm install
npx playwright install # optional: download browsers now
```

Health check
```powershell
npm run health
```

Claude config snippet
```json
{
  "mcpServers": {
    "mcp-playwright": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": ["C:\\DevWorkspace\\MCP_1\\servers\\mcp-playwright\\src\\server.js"]
    }
  }
}
```

Notes
- On Windows, defaults to Edge channel for chromium. Override with PLAYWRIGHT_CHANNEL.
