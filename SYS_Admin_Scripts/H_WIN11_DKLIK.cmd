@echo off
setlocal
:main
cls
echo                             _____   ______   _
echo                            / __\ \ /(_) _ ) /_\
echo                           ^| (__ \ V /^|^| _ \/ _ \
echo                            \___^| \_/ ^|^|___/_/ \_\
echo.
echo.                                                   POWER
echo.
echo.
echo.
echo.
echo.
echo                   ==============================================
echo                   $       WINDOWS 11 DJSNI KLIK MENU           $
echo                   ==============================================
echo.
echo.
echo        		Select an option:
echo        	    1. Enable old context menu - Old right-click
echo        		2. Revert to Windows 11 context menu - Win11 default
echo.
echo                   ----------------------------------------------
set /p option="     Select option (1 or 2): "

if "%option%"=="1" goto old_contextMenu
if "%option%"=="2" goto new_contextMenu

echo.
echo        Invalid selection. Please choose option 1 or 2.
pause
goto main

:old_contextMenu
cls
echo.
echo You selected option 1 - Enable old context menu.
echo.
set /p confirm="Are you sure you want to proceed? (y/n): "
if /I "%confirm%"=="y" (
    echo.
    echo        Registry edit to disable new context menu
    echo.
    set RegPath="HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

    echo        Create registry key and set default value to empty
    reg add %RegPath% /ve /t REG_SZ /d "" /f >nul 2>&1
    echo.
    echo        Restarting EXPLORER process to apply changes
    echo.
    taskkill /F /IM explorer.exe >nul 2>&1
    start explorer.exe
    echo.
    echo        Should be done. Please test right-click.
) else (
    echo.
    echo        Action cancelled. No changes were made.
)
goto end

:new_contextMenu
cls
echo.
echo You selected option 2 - Revert to Windows 11 context menu.
echo.
set /p confirm="Are you sure you want to proceed? (y/n): "
if /I "%confirm%"=="y" (
    echo.
    echo        Registry edit to restore Windows 11 context menu
    echo.
    set RegPath="HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

    echo        Deleting registry key to restore default context menu
    reg delete %RegPath% /f >nul 2>&1
    echo.
    echo        Restarting EXPLORER process to apply changes
    echo.
    taskkill /F /IM explorer.exe >nul 2>&1
    start explorer.exe
    echo.
    echo        Should be done. Please test right-click.
) else (
    echo.
    echo        Action cancelled. No changes were made.
)
goto end

:end
echo.
echo ================================================================
echo #																#
echo #             DONE												#
echo ================================================================
pause
exit /b
