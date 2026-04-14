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


# ===================================#
# Hyper-V Linux VM Deployment Script #
# ===================================#

# ======== CONFIGURATION ========
$BaseDisk = "V:\template-hocko\00-K_CLONER.vhdx"
$VMBaseFolder = "V:\VMs\k8s"
#$SSHKeyPath = "V:\template-hocko\adm-nejc_k8s.local.pub"
$VMMemory = 4GB
$VMCPU = 4
$VMSwitchName = "P01"
$OscdimgPath = "V:\template-hocko\ADK_tools\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"

#======== SSHKEYSELECTOR =========
$SSHKeyBasePath = "V:\template-hocko\PUB_key"

Write-Host "Available SSH public keys in ${SSHKeyBasePath}`n"

# List all .pub files
$KeyFiles = Get-ChildItem -Path $SSHKeyBasePath -Filter *.pub

if ($KeyFiles.Count -eq 0) {
    Write-Error "No .pub SSH keys found in $SSHKeyBasePath"
    exit
}

# Show list with numbers
for ($i = 0; $i -lt $KeyFiles.Count; $i++) {
    Write-Host "[$i] $($KeyFiles[$i].Name)"
}

# Ask user to select
do {
    $Selection = Read-Host "Select key number"
} while (-not ($Selection -match '^\d+$' -and $Selection -lt $KeyFiles.Count))

$SSHKeyPath = $KeyFiles[$Selection].FullName
Write-Host "Using SSH key: $SSHKeyPath"

# Load key
$SSHKey = Get-Content $SSHKeyPath -Raw

# ======== SELECT LINUX USER ========
$VMUser = Read-Host "Enter Linux username (e.g. adm-nejc, adm-laketa)"

if ([string]::IsNullOrWhiteSpace($VMUser)) {
    Write-Error "Username cannot be empty"
    exit
}

Write-Host "Using Linux user: $VMUser"

# ======== VALIDATE SSH KEY ========
if (!(Test-Path $SSHKeyPath)) {
    Write-Error "SSH key not found: $SSHKeyPath"
    exit
}
$SSHKey = Get-Content $SSHKeyPath -Raw

# ======== INPUT ========
$VMFolderName = Read-Host "Folder name (e.g. 00-K1M1)"
$VMName       = Read-Host "Hyper-V VM name"
$VMHostname   = Read-Host "Linux hostname (e.g. k2m1)"

# ======== CREATE FOLDER ========
$VMFolder = Join-Path $VMBaseFolder $VMFolderName
if (!(Test-Path $VMFolder)) {
    New-Item -ItemType Directory -Path $VMFolder | Out-Null
}

# ======== CREATE DISK ========
$NewVHD = Join-Path $VMFolder "$VMName.vhdx"
New-VHD -Path $NewVHD -ParentPath $BaseDisk -Differencing | Out-Null
Write-Host "Disk created: $NewVHD"

# ======== CREATE VM ========
New-VM -Name $VMName -MemoryStartupBytes $VMMemory -Generation 2 -VHDPath $NewVHD -SwitchName $VMSwitchName | Out-Null
Set-VMProcessor -VMName $VMName -Count $VMCPU
Write-Host "VM created: $VMName"

# ======== FIX BOOT ISSUES ========

# Disable Secure Boot (recommended for Linux)
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off

# Set disk as first boot device
$hdd = Get-VMHardDiskDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $hdd

Write-Host "Boot settings fixed (Secure Boot OFF, Disk first)"

# ======== CLOUD-INIT FILES ========
$CloudInitFolder = Join-Path $VMFolder "cloud-init"
New-Item -ItemType Directory -Path $CloudInitFolder -Force | Out-Null

# user-data
$UserData = @"
#cloud-config
hostname: $VMHostname
users:
  - name: $VMUser
    ssh-authorized-keys:
      - $SSHKey
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
"@
$UserData | Out-File "$CloudInitFolder\user-data" -Encoding utf8

# meta-data (REQUIRED!)
$MetaData = @"
instance-id: $VMHostname
local-hostname: $VMHostname
"@
$MetaData | Out-File "$CloudInitFolder\meta-data" -Encoding utf8

# ======== CREATE ISO ========
$ISOPath = Join-Path $VMFolder "cloud-init.iso"

if (Test-Path $OscdimgPath) {
    Write-Host "Creating cloud-init ISO..."

    & $OscdimgPath -m -o -u2 -udfver102 $CloudInitFolder $ISOPath

    if (!(Test-Path $ISOPath)) {
        Write-Error "ISO creation failed!"
        exit
    }
    # Aleksader was here
    # Attach ISO
    if (-not (Get-VMScsiController -VMName $VMName -ErrorAction SilentlyContinue)) {
        Add-VMScsiController -VMName $VMName | Out-Null
    }

    Add-VMDvdDrive -VMName $VMName -Path $ISOPath | Out-Null
    Write-Host "ISO attached: $ISOPath"
}
else {
    Write-Error "oscdimg not found: $OscdimgPath"
    exit
}

# ======== START VM ========
Start-VM -Name $VMName | Out-Null
Write-Host "VM started!"
Write-Host "Hostname: $VMHostname"
Write-Host "User: $VMUser (SSH key login)"