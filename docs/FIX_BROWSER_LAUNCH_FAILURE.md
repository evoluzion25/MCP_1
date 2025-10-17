# Fix: Browser Failed to Launch - MCP Playwright/Puppeteer

## 🔴 Error: "Browser failed to initialize properly"

This error means the MCP server is working, but the browser process cannot start. Here are the solutions:

---

## 🔧 Quick Fix #1: Use Edge Instead of Chromium

Both Playwright and Puppeteer can use Microsoft Edge (already installed on Windows).

### For Playwright Server:

Edit your Playwright server config to use Edge:

**File:** `C:\DevWorkspace\MCP_1\servers\mcp-playwright\src\server.js`

Add this near the top where browsers are launched:

```javascript
// Use Edge if available (Windows)
const browserOptions = {
  channel: 'msedge',  // Use Microsoft Edge
  headless: true,     // Run without UI
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox',
    '--disable-dev-shm-usage'
  ]
};

// When launching browser, use:
const browser = await chromium.launch(browserOptions);
```

### For Puppeteer Server:

**File:** `C:\DevWorkspace\MCP_1\servers\mcp-puppeteer\src\server.js`

```javascript
const browser = await puppeteer.launch({
  channel: 'msedge',  // Use Microsoft Edge
  headless: true,
  args: [
    '--no-sandbox',
    '--disable-setuid-sandbox'
  ]
});
```

---

## 🔧 Quick Fix #2: Install Missing Browsers

### Install Puppeteer's Chromium:

```powershell
cd C:\DevWorkspace\MCP_1\servers\mcp-puppeteer
npm install
node node_modules/puppeteer/install.mjs
```

### Reinstall Playwright Browsers:

```powershell
cd C:\DevWorkspace\MCP_1\servers\mcp-playwright
npx playwright install chromium
npx playwright install msedge
```

---

## 🔧 Quick Fix #3: Set Environment Variables

Tell the MCP servers where to find browsers:

### Option A: System Environment Variables

```powershell
# For Playwright - use Edge
[System.Environment]::SetEnvironmentVariable("PLAYWRIGHT_CHANNEL", "msedge", "User")

# For Puppeteer - use Edge
[System.Environment]::SetEnvironmentVariable("PUPPETEER_EXECUTABLE_PATH", "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", "User")

# Restart LM Studio after setting these
```

### Option B: Add to MCP Config

Update your `lm_studio_mcp.json`:

```json
{
  "mcpServers": {
    "mcp-playwright": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": [
        "C:\\DevWorkspace\\MCP_1\\servers\\mcp-playwright\\src\\server.js"
      ],
      "env": {
        "PLAYWRIGHT_CHANNEL": "msedge"
      }
    },
    "mcp-puppeteer": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": [
        "C:\\DevWorkspace\\MCP_1\\servers\\mcp-puppeteer\\src\\server.js"
      ],
      "env": {
        "PUPPETEER_EXECUTABLE_PATH": "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
      }
    }
  }
}
```

---

## 🔧 Quick Fix #4: Use Headless Mode Explicitly

Some systems need explicit headless configuration:

```json
{
  "mcpServers": {
    "mcp-playwright": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": [
        "C:\\DevWorkspace\\MCP_1\\servers\\mcp-playwright\\src\\server.js"
      ],
      "env": {
        "PLAYWRIGHT_HEADLESS": "true",
        "PLAYWRIGHT_CHANNEL": "msedge"
      }
    }
  }
}
```

---

## 🔍 Diagnose the Specific Issue

### Step 1: Check Playwright Browsers

```powershell
cd C:\DevWorkspace\MCP_1\servers\mcp-playwright
npx playwright install --dry-run
```

**Expected output:**
```
✅ chromium is installed
✅ firefox is installed  
✅ webkit is installed
```

**If missing:**
```
❌ chromium is not installed
```

Run: `npx playwright install chromium`

### Step 2: Test Browser Launch Manually

```powershell
cd C:\DevWorkspace\MCP_1\servers\mcp-playwright

# Test Playwright
node -e "const { chromium } = require('playwright'); (async () => { const browser = await chromium.launch({ channel: 'msedge' }); console.log('Browser launched!'); await browser.close(); })()"
```

**If this works**, the issue is in the MCP server configuration.
**If this fails**, browsers aren't installed correctly.

### Step 3: Check Edge Path

```powershell
Test-Path "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
```

Should return `True`.

If not, find Edge:
```powershell
Get-Command msedge
```

---

## 🎯 Recommended Solution (Easiest)

### Update your `lm_studio_mcp.json` with Edge configuration:

```json
{
  "mcpServers": {
    "mcp-playwright": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": [
        "C:\\DevWorkspace\\MCP_1\\servers\\mcp-playwright\\src\\server.js"
      ],
      "env": {
        "PLAYWRIGHT_CHANNEL": "msedge",
        "PLAYWRIGHT_HEADLESS": "true"
      }
    },
    "mcp-puppeteer": {
      "command": "C:\\Program Files\\nodejs\\node.exe",
      "args": [
        "C:\\DevWorkspace\\MCP_1\\servers\\mcp-puppeteer\\src\\server.js"
      ],
      "env": {
        "PUPPETEER_EXECUTABLE_PATH": "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "BSAjKboJpJrVKmf8AMV87rCYyo3rowy"
      }
    },
    "exa-search": {
      "command": "npx",
      "args": ["-y", "exa-mcp-server"],
      "env": {
        "EXA_API_KEY": "296048a9-6539-4352-957b-3370ed1b3fc2"
      }
    },
    "clickup": {
      "command": "npx",
      "args": ["-y", "@taazkareem/clickup-mcp-server"],
      "env": {
        "CLICKUP_API_KEY": "pk_4234856_T5NJ7PUFZMPGN3KYMDSQIDX3XAO85O23",
        "CLICKUP_TEAM_ID": "2218645"
      }
    }
  }
}
```

**Then restart LM Studio.**

---

## 🔄 Alternative: Reinstall Everything

If nothing else works:

```powershell
# Go to each server directory and reinstall
cd C:\DevWorkspace\MCP_1\servers\mcp-playwright
npm install
npx playwright install chromium msedge

cd C:\DevWorkspace\MCP_1\servers\mcp-puppeteer
npm install
```

---

## 💡 Why This Happens

### Common Causes:

1. **Downloaded browsers were deleted** - Playwright browsers in `%LOCALAPPDATA%\ms-playwright` got removed
2. **Permissions issue** - Browser can't execute due to antivirus/permissions
3. **Wrong browser path** - MCP server looking in wrong location
4. **Headless mode issue** - Some systems require explicit headless configuration
5. **Missing dependencies** - Browser needs specific DLLs/libraries

### Why Edge Works Better:

- ✅ Already installed on Windows
- ✅ Always in a known location
- ✅ No separate download needed
- ✅ More reliable on corporate/locked-down systems
- ✅ Same Chromium engine as Chrome

---

## 🧪 Test After Fix

After applying the fix, test with this simple command:

```
Test the playwright server:
1. Navigate to google.com
2. Take a screenshot
3. Show me the result
```

**Expected:** Screenshot of Google homepage ✅

---

## 🚨 If Still Not Working

### Check LM Studio Logs:

Look for specific error like:
```
Error: Failed to launch browser!
Error: ENOENT: no such file or directory
Error: Browser process exited with code 1
```

### Try Each Browser Type:

1. **Edge (msedge)** - Most reliable on Windows
2. **Chrome** - If you have it installed
3. **Chromium** - Downloaded by Playwright
4. **Firefox** - Alternative browser

### Nuclear Option - Use Chrome:

If you have Chrome installed:

```json
"env": {
  "PUPPETEER_EXECUTABLE_PATH": "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
}
```

---

## 📋 Checklist

- [ ] Updated mcp.json with Edge configuration
- [ ] Restarted LM Studio completely
- [ ] Verified Edge is installed (`Test-Path` returns True)
- [ ] Tested browser launch manually with Node.js
- [ ] Checked LM Studio logs for errors
- [ ] Tried with headless mode explicitly set
- [ ] Reinstalled Playwright browsers if needed

---

## 🎯 Most Likely Solution

**Your issue is probably:** Playwright looking for browsers in the wrong place or using the wrong browser.

**Quick fix:** Add `"PLAYWRIGHT_CHANNEL": "msedge"` to your config and restart LM Studio.

This tells Playwright to use Microsoft Edge instead of trying to find its downloaded Chromium, which is more reliable on Windows systems.
