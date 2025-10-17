@echo off
echo ========================================
echo Verify Windows Defender Optimization
echo ========================================
echo.
echo Checking exclusions (requires Administrator)...
echo.

powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -NoExit -Command \"Write-Host ''Windows Defender Exclusions Verification'' -ForegroundColor Cyan; Write-Host ''''====================================================='''' -ForegroundColor Cyan; Write-Host ''''; Write-Host ''Path Exclusions:'' -ForegroundColor Yellow; Get-MpPreference | Select-Object -ExpandProperty ExclusionPath; Write-Host ''''; Write-Host ''Process Exclusions:'' -ForegroundColor Yellow; Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess; Write-Host ''''; Write-Host ''Scan Schedule:'' -ForegroundColor Yellow; Get-MpPreference | Select-Object ScanScheduleDay, ScanScheduleTime, ScanParameters | Format-List; Write-Host ''''; Write-Host ''Weekly Full Scan Task:'' -ForegroundColor Yellow; try { Get-ScheduledTask -TaskName ''''Windows Defender Weekly Full Scan'''' | Select-Object TaskName, State, LastRunTime, NextRunTime | Format-List } catch { Write-Host ''''Task not found'''' -ForegroundColor Red }; Write-Host ''''; Write-Host ''Press any key to close...'' -ForegroundColor Yellow; $null = $Host.UI.RawUI.ReadKey(''''NoEcho,IncludeKeyDown'''')\"'"

echo.
echo Verification window opened.
pause
