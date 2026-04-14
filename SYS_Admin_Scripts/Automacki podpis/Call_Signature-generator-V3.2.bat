@echo off
:: Script for calling main PowerShell script for generating Outlook signature
:: made by cviba

:main
:: Call PowerShell script
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i

if "%PSVersion7%" equ "7" (
    pwsh.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-Spintec-V3.ps1"
) else (
    powershell.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-Spintec-V3.ps1"
)
pause

