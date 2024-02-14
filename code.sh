#!/bin/bash

# Function to check and send alert if usage exceeds threshold
send_alert() {
    local usage_type=$1
    local usage_value=$2
    local threshold=$3

    if (( $(echo "$usage_value > $threshold" | bc -l) )); then
        echo "ALERT: $usage_type usage is above threshold. Current: $usage_value Threshold: $threshold" >&2
        # Here you can put your code to send an alert, like sending an email or triggering a notification
    fi
}

# Print the header for the table
printf "Memory\t\tDisk\t\tCPU\n" > usage_log.txt

# Set the end time for monitoring
end=$((SECONDS+5))

# Thresholds in percentage
MEMORY_THRESHOLD=20
DISK_THRESHOLD=90
CPU_THRESHOLD=90

# Main loop for monitoring
while [ $SECONDS -lt $end ]; do
    # Get memory usage
    MEMORY=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
    send_alert "Memory" "$MEMORY" $MEMORY_THRESHOLD

    # Get disk usage
    DISK=$(df -h | awk '$NF=="/"{print $5}' | cut -d'%' -f1)
    send_alert "Disk" "$DISK" $DISK_THRESHOLD

    # Get CPU usage
    CPU=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}')
    send_alert "CPU" "$CPU" $CPU_THRESHOLD

    # Append usage information to the log file
    echo -e "$MEMORY%\t\t$DISK%\t\t$CPU%" >> usage_log.txt

    # Wait for 1 seconds before collecting usage information again
    sleep 1
done

# Display message after execution
echo "Information stored in usage_log.txt file."


