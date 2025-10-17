param(
  [string]$NodePath = (Get-Command node -ErrorAction SilentlyContinue).Source,
  [switch]$PlaywrightInstallBrowsers
)

if (-not $NodePath) { throw "Node not found on PATH. Install Node.js 18+ first." }

$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
Write-Host "Repo root: $root"

# Install local server dependencies
foreach ($srv in @("mcp-puppeteer","mcp-playwright")) {
  $dir = Join-Path $root "servers" | Join-Path -ChildPath $srv
  Write-Host "Installing: $dir" -ForegroundColor Cyan
  Push-Location $dir
  npm install
  if ($srv -eq "mcp-playwright" -and $PlaywrightInstallBrowsers.IsPresent) {
    npx --yes playwright install
  }
  Pop-Location
}

# Install global NPM-based MCP servers
Write-Host "`nInstalling NPM-based MCP servers globally..." -ForegroundColor Cyan
$globalServersScript = Join-Path $root "scripts\install-global-servers.ps1"
if (Test-Path $globalServersScript) {
  & $globalServersScript
} else {
  Write-Host "Warning: install-global-servers.ps1 not found, skipping global servers" -ForegroundColor Yellow
}

# Write Claude config example and optionally apply
$claudeDir = Join-Path $env:APPDATA 'Claude'
New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null

$cfg = @{ mcpServers = @{
  'mcp-puppeteer' = @{ command = $NodePath; args = @((Join-Path $root 'servers\mcp-puppeteer\src\server.js')) }
  'mcp-playwright' = @{ command = $NodePath; args = @((Join-Path $root 'servers\mcp-playwright\src\server.js')) }
} } | ConvertTo-Json -Depth 6

$example = Join-Path $root 'examples\claude_desktop_config.example.json'
New-Item -ItemType Directory -Force -Path (Split-Path $example -Parent) | Out-Null
$cfg | Out-File -FilePath $example -Encoding UTF8

$apply = Read-Host "Apply this config to %APPDATA%\\Claude\\claude_desktop_config.json now? (y/N)"
if ($apply -match '^(y|Y)') {
  $cfg | Out-File -FilePath (Join-Path $claudeDir 'claude_desktop_config.json') -Encoding UTF8
  Write-Host "Claude config updated. Restart Claude Desktop." -ForegroundColor Green
} else {
  Write-Host "Wrote example config to: $example" -ForegroundColor Yellow
}
