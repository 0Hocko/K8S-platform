<#
.SYNOPSIS
    ** Automated deployment of Linux VMs on Hyper-V 2025 using a base image. **

.DESCRIPTION
    This script allows you to create a new Linux VM by:
      - Copying a base VHDX (differencing disk)
      - Creating a VM folder automatically
      - Setting hostname based on VM name
      - Attaching to a specified Hyper-V virtual switch
      - Injecting a public SSH key
      - Injecting network settings - netplan
      - Starting the VM automatically

.NOTES
    Requirements:
      - Hyper-V Server 2025
      - Base Linux VM VHDX prepared with no network and cleaned /etc/machine-id
      - Public SSH key
      - Windows ADK installed (for oscdimg to create cloud-init ISO)
      - PowerShell 7+ recommended

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

# ================ VM - CONFIGURATION ================
$BaseDisk       = "V:\template-hocko\00-K_CLONER.vhdx"
$VMBaseFolder   = "V:\VMs\k8s"
$VMMemory       = 4GB
$VMCPU          = 4
$VMSwitchName   = "P01"
$OscdimgPath    = "V:\template-hocko\ADK_tools\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
$SSHKeyBasePath = "V:\template-hocko\PUB_key"

# ================ VALIDATION ================
if (!(Test-Path $BaseDisk)) { Write-Error "Base disk not found"; exit }
if (!(Test-Path $OscdimgPath)) { Write-Error "oscdimg not found"; exit }

# ================ SELECT SSH KEY =================

# Add more key in folder "V:\template-hocko\PUB_key" to select from
Write-Host "______________________________________________________"
Write-Host ""

Write-Host "Available SSH public keys in ${SSHKeyBasePath}`n"
$KeyFiles = Get-ChildItem -Path $SSHKeyBasePath -Filter *.pub

if ($KeyFiles.Count -eq 0) {
    Write-Error "No SSH keys found"
    exit
}

for ($i=0; $i -lt $KeyFiles.Count; $i++) {
    Write-Host "[$i] $($KeyFiles[$i].Name)"
}

do {
    $Selection = Read-Host "Select key number"
} while (-not ($Selection -match '^\d+$' -and [int]$Selection -lt $KeyFiles.Count))

$SSHKey = Get-Content $KeyFiles[$Selection].FullName -Raw
Write-Host "Using SSH key: $($KeyFiles[$Selection].FullName)"
Write-Host "______________________________________________________"
Write-Host ""

# ================ USER INPUT ================
$VMUser       = Read-Host "Enter Linux username"
$VMFolderName = Read-Host "Folder name (e.g. 00-K1M1)"
$VMName       = $VMFolderName        #Read-Host "Hyper-V VM name"
$VMHostname   = (Read-Host "Linux hostname (e.g. K28W1)").ToUpper()

if ([string]::IsNullOrWhiteSpace($VMUser)) {
    Write-Error "Username cannot be empty"
    exit
}

Write-Host "______________________________________________________"
Write-Host ""

# ================ IP ADDRESS FROM HOSTNAME ================
$SubnetMatch = [regex]::Match($VMHostname, 'K(\d+)')
if (-not $SubnetMatch.Success) {
    Write-Error "Cannot parse subnet from hostname ($VMHostname)"
    exit
}
$Subnet = $SubnetMatch.Groups[1].Value

if ($VMHostname -match 'W(\d+)') {
    $LastOctet = 20 + [int]$Matches[1]
}
elseif ($VMHostname -match 'M(\d+)') {
    $LastOctet = 10 + [int]$Matches[1]
}
else {
    Write-Error "Cannot parse node type (W/M) from hostname ($VMHostname)"
    exit
}

$StaticIP = "10.189.$Subnet.$LastOctet/16"
Write-Host "Computed static IP: $StaticIP"

# ================ VM DESTINATION DIRECTORY ================
$VMFolder = Join-Path $VMBaseFolder $VMFolderName

if (Test-Path $VMFolder) {
    Write-Warning "Folder exists, cleaning..."
    cmd /c "rmdir /s /q `"$VMFolder`"" 2>$null
    Start-Sleep -Seconds 1
}

New-Item -ItemType Directory -Path $VMFolder | Out-Null

# ================ VMDISK ================
$NewVHD = Join-Path $VMFolder "$VMName.vhdx"
New-VHD -Path $NewVHD -ParentPath $BaseDisk -Differencing | Out-Null
Write-Host "Disk created: $NewVHD"

# ================ VM CREATION ================
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Warning "VM exists, removing..."
    Stop-VM $VMName -Force -ErrorAction SilentlyContinue
    Remove-VM $VMName -Force
}

New-VM -Name $VMName -MemoryStartupBytes $VMMemory -Generation 2 `
    -VHDPath $NewVHD -SwitchName $VMSwitchName | Out-Null

Set-VMProcessor -VMName $VMName -Count $VMCPU
Write-Host "VM created: $VMName"

# ======== BOOT SETTINGS ========
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
$hdd = Get-VMHardDiskDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -FirstBootDevice $hdd

# ======== CLOUD-INIT ========
$CloudInitFolder = Join-Path $VMFolder "cloud-init"
New-Item -ItemType Directory -Path $CloudInitFolder | Out-Null

# ======== USER-DATA ========
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
    passwd: \$6\$rounds=4096\$abc123\$w5hWgZrWJHnQ9ZKz1vZ0zV6d8z1sWlK9sHqYQwYFzGZx9kF3z6zTnFz1bJ6u3ZP8XkWl9YgYwQvXv8YwF7V1/
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
							   
			 
					 
						 
"@

# ======== META-DATA ========
$MetaData = @"
instance-id: $VMHostname
local-hostname: $VMHostname
"@

# ======== NETWORK-CONFIG ========
$NetworkConfig = @"
version: 2
ethernets:
  eth0:
    dhcp4: no
    addresses:
      - $StaticIP
    nameservers:
      addresses: [10.189.0.4]
      search: [k8s.local]
    routes:
      - to: default
        via: 10.189.0.1
"@

# ================ WRITE TO FILE ================
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

[System.IO.File]::WriteAllText("$CloudInitFolder\user-data", $UserData, $Utf8NoBom)
[System.IO.File]::WriteAllText("$CloudInitFolder\meta-data", $MetaData, $Utf8NoBom)
[System.IO.File]::WriteAllText("$CloudInitFolder\network-config", $NetworkConfig, $Utf8NoBom)

# ================ ISO CREATION ================
$ISOPath = Join-Path $VMFolder "cloud-init.iso"

if (Test-Path $ISOPath) {
    Remove-Item $ISOPath -Force -ErrorAction SilentlyContinue
}

Write-Host "Creating cloud-init ISO..."

$arguments = @(
    "-m",
    "-o",
    "-n",
    "-lCIDATA",
    "`"$CloudInitFolder`"",
    "`"$ISOPath`""
)

$proc = Start-Process -FilePath $OscdimgPath `
    -ArgumentList $arguments `
    -Wait -PassThru -NoNewWindow

if ($proc.ExitCode -ne 0 -or !(Test-Path $ISOPath)) {
    Write-Error "ISO creation failed (exit code $($proc.ExitCode))"
    exit
}

Write-Host "ISO created: $ISOPath"

# ======== ATTACH ISO ========
Add-VMDvdDrive -VMName $VMName -Path $ISOPath | Out-Null

# ======== START VM ========
Write-Host ""
Start-VM -Name $VMName | Out-Null

Write-Host "|-----------------------------|"
Write-Host "|  VM started!                |"
Write-Host "|  Hostname: $VMHostname      |"
Write-Host "|  User: $VMUser (SSH key)    |"
Write-Host "|  Fallback: admin / admin    |"
Write-Host "|-----------------------------|"