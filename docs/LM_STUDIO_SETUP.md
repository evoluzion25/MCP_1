# Using MCP Servers with LM Studio

Yes! You can absolutely use MCP servers with LM Studio locally to login to your online accounts and download PDFs or other data.

## 🎯 What You Can Do with MCP + LM Studio

### 1. **Browser Automation** (Already Installed)
Use **mcp-puppeteer** and **mcp-playwright** to:
- Navigate to websites and login with credentials
- Fill out forms and click buttons
- Download PDFs, documents, and files
- Extract data from web pages
- Take screenshots
- Run JavaScript on pages

### 2. **File Operations** (Available as Extension)
Use **filesystem** server to:
- Read and write files locally
- Create directories
- Move/rename files
- List directory contents

### 3. **Search & Data Retrieval**
Use **exa-search** and **brave-search** to:
- Find and download publicly available documents
- Search for specific information
- Get web content

## 📋 Setup Instructions for LM Studio

### Step 1: Locate LM Studio's MCP Config

LM Studio uses `mcp.json` instead of `claude_desktop_config.json`.

**Location:**
- **Windows**: `%APPDATA%\LM Studio\mcp.json`
- **Mac**: `~/Library/Application Support/LM Studio/mcp.json`
- **Linux**: `~/.config/lmstudio/mcp.json`

Or use the in-app editor:
1. Open LM Studio
2. Go to "Program" tab in right sidebar
3. Click `Install > Edit mcp.json`

### Step 2: Add Your MCP Servers

LM Studio uses Cursor's `mcp.json` format. Here's the configuration:

```json
{
  "mcpServers": {
    "mcp-puppeteer": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": [
        "C:\\DevWorkspace\\MCP_1\\servers\\mcp-puppeteer\\src\\server.js"
      ]
    },
    "mcp-playwright": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": [
        "C:\\DevWorkspace\\MCP_1\\servers\\mcp-playwright\\src\\server.js"
      ]
    },
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory"
      ]
    },
    "brave-search": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-brave-search"
      ],
      "env": {
        "BRAVE_API_KEY": "YOUR_BRAVE_API_KEY_HERE"
      }
    },
    "exa-search": {
      "command": "npx",
      "args": [
        "-y",
        "exa-mcp-server"
      ],
      "env": {
        "EXA_API_KEY": "YOUR_EXA_API_KEY_HERE"
      }
    }
  }
}
```

### Step 3: Update Paths and API Keys

1. **Node.js Path**: Replace `C:\\Program Files\\nodejs\\node.exe` with your Node.js path
   - Find it: `Get-Command node` (PowerShell) or `where node` (CMD)

2. **Server Paths**: Update `C:\\DevWorkspace\\MCP_1` to your actual installation path

3. **API Keys**: Replace placeholder API keys with your actual keys from `.env` file

## 🔐 Example: Login and Download PDFs

### Using Puppeteer/Playwright

Once connected to LM Studio, you can ask your local model:

```
"Please navigate to example.com, login with username 'myuser' and password 'mypass', 
then find all PDF links on the dashboard and download them to C:\Downloads"
```

The model will use these tools:
1. `navigate` - Go to the website
2. `fill` - Fill in login form
3. `click` - Submit the form
4. `getContent` - Extract PDF links
5. `evaluate` - Run JavaScript to trigger downloads

### Example Automation Script

You can also create a custom MCP server for your specific use case:

```python
# custom_downloader.py
from mcp.server.fastmcp import FastMCP
from playwright.async_api import async_playwright

mcp = FastMCP("document-downloader")

@mcp.tool()
async def download_account_pdfs(username: str, password: str, download_path: str) -> str:
    """Login to your account and download all PDFs"""
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()
        
        # Navigate and login
        await page.goto("https://your-account-site.com/login")
        await page.fill("#username", username)
        await page.fill("#password", password)
        await page.click("button[type='submit']")
        
        # Wait for dashboard
        await page.wait_for_selector(".pdf-links")
        
        # Get all PDF links
        pdf_links = await page.eval_on_selector_all(
            "a[href$='.pdf']", 
            "elements => elements.map(e => e.href)"
        )
        
        # Download each PDF
        for i, link in enumerate(pdf_links):
            async with page.expect_download() as download_info:
                await page.goto(link)
            download = await download_info.value
            await download.save_as(f"{download_path}/document_{i+1}.pdf")
        
        await browser.close()
        return f"Downloaded {len(pdf_links)} PDFs to {download_path}"

if __name__ == "__main__":
    mcp.run(transport='stdio')
```

Add to `mcp.json`:
```json
{
  "mcpServers": {
    "document-downloader": {
      "command": "uv",
      "args": [
        "--directory",
        "C:\\DevWorkspace\\custom-mcp",
        "run",
        "custom_downloader.py"
      ]
    }
  }
}
```

## 🔒 Security Best Practices

1. **Never hardcode credentials** - Use environment variables
2. **Store passwords securely** - Use system keyring or encrypted vault
3. **Use 2FA when possible** - Some sites may require manual 2FA step
4. **Verify SSL certificates** - Ensure secure connections
5. **Test in sandbox first** - Use test accounts before production

## 📦 Pre-built MCP Servers for Common Services

Consider these existing MCP servers:

- **GitHub MCP** - Access repositories, issues, PRs
- **Google Drive MCP** - Download files from Drive
- **Notion MCP** - Access Notion pages and databases
- **Slack MCP** - Read messages and download attachments
- **Email MCP servers** - Access Gmail, Outlook, etc.

Search for these at: https://github.com/topics/mcp-server

## ⚠️ Important Notes

### Differences: LM Studio vs Claude Desktop

| Feature | Claude Desktop | LM Studio |
|---------|---------------|-----------|
| Config File | `claude_desktop_config.json` | `mcp.json` |
| Format | Standard MCP JSON | Cursor's notation |
| Token Usage | Cloud-based limits | Local model context limits |
| Performance | Fast (cloud) | Depends on local hardware |
| Privacy | Data sent to Anthropic | 100% local |

### Watch Out For:
- **Context overflow** - Local models have smaller context windows
- **Token-heavy operations** - Some MCP servers designed for cloud models may use too many tokens
- **Response time** - Local models may be slower than Claude
- **Model capabilities** - Smaller models may struggle with complex automation

## 🚀 Recommended Models for MCP in LM Studio

For best results with MCP tools:

1. **DeepSeek R1** (8B or larger) - Great reasoning
2. **Qwen 2.5** (14B or larger) - Good tool use
3. **Llama 3.1** (8B or larger) - Solid function calling
4. **Mistral** (7B or larger) - Efficient tool use

Download in LM Studio: Search > Model name > Download

## 📚 Additional Resources

- [LM Studio MCP Docs](https://lmstudio.ai/docs/app/plugins/mcp)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Playwright Automation Guide](https://playwright.dev/)
- [MCP Server Examples](https://github.com/modelcontextprotocol)

---

## Need Help?

- **LM Studio Discord**: https://discord.gg/lmstudio
- **MCP GitHub Issues**: https://github.com/evoluzion25/MCP_1/issues
- **LM Studio Docs**: https://lmstudio.ai/docs
