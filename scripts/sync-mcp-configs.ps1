# ============================================================================
# MCP Configuration Sync Script
# ============================================================================
# Synchronizes MCP server configurations across Claude Desktop, LM Studio,
# and AnythingLLM from the master configuration file.
#
# Usage:
#   .\sync-mcp-configs.ps1              # Sync all platforms
#   .\sync-mcp-configs.ps1 -Platform claude    # Sync only Claude
#   .\sync-mcp-configs.ps1 -DryRun      # Preview changes without applying
#
# Author: DevWorkspace MCP_1 Project
# Version: 1.0.0
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "claude", "lmstudio", "anythingllm")]
    [string]$Platform = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Backup = $true
)

# Configuration paths
$MasterConfigPath = "C:\DevWorkspace\MCP_1\config\master-mcp-config.json"
$EnvFilePath = "C:\DevWorkspace\.env"

$ClaudeConfigPath = "$env:APPDATA\Claude\claude_desktop_config.json"
$LMStudioConfigPath = "$env:USERPROFILE\.lmstudio\mcp.json"
$AnythingLLMConfigPath = "$env:APPDATA\anythingllm\plugins\anythingllm_mcp_servers.json"

# Alternative AnythingLLM paths to check
$AnythingLLMAlternatives = @(
    "$env:LOCALAPPDATA\anythingllm-desktop\storage\plugins\anythingllm_mcp_servers.json",
    "$env:APPDATA\anythingllm-desktop\storage\plugins\anythingllm_mcp_servers.json",
    "$env:USERPROFILE\.anythingllm\plugins\anythingllm_mcp_servers.json"
)

# ============================================================================
# Helper Functions
# ============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Load-EnvFile {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        Write-ColorOutput "[WARNING] .env file not found at $Path" "Yellow"
        return @{}
    }
    
    $envVars = @{}
    Get-Content $Path | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $envVars[$key] = $value
        }
    }
    
    return $envVars
}

function Replace-EnvVariables {
    param(
        [hashtable]$Config,
        [hashtable]$EnvVars
    )
    
    $json = $Config | ConvertTo-Json -Depth 10
    
    foreach ($key in $EnvVars.Keys) {
        $json = $json -replace "\`${$key}", $EnvVars[$key]
    }
    
    return $json | ConvertFrom-Json
}

function Backup-ConfigFile {
    param([string]$Path)
    
    if (Test-Path $Path) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "$Path.backup_$timestamp"
        Copy-Item $Path $backupPath
        Write-ColorOutput "[BACKUP] Backed up: $backupPath" "Green"
        return $backupPath
    }
    return $null
}

function Get-AnythingLLMConfigPath {
    # Try to find the actual AnythingLLM config path
    foreach ($path in $AnythingLLMAlternatives) {
        $dir = Split-Path $path
        if (Test-Path $dir) {
            return $path
        }
    }
    return $AnythingLLMConfigPath  # Return default if none found
}

# ============================================================================
# Configuration Generators
# ============================================================================

function Generate-ClaudeConfig {
    param(
        [object]$MasterConfig,
        [hashtable]$EnvVars
    )
    
    $config = @{
        mcpServers = @{}
    }
    
    foreach ($serverName in $MasterConfig.servers.PSObject.Properties.Name) {
        $server = $MasterConfig.servers.$serverName
        
        # Skip if not enabled for Claude
        if ($server.platforms -notcontains "claude") {
            continue
        }
        
        # Skip filesystem for Claude (built-in extension)
        if ($serverName -eq "filesystem") {
            continue
        }
        
        $serverConfig = @{
            command = $server.command
            args = $server.args
        }
        
        # Add environment variables if present
        if ($server.env) {
            $serverConfig.env = @{}
            foreach ($envKey in $server.env.PSObject.Properties.Name) {
                $envValue = $server.env.$envKey
                # Replace environment variable placeholders
                if ($envValue -match '\$\{(.+)\}') {
                    $varName = $matches[1]
                    if ($EnvVars.ContainsKey($varName)) {
                        $serverConfig.env[$envKey] = $EnvVars[$varName]
                    } else {
                        Write-ColorOutput "⚠️  Warning: Environment variable $varName not found in .env" "Yellow"
                        $serverConfig.env[$envKey] = $envValue
                    }
                } else {
                    $serverConfig.env[$envKey] = $envValue
                }
            }
        }
        
        $config.mcpServers[$serverName] = $serverConfig
    }
    
    return $config
}

function Generate-LMStudioConfig {
    param(
        [object]$MasterConfig,
        [hashtable]$EnvVars
    )
    
    $config = @{
        mcpServers = @{}
    }
    
    foreach ($serverName in $MasterConfig.servers.PSObject.Properties.Name) {
        $server = $MasterConfig.servers.$serverName
        
        # Skip if not enabled for LM Studio
        if ($server.platforms -notcontains "lmstudio") {
            continue
        }
        
        $serverConfig = @{
            command = $server.command
            args = $server.args
        }
        
        # Add environment variables if present
        if ($server.env) {
            $serverConfig.env = @{}
            foreach ($envKey in $server.env.PSObject.Properties.Name) {
                $envValue = $server.env.$envKey
                # Replace environment variable placeholders
                if ($envValue -match '\$\{(.+)\}') {
                    $varName = $matches[1]
                    if ($EnvVars.ContainsKey($varName)) {
                        $serverConfig.env[$envKey] = $EnvVars[$varName]
                    } else {
                        Write-ColorOutput "⚠️  Warning: Environment variable $varName not found in .env" "Yellow"
                        $serverConfig.env[$envKey] = $envValue
                    }
                } else {
                    $serverConfig.env[$envKey] = $envValue
                }
            }
        }
        
        $config.mcpServers[$serverName] = $serverConfig
    }
    
    return $config
}

function Generate-AnythingLLMConfig {
    param(
        [object]$MasterConfig,
        [hashtable]$EnvVars
    )
    
    $servers = @{}
    
    foreach ($serverName in $MasterConfig.servers.PSObject.Properties.Name) {
        $server = $MasterConfig.servers.$serverName
        
        # Skip if not enabled for AnythingLLM
        if ($server.platforms -notcontains "anythingllm") {
            continue
        }
        
        $serverConfig = @{
            command = $server.command
            args = $server.args
            autoStart = $true
        }
        
        # Add environment variables if present
        if ($server.env) {
            $serverConfig.env = @{}
            foreach ($envKey in $server.env.PSObject.Properties.Name) {
                $envValue = $server.env.$envKey
                # Replace environment variable placeholders
                if ($envValue -match '\$\{(.+)\}') {
                    $varName = $matches[1]
                    if ($EnvVars.ContainsKey($varName)) {
                        $serverConfig.env[$envKey] = $EnvVars[$varName]
                    } else {
                        Write-ColorOutput "⚠️  Warning: Environment variable $varName not found in .env" "Yellow"
                        $serverConfig.env[$envKey] = $envValue
                    }
                } else {
                    $serverConfig.env[$envKey] = $envValue
                }
            }
        }
        
        $servers[$serverName] = $serverConfig
    }
    
    return $servers
}

# ============================================================================
# Main Sync Logic
# ============================================================================

function Sync-Platform {
    param(
        [string]$PlatformName,
        [string]$ConfigPath,
        [object]$Config
    )
    
    Write-ColorOutput "`n[SYNC] Syncing $PlatformName..." "Cyan"
    
    if ($DryRun) {
        Write-ColorOutput "[DRY-RUN] Would write to: $ConfigPath" "Yellow"
        Write-ColorOutput ($Config | ConvertTo-Json -Depth 10) "Gray"
        return
    }
    
    # Create directory if it doesn't exist
    $dir = Split-Path $ConfigPath
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-ColorOutput "[SUCCESS] Created directory: $dir" "Green"
    }
    
    # Backup existing config
    if ($Backup -and (Test-Path $ConfigPath)) {
        Backup-ConfigFile $ConfigPath
    }
    
    # Write new config
    $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath -Encoding UTF8
    Write-ColorOutput "[SUCCESS] Updated: $ConfigPath" "Green"
}

# ============================================================================
# Main Script
# ============================================================================

Write-ColorOutput "===================================================================" "Cyan"
Write-ColorOutput "  MCP Configuration Sync Script" "Cyan"
Write-ColorOutput "===================================================================" "Cyan"

# Load master configuration
if (-not (Test-Path $MasterConfigPath)) {
    Write-ColorOutput "[ERROR] Master config not found at $MasterConfigPath" "Red"
    exit 1
}

Write-ColorOutput "[INFO] Loading master configuration..." "Cyan"
$masterConfig = Get-Content $MasterConfigPath -Raw | ConvertFrom-Json

# Load environment variables
Write-ColorOutput "[INFO] Loading environment variables..." "Cyan"
$envVars = Load-EnvFile $EnvFilePath

# Find AnythingLLM path
$AnythingLLMConfigPath = Get-AnythingLLMConfigPath

# Generate configurations
Write-ColorOutput "[INFO] Generating platform configurations..." "Cyan"

if ($Platform -eq "all" -or $Platform -eq "claude") {
    $claudeConfig = Generate-ClaudeConfig -MasterConfig $masterConfig -EnvVars $envVars
    Sync-Platform -PlatformName "Claude Desktop" -ConfigPath $ClaudeConfigPath -Config $claudeConfig
}

if ($Platform -eq "all" -or $Platform -eq "lmstudio") {
    $lmStudioConfig = Generate-LMStudioConfig -MasterConfig $masterConfig -EnvVars $envVars
    Sync-Platform -PlatformName "LM Studio" -ConfigPath $LMStudioConfigPath -Config $lmStudioConfig
}

if ($Platform -eq "all" -or $Platform -eq "anythingllm") {
    $anythingLLMConfig = Generate-AnythingLLMConfig -MasterConfig $masterConfig -EnvVars $envVars
    Sync-Platform -PlatformName "AnythingLLM" -ConfigPath $AnythingLLMConfigPath -Config $anythingLLMConfig
}

Write-ColorOutput "`n═══════════════════════════════════════════════════════════" "Green"
Write-ColorOutput "✅ Configuration sync complete!" "Green"
Write-ColorOutput "═══════════════════════════════════════════════════════════" "Green"

if (-not $DryRun) {
    Write-ColorOutput "`n⚠️  Important: Restart your applications for changes to take effect:" "Yellow"
    if ($Platform -eq "all" -or $Platform -eq "claude") {
        Write-ColorOutput "   • Close and restart Claude Desktop" "Yellow"
    }
    if ($Platform -eq "all" -or $Platform -eq "lmstudio") {
        Write-ColorOutput "   • Close and restart LM Studio" "Yellow"
    }
    if ($Platform -eq "all" -or $Platform -eq "anythingllm") {
        Write-ColorOutput "   • Close and restart AnythingLLM" "Yellow"
    }
}

