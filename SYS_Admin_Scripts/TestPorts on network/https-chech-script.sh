#!/bin/bash

# Output file path
output_file="https_service_test_results.txt"

# Clear the output file
echo "Testing HTTPS service..." > "$output_file"

# List of URLs to test (edit as per the actual URLs from the website)
urls=(
    "https://94.245.89.109"
    "https://104.45.193.253"
    "https://137.116.115.186"
)

# Loop through the URLs
for url in "${urls[@]}"; do
    # Print test details to console
    echo "Testing HTTPS on $url..."

    # Test the connection with timeout (30 seconds)
    curl --max-time 30 -s -o /dev/null -w "%{http_code}" $url > temp.txt

    # Check if connection was successful (HTTP Status 200)
    http_code=$(cat temp.txt)
    if [ "$http_code" -eq 200 ]; then
        echo "[SUCCESS] $url" >> "$output_file"
    else
        echo "[FAIL] $url HTTP Code: $http_code" >> "$output_file"
    fi
done

# Display results
echo "Results saved to $output_file"
cat "$output_file"
