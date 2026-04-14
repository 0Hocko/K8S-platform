@echo off
setlocal enabledelayedexpansion

:: Output file path
set "output_file=telnet_test_results.txt"

:: Clear the output file
echo Testing Telnet connectivity... > "%output_file%"

:: List of IPs and Ports to test (These are the 3Shape IPs and Ports for EU region)
set "test_list=94.245.89.109 443 104.45.193.253 443 137.116.115.186 443 52.96.163.250 443 137.116.109.248 443 104.40.180.21 443 40.113.183.107 443 13.80.140.157 443 40.112.208.124 443 52.175.195.182 443"

:: Loop through the test list
for %%A in (%test_list%) do (
    :: Extract IP and port from the list
    for /f "tokens=1,2" %%B in ("%%A") do (
        set "ip=%%B"
        set "port=%%C"

        :: Print test details to console
        echo Testing Telnet on !ip! port !port!...

        :: Test the connection with timeout (30 seconds)
        telnet !ip! !port! < nul > nul

        :: Check if connection was successful
        if !errorlevel! equ 0 (
            echo [SUCCESS] !ip! !port! >> "%output_file%"
        ) else (
            echo [FAIL] !ip! !port! >> "%output_file%"
        )
    )
)

:: Display results
echo Results saved to %output_file%
type "%output_file%"

endlocal
