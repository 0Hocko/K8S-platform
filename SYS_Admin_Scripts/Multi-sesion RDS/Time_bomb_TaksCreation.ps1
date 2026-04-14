<#
.SYNOPSIS
    ** Create TaskScheduler for running time bomb. **

.DESCRIPTION
    This script creates TaskScheduler of scritp that resets graceperiod for RDS

.NOTES
    Use PWSH automation for easier life

.BY
       .---.
      /     \
      \.@-@./
      /`\_/`\
     //  _  \\
    | \     )|_
   /`\_`>  <_/ \
   \__/'---'\__/
   CVIBA ADMIN
#>

# ================================#
# SCHEDULE RDS GRACE PERIOD RESET #
# ================================#

 # Parameters 
$scriptPath = "C:\SCRIPTS\RDS_graceperiode-rest-bomb.ps1"
$taskName = "Reset RDS Grace Period"
$trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 10 -At 2:00AM

$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`"" # Create task
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest # Run as ADMIN

# Create the task
try {
    Register-ScheduledTask -TaskName $taskName -Trigger $trigger -Action $action -Principal $principal -Description "Resets RDS 120-day grace period every 10 days" -Force
    Write-Host "Scheduled task '$taskName' created successfully."
} catch {
    Write-Error "Failed to create scheduled task: $_"
}