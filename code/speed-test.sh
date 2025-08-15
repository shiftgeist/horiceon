#!/bin/bash

CONTEXT="${1}"
NAME="${2:-network-test}"
OUTPUT_FILE="$HOME/Documents/${NAME}.txt"
CSV_FILE="$HOME/Documents/${NAME}.csv"

if [[ -z "$CONTEXT" ]]; then
    echo "Error: Context is required"
    echo "Usage: $0 <context> [name]"
    echo "Example: $0 'home wifi' hetzner"
    exit 1
fi

# Initialize CSV with headers if it doesn't exist
if [[ ! -f "$CSV_FILE" ]]; then
    echo "Date/Time,Context,IPv4/IPv6,URL,Ping min,Ping avg,Ping max,Ping stddev,Curl down,Curl time,command" >"$CSV_FILE"
fi

parse_and_log_csv() {
    local cmd="$1"
    local timestamp="$2"
    local output="$3"
    local url=$(echo "$cmd" | grep -o '[a-zA-Z0-9.-]*\.com[^ ]*' | head -1)

    if [[ "$cmd" == ping* ]]; then
        local ipv="IPv4"
        [[ "$cmd" == ping6* ]] && ipv="IPv6"

        local stats=$(echo "$output" | grep "min/avg/max/stddev")
        if [[ -n "$stats" ]]; then
            local values=$(echo "$stats" | sed 's/.*= \([^m]*\) ms/\1/' | tr '/' ',')
            echo "\"$timestamp\",\"$CONTEXT\",\"$ipv\",\"$url\",$values,,,\"$cmd\"" >>"$CSV_FILE"
        fi

    elif [[ "$cmd" == curl* ]]; then
        local ipv="IPv4"
        [[ "$cmd" == *"-6"* ]] && ipv="IPv6"

        local time=$(echo "$output" | grep "Total time:" | sed 's/Total time: \([^s]*\)s/\1/')
        local speed_bytes=$(echo "$output" | grep "Average speed:" | sed 's/Average speed: \([^ ]*\) bytes\/sec/\1/')
        local speed_mb=""

        if [[ -n "$speed_bytes" && -n "$time" ]]; then
            # Convert bytes/sec to MB/sec
            speed_mb=$(echo "scale=2; $speed_bytes / 1048576" | bc)
            echo "\"$timestamp\",\"$CONTEXT\",\"$ipv\",\"$url\",,,,,$speed_mb,$time,\"$cmd\"" >>"$CSV_FILE"
        fi
    fi
}

run_command() {
    local cmd="$1"
    local start_time=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$start_time] \"$cmd\" ($CONTEXT)" | tee -a "$OUTPUT_FILE"
    echo | tee -a "$OUTPUT_FILE"

    local output=$(eval "$cmd" 2>&1)
    echo "$output" | tee -a "$OUTPUT_FILE"

    # Parse output and add to CSV
    parse_and_log_csv "$cmd" "$start_time" "$output"

    echo | tee -a "$OUTPUT_FILE"
    echo "----------------------------------------" | tee -a "$OUTPUT_FILE"
    echo | tee -a "$OUTPUT_FILE"
}

echo | tee -a "$OUTPUT_FILE"
echo "Network Test Results - $(date) - $CONTEXT" | tee -a "$OUTPUT_FILE"
echo "Output saved to: $OUTPUT_FILE" | tee -a "$OUTPUT_FILE"
echo "========================================" | tee -a "$OUTPUT_FILE"
echo | tee -a "$OUTPUT_FILE"

for endpoint in fsn1 nbg1; do
    origin="${endpoint}-speed.hetzner.com"
    url="https://${origin}/100MB.bin"
    run_command "ping -q -c 10 $origin"
    run_command "ping6 -q -c 10 $origin"
    run_command "curl -4 -s -w 'Total time: %{time_total}s\nAverage speed: %{speed_download} bytes/sec\n' -o /dev/null '$url'"
    run_command "curl -6 -s -w 'Total time: %{time_total}s\nAverage speed: %{speed_download} bytes/sec\n' -o /dev/null '$url'"
    run_command "ping -q -c 10 $origin"
    run_command "ping6 -q -c 10 $origin"
done

echo "Test completed at $(date)" | tee -a "$OUTPUT_FILE"
echo "Results saved to: $OUTPUT_FILE"
echo "CSV data saved to: $CSV_FILE"
