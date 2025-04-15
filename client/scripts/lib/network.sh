#!/bin/bash

# Check if host is up
check_host() {
    local host="$1"
    local timeout="${2:-5}"
    ping -c1 -W"$timeout" "$host" >/dev/null 2>&1
}

# Wait for host to respond
wait_for_host() {
    local host="$1"
    local timeout="$2"
    local start_time=$(date +%s)
    local end_time=$((start_time + timeout))
    
    echo -n "Waiting for server to respond"
    
    while [ $(date +%s) -lt $end_time ]; do
        if check_host "$host" 1; then
            echo " OK!"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    
    echo " FAILED!"
    return 1
}

# Send WoL packet
send_wol() {
    local mac="$1"
    if ! command -v wakeonlan >/dev/null 2>&1; then
        echo "Error: wakeonlan command not found"
        return 1
    fi
    wakeonlan "$mac"
}