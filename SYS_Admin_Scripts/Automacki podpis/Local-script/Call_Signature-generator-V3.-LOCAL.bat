@echo off
:: ---------------------------------------------------------------------------------------------------------- ::
:: Interactive script for setting up Outlooksignature and envirement preperation.                             :: 
:: made by cviba                                                                                              :: 
::                                                ./\.                                                        :: 
::                                              /     \                                                       :: 
::                                              \.@-@./                                                       :: 
::                                              /`\_/`\                                                       :: 
::                                             //  _  \\                                                      :: 
::                                            | \     )|_                                                     :: 
::                                           /`\_`>  <_/ \                                                    :: 
::                                           \__/'---'\__/                                                    :: 
:: ---------------------------------------------------------------------------------------------------------- ::
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
echo                  \#       1. CHEK TOOLS                        #/
echo                   #       2. SET UP ENVIREMENT                 #
echo                   #       3. SIGNATURE                         #
echo                   #       4. EXIT                              #
echo                   #                                            #
echo                   **********************************************
echo.
echo.
set /p choice="Please select an option (1-4):" 

if "%choice%"=="1" goto CHK_tools
if "%choice%"=="2" goto setup_environment
if "%choice%"=="3" goto Pull_script
if "%choice%"=="5" goto exit
goto mainMenu

:: ---------------------- CHECK TOOLS ----------------------
:CHK_tools
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~          CHECK TOOLS        ~*
echo                   *********************************
echo                   #                               #
echo                   #  1. PING PDC                  #
echo                   #  2. CHECK PowerShell Version  #
echo                   #  3. CHECK NETWORK             #
echo                   #  4. PULL SCRIPT Signature     #
echo                   #  5. SET UP ENVIREMENT         #
echo                   #  6. BACK                      #
echo                   #                               #
echo                   *********************************
echo.
echo.
set /p choice="         Please select an option (1-6):" 

if "%choice%"=="1" goto test_connection
if "%choice%"=="2" goto PSVersion
if "%choice%"=="3" goto chk_network
if "%choice%"=="4" goto Pull_script
if "%choice%"=="5" goto setup_environment
if "%choice%"=="6" goto mainMenu

goto mainMenu


:: ---------------------- SETUP ENVIREMENT ----------------------
:setup_environment
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~          Setting up         ~*
echo                   *********************************
echo.

:: Check if C:\spintec directory exists
if not exist "C:\spintec" (
    mkdir C:\spintec
    attrib +h C:\spintec
)
:: Check if C:\spintec\signature directory exists
if not exist "C:\spintec\signature" (
    mkdir C:\spintec\signature
    attrib +h C:\spintec\signature
)

:: Prompt user to choose copy location
echo.
echo.
echo     #.  Select the source location to copy PowerShell scripts from:  .#
echo.
echo                   $ 1. PDC server
echo                   $ 2. NAS server
echo                   $ 3. Enter custom path
echo.
echo                   $ 4. Back
echo.
set /p choice="  Enter choice (1-4): "

:: Set source path based on user's choice
set "source_path="
if "%choice%"=="1" (
    set "source_path=\\corp.spintecgaming.com\NETLOGON\OutlookSignature\"
) else if "%choice%"=="2" (
    set "source_path=\\nas1.corp.spintecgaming.com\System_admnistrator\Scripts\Automacki podpis\Local-script"
) else if "%choice%"=="3" (
    set /p source_path="Enter custom path: "
) else if "%choice%"=="4" (
    goto mainMenu
) else (
    echo Invalid choice, get back to main menu.
    pause
    goto mainMenu
)

:: Validate source path and copy PowerShell and Batch scripts only
if not exist "%source_path%" (
    echo Source path does not exist, please check and try again.
    pause
    exit /b
) else (
    echo Copying PowerShell scripts from "%source_path%" to "C:\spintec\signature"
for %%f in ("%source_path%\*.ps1" "%source_path%\*.bat") do (
    copy "%%f" "C:\spintec\signature" > nul 
)

)


echo.
echo Contents of C:\spintec\signature:
dir /b C:\spintec\signature
pause
goto mainMenu

:setup_environment_auto

goto mainMenu

:: ---------------------- TEST CONNECTION ----------------------
:test_connection
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~ testing connection with PDC ~*
echo                   *********************************
echo.
echo.
echo.
echo.
timeout /t 1 /nobreak > nul

ping -n 3 10.10.8.1 > nul

echo.
echo.
if %errorlevel% equ 0 (
    echo Successful connection !
	timeout /t 2 /nobreak > nul
    pause
    goto mainMenu
) else (
    echo Ping failed! No connection to PDC server.
    pause
    goto mainMenu
)

pause

:: ---------------------- SHOW POWERSHELL VERSION ----------------------
:PSVersion
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~     POWERSHELL VERSION      ~*
echo                   *********************************
echo.
echo.
echo.
echo.

:: Check for PWSH // PS7
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i

echo PowerShell version is : %PSVersion7%

if "%PSVersion7%" equ "7" (
    echo PowerShell version is already 7
) else (
    echo PowerShell version is not 7.
    echo Do you want to install PowerShell 7 with WinGet ? 
    set /p choice= [Y / N]:
    if "%choice%"=="Y" (
      winget install --id Microsoft.PowerShell --source winget
    )
    if "%choice%"=="N" (
        echo Ok as you wish.
        pause
        goto mainMenu
    ) 
)

pause
goto mainMenu

:: ---------------------- MENU FOR PULLING SCRIPT ---------------------- 
:Pull_script
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~       PULLING SCRIPT        ~*
echo                   *********************************
echo                   #                               # 
echo                   #  1. ARKA                      #
echo                   #  2. SPINTEC                   #
echo                   #  3. NOE                       #
echo                   #  4. BACK - MainMenu           #
echo                   #  5. EXIT                      #
echo                   #                               #
echo                   *********************************
set /p choice=" Please select an option (1-5):" 

if "%choice%"=="1" ( 
    set company="ARKA"
    goto ARKA 
    )
if "%choice%"=="2" ( 
    set company="Spintec"
    goto Spintec 
    )
if "%choice%"=="3" ( 
    set company="NOE"
    goto NOE 
    )
if "%choice%"=="4" goto mainMenu
if "%choice%"=="5" goto exit 
goto Pull_script

:: ----------------------  Setup for ARKA powershell script -------------
:ARKA
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~   ARKA Outlook signature    ~*
echo                   *********************************
echo                   #                               #
echo                   #  1. AUTO SETUP ALL            #
echo                   #                               # 
echo                   #  2. Set task scheduer         #
echo                   #  3. Pull script LOCAL         #
echo                   #  4. Pull Script with AD       #
echo                   #  5. BACK                      #
echo                   #  6. EXIT                      #
echo                   #                               #
echo                   *********************************
set /p choice=" Please select an option (1-6): "

if "%choice%"=="1" goto Auto_setup_local_ARKA
if "%choice%"=="2" goto TaskScheduler_ARKA
if "%choice%"=="3" goto Pull_script_ARKA
if "%choice%"=="4" goto Pull_script_ARKA-AD
if "%choice%"=="5" goto Pull_script
if "%choice%"=="6" goto exit
goto ARKA

:Auto_setup_local_ARKA
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~   ARKA Outlook signature    ~*
echo                   **         AUTOMATIC           **
echo                   *********************************
echo.
echo.
echo.
:: Check environment if its not setup make it 
:: automatic silent environment setup

:: Check if C:\spintec directory exists
if not exist "C:\spintec" (
    mkdir C:\spintec
    attrib +h C:\spintec
)
:: Check if C:\spintec\signature directory exists
if not exist "C:\spintec\signature" (
    mkdir C:\spintec\signature
    attrib +h C:\spintec\signature
)
:: TRY to copy from servers. If the connection is not worling promp user for path
:: Set source path based on user's choice

ping -n 3 10.10.8.1 > nul

if %errorlevel% equ 0 (
    set "source_path=\\corp.spintecgaming.com\NETLOGON\OutlookSignature\"
) else if "%errorlevel%">="1" (
    set /p source_path="Enter custom path: "
) else (
    echo Invalid choice, get back to main menu.
    pause
    goto mainMenu
)

:: Validate source path and copy PowerShell and Batch scripts only
if not exist "%source_path%" (
    echo Source path does not exist, please check and try again.
    pause
    exit /b
) else (
    echo Copying PowerShell scripts from "%source_path%" to "C:\spintec\signature"
for %%f in ("%source_path%\*.ps1" "%source_path%\*.bat") do (
    copy "%%f" "C:\spintec\signature" > nul 
)

)

echo.
echo Contents of C:\spintec\signature:
dir /b C:\spintec\signature
echo environment done !
pause
:: Create local script for user

setlocal
echo Enter user data :
echo.
:: Prompt the user for input
set /p "userName=Enter name: "
set /p "userTitle=Enter title: "
set /p "userMail=Enter email: "
set /p "userTelephone=Enter telephone: "
set /p "userMobile=Enter mobile: "
set /p "userCompany=Enter company: "
echo.

:: Check if PS 7 is installed if not notmal PS 5 call
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i
  echo PowerShell version %PSVersion7%
pause
if "%PSVersion7%" equ "7" (
    echo Pulling PowerShell 7
    pwsh.exe -ExecutionPolicy Bypass -File "C:\spintec\signature\Outlook-signature-generator-ARKA-V3-LOCAL.ps1" -userName "%userName%" -userTitle "%userTitle%" -userMail "%userMail%" -userTelephone "%userTelephone%" -userMobile "%userMobile%" -userCompany "%userCompany%"
) else (
    echo Pulling PowerShell 5
    powershell.exe -ExecutionPolicy Bypass -File "C:\spintec\signature\Outlook-signature-generator-ARKA-V3-LOCAL.ps1" -userName "%userName%" -userTitle "%userTitle%" -userMail "%userMail%" -userTelephone "%userTelephone%" -userMobile "%userMobile%" -userCompany "%userCompany%"
)

endlocal
echo Script done !
pause

:: Create task scheduler

SET TASK_NAME="Signature-Task"
SET TASK_DESCRIPTION="Runs the signature creation script every day at 8 AM and at logon"
SET SCRIPT_PATH="C:\spintec\signature\Outlook-signature-generator-ARKA-V3-LOCAL.ps1"

:: First check if the envirement is set up. If not set it up
if not exist %SCRIPT_PATH% (
    echo Script file not found at %SCRIPT_PATH%
    echo Plese go set up environment and come back !
    echo.
    set /p choice=Do you want to setup the environment ?  [Y / N]:
    if "%choice%"=="Y" goto setup_environment
    if "%choice%"=="N" (
        echo Ok as you wish.
        pause
        goto mainMenu
    ) else ( 
        goto ARKA 
        )
)

:: Delete existing task with the same name if it exists
schtasks /delete /tn %TASK_NAME% /f >nul 2>&1

:: Create the task
schtasks /create /tn %TASK_NAME% /tr "%SCRIPT_PATH%" /sc daily /st 08:00 /ru SYSTEM /f
schtasks /change /tn %TASK_NAME% /sc onlogon /ru SYSTEM

echo Task "%TASK_NAME%" has been created successfully with the following triggers:
echo - Daily at 8:00 AM
echo - At user logon
pause


:TaskScheduler_ARAK
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~   ARKA Outlook signature    ~*
echo                   *********************************
echo                   #                               # 
echo                   #  1. Set task scheduer         #
echo                   #                               #
echo                   *********************************
echo.
echo.
echo.
echo.
echo      NOTE : Before setting up Tash Scheduler you must have environment setup with ARKA local script !
echo.
echo.
SET TASK_NAME="Signature-Task"
SET TASK_DESCRIPTION="Runs the signature creation script every day at 8 AM and at logon"
SET SCRIPT_PATH="C:\spintec\signature\Outlook-signature-generator-ARKA-V3-LOCAL.ps1"

:: First check if the envirement is set up. If not set it up
if not exist %SCRIPT_PATH% (
    echo Script file not found at %SCRIPT_PATH%
    echo Plese go set up environment and come back !
    echo.
    set /p choice=Do you want to setup the environment ?  [Y / N]:
    if "%choice%"=="Y" goto setup_environment
    if "%choice%"=="N" (
        echo Ok as you wish.
        pause
        goto mainMenu
    ) else ( 
        goto ARKA 
        )
)

:: Delete existing task with the same name if it exists
schtasks /delete /tn %TASK_NAME% /f >nul 2>&1

:: Create the task
schtasks /create /tn %TASK_NAME% /tr "%SCRIPT_PATH%" /sc daily /st 08:00 /ru SYSTEM /f
schtasks /change /tn %TASK_NAME% /sc onlogon /ru SYSTEM

echo Task "%TASK_NAME%" has been created successfully with the following triggers:
echo - Daily at 8:00 AM
echo - At user logon
pause
goto ARKA

:Pull_script_ARKA
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~   ARKA Outlook signature    ~*
echo                   *********************************
echo                   #                               # 
echo                   #  2. Pull script   LOCAL       #
echo                   #                               #
echo                   *********************************
echo.
echo.
echo      Pulling PowerShell script LOCAL. Make sure you modify data.
echo.

setlocal
echo Enter user data :
echo.
:: Prompt the user for input
set /p "userName=Enter name: "
set /p "userTitle=Enter title: "
set /p "userMail=Enter email: "
set /p "userTelephone=Enter telephone: "
set /p "userMobile=Enter mobile: "
set /p "userCompany=Enter company: "
echo.

:: Check if PS 7 is installed if not notmal PS 5 call
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i
  echo PowerShell version %PSVersion7%
pause
if "%PSVersion7%" equ "7" (
    echo Pulling PowerShell 7
    pwsh.exe -ExecutionPolicy Bypass -File "\\corp.spintecgaming.com\NETLOGON\OutlookSignature\Outlook-signature-generator-Spintec-V3-LOCAL.ps1" -userName "%userName%" -userTitle "%userTitle%" -userMail "%userMail%" -userTelephone "%userTelephone%" -userMobile "%userMobile%" -userCompany "%userCompany%"
) else (
    echo Pulling PowerShell 5
    powershell.exe -ExecutionPolicy Bypass -File "\\corp.spintecgaming.com\NETLOGON\OutlookSignature\Outlook-signature-generator-Spintec-V3-LOCAL.ps1" -userName "%userName%" -userTitle "%userTitle%" -userMail "%userMail%" -userTelephone "%userTelephone%" -userMobile "%userMobile%" -userCompany "%userCompany%"
)

endlocal




:Pull_script_ARKA-AD
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~   ARKA Outlook signature    ~*
echo                   *********************************
echo                   #                               # 
echo                   #  2. Pull script with AD       #
echo                   #                               #
echo                   *********************************
echo.
echo.
echo               Pulling User data from Active Directory.
echo.
:: Check if PS 7 is installed if not notmal PS 5 call
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i
  echo PowerShell version %PSVersion7%
pause
if "%PSVersion7%" equ "7" (
    echo Pulling PowerShell 7
    pwsh.exe -ExecutionPolicy Bypass -File "\\corp.spintecgaming.com\NETLOGON\OutlookSignature\Outlook-signature-generator-Spintec-V3.ps1"
) else (
    echo Pulling PowerShell 5
    powershell.exe -ExecutionPolicy Bypass -File "\\corp.spintecgaming.com\NETLOGON\OutlookSignature\Outlook-signature-generator-Spintec-V3.ps1"
)


:: -------------------- Setup for SPINTEC powershell script -------------
:Spintec
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~  SPINTEC Outlook signature  ~*
echo                   *********************************
echo                   #                               # 
echo                   #  1. Set task scheduer         #
echo                   #  2. Pull script               #
echo                   #  3. Pull Script with AD       #
echo                   #  4. BACK - MainMenu           #
echo                   #  5. EXIT                      #
echo                   #                               #
echo                   *********************************
set /p          choice=Please select an option (1-5): 

if "%choice%"=="1" goto TaskScheduler
if "%choice%"=="2" goto Pull_script_SPINTEC
if "%choice%"=="3" goto Pull_script_SPINTEC-AD
if "%choice%"=="4" goto mainMenu
if "%choice%"=="5" goto exit
goto Spintec


:NOE
cls






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
