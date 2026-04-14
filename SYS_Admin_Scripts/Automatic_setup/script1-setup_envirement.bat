@echo off
setlocal
:: Script CViBA Automation !
:: Script will setup envirement for automation and setup pc for use.
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
echo.

echo Copying Scripts to C:\SCRIPTS ...
echo.
:: Checking if directory SCRIPTS exists on C:\
if not exist "C:SCRIPTS" (
    mkdir C:\SCRIPTS
) else (
    echo C:\SCRIPTS is already there ...
)

:: Copying scripts
set "source=\\10.10.16.101\System_admnistrator\Scripts\Automatic_setup\*"
set "destination=C:\SCRIPTS"
xcopy "%source%" "%destination%" /s /e /y


echo Envirement is ready ...
echo Please continue ...
echo ...
:: Prompt user to run the next script
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo # Do you want to set up user?
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo

set /p choice=Enter choice (Y/N):

if /i "%choice%"=="Y" (
    echo Starting new script...

    :: Define the path to the script to run as administrator
    set "elevatedScript=C:\SCRIPTS\script2-setup_user_group.bat"

    :: Log to a file for debugging
    echo Running PowerShell command to elevate %elevatedScript% >> debug.log

    :: Use PowerShell to run the script as administrator
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c \"%elevatedScript%\"' -Verb RunAs" >> debug.log 2>&1

    :: Check if the command was successful
    if %ERRORLEVEL% neq 0 (
        echo Failed to start process with elevation. Check debug.log for details.
        exit /b %ERRORLEVEL%
    )
) else (
    echo Skipping and exiting ...
)

echo Closing main script ...
pause