@echo off

:: Made by CVIBA
::       .---.
::      /     \
::      \.@-@./
::      /`\_/`\
::     //  _  \\
::    | \     )|_
::   /`\_`>  <_/ \
::   \__/'---'\__/
echo ############################
echo #                          #
echo # * Running Batch Script * #
echo # *For Outlook Signature * #
echo #                          #
echo ############################
echo.
echo ~ testing connection with NAS ~
echo.
timeout /t 2 /nobreak > NUL
ping -n 1 10.10.16.101 > nul

if %errorlevel% equ 0 (
    echo Successful connection !
    echo Pulling script !
    :: Call PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "\\nas1.corp.spintecgaming.com\System_Admnistrator\Signature\Outlook-signature-generator-ARKA-V3-LOCAL-JS.ps1"
) else (
    echo.
    echo Ping failed! Script will exit.
    timeout /t 5 /nobreak > NUL
    exit /b 1
)
echo.
timeout /t 5 /nobreak > NUL
echo Done !