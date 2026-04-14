@echo off
setlocal
:: Script CViBA Automation !
:: Script will join computer to domain corp.spintecgaming.com ...
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
echo $     JOIN DOMAIN      $
echo \----------------------/
echo.

:: Set domain name and credentials
set DOMAIN_NAME=corp.spintecgaming.com
set DOMAIN_USER=Administrator
set /p DOMAIN_PASS=Enter Domain Password :
set COMPUTER_NAME=%COMPUTERNAME%

echo Joining %COMPUTER_NAME% to the domain %DOMAIN_NAME% ...

netdom join %COMPUTER_NAME% /domain:%DOMAIN_NAME% /userD:%DOMAIN_USER% /passwordD:%DOMAIN_PASS% /OU:"OU=Computers,DC=YourDomain,DC=com"


:: Check if the join was successful
if %errorlevel%==0 (
    echo Successfully joined the domain. The computer will need reboot.
) else (
    echo Failed to join the domain. REBOOT is missing :)
)

echo.
echo.
:: before continueing and creating new task scheduler is good to clean up the old one to run this script
schtasks /delete /tn "RunScript3-join_domain" /f

:: Prompt user to join domain
echo *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
echo # Do you wanna Install programs ?
echo *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
echo.

set /p choice=(Y/N):

if /i "%choice%"=="Y" (
    echo Creating task to run script to install software after reboot ...
    :: Schedule script to run after reboot
    schtasks /create /tn "RunScript4-setup_software" /tr "C:\SCRIPTS\script4-setup_software.bat" /sc onstart /ru SYSTEM /f

   :: start /wait cmd /c "C:\SCRIPTS\script4-setup_software.bat"
) else (
    echo Skipping software install ...
)
echo Reboot in 5 sec
timeout /t 5 /nobreak

:: Reboot the system
shutdown /r /t 0
