##########################################
# Offline logon
#
# Must run as Administrator
# ---------------------------------------------

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\UserTile"
$backupFolder = "C:\reg-backup"
$backupFile = "$backupFolder\UserTile-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').reg"

Write-Host "Starting registry backup and SID removal process..." -ForegroundColor Cyan


if (!(Test-Path $backupFolder)) {
    Write-Host "Creating backup folder at $backupFolder"
    New-Item -Path $backupFolder -ItemType Directory -Force | Out-Null
}

# Backup registry key using reg.exe (more reliable for full export)
Write-Host "Backing up registry key..."
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\UserTile" $backupFile /y

if (!(Test-Path $backupFile)) {
    Write-Host "Backup failed. Aborting." -ForegroundColor Red
    exit
}

Write-Host "Backup saved to: $backupFile" -ForegroundColor Green

# Ask for username
$username = Read-Host "Enter the username (without domain)"

try {
    # Resolve SID
    $ntAccount = New-Object System.Security.Principal.NTAccount($username)
    $sid = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier]).Value
    Write-Host "Resolved SID: $sid" -ForegroundColor Yellow
}
catch {
    Write-Host "Could not resolve SID for username: $username" -ForegroundColor Red
    exit
}

# Delete SID key if it exists
$userSidPath = Join-Path $registryPath $sid

if (Test-Path $userSidPath) {
    Write-Host "Removing SID key from UserTile..."
    Remove-Item -Path $userSidPath -Recurse -Force
    Write-Host "SID key successfully removed." -ForegroundColor Green
}
else {
    Write-Host "SID key not found in UserTile registry path." -ForegroundColor Yellow
}

Write-Host "Process completed."
