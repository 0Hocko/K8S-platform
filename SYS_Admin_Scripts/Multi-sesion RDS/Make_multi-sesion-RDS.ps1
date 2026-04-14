<#
.SYNOPSIS
    ** Create Multi-Sesion. **

.DESCRIPTION
    This script allows and creates multi session RDS with grace period 120Days.

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

# ================================
# MULTI-SESSION RDP SETUP FOR DOMAIN USERS
# ================================

Write-Host "Enabling Remote Desktop..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" `
  -Name "fDenyTSConnections" -Value 0

Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Host "Allowing multiple RDP sessions..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
  -Name "fSingleSessionPerUser" -Value 0

Write-Host "Setting max sessions to 6..."
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
  -Name "MaxInstanceCount" -PropertyType DWord -Value 6 -Force

# ================================
# ADD DOMAIN USERS TO LOCAL RDP GROUP
# ================================

$domainUsers = @(
    "K8S\aleksander-admin",
    "K8S\damir-admin",
    "K8S\nejc-admin"
    #"K8S\user4"
    # "DOMAIN\user5",
    # "DOMAIN\user6"
)

foreach ($user in $domainUsers) {
    Write-Host "Adding $user to Remote Desktop Users group..."
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $user -ErrorAction SilentlyContinue
}

# ================================
# RESTART RDP SERVICE
# ================================

Write-Host "Restarting Remote Desktop Service..."
Restart-Service TermService -Force

Write-Host "==================================="
Write-Host "DONE!"
Write-Host "Domain users added: $($domainUsers -join ', ')"
Write-Host "RDP ready for up to 6 simultaneous sessions"
Write-Host "==================================="