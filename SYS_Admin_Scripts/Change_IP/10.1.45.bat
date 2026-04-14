@echo off
set ip_naslov=10.1.45.67 255.255.0.0
netsh interface ipv4 set address name="Lokalna povezava" static %ip_naslov%
::netsh interface set interface name="Lokalna povezava" admin=DISABLED
::timeout /t 1
::netsh interface set interface name="Lokalna povezava" admin=ENABLED
::timeout /t 3
IF %ERRORLEVEL% EQU 0 Echo IP Successfuly Changed To : %ip_naslov%
::IF %ERRORLEVEL% NEQ 0 Echo IP is already 10.1.45.67
timeout /t 4 >nul
