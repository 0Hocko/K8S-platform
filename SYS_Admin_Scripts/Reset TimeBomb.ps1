## This Script is intended to be used for Querying remaining time and resetting Terminal Server (RDS) Grace Licensing Period to Default 120 Days.
## Developed by Prakash Kumar (prakash82x@gmail.com) May 28th 2016
## www.adminthing.blogspot.com
## Disclaimer: Please test this script in your test environment before executing on any production server.
## Author will not be responsible for any misuse/damage caused by using it.

Clear-Host
$ErrorActionPreference = "SilentlyContinue"
$uri = "https://outlook.office.com/webhook/610ebe10-1bb7-44ff-83aa-ec2309ea7b9c@124d2c57-457a-43a7-b62b-83809853f7c9/IncomingWebhook/d17e80c779b7451fa5b5d94fa5d70bbd/258a41f8-7357-4a76-b962-d94ba6b4acff"
$body = ConvertTo-Json -Depth 8 @{
	title = "$($env:COMPUTERNAME)"
	text  = "$($env:COMPUTERNAME)'s Terminal Server Grace period reset"}
##Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'

## Display current Status of remaining days from Grace period.
$GracePeriod = (Invoke-WmiMethod -PATH (gwmi -namespace root\cimv2\terminalservices -class win32_terminalservicesetting).__PATH -name GetGracePeriodDays).daysleft


if ($GracePeriod -le 2) {
## Reset Terminal Services Grace period to 120 Days
$body = ConvertTo-Json -Depth 8 @{
	title = "$($env:COMPUTERNAME)"
	text  = "$($env:COMPUTERNAME) Terminal Server (RDS) grace period Days remaining are: $($GracePeriod)"}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'

$definition = @"
using System;
using System.Runtime.InteropServices; 
namespace Win32Api
{
	public class NtDll
	{
		[DllImport("ntdll.dll", EntryPoint="RtlAdjustPrivilege")]
		public static extern int RtlAdjustPrivilege(ulong Privilege, bool Enable, bool CurrentThread, ref bool Enabled);
	}
}
"@ 

Add-Type -TypeDefinition $definition -PassThru

$bEnabled = $false

## Enable SeTakeOwnershipPrivilege
$res = [Win32Api.NtDll]::RtlAdjustPrivilege(9, $true, $false, [ref]$bEnabled)

## Take Ownership on the Key
$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::takeownership)
$acl = $key.GetAccessControl()
$acl.SetOwner([System.Security.Principal.NTAccount]"Administrators")
$key.SetAccessControl($acl)

## Assign Full Controll permissions to Administrators on the key.
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ("Administrators","FullControl","Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)

## Finally Delete the key which resets the Grace Period counter to 120 Days.
Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod'

write-host
Write-host -ForegroundColor Red 'Resetting, Please Wait....'
Start-Sleep -Seconds 10 

Get-Service  -Name 'Remote Desktop Services UserMode Port Redirector' | Stop-Service -Force -Verbose
Get-Service  -Name 'TermService' | Stop-Service -Force -Verbose

Get-Service  -Name 'TermService' | Start-Service -Verbose
Get-Service  -Name 'Remote Desktop Services UserMode Port Redirector' | Start-Service -Verbose
$body = ConvertTo-Json -Depth 8 @{
	title = "$($env:COMPUTERNAME)"
	text  = "$($env:COMPUTERNAME)'s Terminal Service Restarted!"}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'

## Display Remaining Days again as final status
tlsbln.exe
$GracePost = (Invoke-WmiMethod -PATH (gwmi -namespace root\cimv2\terminalservices -class win32_terminalservicesetting).__PATH -name GetGracePeriodDays).daysleft


$body = ConvertTo-Json -Depth 8 @{
	title = "$($env:COMPUTERNAME)"
	text  = "$($env:COMPUTERNAME) Terminal Server (RDS) services RESTARTED and grace period Days remaining are: $($GracePost)"}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'



  }

Else 
    {
Write-Host
Write-Host -ForegroundColor Yellow '**You Chose not to reset Grace period of Terminal Server (RDS) Licensing'
  }



## Cleanup of Variables
Remove-Variable * -ErrorAction SilentlyContinue