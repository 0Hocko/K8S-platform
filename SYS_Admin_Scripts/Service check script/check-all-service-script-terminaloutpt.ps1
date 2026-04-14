# PowerShell is nice      #
# CVIbA !                 #

# Get running service on the machine
$allServices = Get-Service

# Getting info about service
function Get-ServiceInfo {
    param (
        [string]$serviceName
    )

    $service = $allServices | Where-Object { $_.Name -eq $serviceName }

    if ($service) {
        [PSCustomObject]@{
            'Service Name' = $service.Name
            'Display Name' = $service.DisplayName
            #'Status' = $service.Status
            'Startup Type' = $service.StartType
        }
    }
    else {
        [PSCustomObject]@{
            'Service Name' = $serviceName
            'Display Name' = "Not Found"
            #'Status' = "Not Found"
            'Startup Type' = "Not Found"
        }
    }
}

# Parse data together
$serviceInfoList = foreach ($service in $allServices) {
    Get-ServiceInfo -serviceName $service.Name
}

# Output in CSV
$serviceInfoList | Export-Csv -Path "Service-report-$env:computername.csv" -NoTypeInformation

Write-Host "Service status report of $env:computername has been saved to Service-report-$env:computername.csv"
