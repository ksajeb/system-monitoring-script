#!/bin/bash

email_id="sajebk007@gmail.com"
Report="/tmp/system-usage-report.txt"

disk_threshold=60
memory_threshold=75
cpu_threshold=85

memory_usage(){
        echo ""
        echo "Checking Memory Usage..........."
        echo ""
	memory_usage_perc=$(free | awk '/Mem:/ {printf "%.0f", ($3 / $2) * 100}')

	echo " Memory Usage: ${memory_usage_perc}%"

	if [ "$memory_usage_perc" -ge "$memory_threshold" ]; then
	echo "WARNING: Memory has reached or exceeded the ${memory_threshold}% threshold. Please free memory space."
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
        else
        echo "CPU usage is normal."
        fi	
	echo ""
}

disk_usage(){
        echo ""
        echo "Checking Disk Usage............."
        echo ""
	disk_usage_perc=$(df -h |  grep '^/dev/sda2' | awk '{print $5}' | tr -d '%')

	echo "Disk Usage: ${disk_usage_perc}%"

	if [ "$disk_usage_perc" -ge "$disk_threshold" ]; then
        echo "WARNING: Disk usage has reached or exceeded the ${disk_threshold}% threshold. Please free up disk space."
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

        } | tee "$Report"
        echo "Report saved to: $Report"
}

send_email(){

        echo "Sending report to $email_id..."

        if mail -s "System Health Report" "$email_id" < "$Report"; then
                echo "Report sent successfully: $email_id."
        else
                echo "Failed to send email."
        fi
}
generate_report
send_email
