#!/bin/bash

# Set the endpoint
ENDPOINT="${1:-dns.google}"

# Print TSV header
printf "Zeitpunkt\thost\tIP\tSend\tReceived\tLoss\tmin\tavg\tmax\tstddev\n"

# Function to run ping and parse results
run_ping() {
  local endpoint="$1"
  local timestamp=$(date '+%m/%d/%Y %H:%M:%S')

  # Run ping and capture output
  local ping_output=$(ping -c 1000 "$endpoint" 2>&1)

  # Extract host and IP from first line
  local host_ip_line=$(echo "$ping_output" | head -1)
  local host=$(echo "$host_ip_line" | sed -n 's/PING \([^ ]*\).*/\1/p')
  local ip=$(echo "$host_ip_line" | sed -n 's/.*(\([^)]*\)).*/\1/p')

  # Extract statistics from ping output
  local stats_line=$(echo "$ping_output" | grep "packets transmitted")
  local timing_line=$(echo "$ping_output" | grep "round-trip\|rtt")

  if [[ -n "$stats_line" && -n "$timing_line" ]]; then
    # Parse packet statistics
    local sent=$(echo "$stats_line" | sed -n 's/\([0-9]*\) packets transmitted.*/\1/p')
    local received=$(echo "$stats_line" | sed -n 's/.*transmitted, \([0-9]*\).*received.*/\1/p')
    local loss_percent=$(echo "$stats_line" | sed -n 's/.*received, \([0-9.]*\)% packet loss.*/\1/p')

    # Convert loss percentage to decimal
    local loss=$(echo "scale=4; $loss_percent / 100" | bc -l 2>/dev/null || echo "0")

    # Parse timing statistics (handles both Linux and macOS format)
    local timing_values=$(echo "$timing_line" | sed -n 's/.*= \([0-9.]*\)\/\([0-9.]*\)\/\([0-9.]*\)\/\([0-9.]*\).*/\1 \2 \3 \4/p')
    read -r min avg max stddev <<<"$timing_values"

    # Output TSV line
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$timestamp" "$host" "$ip" "$sent" "$received" "$loss" "$min" "$avg" "$max" "$stddev"
  else
    # Handle ping failure
    printf "%s\t%s\t%s\t10\t0\t1.0000\t-\t-\t-\t-\n" "$timestamp" "$host" "$ip"
  fi
}

# Main loop
while true; do
  run_ping "$ENDPOINT"
  sleep 60 # Wait 60 seconds between pings (adjust as needed)
done
