@echo off
echo ========================================
echo Windows Defender Optimization
echo ========================================
echo.
echo This will optimize Windows Defender for development work.
echo You will be prompted for Administrator permissions.
echo.
pause

powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -NoExit -Command \"cd C:\DevWorkspace\MCP_1\scripts; Write-Host ''Running Windows Defender Optimization...'' -ForegroundColor Cyan; .\optimize-defender.ps1 -ApplyDev; Write-Host ''''; Write-Host ''Press any key to close this window...'' -ForegroundColor Yellow; $null = $Host.UI.RawUI.ReadKey(''NoEcho,IncludeKeyDown'')\"'"

echo.
echo Administrator window opened. Follow the prompts in the new window.
pause
