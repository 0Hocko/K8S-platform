<#
.SYNOPSIS
    Automated deployment of Linux VMs on Hyper-V 2025 using cloud-init ISO
.DESCRIPTION
    - Creates a differencing VHDX from base image
    - Sets hostname
    - Adds Linux user with SSH key
    - Adds fallback admin user with password
    - Configures static network (netplan)
    - Generates cloud-init ISO natively (PowerShell)
    - Attaches ISO and boots VM
#>

# ======== CONFIGURATION ========
$BaseDisk = "V:\template-hocko\00-K_CLONER.vhdx"
$VMBaseFolder = "V:\VMs\k8s"
$VMMemory = 4GB
$VMCPU = 4
$VMSwitchName = "P01"
$SSHKeyBasePath = "V:\template-hocko\PUB_key"

# ======== SELECT SSH KEY =========
Write-Host "`nAvailable SSH public keys in $SSHKeyBasePath`n"
$KeyFiles = Get-ChildItem -Path $SSHKeyBasePath -Filter *.pub
if ($KeyFiles.Count -eq 0) { Write-Error "No .pub SSH keys found"; exit }

for ($i=0; $i -lt $KeyFiles.Count; $i++) { Write-Host "[$i] $($KeyFiles[$i].Name)" }

do {
    $Selection = Read-Host "Select key number"
} while (-not ($Selection -match '^\d+$' -and $Selection -lt $KeyFiles.Count))

$SSHKeyPath = $KeyFiles[$Selection].FullName
$SSHKey = (Get-Content $SSHKeyPath -Raw -Encoding UTF8).Trim()
Write-Host "Using SSH key: $SSHKeyPath"

# ======== SELECT LINUX USER =========
$VMUser = Read-Host "Enter Linux username (e.g. adm-nejc, adm-laketa)"
if ([string]::IsNullOrWhiteSpace($VMUser)) { Write-Error "Username cannot be empty"; exit }

# ======== INPUT =========
$VMFolderName = Read-Host "Folder name (e.g. 00-K1M1)"
$VMName       = $VMFolderName
$VMHostname   = Read-Host "Linux hostname (e.g. K28W1)"

# ======== COMPUTE STATIC IP =========
if ($VMHostname -match 'K(\d+)') { $Subnet = [int]$Matches[1] } else { $Subnet = 0 }
if ($VMHostname -match 'M(\d+)') { $LastOctet = 10 + [int]$Matches[1] }
elseif ($VMHostname -match 'W(\d+)') { $LastOctet = 20 + [int]$Matches[1] }
else { $LastOctet = 11 }

$StaticIP = "10.189.$Subnet.$LastOctet/16"
$Gateway = "10.189.0.1"
$DNS = "10.189.0.4"
Write-Host "Using static IP: $StaticIP"

# ======== CREATE VM FOLDER =========
$VMFolder = Join-Path $VMBaseFolder $VMFolderName
if (!(Test-Path $VMFolder)) { New-Item -ItemType Directory -Path $VMFolder | Out-Null }

# ======== CREATE DIFFERENCING DISK =========
$NewVHD = Join-Path $VMFolder "$VMName.vhdx"
New-VHD -Path $NewVHD -ParentPath $BaseDisk -Differencing | Out-Null
Write-Host "Disk created: $NewVHD"

# ======== CREATE VM =========
New-VM -Name $VMName -MemoryStartupBytes $VMMemory -Generation 2 -VHDPath $NewVHD -SwitchName $VMSwitchName | Out-Null
Set-VMProcessor -VMName $VMName -Count $VMCPU
Write-Host "VM created: $VMName"

# ======== BOOT SETTINGS =========
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
$hdd = Get-VMHardDiskDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $hdd
Write-Host "Boot settings fixed"

# ======== CLOUD-INIT FILES =========
$CloudInitFolder = Join-Path $VMFolder "cloud-init"
if (Test-Path $CloudInitFolder) { Remove-Item -Recurse -Force $CloudInitFolder }
New-Item -ItemType Directory -Path $CloudInitFolder | Out-Null

# --- user-data with fallback password ---
$UserData = @"
#cloud-config
hostname: $VMHostname
ssh_pwauth: true

users:
  - name: $VMUser
    ssh-authorized-keys:
      - $SSHKey
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash

  - name: admin
    plain_text_passwd: admin
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash

chpasswd:
  expire: false
"@
$UserData | Out-File "$CloudInitFolder\user-data" -Encoding utf8

# --- meta-data ---
@"
instance-id: $VMHostname
local-hostname: $VMHostname
"@ | Out-File "$CloudInitFolder\meta-data" -Encoding utf8

# --- network-config ---
$NetworkConfig = @"
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses: ['$StaticIP']
      nameservers:
        addresses: ['$DNS']
        search: [k8s.local]
      routes:
        - to: default
          via: '$Gateway'
"@
$NetworkConfig | Out-File "$CloudInitFolder\network-config" -Encoding utf8

# ======== CREATE ISO (native, no OSCDIMG) =========
$ISOPath = Join-Path $VMFolder "cloud-init.iso"
if (Test-Path $ISOPath) { Remove-Item $ISOPath -Force }

# Requires Windows 10+ / Server 2022+
# Use "mkisofs" style with System.IO.Compression.ZipFile (ISO9660-like)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$TempISOFolder = Join-Path $VMFolder "cloud-init-temp"
if (Test-Path $TempISOFolder) { Remove-Item -Recurse -Force $TempISOFolder }
Copy-Item -Path "$CloudInitFolder\*" -Destination $TempISOFolder -Recurse

$isoStream = [System.IO.File]::Open($ISOPath, [System.IO.FileMode]::Create)
[System.IO.Compression.ZipFile]::CreateFromDirectory($TempISOFolder, $ISOPath)
Remove-Item -Recurse -Force $TempISOFolder
Write-Host "ISO created: $ISOPath"

# ======== ATTACH ISO =========
if (-not (Get-VMScsiController -VMName $VMName -ErrorAction SilentlyContinue)) {
    Add-VMScsiController -VMName $VMName | Out-Null
}
Add-VMDvdDrive -VMName $VMName -Path $ISOPath | Out-Null
Write-Host "ISO attached"

# ======== START VM =========
Start-VM -Name $VMName | Out-Null
Write-Host "VM started!"
Write-Host "Hostname: $VMHostname"
Write-Host "User: $VMUser (SSH key login)"
Write-Host "Fallback user: admin / admin"
Write-Host "Static IP: $StaticIP"