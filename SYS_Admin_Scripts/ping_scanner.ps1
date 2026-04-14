# Define the subnet you want to scan (e.g., 192.168.1.0/24)
$subnet = "192.168.11"
$startIP = 1
$endIP = 254

# Loop through all IP addresses in the subnet
for ($i = $startIP; $i -le $endIP; $i++) {
    $ip = "$subnet.$i"
    try {
        # Send a ping request and check if the host is reachable
        $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet
        if ($ping) {
            $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
            Write-Host "$ip - $hostname" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "$ip is offline" -ForegroundColor Red
    }
}