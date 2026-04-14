# Define the desired screen resolution and scaling
$screenResolutionWidth = 2560
$screenResolutionHeight = 1440
$scalingPercentage = 133

# Get the WMI object for the screen resolution
$screen = Get-WmiObject -Namespace root\cimv2 -Class Win32_DesktopMonitor

# Set the screen resolution
$screen.PsBase.InvokeMethod("SetDisplaySettings", $screenResolutionWidth, $screenResolutionHeight, $screen.PsBase.Properties["ScreenWidth"].Value, $screen.PsBase.Properties["ScreenHeight"].Value, 32)

# Set the scaling
$registryPath = 'HKCU:\Control Panel\Desktop\'
Set-ItemProperty -Path $registryPath -Name LogPixels -Value 96
Set-ItemProperty -Path $registryPath -Name Win8DpiScaling -Value 1
Set-ItemProperty -Path $registryPath -Name PaddedBordres -Value 0

# Calculate the DPI value based on scaling percentage
$dpiValue = [math]::Round(96 * ($scalingPercentage / 100))
Set-ItemProperty -Path $registryPath -Name LogPixels -Value $dpiValue

# Restart the explorer process to apply the changes
Stop-Process -Name explorer -Force
Start-Process explorer