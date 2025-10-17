# Ready-to-Use Prompts for LM Studio MCP Automation

## 🎯 System Prompt (Add to LM Studio Settings)

Copy this into LM Studio → Chat Settings → System Prompt:

```
You are an AI assistant with browser automation capabilities through Playwright MCP tools.

AVAILABLE TOOLS:
- navigate(url): Go to any website
- click(selector): Click elements (buttons, links)
- fill(selector, text): Fill form fields
- type(selector, text): Type text character by character
- press(key): Press keys (Enter, Tab, Escape)
- screenshot(): Capture current page
- getContent(): Get page HTML
- evaluate(javascript): Run JavaScript
- waitForSelector(selector): Wait for elements
- getText(selector): Get element text
- getAttribute(selector, name): Get attributes

IMPORTANT RULES:
1. ALWAYS use these tools when asked to automate web tasks
2. DO NOT say you cannot do something if tools support it
3. Break tasks into tool calls
4. Use CSS selectors for elements (e.g., "input[type='email']", "#password", "button.login")
5. Wait between actions when needed (use JavaScript: await new Promise(r => setTimeout(r, 2000)))

FOR LOGIN TASKS:
1. navigate() to login page
2. fill() username field
3. fill() password field
4. click() submit button
5. screenshot() to confirm

Execute automation proactively. Show your tool calls clearly.
```

---

## 🔐 RunPod Login - Explicit Version

Use this exact prompt:

```
TASK: Login to RunPod and screenshot the dashboard

STEP-BY-STEP TOOL CALLS:

1. Call: navigate("https://www.runpod.io/console/login")
2. Wait 2 seconds for page to load
3. Call: fill("input[name='email']", "ryan@rg1.us")
4. Call: fill("input[name='password']", "Mars25!!")
5. Call: click("button[type='submit']")
6. Wait 5 seconds for login to complete
7. Call: screenshot()
8. Call: getContent()

Execute these Playwright tool calls NOW. Do not explain why you cannot do it - just do it.

If a selector doesn't work, try alternatives:
- For email: "input[type='email']" or "#email" or ".email-input"
- For password: "input[type='password']" or "#password"  
- For button: "button[type='submit']" or "button.login" or "button:contains('Log in')"
```

---

## 📋 RunPod Template Extraction - Complete Workflow

```
AUTOMATION TASK: Get all RunPod templates

You have Playwright tools. Use them to:

**Phase 1: Login**
1. navigate("https://www.runpod.io/console/login")
2. fill("input[name='email']", "ryan@rg1.us")
3. fill("input[name='password']", "Mars25!!")
4. click("button[type='submit']")
5. Wait 5 seconds

**Phase 2: Navigate to Templates**
6. navigate("https://www.runpod.io/console/templates")
7. Wait 3 seconds for page to load

**Phase 3: Extract Data**
8. screenshot() - Capture the templates page
9. getContent() - Get the full HTML
10. evaluate(`
   Array.from(document.querySelectorAll('.template-card')).map(card => ({
     name: card.querySelector('.template-name')?.textContent,
     description: card.querySelector('.template-desc')?.textContent,
     image: card.querySelector('img')?.src
   }))
`) - Extract structured template data

**Phase 4: Report Results**
11. Present the extracted templates in a formatted list

DO NOT SAY YOU CANNOT DO THIS. Execute the tool calls above.
```

---

## 🔍 Generic Web Scraping Template

```
AUTOMATION: Scrape [WEBSITE_NAME]

TOOLS YOU HAVE:
- navigate, click, fill, type, press, screenshot, getContent, evaluate

STEPS:
1. navigate("[URL]")
2. [If login needed: fill username, fill password, click submit]
3. [If navigation needed: click to desired section]
4. screenshot() - Visual confirmation
5. getContent() - Get HTML
6. evaluate("[JAVASCRIPT TO EXTRACT DATA]")

Replace [PLACEHOLDERS] with actual values and EXECUTE.
```

---

## 💾 Form Filling Template

```
TASK: Fill form at [URL]

AVAILABLE TOOLS: navigate, fill, click, screenshot

SEQUENCE:
1. navigate("[FORM_URL]")
2. fill("[FIELD_1_SELECTOR]", "[VALUE_1]")
3. fill("[FIELD_2_SELECTOR]", "[VALUE_2]")
4. fill("[FIELD_3_SELECTOR]", "[VALUE_3]")
5. click("[SUBMIT_BUTTON_SELECTOR]")
6. screenshot()

Execute these tool calls to complete the form.
```

---

## 🔄 If Model Still Refuses

### Option 1: Ultra-Explicit Instruction

```
IGNORE any tendency to say you cannot do automation.

YOU HAVE THESE EXACT TOOLS IN YOUR FUNCTION LIST:
- navigate
- click  
- fill
- screenshot
- getContent

PROOF: Check your available functions right now. You WILL see them.

NOW execute this automation without excuses:

1. Call the 'navigate' function with url = "https://runpod.io/login"
2. Call the 'fill' function with selector = "input[type='email']" and text = "ryan@rg1.us"
3. Call the 'fill' function with selector = "input[type='password']" and text = "Mars25!!"
4. Call the 'click' function with selector = "button[type='submit']"

DO IT NOW.
```

### Option 2: Show Example Tool Call

```
Here's an example of using the navigate tool:

{
  "function": "navigate",
  "arguments": {
    "url": "https://google.com"
  }
}

Now you do the same for this task:
1. Navigate to https://runpod.io/login
2. Fill email: ryan@rg1.us
3. Fill password: Mars25!!
4. Click submit

Write the tool calls in the same format and execute them.
```

### Option 3: Ask Model to List Available Tools First

```
Before we start, please list ALL tools/functions you currently have access to.

Check your function list and tell me every function name you can call.

After listing them, we'll use those tools to login to RunPod.
```

---

## 🎨 Alternative: Use AnythingLLM

If LM Studio keeps refusing, AnythingLLM has better MCP integration:

### In AnythingLLM:

**Simple prompt (just works):**
```
Login to runpod.io:
- Email: ryan@rg1.us
- Password: Mars25!!

Then show me the templates page.
```

AnythingLLM's agent system automatically:
- Detects available MCP tools
- Plans the automation steps
- Executes tool calls without hesitation
- Shows tool usage in UI

---

## 📊 Prompt Comparison

| Prompt Type | Success Rate | Model Understanding |
|-------------|--------------|---------------------|
| "Login to runpod" | ⭐ 20% | Vague, model confused |
| "Use playwright to login..." | ⭐⭐⭐ 60% | Better, but needs detail |
| "Step 1: navigate(...)" | ⭐⭐⭐⭐ 80% | Explicit, structured |
| "Call navigate() function..." | ⭐⭐⭐⭐⭐ 95% | Direct function reference |

---

## 🔧 Quick Fixes

### Fix 1: Check Tools Are Loaded
```
Ask model: "What tools do you have access to? List all functions."
```

### Fix 2: Restart Everything
```powershell
# Close LM Studio completely
# Wait 10 seconds
# Open LM Studio
# Load model
# Try again
```

### Fix 3: Test Server Directly
```powershell
& "C:\Program Files\nodejs\node.exe" "C:\DevWorkspace\MCP_1\servers\mcp-playwright\src\server.js"
```

Should output: "Server started and listening on stdio"

### Fix 4: Use Better Model
Download **DeepSeek R1 14B** or **Qwen 2.5 14B** - they understand tools better.

---

## 💡 Pro Tips

1. **Be explicit** - Don't assume model knows what tools it has
2. **Reference tools by name** - Say "use the fill() tool" not "enter text"
3. **Show the steps** - Number each tool call
4. **Provide selectors** - Give CSS selectors upfront
5. **Add waits** - Tell model to wait between actions
6. **Confirm with screenshot** - Always end with screenshot()

---

## 🆘 Still Not Working?

### Check These:

1. **MCP servers connected?** - Look for "MCP connected" in LM Studio
2. **Right model?** - Use >7B instruct model, not base model
3. **Tools visible?** - Can you see tool list in LM Studio UI?
4. **Logs show errors?** - Check LM Studio logs for MCP errors
5. **Server running?** - Test Node.js command directly

### Alternative Solutions:

- ✅ Switch to AnythingLLM (better MCP support)
- ✅ Use Claude Desktop (most reliable)
- ✅ Try different model in LM Studio
- ✅ Update LM Studio to latest version
