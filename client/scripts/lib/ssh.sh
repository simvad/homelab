#!/bin/bash

# Test SSH connection
test_ssh() {
    local host="$1"
    local user="$2"
    local key="$3"
    ssh -i "$key" -o BatchMode=yes -o ConnectTimeout=5 "$user@$host" echo "SSH connection successful" >/dev/null 2>&1
}

# Execute remote command
remote_exec() {
    local host="$1"
    local user="$2"
    local key="$3"
    local cmd="$4"
    ssh -i "$key" "$user@$host" "$cmd"
}