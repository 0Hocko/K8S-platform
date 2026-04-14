<#
   Made by SysAdmin CVIBA
       .---.
      /     \
      \.@-@./
      /`\_/`\
     //  _  \\
    | \     )|_
   /`\_`>  <_/ \
   \__/'---'\__/

.DESCRIPTION
Script that changes wallpaper of Spintec computers.

#>
# ------- WALLPAPER CHANGE -------

$wallpaperPath = "C:\Spintec\wallpaper\Spintec_2024_Wallpaper.png"

if (Test-Path $wallpaperPath) {
    # Set the wallpaper using SystemParametersInfo API
    $null = Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@

    # Define constants for SystemParametersInfo ## I dont have any idea wtf
    $SPI_SETDESKWALLPAPER = 20
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDCHANGE = 0x02

    # Change the wallpaper
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaperPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)

    # Change registry settings to make wallpaper fit to screen
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "3"   # 3 = Fit
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0"   # 0 = No tiling

    <#
    0: Center
    1: Tile
    2: Stretch
    3: Fit
    4: Fill
    5: Span (used in multi-monitor setups)
    #>

    # Update the system to apply changes
    rundll32.exe user32.dll, UpdatePerUserSystemParameters

    Write-Host "Wallpaper has been changed successfully to $wallpaperPath and set to 'Fit'."
} else {
    Write-Host "The specified wallpaper path does not exist."
}

# ------- TASK SCHEDULER -------
#
#
#$taskName = "WallpaperChangeTask"
#$scriptPath = "C:\spintec\wallpaper\ChangeWallpaper.ps1"
#
## Check if the task already exists
#$taskExists = schtasks /Query /TN $taskName 2>$null
#
#if ($taskExists) {
#    Write-Host "Task '$taskName' already exists. No need to create a new one."
#} else {
#    # Create a new task that runs every day at 8 
#    $action = "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`""
#    
#    schtasks /Create /TN $taskName /TR "$action" /SC DAILY /ST 08:00 /F
#
#    if ($LASTEXITCODE -eq 0) {
#        Write-Host "Scheduled task '$taskName' created successfully to run every day at 8 AM."
#    } else {
#        Write-Host "Failed to create the scheduled task."
#    }
#}


