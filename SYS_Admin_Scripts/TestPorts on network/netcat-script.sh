#!/bin/bash

# Output file path
output_file="netcat_test_results.txt"

# Clear the output file
echo "Testing Netcat connectivity..." > "$output_file"

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
    echo "Testing Netcat on $ip port $port..."

    # Test the connection with timeout (30 seconds)
    nc -zv -w 30 $ip $port &>/dev/null

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
