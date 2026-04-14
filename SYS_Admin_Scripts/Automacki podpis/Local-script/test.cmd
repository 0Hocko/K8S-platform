@echo off
:: Check if enviroment is setup
if not exist "C:\spintec" (
    echo Environment ROOT directory NOT EXISTS
    set /p choice=" Setup environment ? (Y/N) "
    if "%choice%"=="y" ( 
        goto SetUp_environment
        ) else (
            echo Get back to Main Menu !
            pause
            goto MainMenu
        )
)
pause
:: Check if C:\spintec\signature directory exists
if not exist "C:\spintec\signature" (
    echo Environment SIGNATURE directory NOT EXISTS
    set /p choice="set up environment ? (Y/N) "
    if "%choice%"=="y" ( 
        goto SetUp_environment
        ) else (
            echo Get back to Main Menu !
            pause
            goto MainMenu
        )
)
pause