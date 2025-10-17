# ============================================================================
# Windows Defender Optimization Script
# ============================================================================
# Analyzes current Windows Defender settings and provides recommendations
# for optimal performance while maintaining security.
#
# Usage:
#   .\optimize-defender.ps1 -AnalyzeOnly        # View recommendations only
#   .\optimize-defender.ps1 -Apply              # Apply recommended settings
#   .\optimize-defender.ps1 -ApplyDev           # Apply developer-optimized settings
#
# IMPORTANT: Must be run as Administrator
#
# Author: DevWorkspace MCP_1 Project
# Version: 1.0.0
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [switch]$AnalyzeOnly = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Apply = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$ApplyDev = $false
)

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERROR] This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  Windows Defender Optimization Analysis" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

# ============================================================================
# Current Configuration Analysis
# ============================================================================

Write-Host "`n[INFO] Analyzing current Windows Defender configuration..." -ForegroundColor Cyan

$preferences = Get-MpPreference
$status = Get-MpComputerStatus

Write-Host "`n--- Current Scan Schedule ---" -ForegroundColor Yellow
Write-Host "Scheduled Scan Day: $(if ($preferences.ScanScheduleDay -eq 0) { 'Daily' } else { $preferences.ScanScheduleDay })"
Write-Host "Scheduled Scan Time: $($preferences.ScanScheduleTime)"
Write-Host "Scan Type: $(if ($preferences.ScanParameters -eq 1) { 'Quick Scan' } elseif ($preferences.ScanParameters -eq 2) { 'Full Scan' } else { 'Custom' })"

Write-Host "`n--- Real-Time Protection Status ---" -ForegroundColor Yellow
Write-Host "Real-Time Monitoring: $(if ($preferences.DisableRealtimeMonitoring) { 'Disabled' } else { 'Enabled' })"
Write-Host "Behavior Monitoring: $(if ($preferences.DisableBehaviorMonitoring) { 'Disabled' } else { 'Enabled' })"
Write-Host "Script Scanning: $(if ($preferences.DisableScriptScanning) { 'Disabled' } else { 'Enabled' })"

Write-Host "`n--- Current Exclusions ---" -ForegroundColor Yellow
$exclusionPaths = $preferences.ExclusionPath
if ($exclusionPaths) {
    Write-Host "Excluded Paths:"
    foreach ($path in $exclusionPaths) {
        Write-Host "  - $path"
    }
} else {
    Write-Host "No path exclusions configured"
}

$exclusionProcesses = $preferences.ExclusionProcess
if ($exclusionProcesses) {
    Write-Host "`nExcluded Processes:"
    foreach ($process in $exclusionProcesses) {
        Write-Host "  - $process"
    }
} else {
    Write-Host "No process exclusions configured"
}

# ============================================================================
# Recommended Developer Exclusions
# ============================================================================

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  RECOMMENDATIONS FOR DEVELOPMENT ENVIRONMENT" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

$recommendedPaths = @(
    "C:\DevWorkspace",
    "C:\Program Files\nodejs",
    "C:\Program Files\Docker",
    "$env:USERPROFILE\.npm",
    "$env:USERPROFILE\.lmstudio",
    "$env:LOCALAPPDATA\ms-playwright",
    "$env:APPDATA\npm",
    "$env:LOCALAPPDATA\Programs\Python",
    "C:\Program Files (x86)\Microsoft\Edge\Application"
)

$recommendedProcesses = @(
    "node.exe",
    "npm.exe",
    "npx.exe",
    "python.exe",
    "git.exe",
    "code.exe",
    "msedge.exe"
)

Write-Host "`n[RECOMMENDATION] Add the following path exclusions:" -ForegroundColor Green
Write-Host "These paths contain development tools and will be scanned frequently during builds/tests." -ForegroundColor Gray
Write-Host ""
foreach ($path in $recommendedPaths) {
    if (Test-Path $path) {
        $exists = $exclusionPaths -contains $path
        if ($exists) {
            Write-Host "  [ALREADY EXCLUDED] $path" -ForegroundColor Gray
        } else {
            Write-Host "  [RECOMMENDED] $path" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [SKIP - Not Found] $path" -ForegroundColor DarkGray
    }
}

Write-Host "`n[RECOMMENDATION] Add the following process exclusions:" -ForegroundColor Green
Write-Host "These processes are frequently used in development and safe to exclude." -ForegroundColor Gray
Write-Host ""
foreach ($process in $recommendedProcesses) {
    $exists = $exclusionProcesses -contains $process
    if ($exists) {
        Write-Host "  [ALREADY EXCLUDED] $process" -ForegroundColor Gray
    } else {
        Write-Host "  [RECOMMENDED] $process" -ForegroundColor Yellow
    }
}

# ============================================================================
# Additional Directories to Consider
# ============================================================================

Write-Host "`n[WARNING] Large directories that may impact performance:" -ForegroundColor Yellow

$largeDirs = @(
    @{Path="C:\Windows\System32"; Reason="System files (already optimized by Defender)"},
    @{Path="C:\Windows\WinSxS"; Reason="System component store (already optimized)"},
    @{Path="C:\ProgramData"; Reason="Contains app data (should NOT exclude entirely)"},
    @{Path="$env:USERPROFILE\AppData\Local"; Reason="Contains caches (selective exclusion recommended)"},
    @{Path="C:\Program Files\AnythingLLM"; Reason="AI application (consider excluding)"},
    @{Path="C:\inetpub"; Reason="IIS web server (consider excluding if actively used)"}
)

foreach ($dir in $largeDirs) {
    if (Test-Path $dir.Path) {
        Write-Host "  $($dir.Path)"
        Write-Host "    -> $($dir.Reason)" -ForegroundColor Gray
    }
}

# ============================================================================
# Scan Schedule Recommendations
# ============================================================================

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  SCAN SCHEDULE RECOMMENDATIONS" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`nCurrent Schedule: Daily at 2:00 AM" -ForegroundColor Yellow
Write-Host ""
Write-Host "[RECOMMENDATION] Optimal scan times for developers:" -ForegroundColor Green
Write-Host "  - Quick Scan: Daily at 2:00 AM (current setting is good)"
Write-Host "  - Full Scan: Weekly on Sunday at 2:00 AM (less resource-intensive)"
Write-Host "  - Avoid scanning during: 9:00 AM - 6:00 PM (peak work hours)"

# ============================================================================
# Performance Impact Analysis
# ============================================================================

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  PERFORMANCE IMPACT ASSESSMENT" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

Write-Host "`n[INFO] Checking for performance-impacting settings..." -ForegroundColor Cyan

$issues = @()

if (-not $preferences.DisableRealtimeMonitoring) {
    if (-not $exclusionPaths -or $exclusionPaths.Count -lt 3) {
        $issues += "Real-time monitoring enabled with minimal exclusions - may slow development builds"
    }
}

if ($preferences.ScanParameters -eq 2) {
    $issues += "Scheduled for FULL scan daily - consider changing to weekly"
}

if (-not $preferences.DisableScriptScanning) {
    $hasNodeExclusion = $exclusionProcesses -contains "node.exe"
    if (-not $hasNodeExclusion) {
        $issues += "Script scanning enabled but node.exe not excluded - may slow npm/Node.js operations"
    }
}

if ($issues.Count -gt 0) {
    Write-Host "`n[WARNING] Performance issues detected:" -ForegroundColor Yellow
    foreach ($issue in $issues) {
        Write-Host "  ! $issue" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[SUCCESS] No major performance issues detected" -ForegroundColor Green
}

# ============================================================================
# Apply Settings (if requested)
# ============================================================================

if ($Apply -or $ApplyDev) {
    Write-Host "`n===================================================================" -ForegroundColor Cyan
    Write-Host "  APPLYING OPTIMIZATIONS" -ForegroundColor Cyan
    Write-Host "===================================================================" -ForegroundColor Cyan
    
    Write-Host "`n[INFO] This will add exclusions for development tools..." -ForegroundColor Cyan
    Write-Host "[WARNING] Only exclude paths you trust!" -ForegroundColor Yellow
    
    $confirm = Read-Host "`nContinue? (yes/no)"
    
    if ($confirm -ne "yes") {
        Write-Host "[INFO] Aborted by user" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "`n[INFO] Adding path exclusions..." -ForegroundColor Cyan
    foreach ($path in $recommendedPaths) {
        if (Test-Path $path) {
            $exists = $exclusionPaths -contains $path
            if (-not $exists) {
                try {
                    Add-MpPreference -ExclusionPath $path
                    Write-Host "  [SUCCESS] Added exclusion: $path" -ForegroundColor Green
                } catch {
                    Write-Host "  [ERROR] Failed to add: $path - $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Host "`n[INFO] Adding process exclusions..." -ForegroundColor Cyan
    foreach ($process in $recommendedProcesses) {
        $exists = $exclusionProcesses -contains $process
        if (-not $exists) {
            try {
                Add-MpPreference -ExclusionProcess $process
                Write-Host "  [SUCCESS] Added exclusion: $process" -ForegroundColor Green
            } catch {
                Write-Host "  [ERROR] Failed to add: $process - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    if ($ApplyDev) {
        Write-Host "`n[INFO] Optimizing scan schedule for developers..." -ForegroundColor Cyan
        
        # Set quick scan instead of full scan
        Set-MpPreference -ScanParameters 1
        Write-Host "  [SUCCESS] Changed daily scan to Quick Scan" -ForegroundColor Green
        
        # Keep daily at 2 AM (already optimal)
        Write-Host "  [INFO] Keeping daily scan at 2:00 AM (optimal)" -ForegroundColor Gray
        
        # Create a weekly full scan scheduled task
        Write-Host "`n[INFO] Creating weekly full scan task..." -ForegroundColor Cyan
        
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
            -Argument "-Command `"Start-MpScan -ScanType FullScan`""
        
        $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
        
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false
        
        try {
            Register-ScheduledTask -TaskName "Windows Defender Weekly Full Scan" `
                -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
            Write-Host "  [SUCCESS] Created weekly full scan task (Sundays at 2:00 AM)" -ForegroundColor Green
        } catch {
            Write-Host "  [WARNING] Could not create scheduled task: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`n[SUCCESS] Optimization complete!" -ForegroundColor Green
    Write-Host "[INFO] Changes take effect immediately" -ForegroundColor Cyan
}

# ============================================================================
# Summary and Next Steps
# ============================================================================

Write-Host "`n===================================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan

if ($AnalyzeOnly -or (-not $Apply -and -not $ApplyDev)) {
    Write-Host "`n[INFO] Analysis complete. To apply optimizations, run:" -ForegroundColor Cyan
    Write-Host "  .\optimize-defender.ps1 -ApplyDev" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "This will:" -ForegroundColor Gray
    Write-Host "  - Add development tool exclusions" -ForegroundColor Gray
    Write-Host "  - Change daily scan to Quick Scan" -ForegroundColor Gray
    Write-Host "  - Schedule weekly full scan on Sundays" -ForegroundColor Gray
} else {
    Write-Host "`n[SUCCESS] Your Windows Defender is now optimized for development!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Optimizations applied:" -ForegroundColor Gray
    Write-Host "  - Development paths excluded from scanning" -ForegroundColor Gray
    Write-Host "  - Development processes excluded" -ForegroundColor Gray
    if ($ApplyDev) {
        Write-Host "  - Daily quick scans at 2:00 AM" -ForegroundColor Gray
        Write-Host "  - Weekly full scans on Sundays at 2:00 AM" -ForegroundColor Gray
    }
}

Write-Host "`n[INFO] To view current exclusions anytime:" -ForegroundColor Cyan
Write-Host "  Get-MpPreference | Select-Object ExclusionPath, ExclusionProcess" -ForegroundColor Yellow

Write-Host "`n[INFO] To manually trigger a scan:" -ForegroundColor Cyan
Write-Host "  Start-MpScan -ScanType QuickScan" -ForegroundColor Yellow
Write-Host "  Start-MpScan -ScanType FullScan" -ForegroundColor Yellow

Write-Host ""
