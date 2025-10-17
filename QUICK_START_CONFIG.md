# MCP Configuration Management - Quick Start

## 🎯 What This System Does

**Problem**: Managing MCP servers across Claude Desktop, LM Studio, and AnythingLLM means editing 3 different config files manually.

**Solution**: Edit ONE master config file, run ONE sync script, and all platforms get updated automatically.

## 📁 Key Files

| File | Purpose |
|------|---------|
| `config/master-mcp-config.json` | **Single source of truth** - All MCP servers defined here |
| `scripts/sync-mcp-configs.ps1` | **Sync script** - Updates all platforms from master config |
| `C:\DevWorkspace\.env` | **API keys** - Stores sensitive keys securely |

## ⚡ Quick Commands

### Sync All Platforms
```powershell
cd C:\DevWorkspace\MCP_1\scripts
.\sync-mcp-configs.ps1
```

### Sync One Platform
```powershell
# Claude only
.\sync-mcp-configs.ps1 -Platform claude

# LM Studio only
.\sync-mcp-configs.ps1 -Platform lmstudio

# AnythingLLM only
.\sync-mcp-configs.ps1 -Platform anythingllm
```

### Preview Changes (Dry Run)
```powershell
# See what would change without applying
.\sync-mcp-configs.ps1 -DryRun
```

## 🔄 Typical Workflow

### Adding a New MCP Server

1. **Edit master config**: `config/master-mcp-config.json`
   ```json
   "your-new-server": {
     "type": "npm",
     "command": "npx",
     "args": ["-y", "your-package-name"],
     "description": "What it does",
     "platforms": ["claude", "lmstudio", "anythingllm"]
   }
   ```

2. **Add API key** (if needed): `C:\DevWorkspace\.env`
   ```
   YOUR_API_KEY=your-actual-key-here
   ```

3. **Run sync script**:
   ```powershell
   .\sync-mcp-configs.ps1
   ```

4. **Restart applications**: Close and reopen Claude/LM Studio/AnythingLLM

5. **Commit changes**:
   ```powershell
   cd C:\DevWorkspace\MCP_1
   git add config\ examples\
   git commit -m "Add new MCP server: your-server"
   git push origin main
   ```

### Updating API Keys

1. **Edit .env file**: `C:\DevWorkspace\.env`
   ```
   BRAVE_API_KEY=new-key-here
   ```

2. **Run sync script**:
   ```powershell
   .\sync-mcp-configs.ps1
   ```

3. **Restart applications**

4. **Backup .env** (optional):
   ```powershell
   cd C:\DevWorkspace
   git add .env
   git commit -m "Update API keys"
   git push origin main  # Only if using private repo!
   ```

### Pulling Updates from Git

```powershell
# Pull latest configs
cd C:\DevWorkspace\MCP_1
git pull origin main

# Apply to all platforms
.\scripts\sync-mcp-configs.ps1

# Restart apps
```

## 🛡️ What Gets Synced

### Claude Desktop
- ✅ Puppeteer (with Edge)
- ✅ Playwright (with Edge)
- ✅ Memory
- ✅ Sequential Thinking
- ✅ Brave Search
- ✅ Exa Search
- ✅ ClickUp
- ❌ Filesystem (built-in)

### LM Studio
- ✅ All servers including Filesystem

### AnythingLLM
- ✅ All servers including Filesystem
- ✅ Auto-adds `autoStart: true` for each server

## 📋 Configuration Locations

| Platform | Config Path |
|----------|-------------|
| **Claude Desktop** | `%APPDATA%\Claude\claude_desktop_config.json` |
| **LM Studio** | `%USERPROFILE%\.lmstudio\mcp.json` |
| **AnythingLLM** | `%APPDATA%\anythingllm-desktop\storage\plugins\anythingllm_mcp_servers.json` |

## 🔑 API Key Management

### Current API Keys (in `.env`)
- `BRAVE_API_KEY` - Brave Search API
- `EXA_API_KEY` - Exa Search API
- `CLICKUP_API_KEY` - ClickUp API token
- `CLICKUP_TEAM_ID` - ClickUp workspace ID

### How It Works
1. Master config uses placeholders: `"${BRAVE_API_KEY}"`
2. Sync script reads `.env` file
3. Script replaces placeholders with actual keys
4. Platform configs get real keys

## 🚨 Important Notes

### Always Edit Master Config First
❌ **DON'T** edit Claude/LM Studio/AnythingLLM configs directly
✅ **DO** edit `config/master-mcp-config.json` then sync

### Restart After Sync
The sync script updates config files, but apps need to restart to load them:
- **Claude Desktop**: Close completely and reopen
- **LM Studio**: Restart or use "Developer" → "Restart MCP Servers"
- **AnythingLLM**: Close and reopen

### Backups Are Automatic
Every sync creates a backup:
- Format: `config_name.backup_20251017_143022`
- Location: Same directory as config
- Restore: Just copy the backup file back

### Use Dry Run for Big Changes
```powershell
# Preview before applying
.\sync-mcp-configs.ps1 -DryRun

# Review the output, then apply
.\sync-mcp-configs.ps1
```

## 🎓 PowerShell Profile Integration

Add to your PowerShell profile for easy access:

```powershell
# Open profile
code $PROFILE

# Add this function
function Sync-MCPConfigs {
    param([string]$Platform = "all")
    Push-Location C:\DevWorkspace\MCP_1\scripts
    .\sync-mcp-configs.ps1 -Platform $Platform
    Pop-Location
}

# Usage anywhere:
# Sync-MCPConfigs
# Sync-MCPConfigs -Platform claude
```

## 📚 Full Documentation

For complete details, see:
- **[CONFIG_MANAGEMENT.md](../docs/CONFIG_MANAGEMENT.md)** - Complete guide
- **[LM_STUDIO_SETUP.md](../docs/LM_STUDIO_SETUP.md)** - LM Studio specific
- **[ANYTHINGLLM_VS_LMSTUDIO.md](../docs/ANYTHINGLLM_VS_LMSTUDIO.md)** - Platform comparison

## 🐛 Troubleshooting

### "Script cannot be loaded"
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### "Warning: Environment variable not found"
- Check `.env` file has the key
- Verify key name matches exactly
- Run sync again after adding key

### Changes not applied
1. Check config file timestamp (should be recent)
2. Restart application completely
3. Check application logs for errors

### Restore from backup
```powershell
# Find latest backup
Get-ChildItem "$env:APPDATA\Claude\*.backup_*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Restore it
Copy-Item "config_name.backup_TIMESTAMP" "config_name.json"
```

## ✅ Checklist: Adding a Server

- [ ] Update `config/master-mcp-config.json`
- [ ] Add API keys to `C:\DevWorkspace\.env` (if needed)
- [ ] Run `.\sync-mcp-configs.ps1`
- [ ] Verify output shows all platforms updated
- [ ] Restart Claude Desktop
- [ ] Restart LM Studio
- [ ] Restart AnythingLLM
- [ ] Test server is available in each app
- [ ] Commit changes to git
- [ ] Push to GitHub

## 🎉 Benefits

✅ **One source of truth** - No more keeping 3 configs in sync  
✅ **Git-friendly** - Easy version control and sharing  
✅ **Automatic backups** - Safe to experiment  
✅ **API key security** - Keys in `.env`, not in configs  
✅ **Platform flexibility** - Choose which platforms get each server  
✅ **Quick updates** - Pull from git, run sync, done  
✅ **Dry-run mode** - Preview before applying  

## 🔗 Quick Links

- **Master Config**: `C:\DevWorkspace\MCP_1\config\master-mcp-config.json`
- **Sync Script**: `C:\DevWorkspace\MCP_1\scripts\sync-mcp-configs.ps1`
- **API Keys**: `C:\DevWorkspace\.env`
- **GitHub Repo**: https://github.com/evoluzion25/MCP_1

---

**Need Help?** See [CONFIG_MANAGEMENT.md](../docs/CONFIG_MANAGEMENT.md) for complete documentation.
