@echo off
setlocal

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
echo                   ==============================================
echo                   $       WINDOWS 11 DJSNI KLIK MENU           $
echo                   ==============================================
echo.
echo.
echo.
echo        Registry edit to disable new contextmenu
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
echo        Should be done. Please test right click
echo.
echo.
echo.
pause

exit /b %ERRORLEVEL%
