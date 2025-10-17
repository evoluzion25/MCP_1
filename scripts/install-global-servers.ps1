param(
  [string]$NodePath = (Get-Command node -ErrorAction SilentlyContinue).Source
)

if (-not $NodePath) { throw "Node not found on PATH. Install Node.js 18+ first." }

Write-Host "Installing global NPM-based MCP servers..." -ForegroundColor Cyan

# Array of NPM packages to install globally
$globalPackages = @(
    "@modelcontextprotocol/server-filesystem",
    "@modelcontextprotocol/server-memory",
    "@modelcontextprotocol/server-brave-search",
    "@modelcontextprotocol/server-sequential-thinking",
    "exa-mcp-server",
    "@taazkareem/clickup-mcp-server"
)

foreach ($package in $globalPackages) {
    Write-Host "Installing: $package" -ForegroundColor Yellow
    npm install -g $package
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Successfully installed $package" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to install $package" -ForegroundColor Red
    }
}

Write-Host "`nAll global MCP servers installed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Update your .env file with API keys (see examples/.env.example)" -ForegroundColor White
Write-Host "2. Run setup-all.ps1 to install local servers" -ForegroundColor White
Write-Host "3. Update Claude Desktop config with your API keys" -ForegroundColor White
Write-Host "4. Restart Claude Desktop" -ForegroundColor White
