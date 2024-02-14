#!/bin/bash

# Function to check and send alert if usage exceeds threshold
send_alert() {
    local usage_type=$1
    local usage_value=$2
    local threshold=$3
    local alert_count=$4

    if (( $(echo "$usage_value > $threshold" | bc -l ) )); then
        ((alert_count++))
        if ((alert_count >= 5)); then
            echo "ALERT: $usage_type usage is consistently above threshold. Current: $usage_value Threshold: $threshold" >&2
	fi
    else
        alert_count=0;
    fi
    echo $alert_count
}

# Print the header for the table
printf "Memory\t\tDisk\t\tCPU\n" > usage_log.txt

# Set the end time for monitoring
end=$((SECONDS+6))  # 6 checks with 1 second gap

# Thresholds in percentage
MEMORY_THRESHOLD=20
DISK_THRESHOLD=90
CPU_THRESHOLD=90

# Alert counters
MEMORY_ALERTS=0
DISK_ALERTS=0
CPU_ALERTS=0

# Main loop for monitoring
while [ $SECONDS -lt $end ]; do
    # Get memory usage
    MEMORY=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
    MEMORY_ALERTS=$(send_alert "Memory" "$MEMORY" $MEMORY_THRESHOLD $MEMORY_ALERTS)

    # Get disk usage
    DISK=$(df -h | awk '$NF=="/"{print $5}' | cut -d'%' -f1)
    DISK_ALERTS=$(send_alert "Disk" "$DISK" $DISK_THRESHOLD $DISK_ALERTS)

    # Get CPU usage
    CPU=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}')
    CPU_ALERTS=$(send_alert "CPU" "$CPU" $CPU_THRESHOLD $CPU_ALERTS)

    # Append usage information to the log file
    echo -e "$MEMORY%\t\t$DISK%\t\t$CPU%" >> usage_log.txt

    # Wait for 6 seconds before collecting usage information again
    sleep 1
done

# Display message after execution
echo "Information stored in usage_log.txt file."
