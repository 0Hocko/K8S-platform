@echo off
setlocal enabledelayedexpansion
:: Script CViBA Automation !
:: Created for faster setting up new laptops

:: ------------------ MAIN MENU -----------------------------------
:mainMenu
cls
echo.
echo.
echo.
echo                             _____   ______   _
echo                            / __\ \ /(_) _ ) /_\
echo                           ^| (__ \ V /^|^| _ \/ _ \
echo                            \___^| \_/ ^|^|___/_/ \_\
echo.                         
echo.                                                   POWER
echo.
echo.
echo.
echo                   ==============================================
echo                   $ Welcome to CVIBA AUTOMATION Terminal Menu! $
echo                   ==============================================
echo                   #                                            #
echo                   #             1. SETUP ENVIREMENT            #
echo                   #             2. SETUP USER                  #
echo                   #             3. SETUP NETWORK               #
echo                   #             4. SETUP PROGRAMS              #
echo                   #             5. CLEAN BALAST                #
echo                   #             6. Exit                        #
echo                   #                                            #
echo                   ==============================================
echo.
set /p          choice=Please select an option (1-6): 

if "%choice%"=="1" goto setup_envirement_menu
if "%choice%"=="2" goto setup_user_menu
if "%choice%"=="3" goto setup_network_menu
if "%choice%"=="4" goto setup_programs_menu
if "%choice%"=="5" goto clean_balast
if "%choice%"=="6" goto quit
goto mainMenu

:: ------------------ ENVIREMENT SET UP -------------------------
:setup_envirement_menu
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                    =================================================
echo                                   SETUP ENVIREMENT MENU
echo                    =================================================
echo                    # 1. Main Menu                                  #
echo                    # 2. Copy icons and data from server to local   #
echo                    # 3. Create shortcuts on desktop                #
echo                    # 4. Exit                                       #
echo                    =================================================
echo.
echo.
echo.
set /p choice=Please select an option (1-4): 

if "%choice%"=="1" goto mainMenu
if "%choice%"=="2" goto setup_envirement_script
if "%choice%"=="3" goto shortcuts_dekstop
if "%choice%"=="4" goto quit
goto setup_envirement_menu


:: ------------------ ENVIREMENT SETUP -------------------------------------
:setup_envirement_script
echo.
echo.
echo.
echo Copying data to C drive...
echo.
:: Checking if directory SCRIPTS exists on C:\
if not exist "C:\spintec" (
    mkdir C:\spintec
    attrib +h C:\spintec\icons /s /d
    attrib +h C:\spintec /s /d
    if not exist "C:\spintec\icons" (
        mkdir C:\spintec\icons
        copy \\10.10.16.101\System_admnistrator\Spintec-content-scripts\Automatization-install-newpc\icons C:\spintec\icons
    )
    else (
        copy \\10.10.16.101\System_admnistrator\Spintec-content-scripts\Automatization-install-newpc\icons C:\spintec\icons
    )
) else (
    echo Directory is already there ...
)

:: Copying scripts
:: set "source=\\10.10.16.101\System_admnistrator\Scripts\Automatic_setup\*"
:: set "destination=C:\spintec"
:: xcopy "%source%" "%destination%" /s /e /y
:: echo.
echo Envirement is ready ...
echo Please continue ...
pause
goto mainMenu

:: ------------------ SHORTCUTS -------------------------------------
:shortcuts_dekstop
::setlocal enabledelayedexpansion
echo.
echo Checking if icons are on C drive

:: Ensure icons directory exists on C drive
if not exist "C:\spintec\icons" (
    mkdir C:\spintec\icons
    if %errorlevel% neq 0 (
        echo [%date% %time%] Failed to create C:\spintec\icons directory. Exiting. >> C:\spintec\shortcut_log.txt
        exit /b
    )
    attrib +h C:\spintec\icons /s /d
    attrib +h C:\spintec /s /d
    xcopy /Y /E "\\10.10.16.101\System_admnistrator\Spintec-content-scripts\Automatization-install-newpc\icons" "C:\spintec\icons\"
    if %errorlevel% neq 0 (
        echo [%date% %time%] Failed to copy icons. Exiting. >> C:\spintec\shortcut_log.txt
        exit /b
    )
) else (
    echo Icons are on local drive.
)

:: Call function to create shortcut. Change variables here 
call :CreateShortcut "MREZNI DISK" "\\nas1.corp.spintecgaming.com\" ""
call :CreateShortcut "EDC" "http://10.10.8.2:9090/addons/userslogin.html" "C:\spintec\icons\edc.ico"
call :CreateShortcut "Intranet" "https://intranet.sharepoint.com/sites/intranet-main" "C:\spintec\icons\intranet.ico"

:: For R&D part of the company you can add RM and OP 
echo Do you want to add REDMINE and OPENPROJECT shortcut too ?
set /p choice=Enter choice (Y/N) : 
if /i "%choice%"=="Y" (
    echo.
    echo Adding REDMINE AND OPENPROJECT to the desktop

    call :CreateShortcut "RedMine" "http://redmine.spintec.si" "C:\spintec\icons\redmine-logo.ico"
    call :CreateShortcut "OpenProject" "http://openproject.spintec.si" "C:\spintec\icons\spintec-logo-64.ico"

    ) else (
        echo.
        echo.
        echo ok done.
        pause
        goto setup_envirement_menu
    )


echo.
echo ALL DONE ...
echo.
endlocal
pause
goto setup_envirement_menu

:: --- CreateShortcut Function
:CreateShortcut
set "shortcutName=%~1"
set "targetPath=%~2"
set "iconPath=%~3"
set "desktopPath=%USERPROFILE%\Desktop\%shortcutName%.lnk"

:: Have to use POWERSHELL just because ....
powershell -noprofile -executionpolicy bypass -command ^ "try {$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut('%desktopPath%'); $sc.TargetPath = '%targetPath%'; if ('%iconPath%' -ne '') { $sc.IconLocation = '%iconPath%' }; $sc.Save(); Add-Content -Path 'C:\spintec\shortcut_log.txt' -Value '[%date% %time%] Shortcut for %shortcutName% created successfully.'; } catch { Add-Content -Path 'C:\spintec\shortcut_log.txt' -Value '[%date% %time%] Failed to create shortcut for %shortcutName%. Error: ' + $_.Exception.Message; exit 1; }"

if %errorlevel% neq 0 (
    echo [%date% %time%] Failed to create shortcut for %shortcutName%. Exiting. >> C:\spintec\shortcut_log.txt
    exit /b 1
)
exit /b 0

:: ------------------ USER and GROUP SET UP ------------------------- 
:setup_user_menu
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                    =======================================
echo                          SETUP USER and GROUP MENU
echo                    =======================================
echo                    #          1. Main Menu               #
echo                    #          2. CREATE USER             #
echo                    #          3. REMANE PC               #
echo                    #          4. JOIN DOMAIN             #
echo                    #          5. Exit                    #
echo                    =======================================
echo.
set /p choice=Please select an option (1-5): 

if "%choice%"=="1" goto mainMenu
if "%choice%"=="2" goto create_user
if "%choice%"=="3" goto rename_pc
if "%choice%"=="4" goto join_domain
if "%choice%"=="5" goto quit
goto setup_user_menu

:create_user
echo.
echo.
echo.
echo.
echo Enter data for new user profile
echo.
:: Prompt for username, password, and group --- data
set /p username=Enter the new username :
set /p password=Enter the new password :
echo.
echo Select group for the new user %username%
echo.
echo 1. Administrator
echo 2. User
set /p group=Please select an optino (1-2):

if "%group%"=="1" set group="Administrator"
if "%group%"=="2" set group="User"

:: Add the new user
net user %username% %password% /add
if %errorlevel% neq 0 (
    echo Failed to add the user. Check if the username already exists or if there are other issues.
    echo Have you run script as Admin ? 
    echo Use SUDO
    pause
    exit /b
)

:: Add the user to the specified group
net localgroup %group% %username% /add
if %errorlevel% neq 0 (
    echo Failed to add the user to the group. Check if the group exists or if there are other issues.
    echo Make sure you have run the sctipt as ADMin
    pause
    exit /b
)

echo.
echo.
echo User %username% added and assigned to the %group% group successfully.
echo.
echo Please continue ...
pause
goto setup_user_menu

:: --- Renaming pc 
:rename_pc
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                    =======================================
echo                                  RENAMING PC
echo                    =======================================
echo.
echo.
echo.
set /p "name=Enter new computer name : "
wmic computersystem where "caption='%computername%'" rename "%name%"
echo.
echo Computer is renamed ...
echo.
echo.
echo PC MUST BE REBOOTED TO APPLY NEW NAME
echo.
echo # Do you want to reboot PC to apply new name ?
echo.
set /p choice=Enter choice (Y/N) : 
if /i "%choice%"=="Y" (
    echo.
    echo PC will reboot after creating task scheduler to re-run this script
    echo and temporary registry will be applyed to auto login new user after reboot

    :: Check if the script MAIN is present on local disk ... if not run from NAS ...
    if not exist "C:\SCRIPTS\MAIN_SET-UP_SCRIPT_V1.bat" (
        echo.
        echo.
        echo Script does not exist on local machine ...
        echo.
        echo Copying from server to C:\ ...
        set "source=\\10.10.16.101\System_admnistrator\Scripts\Automatic_setup\MAIN_SET-UP_SCRIPT_V1.bat"
        set "destination=C:\spintec"
        xcopy "%source%" "%destination%" /s /e /y
        echo.
        goto create_task_scheduler
    ) else (
        echo.
        echo.
        echo Script MAIN is already there ...
        echo Run it like its hot
        goto create_task_scheduler
    )
:create_task_scheduler

    schtasks /create /tn "RUN-MAIN_SET-UP_SCRIPT" /tr "C:\spintec\MAIN_SET-UP_SCRIPT_V1.bat" /sc onstart /ru SYSTEM /f

    :: Modifying registry to autologin after reboot
    echo Enabling autologin ....
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "1" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t REG_SZ /d "%username%" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /t REG_SZ /d "%password%" /f

    echo.
    echo.
    echo Auto-Login enabled. The system will log in automatically on the next reboot.
    echo Press any keys to REBOOT
    pause
    shutdown /r /t 0
)

:join_domain
echo.
echo.
echo.
echo.
echo Joining domain SPINTECGAMING
echo.
echo.

set DOMAIN_NAME=corp.spintecgaming.com
set DOMAIN_USER=Administrator
set /p DOMAIN_PASS=Enter Domain Admin Password :
set COMPUTER_NAME=%COMPUTERNAME%

echo Joining %COMPUTER_NAME% to the domain %DOMAIN_NAME% ...

netdom join %COMPUTER_NAME% /domain:%DOMAIN_NAME% /userD:%DOMAIN_USER% /passwordD:%DOMAIN_PASS% /OU:"OU=Computers,DC=YourDomain,DC=com"

echo.
if %errorlevel%==0 (
    echo Successfully joined the domain. The computer will need reboot.
    echo NOTE : Computer might need reboot after joining domain ...
    echo Press any key to go to MAIN MENU
    pause
    goto mainMenu
) else (
    echo Failed to join the domain. REBOOT is missing 
    echo Please reboot computer first than try again
    echo Going to main Menu ..
    echo press any key to continue to Main menu
    pause
    goto mainMenu
)

:: -------------------- NETWORK SETUP --------------------------------- 
:setup_network_menu
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                    =======================================
echo                                 SETUP NETWORK 
echo                    =======================================
echo.
echo.
:SetDNS
setlocal enabledelayedexpansion
echo.
echo Setting up DNS ...
echo.
echo Listing active network adapters...
echo.
:: Search for network adapters and promt user to select network adapter to change parameters
set count=0
for /f "tokens=1,2,3,* delims= " %%a in ('netsh interface show interface ^| findstr /R "Ethernet Wi-Fi"') do (
    set /a count+=1
    set adapter!count!=%%d
    echo !count!^: %%d
)

echo.
set /p adapternum=Enter the number of the adapter you want to change DNS settings for:

:: Validate input jus to be sure
if not defined adapter%adapternum% (
    echo Invalid selection.
    pause
    exit /b
)

:: Extract the chosen adapter name
set adaptername=!adapter%adapternum%!
echo.
echo You chose adapter: !adaptername!
echo.
:: Change DNS settings for the selected adapter
echo Setting DNS for !adaptername!...
netsh interface ipv4 set dnsservers name="!adaptername!" static 10.10.8.1 primary
netsh interface ipv4 add dnsservers name="!adaptername!" 1.1.1.1 index=2
echo DNS settings updated for !adaptername!.

echo.
echo. Network setup done.
echo Press anykey to return to MAIN MENU
pause
goto mainMenu

:: -------------------- SETUP PROGRAMS --------------------------------
:setup_programs_menu
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                    =======================================
echo                               INSTALLING PROGRAMS
echo                    =======================================
echo.

:: Check if WinGet is installed
echo Checking if WinGet is installed on the system...
if exist "%LocalAppData%\Microsoft\WindowsApps\winget.exe" (
    echo Winget is installed
    echo.
) else (
    echo Winget is not installed. Please install Winget first.
    pause
    exit /b
)

:: Define software options (no need for arrays)
set software1=7zip.7zip
set software2=XPDP273C0XHQH2  :: Adobe Reader
set software3=Microsoft.LAPS
set software4=XPDM1ZW6815MQM  :: VLC
set software5=Google.Chrome
set software6=Mozilla.Firefox.ESR
set software7=GIMP.GIMP
set software8=Notepad++.Notepad++
set software9=Microsoft.Teams
set software10=geeksoftwareGmbH.PDF24Creator  :: PDF24 Tool

:: Initialize choices
set choice1=0
set choice2=0
set choice3=0
set choice4=0
set choice5=0
set choice6=0
set choice7=0
set choice8=0
set choice9=0
set choice10=0

:: Display available software to install with checkboxes
:menu
cls
echo Select software to install (Press number 1-10 to toggle selection, or Enter to install selected software):
echo.

:: Show the list of software with their current selection status
echo [1] [ ] 7zip (7zip.7zip)      - Not selected
echo [2] [ ] Adobe Reader (XPDP273C0XHQH2) - Not selected
echo [3] [ ] LAPS (Microsoft.LAPS) - Not selected
echo [4] [ ] VLC (XPDM1ZW6815MQM)  - Not selected
echo [5] [ ] Chrome (Google.Chrome) - Not selected
echo [6] [ ] Firefox ESR (Mozilla.Firefox.ESR) - Not selected
echo [7] [ ] GIMP (GIMP.GIMP)       - Not selected
echo [8] [ ] Notepad++ (Notepad++.Notepad++) - Not selected
echo [9] [ ] Teams (Microsoft.Teams) - Not selected
echo [10] [ ] PDF24 (geeksoftwareGmbH.PDF24Creator) - Not selected

:: Display current choices
for /L %%i in (1,1,10) do (
    set "choice_var=choice%%i"
    if !%choice_var%! == 1 (
        echo [%%i] [x] %%software%%i%% - Selected
    ) else (
        echo [%%i] [ ] %%software%%i%% - Not selected
    )
)

:: Get user input (spacebar to toggle, enter to confirm)
set /p input=Press a number (1-10) to toggle selection, or press Enter to install selected software: 

:: Toggle selection based on input
if "%input%"=="" goto install
if "%input%" geq "1" if "%input%" leq "10" (
    set /a "choice%input%=!choice%input%! + 1"
    if !choice%input%! geq 2 set choice%input%=0
    goto menu
)

:: Installation logic
:install
cls
echo Installing selected software...
echo.

:: Loop through all software and install selected ones
for /L %%i in (1,1,10) do (
    set "choice_var=choice%%i"
    set "software_var=software%%i"
    if !%choice_var%! == 1 (
        echo Installing %%software_var%%...
        if %%i==1 (
            winget install --id 7zip.7zip --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==2 (
            winget install --id XPDP273C0XHQH2 --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==3 (
            winget install --id Microsoft.LAPS --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==4 (
            winget install --id XPDM1ZW6815MQM --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==5 (
            winget install --id Google.Chrome --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==6 (
            winget install --id Mozilla.Firefox.ESR --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==7 (
            winget install --id GIMP.GIMP --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==8 (
            winget install --id Notepad++.Notepad++ --accept-package-agreements --accept-source-agreements --silent --force
        ) else if %%i==9 (
            winget install --id Microsoft.Teams --scope machine --accept-package-agreements --accept-source-agreements --silent
        ) else if %%i==10 (
            winget install --id geeksoftwareGmbH.PDF24Creator --accept-package-agreements --accept-source-agreements --silent --force
        )
    )
)

echo.
echo All selected software has been installed.
pause
goto mainMenu


:: -------------------- CLEAR BALAST ----------------------------------
:clean_balast
cls
echo.
echo.
echo.
echo *********************************************************************
echo *  Clearing temp Task Scheduler and Autologin registry script...    *
echo *********************************************************************
echo.
echo.
echo.
echo.
schtasks /delete /tn "RUN-MAIN_SET-UP_SCRIPT" /f

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /f

echo Auto-Login settings reverted to default.
echo.
echo Press any key to return to MAIN MENU ..
pause
goto mainMenu

:: -------------------- EXIT ---------------------------------
:: EXIT of the script.
:quit
cls

echo.
echo.

echo __________________                                         __________________________
echo                   \                                       /
echo                    =======================================
echo                             Good bye ! Cviba out ..
echo                    =======================================
echo __________________/                                       \_________________________
echo.
echo.
echo _______________________________________________________________________________________
echo.
echo                             _____   ______   _
echo                            / __\ \ /(_) _ ) /_\
echo                           ^| (__ \ V / ^|^| _ \/ _ \
echo                            \___^| \_/  ^|^|___/_/ \_\
echo.                         
echo.                                                   POWER
echo.
echo            .---.                                                    .---.         
echo           /     \                                                  /     \        
echo           \.@-@./                                                  \.@-@./        
echo           /`^\_^/^`\                                                  /`^\_^/^`\     
echo          //  _  \\                                                //  _  \\          
echo         ^| \     )^|_                                              ^| \     )^|_    
echo        /`^\_^`^>  ^<_/ \                                             /`^\_^`^>  ^<_/ \ 
echo        \__/'---'\__/                                             \__/'---'\__/     
echo.
echo ___________________________________________________________________________________________

pause
exit /b %ERRORLEVEL%
