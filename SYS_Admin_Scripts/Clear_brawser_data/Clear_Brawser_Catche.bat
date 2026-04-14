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
::.DESCRIPTION
:: Clear web brawser cache.
::
::
@echo off
echo                           "+=================+"
echo                           "|  Clear Brawser  |"
echo                           "|    *CACHE*      |"
echo                           "|   and cookies   |"
echo                           "+=================+"
echo .
echo .


rem Chrome
set "ChromeCache=%LocalAppData%\Google\Chrome\User Data\Default\Cache\Cache_Data"

rem MS Edge
set "EdgeCache=%LocalAppData%\Microsoft\Edge\User Data\Default\Cache\Cache_Data"

rem Mozilla FireFox
set "MozillaCache=%LocalAppData%\Mozilla\Firefox\Profiles\<ID-profiles>\ "

rem Brave
set "BraveCache=%LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache\Cache_Data"

if exist "%ChromeCache%" (
    rd /s /q "%ChromeCache%"
    echo - Chrome cache cleared successfully.
    echo --------------------------------------
) else (
    echo * Chrome cache directory not found.
    echo --------------------------------------
)

if exist "%EdgeCache%" (
    rd /s /q "%EdgeCache%"
    echo - Edge cache cleared successfully.
    echo --------------------------------------
) else (
    echo * Edge cache directory not found.
    echo --------------------------------------
)

if exist "%MozillaCache%" (
    rd /s /q "%MozillaCache%"
    echo - Mozilla cache cleared successfully.
    echo --------------------------------------
) else (
    echo * Mozilla cache directory not found.
    echo --------------------------------------
)

if exist "%BraveCache%" (
    rd /s /q "%BraveCache%"
    echo - Brave cache cleared successfully.
    echo --------------------------------------
) else (
    echo * Brave cache directory not found.
    echo --------------------------------------
)

exit /b 0

rem /s: This switch is used to remove the directory and all of its subdirectories and files.
rem /q: This switch makes the command quiet, meaning it will not prompt for confirmation before deleting the directory and its contents.


rem CHROME CACHE LOCATION :
rem %LocalAppData%\Google\Chrome\User Data\Default\Cache
rem
rem EDGE CACHE LOCATION :
rem %LocalAppData%\Microsoft\Edge\User Data\Default\Cache
rem
rem MOZILLA CACHE LOCATION ;
rem %LocalAppData%\Mozilla\Firefox\Profile
rem
rem BRAVE CACHE LOCATION :
rem %LocalAppData%\BraveSoftware\Brave-Browser\User Data\Default\Cache
