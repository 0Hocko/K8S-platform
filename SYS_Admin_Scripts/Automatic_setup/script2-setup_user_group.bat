@echo off
setlocal
:: Script CViBA Automation !
:: Script will setup user account and group  ...
::
echo.
echo.
echo   _____   ___ ___   _
echo  / __\ \ / (_) _ ) /_\
echo ^| (__ \ V / ^| ^| _ \/ _ \
echo  \___^| \_/ ^|^|___/_/ \_\
echo.
echo.
echo.
echo /----------------------\
echo $     USER PROFILE     $
echo \----------------------/


:: Prompt for username, password, and group
set /p username=Enter the new username :
set /p password=Enter the new password :
set /p group=Enter the group to add the user to (e.g., Users, Administrators):

:: Add the new user
net user %username% %password% /add
if %errorlevel% neq 0 (
    echo Failed to add the user. Check if the username already exists or if there are other issues.
    pause
    exit /b
)

:: Add the user to the specified group
net localgroup %group% %username% /add
if %errorlevel% neq 0 (
    echo Failed to add the user to the group. Check if the group exists or if there are other issues.
    pause
    exit /b
)

echo User %username% added and assigned to the %group% group successfully.


:: Rename PC
echo.
echo /-------------------\
echo $ RENAME OF LAPTOP  $
echo \-------------------/
echo.
set /p "name=Enter new computer name : "
wmic computersystem where "caption='%computername%'" rename "%name%"

echo Computer is renamed ...
echo.
:: Before needed reboot promt user if he wants to join domain so task is created

:: Prompt user to join domain
echo *~~~~~~~~~~~~~~~~~~~~~~~~~~~*
echo # Do you wanna join Domain ?
echo *~~~~~~~~~~~~~~~~~~~~~~~~~~~*
echo.

set /p choice=(Y/N):

if /i "%choice%"=="Y" (
    echo Creating task to run script to join domain after reboot ...
    schtasks /create /tn "RunScript3-join_domain" /tr "C:\SCRIPTS\script3-join_domain.bat" /sc onstart /ru SYSTEM /f

    :: Modifying registry to autologin after reboot
    echo Enabling autologin ....
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t REG_SZ /d "1" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t REG_SZ /d "%username%" /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /t REG_SZ /d "%password%" /f

    echo.
    echo.
    echo Auto-Login enabled. The system will log in automatically on the next reboot.
    echo Press any keys to continue ...
    pause
    ::    start /wait cmd /c "C:\SCRIPTS\script3-join_domain.bat"
) else (
    echo Skipping ...
)
:: Continue with the rest of the script
echo Resuming reboot process ...
echo.
echo PC will reboot after 10 secound
echo.
timeout /t 10

shutdown /r /t 0

pause
