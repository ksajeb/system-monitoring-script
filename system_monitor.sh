#!/bin/bash

email_id="sajebk007@gmail.com"
Report="/tmp/system-report.txt"

disk_threshold=60
memory_threshold=75
cpu_threshold=85


memory_limit_cross=0
cpu_limit_cross=0
disk_limit_cross=0

memory_usage(){
        echo ""
        echo "Checking Memory Usage..........."
        echo ""
	memory_usage_perc=$(free | awk '/Mem:/ {printf "%.0f", ($3 / $2) * 100}')

	echo " Memory Usage: ${memory_usage_perc}%"

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
	cpu_usage_perc=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk -F. '{print $1}')

        echo " CPU Usage: ${cpu_usage_perc}%"

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
	cat "$Report"
        echo "Report saved to: $Report"
}

send_email(){
	if [ "$memory_limit_cross" -eq 1 ] || [ "$cpu_limit_cross" -eq 1 ] || [ "$disk_limit_cross" -eq 1 ]; then
            echo "Threshold crossed in one or more metrics! Sending alert report to $email_id..."

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
