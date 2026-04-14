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
:MainMenu
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
echo                  \#       1. SIGNATURE MAKER                   #/
echo                   #       2. SET UP ENVIREMENT                 #
echo                   #       3. CHECK TOOLS                       #
echo                   #       4. EXIT                              #
echo                   #                                            #
echo                   **********************************************
echo.
echo.

set /p choice="Please select an option (1-4):" 

if "%choice%"=="1" goto Signature_maker
if "%choice%"=="2" ( set mode=manual
 goto SetUp_environment )
if "%choice%"=="3" goto CHK_tools
if "%choice%"=="4" goto exit
goto MainMenu


: ---------------------- MAIN MENU FOR SIGNATURE MAKER ---------------------- 
:Signature_maker
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~       SIGNATURE MAKER       ~*
echo                   *********************************
echo                   #  $ Select company you want    # 
echo                   #        signature for          # 
echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
echo                   #                               #
echo                   #  1. ARKA                      #
echo                   #  2. SPINTEC                   #
echo                   #  3. NOE                       #
echo                   #                               #
echo                   #  4. BACK TO MAIN MENU         #
echo                   #  5. EXIT                      #
echo                   #                               #
echo                   *********************************
set /p choice=" Please select an option (1-5):" 

if "%choice%"=="1" ( 
    set company=ARKA
    goto Sub_menu 
    )
if "%choice%"=="2" ( 
    set company=Spintec
    goto Sub_menu 
    )
if "%choice%"=="3" ( 
    set company=NOE
    goto Sub_menu 
    )
if "%choice%"=="4" goto MainMenu
if "%choice%"=="5" goto exit 
goto Pull_script


:: ----------------------  SUB MENU FOR SIGNATURE MAKER -------------
:Sub_menu
cls
echo.
echo.
echo.
echo                   **********************************
echo                   *~  SIGNATURE MAKER %company%   ~*
echo                   **********************************
echo                   #        $ Select option         # 
echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
echo                   #                                #
echo                   #  1. AUTO SETUP LOCAL USER ONLY #
echo                   #  2. MANUAL SET UP              # 
echo                   #                                #
echo                   #  3. BACK                       #
echo                   #  4. EXIT                       #
echo                   #                                #
echo                   **********************************
set /p choice=" Please select an option (1-4): "

if "%choice%"=="1" ( 
    set mode=automatic
    goto Automatic_setup_local
     )
if "%choice%"=="2" (
    set mode=manual
    goto Manual_setup_local
    )
if "%choice%"=="3" goto Signature_maker
if "%choice%"=="4" goto exit
goto ARKA


:: ----------------------  AUTOMATIC SETUP SIGNATURE MAKER -------------
:Automatic_setup_local
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~           AUTOMATIC         ~*
echo                   *~        SIGNATURE MAKER      ~*
echo                   *~           %company%         ~*
echo                   *********************************
echo.
echo.
echo.

goto SetUp_environment



:: ----------------------  MANUAL SETUP SIGNATURE MAKER -------------
:Manual_setup_local
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~             MANUAL          ~*
echo                   *~        SIGNATURE MAKER      ~*
echo                   *~           %company%         ~*
echo                   *********************************
echo                   #                               #
echo                   #  1. SETUP ENVIRONMENT         #
echo                   #  2. SETUP SCRIPT LOCAL USER   #
echo                   #  3. SETUP SCRIPT AD USER      #
echo                   #  4. CREATE TASK SCHEDULER     #
echo                   #  5. BACK                      #
echo                   #  6. EXIT                      #
echo                   #                               #
echo                   *********************************
set /p choice=" Please select an option (1-6): "

if "%choice%"=="1" goto SetUp_environment
if "%choice%"=="2" goto SetUp_script_local_user
if "%choice%"=="3" goto SetUp_script_AD_user
if "%choice%"=="4" goto SetUp_taskscheduler
if "%choice%"=="5" goto Sub_menu
if "%choice%"=="6" goto exit
goto Sub_menu



:: ----------------------  ENVIRONMENT SETUP  ------------- 
:SetUp_environment
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~           %mode%            ~*
echo                   *~      ENVIRONMENT SETUP      ~*
echo                   *~          %company%           ~*
echo                   *********************************
echo.
echo.
echo.

setlocal
set source_path_SYSVOL=\\corp.spintecgaming.com\NETLOGON\OutlookSignature\
set source_path_NAS=\\nas1.corp.spintecgaming.com\System_admnistrator\Scripts\Automacki podpis\Local-script
set source_path=\\corp.spintecgaming.com\NETLOGON\OutlookSignature\
:: Sourcepath just to set by default 

set destinatio_path=C:\spintec\signature\
set destinatio_path_generator=%destinatio_path%Outlook-signature-generator-*

echo Check if directory exists ...
:: Check if C:\spintec directory exists
if not exist "C:\spintec" (
    mkdir C:\spintec
    attrib +h C:\spintec
    echo making directory
)
:: Check if C:\spintec\signature directory exists
if not exist "C:\spintec\signature" (
    mkdir C:\spintec\signature
    attrib +h C:\spintec\signature
)

::------------------------------------------
if not exist "C:\spintec\signature\Outlook-signature-generator-*" (
    :: Ping the server to check connection
    ping -n 1 10.10.10.1 > nul

    :: Check the error level to verify network availability
    if %errorlevel% equ 0 (
        echo Network connection to PDC is successful !
        echo Source path is: %source_path%
        echo.
    ) else (
        echo Connection to PDC and NAS server is unavailable. Please manually input the location of scripts!
        echo "HINT: Use absolute path (USB Drive - X:\Signature)"
        echo.

        :: Prompt the user for a custom source path
        set /p source_path="Enter custom path: "
    )
    :: Validate the source path
    if not exist "%source_path%" (
        echo Source path does not exist, please check and try again.
        echo Debug: source_path="%source_path%"  :: Debug line to confirm the value
        pause
        goto Sub_menu
    ) else (
        echo Copying PowerShell scripts from "%source_path%" to "C:\spintec\signature"

        :: Copy .ps1 files
        for %%f in ("%source_path%\*.ps1") do (
            copy "%%f" "C:\spintec\signature" > nul
        )

        :: Copy .bat files
        for %%f in ("%source_path%\*.bat") do (
            copy "%%f" "C:\spintec\signature" > nul
        )
    )
)

echo.
echo Contents of C:\spintec\signature:
dir /b C:\spintec\signature
echo.
echo Environment setup is done ! 

endlocal

pause

::if %task%=="1" goto SetUp_taskscheduler
if %mode%==automatic (
    ::set automatic_environment=done
    goto SetUp_script_local_user
    )
if %mode%==manual goto MainMenu

goto SetUp_environment


:: ----------------------  SCRIPT FOR LOCAL USER  ------------- 
:SetUp_script_local_user
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~           %mode%            ~*
echo                   *~      LOCAL USER SCRIPT      ~*
echo                   *~     SET UP FOR %company%    ~*
echo                   *********************************
echo.
echo.
echo.

setlocal enabledelayedexpansion

:: Check if environment is setup
if not exist "C:\spintec" (
    echo Environment ROOT directory NOT EXISTS
    set /p choice=" Setup environment ? (Y/N) "
    
    :: Convert input to lowercase (or uppercase)
    set choice=%choice:~0,1%
    set choice=%choice: =%

    :: Convert to lowercase by using a trick
    set choice=%choice:~0,1%
    if /i "%choice%"=="y" (
        goto SetUp_environment
    ) else (
        echo Get back to Main Menu!
        pause
        goto MainMenu
    )
)

pause
:: Check if C:\spintec\signature directory exists
if not exist "C:\spintec\signature" (
    echo Environment SIGNATURE directory NOT EXISTS
    set /p choice="set up environment ? (Y/N) "
    if "%choice%"=="y" ( 
        goto SetUp_environment
        ) else (
            echo Get back to Main Menu !
            pause
            goto MainMenu
        )
)
pause
if not exist "C:\spintec\signature\Outlook-signature-generator-*" (
    echo NO PowerShell Script detected in directory. Please set up enviroment !
    set /p choice="set up environment ? (Y/N) "
    if "%choice%"=="y" ( 
        goto SetUp_environment
        ) else (
            echo Get back to Main Menu !
            pause
            goto MainMenu
        )
)


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

:: Check if PS 7 is installed 
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i
  echo PowerShell version %PSVersion7%
pause
:: If PowerShell 7 is installed use PWSH.exe to call script. If not use standard PowerShell 5
if "%PSVersion7%" equ "7" (
    echo Pulling PowerShell 7
    pwsh.exe -ExecutionPolicy Bypass -File "C:\spintec\signature\Outlook-signature-generator-%company%-V3-LOCAL.ps1" -userName "%userName%" -userTitle "%userTitle%" -userMail "%userMail%" -userTelephone "%userTelephone%" -userMobile "%userMobile%" -userCompany "%userCompany%"
) else (
    echo Pulling PowerShell 5
    powershell.exe -ExecutionPolicy Bypass -File "C:\spintec\signature\Outlook-signature-generator-%company%-V3-LOCAL.ps1" -userName "%userName%" -userTitle "%userTitle%" -userMail "%userMail%" -userTelephone "%userTelephone%" -userMobile "%userMobile%" -userCompany "%userCompany%"
)

endlocal
echo Script done !
pause
if %mode%==automatic goto SetUp_taskscheduler
if %mode%==manual goto Manual_setup_local

goto SetUp_script_local_user

:: ----------------------  SCRIPT FOR AD USER  ------------- 
:SetUp_script_AD_user
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~                             ~*
echo                   *~        AD USER SCRIPT       ~*
echo                   *~     SET UP FOR %company%    ~*
echo                   *********************************
echo.
echo.
echo.

echo Checking environment ...
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

echo Checking network connection to PDC server of %company%
ping -n 1 10.10.8.1 > nul

if %errorlevel% equ 0 (

    :: Check if PS 7 is installed if not notmal PS 5 call
    for /f  %%i in ('
      pwsh -c "($PSVersionTable.PSVersion.Major)" 
      ') do set PSVersion7=%%i
      echo PowerShell version %PSVersion7%

    if "%PSVersion7%" equ "7" (
        echo Pulling PowerShell 7
        pwsh.exe -ExecutionPolicy Bypass -File "\\corp.spintecgaming.com\NETLOGON\OutlookSignature\Outlook-signature-generator-%company%-V3.ps1"
        echo Executing PWSH command
        pause
        goto Manual_setup_local
    ) else (
        echo Pulling PowerShell 5
        powershell.exe -ExecutionPolicy Bypass -File "\\corp.spintecgaming.com\NETLOGON\OutlookSignature\Outlook-signature-generator-%company%-V3.ps1"
        echo Executing PowerShell command
        pause
        goto Manual_setup_local
    )
    

) else (
    echo No network connection to PDC server ! 
    echo Please check your network
    pause
    goto Manual_setup_local
)

goto SetUp_script_AD_user

:: ----------------------  TASK SCHEDULER SETUP  ------------- 
:SetUp_taskscheduler
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~           %mode%            ~*
echo                   *~       TASK SCHEDULER        ~*
echo                   *~     SET UP FOR %company%    ~*
echo                   *********************************
echo.
echo.
echo.

SET TASK_NAME="Signature-Task"
SET TASK_DESCRIPTION="Runs the signature creation script every day at 8 AM and at logon"
SET SCRIPT_PATH="C:\spintec\signature\Outlook-signature-generator-%company%-V3-LOCAL.ps1"

:: First check if the envirement is set up. If not set it up
if not exist %SCRIPT_PATH% (
    echo %SCRIPT_PATH% does not exist
    echo taking you to environment setup ...
    set task="1"
    echo task mode is : %task%
    pause
    goto SetUp_environment
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

if %mode%==automatic (
    echo Automatic task done ! 
    pause
    goto MainMenu
)
if %mode%==manual goto Manual_setup_local

goto SetUp_taskscheduler


:: ----------------------  CHECK TOOLS MENU  ------------- 
:CHK_tools
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~       CHECK TOOLS MENU      ~*
echo                   *********************************
echo                   #  $ Menu with simple tools     # 
echo                   #     just to make sure         # 
echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
echo                   #                               #
echo                   #  1. NETWORK                   #
echo                   #  2. POWERSHELL                #
echo                   #  3. ENVIRONMENT               #
echo                   #                               #
echo                   #  4. BACK TO MAIN MENU         #
echo                   #  5. EXIT                      #
echo                   #                               #
echo                   *********************************
set /p choice=" Please select an option (1-5):" 

if "%choice%"=="1" goto Network_menu
if "%choice%"=="2" goto PowerShell_menu 
if "%choice%"=="3" goto Environment_menu
if "%choice%"=="4" goto MainMenu
if "%choice%"=="5" goto exit
goto CHK_tools

:: ----------------------  NETWORK TOOLS MENU  ------------- 
:Network_menu
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~         CHECK TOOLS         ~*
echo                   *********************************
echo                   #      $ Network menu           # 
echo                   #                               # 
echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
echo                   #                               #
echo                   #  1. PING PDC                  #
echo                   #  2. PING NAS                  #
echo                   #  3. SHOW NET ADAPTER STATUS   #
echo                   #  4. SET DNS                   #
echo                   #                               #
echo                   #  5. BACK TO MAIN MENU         #
echo                   #  6. EXIT                      #
echo                   #                               #
echo                   *********************************
set /p choice=" Please select an option (1-6):" 

echo.
echo.
echo.
echo.
echo.
echo.

if "%choice%"=="1" (
    cls
    echo.
    echo                   *********************************
    echo                   *~         CHECK TOOLS         ~*
    echo                   *********************************
    echo                   #      $ Network menu           # 
    echo                   #                               # 
    echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
    echo                   #                               #
    echo                   #    $ PING PDC                 #
    echo                   #                               #    
    echo                   *********************************
    echo.
    echo.
    echo.
    echo.
    echo.
    ping 10.10.8.1
    echo %ping%
    echo.
    echo Error level is : %errorlevel%
    echo.
    if %errorlevel% equ 0 (
        echo Connection to PDC DEJLA !
        pause
        goto Network_menu
    ) else (
        echo No connection to PDC server
        pause
        goto Network_menu
    )
)
if "%choice%"=="2" (
    cls
    echo.
    echo                   *********************************
    echo                   *~         CHECK TOOLS         ~*
    echo                   *********************************
    echo                   #      $ Network menu           # 
    echo                   #                               # 
    echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
    echo                   #                               #
    echo                   #    $ PING NAS                 #
    echo                   #                               #    
    echo                   *********************************
    echo.
    echo.
    echo.
    echo.
    echo.
    ping 10.10.16.101
    echo %ping%
    echo.
    echo Error level is : %errorlevel%
    echo.
    if %errorlevel% equ 0 (
        echo Connection to NAS DEJLA !
        pause
        goto Network_menu
    ) else (
        echo No connection to NAS server
        pause
        goto Network_menu
    )
)
if "%choice%"=="3" (
    cls
    echo.
    echo                   *********************************
    echo                   *~         CHECK TOOLS         ~*
    echo                   *********************************
    echo                   #      $ Network menu           # 
    echo                   #                               # 
    echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
    echo                   #                               #
    echo                   #    $ NETWORK ADAPTERS         #
    echo                   #                               #    
    echo                   *********************************
    echo.
    echo.
    echo.
    echo.
    echo.
    :: Loop through each network interface
    for /f "tokens=2 delims=:" %%A in ('netsh interface show interface ^| findstr "Connected"') do (
        set "adapter=%%A"
        setlocal enabledelayedexpansion
        set "adapter=!adapter:~1!"

        echo Adapter Name: !adapter!

        ipconfig /all | findstr /i /c:"!adapter!" /c:"IPv4 Address" /c:"Subnet Mask" /c:"Default Gateway" /c:"DNS Servers"

        echo -------------------------------------------
        endlocal
    )


    pause
    goto Network_menu
)
if "%choice%"=="4" (
    cls
    echo.
    echo                   *********************************
    echo                   *~         CHECK TOOLS         ~*
    echo                   *********************************
    echo                   #      $ Network menu           # 
    echo                   #                               # 
    echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
    echo                   #                               #
    echo                   # $ SET DNS TO NETWORK ADAPTER  #
    echo                   #                               #    
    echo                   *********************************
    echo.
    echo.
    echo.
    echo.
    echo.

    :: Get the name of the active network adapter
    for /f "tokens=2 delims=:" %%A in ('netsh interface show interface ^| findstr "Connected"') do (
        set "adapter=%%A"
        setlocal enabledelayedexpansion
        set "adapter=!adapter:~1!"
        echo Configuring DNS for Adapter: !adapter!

        netsh interface ip set dns name="!adapter!" source=static addr=10.10.8.1 register=PRIMARY
        netsh interface ip add dns name="!adapter!" addr=1.1.1.1 index=2

        echo DNS settings updated for !adapter!.
        echo --------------------------------------------
        endlocal
    )

    pause
    goto Network_menu

)
if "%choice%"=="5" goto MainMenu
if "%choice%"=="5" exit /b
goto CHK_tools

:: ----------------------  POWERSHELL MENU  ------------- 
:PowerShell_menu 
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~         CHECK TOOLS         ~*
echo                   *********************************
echo                   #      $ POWERSHELL             # 
echo                   #                               # 
echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
echo                   #                               #
echo                   #   $ VERSION OF INSTALLED      #
echo                   #        POWERSHELL             #
echo                   #                               #
echo                   *********************************
echo.
echo.
echo.
:: Check if PS 7 is installed 
for /f  %%i in ('
  pwsh -c "($PSVersionTable.PSVersion.Major)" 
  ') do set PSVersion7=%%i
  echo PowerShell version %PSVersion7%
echo.

if "%PSVersion7%" equ "7" (
    echo PowerShell 7 is isntalled

) else (
    echo PowerShell 5 is installed
)

pause
goto CHK_tools


:: ----------------------  ENVIRONMENT CHECK MENU  ------------- 
:Environment_menu
cls
echo.
echo.
echo.
echo                   *********************************
echo                   *~         CHECK TOOLS         ~*
echo                   *********************************
echo                   #      $ ENVIRONMENT            # 
echo                   #                               # 
echo                   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~# 
echo                   #                               #
echo                   #   $ CHECKING IF ENVIRONMENT   #
echo                   #     IS SETUP CORECTLY         #
echo                   #                               #
echo                   *********************************
echo.
echo.
echo.
echo Checking if environment is set up.
echo.
:: Check if C:\spintec directory exists
if not exist "C:\spintec" (
    echo Directory does not exist.
    echo Do you want to create it ?
    set /p choice=" Do you want to setup envirement ? (Y/N)"
    
    if "%choice%"=="Y" (
        echo Seting up environment.
        mkdir C:\spintec
        attrib +h C:\spintec
    
        :: Check if C:\spintec\signature directory exists
        if not exist "C:\spintec\signature" (
            mkdir C:\spintec\signature
            attrib +h C:\spintec\signature
            
            mkdir C:\spintec\signature\test
            attrib +h C:\spintec\signature\test
        )
        echo Environment is set up.
        pause
        goto CHK_tools    
    ) else (
        echo As you wish.
        pause
        goto CHK_tools
    )

)
echo Envirement is set up.
echo Contents of C:\spintec\signature:
dir /b C:\spintec\signature

pause
goto CHK_tools