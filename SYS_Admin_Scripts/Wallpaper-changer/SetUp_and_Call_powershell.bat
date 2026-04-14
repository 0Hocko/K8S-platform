@echo off
::   Made by SysAdmin CVIBA

::       .---.
::      /     \
::      \.@-@./
::      /`\_/`\
::     //  _  \\
::    | \     )|_
::   /`\_`>  <_/ \
::   \__/'---'\__/
::

set "remoteImage=\\10.10.16.101\System_admnistrator\Scripts\Wallpaper-changer\WALLPAPER-Spintec\Spintec_2024_Wallpaper.png"  
set "localDir=C:\Spintec\wallpaper"
set "localImage=%localDir%\Spintec_2024_Wallpaper.png"
set "localPowerShell=%localDir%\ChangeWallpaper.ps1"
set "powershellScript=\\corp.spintecgaming.com\NETLOGON\Scripts\Change_wallpaper\ChangeWallpaper.ps1"  

if not exist "%localDir%" (
    mkdir "%localDir%"
    attrib +h "%localDir%"
)

copy "%remoteImage%" "%localImage%" /Y
copy "%powershellScript%" "%localPowerShell%" /Y

:: Final step execute powershell  
powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%powershellScript%"
  
