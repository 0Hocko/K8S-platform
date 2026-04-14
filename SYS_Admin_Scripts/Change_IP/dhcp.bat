@echo off
netsh interface ip set address "Lokalna povezava" dhcp
::netsh interface set interface name="Lokalna povezava" admin=DISABLED
::timeout /t 1
::netsh interface set interface name="Lokalna povezava" admin=ENABLED
::timeout /t 3
IF %ERRORLEVEL% EQU 0 Echo IP Successfuly Changed To dhcp
::IF %ERRORLEVEL% NEQ 0 Echo Already in DHCP
timeout /t 4 >nul