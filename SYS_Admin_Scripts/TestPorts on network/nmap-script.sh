#!/bin/bash

# Output file path
output_file="nmap_test_results.txt"

# Clear the output file
echo "Testing Nmap connectivity..." > "$output_file"

# List of IPs and Ports to test (edit as per the actual IPs/Ports from the website)
test_list=(
    "94.245.89.109 443"
    "104.45.193.253 443"
    "137.116.115.186 443"
)

# Loop through the test list
for test in "${test_list[@]}"; do
    ip=$(echo $test | cut -d' ' -f1)
    port=$(echo $test | cut -d' ' -f2)

    # Print test details to console
    echo "Testing Nmap on $ip port $port..."

    # Test the connection with timeout (30 seconds)
    nmap -p $port --host-timeout 30s $ip &>/dev/null

    # Check if connection was successful
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] $ip $port" >> "$output_file"
    else
        echo "[FAIL] $ip $port" >> "$output_file"
    fi
done

# Display results
echo "Results saved to $output_file"
cat "$output_file"
