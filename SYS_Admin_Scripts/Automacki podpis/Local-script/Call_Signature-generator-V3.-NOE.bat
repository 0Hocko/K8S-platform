@echo off
echo OutlookSignature generator.

echo ~ testing connection with NAS ~
timeout /t 1 /nobreak > nul
ping -n 1 10.10.16.101 > nul
echo.
if %errorlevel% equ 0 (
    echo Successful connection !
	timeout /t 2 /nobreak > nul
    echo Pulling script !
    :: Call PowerShell script
::powershell.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-Spintec-V3.ps1"
pwsh.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-NOE-V3.ps1"
) else (
    echo Ping failed! Script will exit.
    exit /b 1
)
echo Done !
pause

@echo off
:: Script for calling main PowerShell script for generating Outlook signature
:: made by cviba


:mainMenu
cls
echo.
echo.
echo.
echo                             _____   ___ ___   _
echo                            / __\ \ / (_) _ ) /_\
echo                           ^| (__ \ V / ^| ^| _ \/ _ \
echo                            \___^| \_/ ^|^|___/_/ \_\
echo.                         
echo.                                                   POWER
echo.
echo.
echo.
echo               ======================================================
echo                $ Welcome to CVIBA testing for automatic signature! $
echo               ======================================================
echo                 \ #                                            # /
echo                  \#             1. PING PDC                    #/
echo                   #             2. CHECK PowerShell Version    #
echo                   #             3. CHECK NETWORK               #
echo                   #             4. PULL SCRIPT Signature       #
echo                   #             5. EXIT                        #
echo                   #                                            #
echo                   **********************************************
set /p          choice=Please select an option (1-6): 

if "%choice%"=="1" goto test_connection
if "%choice%"=="2" goto PSVersion
if "%choice%"=="3" goto chk_network
if "%choice%"=="4" goto Outlook_signature
if "%choice%"=="5" goto exit
goto mainMenu

:test_connection
cls
echo.
echo.
echo                   *********************************
echo                   *~ testing connection with PDC ~*
echo                   *********************************
echo.
timeout /t 1 /nobreak > nul

ping -n 1 10.10.8.1 > nul

echo.
echo.
if %errorlevel% equ 0 (
    echo Successful connection !
	timeout /t 2 /nobreak > nul
    pause
    goto mainMenu
    ::echo Pulling script !
    :: Call PowerShell script
::powershell.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-Spintec-V3.ps1"
::pwsh.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-Spintec-V3.ps1"
) else (
    echo Ping failed! No connection to PDC server.
    pause
    goto mainMenu
)

pause

:PSVersion
cls
echo.
echo.
echo                   *********************************
echo                   *~     POWERSHELL VERSION      ~*
echo                   *********************************
echo.
echo.


:: Check for PWSH // PS7
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i

echo PowerShell version is : %PSVersion7%


pause
goto mainMenu

:Outlook_signature
cls
echo.
echo.
echo                   *********************************
echo                   *~       PULLING SCRIPT        ~*
echo                   *********************************
echo.
echo.

for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i
  echo %PSVersion7%
pause
if "%PSVersion7%" equ "7" (
    echo Pulling PowerShell 7
    pwsh.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-Spintec-V3.ps1"
) else (
    echo Pulling PowerShell 5
    powershell.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-Spintec-V3.ps1"
)


pause
goto mainMenu
