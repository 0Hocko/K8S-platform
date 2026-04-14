<#
.SYNOPSIS
    ** Automated deployment of Linux VMs on Hyper-V 2025 using a base image. **

.DESCRIPTION
    This script allows you to create a new Linux VM by:
      - Copying a base VHDX (differencing disk)
      - Creating a VM folder automatically
      - Setting hostname based on VM name
      - Attaching to a specified Hyper-V virtual switch
      - Injecting a public SSH key for the user 'adm-nejc' via cloud-init
      - Starting the VM automatically

.NOTES
    Requirements:
      - Hyper-V Server 2025
      - Base Linux VM VHDX prepared with no network and cleaned /etc/machine-id
      - Public SSH key for 'adm-nejc'
      - Windows ADK installed (for oscdimg to create cloud-init ISO)
      - PowerShell 7+ recommended

.EXAMPLE
    Run the script and enter a VM name when prompted:
    PS> .\Deploy-LinuxVM.ps1

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

# ======== CONFIGURATION ========
$BaseDisk = "V:\template-hocko\00-K_CLONER.vhdx"
$VMBaseFolder = "V:\VMs\k8s"
$VMMemory = 4GB
$VMCPU = 4
$VMSwitchName = "P01"
$OscdimgPath = "V:\template-hocko\ADK_tools\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$SSHKeyBasePath = "V:\template-hocko\PUB_key"

# ======== SELECT SSH KEY =========
Write-Host "Available SSH public keys in ${SSHKeyBasePath}`n"
$KeyFiles = Get-ChildItem -Path $SSHKeyBasePath -Filter *.pub

if ($KeyFiles.Count -eq 0) { Write-Error "No .pub SSH keys found"; exit }

for ($i=0; $i -lt $KeyFiles.Count; $i++) { Write-Host "[$i] $($KeyFiles[$i].Name)" }

do { $Selection = Read-Host "Select key number" }
while (-not ($Selection -match '^\d+$' -and $Selection -lt $KeyFiles.Count))

$SSHKeyPath = $KeyFiles[$Selection].FullName
Write-Host "Using SSH key: $SSHKeyPath"
$SSHKey = Get-Content $SSHKeyPath -Raw

# ======== SELECT LINUX USER ========
$VMUser = Read-Host "Enter Linux username (e.g. adm-nejc, adm-laketa)"
if ([string]::IsNullOrWhiteSpace($VMUser)) { Write-Error "Username cannot be empty"; exit }

# ======== INPUT ========
$VMFolderName = Read-Host "Folder name (e.g. 00-K1M1)"
$VMName       = Read-Host "Hyper-V VM name"
$VMHostname   = Read-Host "Linux hostname (e.g. K28W1)"

# ======== COMPUTE STATIC IP ========
# Extract subnet from hostname (K28 => 28)
$Subnet = [regex]::Match($VMHostname, 'K(\d+)').Groups[1].Value
if ($VMHostname -match 'W(\d+)') { $LastOctet = 20 + [int]$Matches[1] } # worker 21,22,23
elseif ($VMHostname -match 'M(\d+)') { $LastOctet = 10 + [int]$Matches[1] } # master 11,12,13
else { Write-Error "Cannot parse hostname"; exit }

$StaticIP = "10.189.$Subnet.$LastOctet/16"
Write-Host "Computed static IP: $StaticIP"

# ======== CREATE VM FOLDER ========
$VMFolder = Join-Path $VMBaseFolder $VMFolderName
if (!(Test-Path $VMFolder)) { New-Item -ItemType Directory -Path $VMFolder | Out-Null }

# ======== CREATE DIFFERENCING DISK ========
$NewVHD = Join-Path $VMFolder "$VMName.vhdx"
New-VHD -Path $NewVHD -ParentPath $BaseDisk -Differencing | Out-Null
Write-Host "Disk created: $NewVHD"

# ======== CREATE VM ========
New-VM -Name $VMName -MemoryStartupBytes $VMMemory -Generation 2 -VHDPath $NewVHD -SwitchName $VMSwitchName | Out-Null
Set-VMProcessor -VMName $VMName -Count $VMCPU
Write-Host "VM created: $VMName"

# ======== BOOT SETTINGS ========
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
$hdd = Get-VMHardDiskDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $hdd
Write-Host "Boot settings fixed (Secure Boot OFF, Disk first)"

# ======== CLOUD-INIT FOLDER ========
$CloudInitFolder = Join-Path $VMFolder "cloud-init"

# Clear folder to avoid OSCDIMG errors
if (Test-Path $CloudInitFolder) { Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $CloudInitFolder }
New-Item -ItemType Directory -Path $CloudInitFolder -Force | Out-Null

# ======== EMERGENCY BACKDOOR USER ========
$EmergencyUser = "admin"
$EmergencyPassHash = '$6$rounds=4096$abcdef123456$E6UJvQnRrU1miyPxuCln/7H0kg8/CbfHk0qQXy6XZTgnHgBjl3d1NxCVaDlmD7RlHIYzqBfxv2/ADq.8R3k4.'  # password: admin

# ======== CLOUD-INIT USER DATA ========
$UserData = @"
#cloud-config
hostname: $VMHostname
users:
  - name: $VMUser
    ssh-authorized-keys:
      - $SSHKey
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
  - name: $EmergencyUser
    passwd: $EmergencyPassHash
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    groups: sudo
"@

# ======== CLOUD-INIT NETWORK CONFIG (Netplan) ========
$UserData += @"

network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - '$StaticIP'
      nameservers:
        addresses: [10.189.0.4]
        search: [k8s.local]
      routes:
        - to: default
          via: 10.189.0.1
"@

$UserData | Out-File "$CloudInitFolder\user-data" -Encoding utf8

# ======== CLOUD-INIT META-DATA ========
$MetaData = @"
instance-id: $VMHostname
local-hostname: $VMHostname
"@
$MetaData | Out-File "$CloudInitFolder\meta-data" -Encoding utf8

# ======== CREATE ISO ========
$ISOPath = Join-Path $VMFolder "cloud-init.iso"
if (!(Test-Path $OscdimgPath)) { Write-Error "oscdimg not found"; exit }

Write-Host "Creating cloud-init ISO..."
& $OscdimgPath -m -o -u2 -udfver102 -l CIDATA $CloudInitFolder $ISOPath

if (!(Test-Path $ISOPath)) { Write-Error "ISO creation failed!"; exit }

# Attach ISO
if (-not (Get-VMScsiController -VMName $VMName -ErrorAction SilentlyContinue)) { Add-VMScsiController -VMName $VMName | Out-Null }
Add-VMDvdDrive -VMName $VMName -Path $ISOPath | Out-Null
Write-Host "ISO attached: $ISOPath"

# ======== START VM ========
Start-VM -Name $VMName | Out-Null
Write-Host "VM started!"
Write-Host "Hostname: $VMHostname"
Write-Host "Linux user: $VMUser (SSH key login)"
Write-Host "Backup admin user: admin / admin"