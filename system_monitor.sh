#!/bin/bash

email_id="sajebk007@gmail.com"
Report="/tmp/system-report.txt"

# define threshold limit
disk_threshold=90
memory_threshold=90
cpu_threshold=85

# alert flag limit
memory_limit_cross=0
cpu_limit_cross=0
disk_limit_cross=0

memory_usage(){
        echo ""
        echo "Checking Memory Usage..........."
        echo ""
	# calculating memory usage into percentage
	memory_usage_perc=$(free | awk '/Mem:/ {printf "%.0f", ($3 / $2) * 100}')

	echo " Memory Usage: ${memory_usage_perc}%"

	# check if usage cross limit then sent the alert message
	if [ "$memory_usage_perc" -ge "$memory_threshold" ]; then
	echo "WARNING: Memory has reached or exceeded the ${memory_threshold}% threshold. Please free memory space."
	memory_limit_cross=1
	else
	echo "Memory usage is normal."
	fi
        echo ""
}

cpu_usage(){
	echo ""
        echo "Checking CPU Usage.............."
	# getting CPU usage percentage by subtracting idle time ($8) from 100
	cpu_usage_perc=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk -F. '{print $1}')

        echo " CPU Usage: ${cpu_usage_perc}%"
	
	# check if usage cross limit then sent the CPU space alert message
        if [ "$cpu_usage_perc" -ge "$cpu_threshold" ]; then
        echo "WARNING: CPU usage has reached or exceeded the ${cpu_threshold}% threshold. Please check high resource processes."
	cpu_limit_cross=1
        else
        echo "CPU usage is normal."
        fi	
	echo ""
}

disk_usage(){
        echo ""
        echo "Checking Disk Usage............."
        echo ""
	# get root filesystem usage percentage	
	disk_usage_perc=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

	echo "Disk Usage: ${disk_usage_perc}%"

	if [ "$disk_usage_perc" -ge "$disk_threshold" ]; then
        echo "WARNING: Disk usage has reached or exceeded the ${disk_threshold}% threshold. Please free up disk space."
	disk_limit_cross=1
        else
        echo "Disk usage is normal."
        fi
        echo ""
}

generate_report(){

        echo "Generating System Health Report..."

        {
                echo "=========================================="
                echo "       SYSTEM HEALTH MONITORING REPORT"
                echo "=========================================="
                echo "Date:$(date)"
                echo ""

                echo "========== DISK USAGE =========="
                disk_usage

                echo "========== CPU USAGE =========="
                cpu_usage

                echo "========== MEMORY USAGE =========="
                memory_usage

                echo "=========================================="
                echo "Report generated successfully."
                echo "=========================================="

        } > "$Report"

	# cat prints the report to the terminal 
	cat "$Report"
        echo "Report saved to: $Report"
}

send_email(){
	# check if any resource cross the limit
	if [ "$memory_limit_cross" -eq 1 ] || [ "$cpu_limit_cross" -eq 1 ] || [ "$disk_limit_cross" -eq 1 ]; then
            echo "Threshold crossed in one or more metrics! Sending alert report to $email_id..."

	    # sent the warning message to the email if the threshold is crossed
            if mail -s "WARNING: System Health Threshold Exceeded" "$email_id" < "$Report"; then
                echo "Alert email sent successfully: $email_id."
            else
                echo "Failed to send email."
            fi
        else
            echo "All system metrics (Disk, CPU, and Memory) are within normal limits. No email sent."
        fi


}

generate_report
send_email
