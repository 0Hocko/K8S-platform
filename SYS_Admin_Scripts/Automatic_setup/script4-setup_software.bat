@echo off
setlocal
:: Script CViBA Automation !
:: Script will setup IP address, create shortcut, install programs ...
::
echo.
echo.
echo.
echo   _____   ___ ___   _
echo  / __\ \ / (_) _ ) /_\
echo ^| (__ \ V / ^| ^| _ \/ _ \
echo  \___^| \_/ ^|^|___/_/ \_\
echo.
echo.                            POWER
echo.
echo.
echo.
echo /--------------\
echo $  SET DNS IP  $
echo \--------------/
echo.
echo.

:SetDNS
setlocal enabledelayedexpansion

echo DNS servers settings...
echo.
:: List all active network adapters
echo Listing active network adapters...
echo.
set count=0
for /f "tokens=1,2,3,* delims= " %%a in ('netsh interface show interface ^| findstr /R "Ethernet Wi-Fi"') do (
    set /a count+=1
    set adapter!count!=%%d
    echo !count!^: %%d
)

:: Ask what adapter  to use
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

pause

echo.
echo.
echo.
echo /-------------------------------------\
echo $ SHORTCUTS -- NAS -- EDC -- INTRANET $
echo \-------------------------------------/
echo.
echo.
echo Copying icons from server to hidden folder on C drive.
echo
:: Hiden directory
if not exist "C:\spintec\icons" (
    mkdir C:\spintec\icons
    attrib +h C:\spintec\icons /s /d
    attrib +h C:\spintec /s /d
) else (
    echo C:\spintec\icons is already there ...
)
copy \\10.10.16.101\System_admnistrator\Spintec-content-scripts\Automatization-install-newpc\icons C:\spintec\icons

:: Shortcut for NAS
:ShortCutNAS
echo Creating network shortcuts...
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\MREZNI DISK.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "\\nas1.corp.spintecgaming.com\" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%
:: Run temp VBO script
cscript /nologo %SCRIPT%
:: Delete that VBO jajca
del %SCRIPT%
echo Network shortcut created on Desktop.
echo.

:: Shortcut for EDC
:ShortCutEDC
echo Creating EDC shortcuts...
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\EDC.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "http://10.10.8.2:9090/addons/userslogin.html" >> %SCRIPT%
echo oLink.IconLocation = "C:\spintec\icons\edc.ico" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%
cscript /nologo %SCRIPT%
del %SCRIPT%
echo EDC shortcut created on Desktop.
echo.

:: Shortcut for Intranet
:ShortCutIntranet
echo Creating Intranet shortcuts...
set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\Intranet.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "https://spintecgaming.sharepoint.com/sites/intranet-main" >> %SCRIPT%
echo oLink.IconLocation = "C:\spintec\icons\intranet.ico" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%
cscript /nologo %SCRIPT%
del %SCRIPT%
echo Intranet shortcut created on Desktop.
echo.
echo.
echo.

echo /------------------------------\
echo $ Install programs with WinGet $
echo \------------------------------/

echo.
echo.

:WinGet
echo Installing required software...

:: 7-zip
winget install --id 7zip.7zip --silent --accept-package-agreements

:: Adobe Reader -- Source MSSTORE
winget install --id XPDP273C0XHQH2 --silent --accept-package-agreements

:: LAPS
winget install --id Microsoft.LAPS --silent --accept-package-agreements

:: VLC
winget install --id XPDM1ZW6815MQM --silent --accept-package-agreements

:: Chrome
winget install -e --id Google.Chrome --silent --accept-package-agreements

:: Mozilla FireFox ESR
winget install -e --id Mozilla.Firefox.ESR --silent --accept-package-agreements

:: GIMP
winget install -e --id GIMP.GIMP --silent --accept-package-agreements

:: NotePad++
winget install -e --id Notepad++.Notepad++ --silent --accept-package-agreements

:: Teams
winget install --id Microsoft.Teams --scope machine --accept-package-agreements --accept-source-agreements --silent

echo.
echo All required software has been installed.
echo.
echo.
echo.

echo Clearing temp Task Scheduler and Autologin registry ...
:: Clearing temp data and scheduler ...
schtasks /delete /tn "RunScript4-setup_software" /f

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultDomainName" /f

echo Auto-Login settings reverted to default.

echo.
echo /------------------------------\
echo $        End of Script         $
echo \------------------------------/

echo
echo
echo        .---.
echo       /     \
echo       \.@-@./
echo       /`\_/`\
echo      //  _  \\
echo.     | \     )|_
echo.    /`\_`>  <_/ \
echo    \__/'---'\__/

echo.
echo.
echo Script execution completed. Press any key to exit...
echo ! Reboot !
pause


:: ------------------ SHORTCUTS -------------------------------------
:shortcuts_dekstop
setlocal enabledelayedexpansion
echo.
echo.
echo.

echo Checking if icons are on C drive 
echo.
if not exist "C:\spintec\icons" (
    mkdir C:\spintec\icons
    attrib +h C:\spintec\icons /s /d
    attrib +h C:\spintec /s /d
    copy \\10.10.16.101\System_admnistrator\Spintec-content-scripts\Automatization-install-newpc\icons C:\spintec\icons

) else (
    echo Icons are on local drive.
)

:: Shortcut for NAS
:ShortCutNAS
set "shortcutName=MREZNI DISK"
set "networkPath=\\nas1.corp.spintecgaming.com\"
set "iconPath="  
set "startMenuFolder=%USERPROFILE%\Start Menu\%USERNAME%"

REM Create the directory if it doesn't exist
if not exist "%startMenuFolder%\%startMenuFolder%" mkdir "%startMenuFolder%"

REM Create the shortcut with the specified icon (or leave it blank)
echo [Shortcut] > "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconFile=%iconPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconIndex=0 >> "%startMenuFolder%\!shortcutName!.lnk"

REM Define the target path and name
set "targetPath=%networkPath%"
set "shortcutName=%shortcutName%"

REM Add the network path to the shortcut
echo TargetDir=%targetPath% >> "%startMenuFolder%\!shortcutName!.lnk"
echo WorkingDir=%targetPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconFile=%iconPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconIndex=0 >> "%startMenuFolder%\!shortcutName!.lnk"
echo Mrezni disk shortcut done

:: Shortcut for EDC
:ShortCutEDC
set "shortcutName=EDC"
set "networkPath=http://10.10.8.2:9090/addons/userslogin.html"
set "iconPath=C:\spintec\icons\edc.ico"  
set "startMenuFolder=%USERPROFILE%\Start Menu\%USERNAME%"

REM Create the directory if it doesn't exist
if not exist "%startMenuFolder%\%startMenuFolder%" mkdir "%startMenuFolder%"

REM Create the shortcut with the specified icon (or leave it blank)
echo [Shortcut] > "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconFile=%iconPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconIndex=0 >> "%startMenuFolder%\!shortcutName!.lnk"

REM Define the target path and name
set "targetPath=%networkPath%"
set "shortcutName=%shortcutName%"

REM Add the network path to the shortcut
echo TargetDir=%targetPath% >> "%startMenuFolder%\!shortcutName!.lnk"
echo WorkingDir=%targetPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconFile=%iconPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconIndex=0 >> "%startMenuFolder%\!shortcutName!.lnk"
echo EDC shortcut done

:: Shortcut for Intranet
:ShortCutIntranet
set "shortcutName=Intranet"
set "networkPath=https://spintecgaming.sharepoint.com/sites/intranet-main"
set "iconPath=C:\spintec\icons\intranet.ico"  
set "startMenuFolder=%USERPROFILE%\Start Menu\%USERNAME%"

REM Create the directory if it doesn't exist
if not exist "%startMenuFolder%\%startMenuFolder%" mkdir "%startMenuFolder%"

REM Create the shortcut with the specified icon (or leave it blank)
echo [Shortcut] > "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconFile=%iconPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconIndex=0 >> "%startMenuFolder%\!shortcutName!.lnk"

REM Define the target path and name
set "targetPath=%networkPath%"
set "shortcutName=%shortcutName%"

REM Add the network path to the shortcut
echo TargetDir=%targetPath% >> "%startMenuFolder%\!shortcutName!.lnk"
echo WorkingDir=%targetPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconFile=%iconPath% >> "%startMenuFolder%\!shortcutName!.lnk"
if defined iconPath echo IconIndex=0 >> "%startMenuFolder%\!shortcutName!.lnk"
echo Intranet shortcut is done

echo.
echo.
echo.
echo ALL DONE ...
echo Press any key to return to MAIN MENU
endlocal
pause
goto mainMenu