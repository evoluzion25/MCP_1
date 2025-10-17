# MCP Configuration Management

This document explains how to manage MCP server configurations across multiple platforms (Claude Desktop, LM Studio, and AnythingLLM) using the centralized configuration system.

## Overview

Instead of manually editing configuration files for each platform, we use a **master configuration file** that serves as the single source of truth. A PowerShell sync script automatically generates and updates platform-specific configs.

## Architecture

```
master-mcp-config.json (Source of Truth)
           ↓
   sync-mcp-configs.ps1 (Sync Script)
           ↓
    ┌──────┴──────┬──────────┐
    ↓             ↓          ↓
Claude Desktop  LM Studio  AnythingLLM
```

## Files

### Master Configuration
- **Location**: `C:\DevWorkspace\MCP_1\config\master-mcp-config.json`
- **Purpose**: Single source of truth for all MCP server configurations
- **Contains**: Server definitions, API key placeholders, platform mappings

### Sync Script
- **Location**: `C:\DevWorkspace\MCP_1\scripts\sync-mcp-configs.ps1`
- **Purpose**: Generates platform-specific configs from master config
- **Features**: Automatic backups, environment variable substitution, dry-run mode

### Environment Variables
- **Location**: `C:\DevWorkspace\.env`
- **Purpose**: Stores sensitive API keys securely
- **Backed up to**: Private GitHub repo `evoluzion25/dev-env-config`

## Usage

### Sync All Platforms

```powershell
cd C:\DevWorkspace\MCP_1\scripts
.\sync-mcp-configs.ps1
```

This will:
1. Read the master configuration
2. Load API keys from `.env` file
3. Generate configs for Claude, LM Studio, and AnythingLLM
4. Create backups of existing configs
5. Write new configurations

### Sync Specific Platform

```powershell
# Sync only Claude Desktop
.\sync-mcp-configs.ps1 -Platform claude

# Sync only LM Studio
.\sync-mcp-configs.ps1 -Platform lmstudio

# Sync only AnythingLLM
.\sync-mcp-configs.ps1 -Platform anythingllm
```

### Dry Run (Preview Changes)

```powershell
# Preview what would be changed without actually updating
.\sync-mcp-configs.ps1 -DryRun
```

### Skip Backups

```powershell
# Sync without creating backups
.\sync-mcp-configs.ps1 -Backup:$false
```

## Adding a New MCP Server

### Step 1: Update Master Config

Edit `C:\DevWorkspace\MCP_1\config\master-mcp-config.json`:

```json
{
  "servers": {
    "your-new-server": {
      "type": "npm",
      "command": "npx",
      "args": ["-y", "your-mcp-package"],
      "env": {
        "YOUR_API_KEY": "${YOUR_API_KEY}"
      },
      "description": "Description of your server",
      "platforms": ["claude", "lmstudio", "anythingllm"],
      "requiresApiKey": true
    }
  }
}
```

### Step 2: Add API Key (if needed)

Add to `C:\DevWorkspace\.env`:

```
YOUR_API_KEY=your-actual-api-key-here
```

### Step 3: Document API Key

Update the `apiKeys` section in master config:

```json
{
  "apiKeys": {
    "YOUR_API_KEY": {
      "description": "API key from https://service.com",
      "required": true,
      "servers": ["your-new-server"]
    }
  }
}
```

### Step 4: Run Sync Script

```powershell
.\sync-mcp-configs.ps1
```

### Step 5: Commit Changes

```powershell
cd C:\DevWorkspace\MCP_1
git add config\master-mcp-config.json
git commit -m "Add new MCP server: your-new-server"
git push origin main
```

## Updating Existing Servers

### Modify Server Configuration

1. Edit `config\master-mcp-config.json`
2. Run sync script: `.\sync-mcp-configs.ps1`
3. Restart applications
4. Commit and push changes

### Update API Keys

1. Edit `C:\DevWorkspace\.env`
2. Run sync script to propagate changes
3. Commit to private repo: `evoluzion25/dev-env-config`

## Platform-Specific Notes

### Claude Desktop
- **Config Location**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Note**: Filesystem server is built-in, not added to config
- **Restart**: Close Claude Desktop completely and reopen

### LM Studio
- **Config Location**: `%USERPROFILE%\.lmstudio\mcp.json`
- **Format**: Uses Cursor MCP format
- **Restart**: Use "Developer" → "Restart MCP Servers" or restart LM Studio

### AnythingLLM
- **Config Location**: `%APPDATA%\anythingllm\plugins\anythingllm_mcp_servers.json`
- **Alternative Paths** (auto-detected):
  - `%LOCALAPPDATA%\anythingllm-desktop\storage\plugins\anythingllm_mcp_servers.json`
  - `%APPDATA%\anythingllm-desktop\storage\plugins\anythingllm_mcp_servers.json`
- **Feature**: `autoStart: true` is automatically added for all servers
- **Restart**: Close and reopen AnythingLLM

## Git Workflow for Config Updates

### Daily Workflow

```powershell
# 1. Make changes to master config
code C:\DevWorkspace\MCP_1\config\master-mcp-config.json

# 2. Sync all platforms
.\sync-mcp-configs.ps1

# 3. Test with one platform
# (Restart Claude/LM Studio/AnythingLLM and verify)

# 4. Commit and push
cd C:\DevWorkspace\MCP_1
git add config\
git add examples\
git commit -m "Update MCP server configurations"
git push origin main
```

### Backup API Keys

```powershell
# Backup .env to private repo
cd C:\DevWorkspace
git add .env
git commit -m "Update API keys"
git push origin main
```

### Pull Latest Configs

```powershell
# On another machine or after changes
cd C:\DevWorkspace\MCP_1
git pull origin main

# Sync to apply updates
.\scripts\sync-mcp-configs.ps1
```

## Troubleshooting

### Script Errors

```powershell
# Run with verbose output
.\sync-mcp-configs.ps1 -Verbose

# Check PowerShell execution policy
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Missing API Keys

If you see warnings like "Environment variable X not found":

1. Check `C:\DevWorkspace\.env` has the key
2. Verify key name matches master config exactly
3. Run sync script again

### Config Not Applied

1. Verify file was written: Check timestamp
2. Restart application completely (don't just reload)
3. Check application logs for errors

### Backup Recovery

Backups are created in the same directory with format:
- `claude_desktop_config.json.backup_20251017_143022`

To restore:
```powershell
# Find latest backup
Get-ChildItem "$env:APPDATA\Claude\*.backup_*" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Copy back
Copy-Item "claude_desktop_config.json.backup_TIMESTAMP" "claude_desktop_config.json"
```

## Automation

### Add to PowerShell Profile

Add to your `Microsoft.PowerShell_profile.ps1`:

```powershell
function Sync-MCPConfigs {
    param([string]$Platform = "all")
    
    Push-Location C:\DevWorkspace\MCP_1\scripts
    .\sync-mcp-configs.ps1 -Platform $Platform
    Pop-Location
}

# Usage: Sync-MCPConfigs
# Usage: Sync-MCPConfigs -Platform claude
```

### Scheduled Task

Create a scheduled task to sync configs daily:

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\DevWorkspace\MCP_1\scripts\sync-mcp-configs.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 9am

Register-ScheduledTask -TaskName "MCP Config Sync" `
    -Action $action -Trigger $trigger -Description "Daily MCP config sync"
```

## Best Practices

1. **Always edit master config first** - Never edit platform configs directly
2. **Test after sync** - Always verify one platform before committing
3. **Keep backups** - Don't disable backup feature unless necessary
4. **Use dry-run** - Preview changes with `-DryRun` for major updates
5. **Document changes** - Use clear commit messages
6. **Protect API keys** - Never commit `.env` to public repos
7. **Version control** - Commit master config changes regularly
8. **Sync before pull** - Run sync after pulling latest changes

## Security Considerations

- **API Keys**: Stored in `.env`, never in config files
- **Private Backup**: `.env` backed up to private GitHub repo only
- **Placeholders**: Master config uses `${VAR_NAME}` placeholders
- **Substitution**: Sync script replaces placeholders with actual keys
- **Backups**: Contain real API keys, protect accordingly

## Quick Reference

| Action | Command |
|--------|---------|
| Sync all platforms | `.\sync-mcp-configs.ps1` |
| Sync Claude only | `.\sync-mcp-configs.ps1 -Platform claude` |
| Preview changes | `.\sync-mcp-configs.ps1 -DryRun` |
| Sync without backup | `.\sync-mcp-configs.ps1 -Backup:$false` |
| Add server | Edit master config → Run sync → Test → Commit |
| Update API key | Edit `.env` → Run sync → Restart apps |
| Restore backup | Copy `.backup_TIMESTAMP` file back |

## Support

For issues or questions:
- GitHub Issues: https://github.com/evoluzion25/MCP_1/issues
- Documentation: https://github.com/evoluzion25/MCP_1/docs
- Master Config: `config/master-mcp-config.json`
