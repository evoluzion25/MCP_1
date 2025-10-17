# MCP Server Troubleshooting Guide for LM Studio

## Issue: Model Says It Can't Use Automation Tools

### Problem
Model responds with: "I cannot perform authentication" or "tools do not support form submission"

This means either:
1. MCP tools aren't fully loaded
2. Model doesn't understand available tools
3. System prompt needs improvement
4. Wrong model is being used

---

## Solution 1: Verify All Tools Are Available

### Check in LM Studio:

1. **Open Chat with your model loaded**
2. **Look for MCP Tools indicator** (usually in sidebar or settings)
3. **Check available tools** - You should see:

**From mcp-playwright (should have 15+ tools):**
- ✅ `navigate(url)` - Go to a URL
- ✅ `click(selector)` - Click elements
- ✅ `fill(selector, text)` - Fill forms
- ✅ `screenshot()` - Take screenshots
- ✅ `getContent()` - Extract page HTML
- ✅ `evaluate(script)` - Run JavaScript
- ✅ `waitForSelector(selector)` - Wait for element
- ✅ `type(selector, text)` - Type into fields
- ✅ `press(key)` - Press keyboard keys
- ✅ `hover(selector)` - Hover over elements
- ✅ `select(selector, value)` - Select dropdown options
- ✅ `getAttribute(selector, attribute)` - Get element attributes
- ✅ `getText(selector)` - Get element text
- ✅ `scrollTo(selector)` - Scroll to element
- ✅ `goBack()` - Browser back button
- ✅ `goForward()` - Browser forward button

**If you only see 3 tools (navigate, screenshot, getContent), the MCP server isn't fully loaded!**

---

## Solution 2: Use Better Prompts

### ❌ Vague Prompt (Won't Work):
```
"Login to runpod.io and get templates"
```

### ✅ Explicit Tool Instructions (Will Work):
```
I need you to use Playwright tools to automate this task:

1. Use the 'navigate' tool to go to https://runpod.io/login
2. Use the 'fill' tool to enter username: ryan@rg1.us
3. Use the 'fill' tool to enter password: Mars25!!
4. Use the 'click' tool to submit the login form
5. Wait for the dashboard to load
6. Use the 'navigate' tool to go to the templates page
7. Use the 'getContent' tool to extract the template list
8. Use the 'screenshot' tool to capture the page

Please execute these steps using the Playwright MCP tools available to you.
```

### ✅ Even Better - Reference Tools Directly:
```
You have access to Playwright automation tools. Use them to:

**Step 1:** Call navigate("https://runpod.io/login")
**Step 2:** Call fill("#email", "ryan@rg1.us")
**Step 3:** Call fill("#password", "Mars25!!")
**Step 4:** Call click("button[type='submit']")
**Step 5:** Wait 3 seconds for login to complete
**Step 6:** Call navigate("https://runpod.io/templates")
**Step 7:** Call screenshot() to capture the templates
**Step 8:** Call getContent() to extract the HTML

Execute these Playwright tool calls in sequence.
```

---

## Solution 3: Restart LM Studio & Reload MCP

Sometimes MCP servers need to be restarted:

### Steps:
1. **Close LM Studio completely**
2. **Check MCP servers are configured** in `mcp.json`
3. **Restart LM Studio**
4. **Wait 10-15 seconds** for MCP servers to initialize
5. **Check logs** for MCP server connection

### Check MCP Connection:

Look for these messages in LM Studio logs:
```
✅ MCP server 'mcp-playwright' connected
✅ Tools loaded: navigate, click, fill, screenshot, ...
```

If you see:
```
❌ MCP server 'mcp-playwright' failed to start
❌ Error: spawn ENOENT
```

Then the Node.js path or server path is wrong in mcp.json.

---

## Solution 4: Test MCP Server Directly

Let's verify your Playwright server works:

### Open PowerShell and run:
```powershell
# Test if Node.js is accessible
& "C:\Program Files\nodejs\node.exe" --version

# Test if Playwright server can start
& "C:\Program Files\nodejs\node.exe" "C:\DevWorkspace\MCP_1\servers\mcp-playwright\src\server.js"
```

**Expected output:**
```
Server started and listening on stdio
```

If you get an error, the server path is wrong or dependencies aren't installed.

---

## Solution 5: Use the Right Model

Some models are better at understanding tools:

### ✅ Best Models for MCP Tool Use:

1. **DeepSeek R1 14B** - Best overall
2. **Qwen 2.5 14B** - Best function calling
3. **Hermes 3 Llama 3.1** - Good tool understanding
4. **Command R+ (35B)** - Excellent for tools

### ❌ Models That Struggle:

1. **Small models (<7B)** - May not understand tools well
2. **Base models (not instruct)** - Not trained for tool use
3. **OpenAI via API** - Blocks automation requests
4. **Old models** - Pre-2024 models lack tool training

---

## Solution 6: Add System Prompt

In LM Studio, add this system prompt:

```
You are an AI assistant with access to browser automation tools via the Model Context Protocol (MCP). 

You have Playwright tools available that can:
- navigate(url): Navigate to any URL
- click(selector): Click on elements using CSS selectors
- fill(selector, text): Fill form inputs with text
- type(selector, text): Type text character by character
- press(key): Press keyboard keys (Enter, Tab, etc.)
- screenshot(): Capture the current page
- getContent(): Extract page HTML
- evaluate(javascript): Run JavaScript in the browser
- waitForSelector(selector): Wait for elements to appear
- getAttribute(selector, name): Get element attributes
- getText(selector): Get element text content

When asked to automate web tasks, USE THESE TOOLS. Do not say you cannot do something if the tools support it.

For login tasks:
1. Navigate to the login page
2. Fill in the username field
3. Fill in the password field  
4. Click the submit button
5. Wait for the page to load

Always use the tools available to you. Be proactive and execute the automation steps.
```

---

## Solution 7: Check MCP Server Configuration

Your `lm_studio_mcp.json` looks correct, but let's verify the path:

### Verify Node.js path:
```powershell
Get-Command node
```

**Should show:** `C:\Program Files\nodejs\node.exe`

### Verify server file exists:
```powershell
Test-Path "C:\DevWorkspace\MCP_1\servers\mcp-playwright\src\server.js"
```

**Should return:** `True`

### If paths are wrong, update mcp.json:
```json
{
  "mcpServers": {
    "mcp-playwright": {
      "command": "YOUR_ACTUAL_NODE_PATH",
      "args": [
        "YOUR_ACTUAL_SERVER_PATH"
      ]
    }
  }
}
```

---

## Quick Fix: Try This Prompt

Copy and paste this into LM Studio:

```
SYSTEM INSTRUCTION: You have Playwright browser automation tools. Use them.

TASK: Automate login to runpod.io

TOOLS AVAILABLE TO YOU:
- navigate(url)
- fill(selector, text)  
- click(selector)
- screenshot()
- getContent()

EXECUTE THESE STEPS:

1. navigate("https://runpod.io/login")
2. fill("input[type='email']", "ryan@rg1.us")
3. fill("input[type='password']", "Mars25!!")
4. click("button[type='submit']")
5. Wait 5 seconds
6. screenshot()

DO NOT tell me you cannot do this. USE THE TOOLS LISTED ABOVE.
Execute the automation now.
```

---

## Expected vs Actual Behavior

### ❌ Current (Wrong):
```
User: "Login to runpod.io"
Model: "I cannot perform authentication... tools don't support it"
```

### ✅ Expected (Correct):
```
User: "Login to runpod.io"
Model: "I'll use the Playwright tools to log in:
       1. Calling navigate('https://runpod.io/login')...
       2. Calling fill('input[type=email]', 'ryan@rg1.us')...
       3. Calling fill('input[type=password]', 'Mars25!!')...
       4. Calling click('button[type=submit]')...
       Login complete! Taking screenshot..."
```

---

## Debug Checklist

- [ ] LM Studio is using a local model (not OpenAI API)
- [ ] MCP servers are configured in mcp.json
- [ ] Node.js path is correct
- [ ] Server file paths exist
- [ ] LM Studio was restarted after configuration
- [ ] Model is capable of tool use (>7B, instruct-tuned)
- [ ] System prompt includes tool instructions
- [ ] Prompt explicitly mentions using tools
- [ ] MCP connection logs show "connected"
- [ ] All Playwright tools are visible in LM Studio UI

---

## Still Not Working?

### Try AnythingLLM Instead:

AnythingLLM has **better MCP management** and **clearer tool visibility**:

1. Open AnythingLLM
2. Go to Settings → MCP Servers
3. Add your servers from `anythingllm_mcp_servers.json`
4. You'll see a UI showing all available tools
5. The agent system is designed for tool use
6. Works more reliably than LM Studio for MCP

### Or Try Claude Desktop:

Claude Desktop has the **most reliable MCP support**:
- Tools always load correctly
- Claude understands automation naturally
- No prompt engineering needed
- Just works™

---

## Need More Help?

1. **Check LM Studio logs** - Look for MCP connection errors
2. **Test server manually** - Run the Node.js command directly
3. **Try a different model** - Some models are better at tools
4. **Use AnythingLLM** - Better MCP integration
5. **Report issue** - Share error messages for specific help
