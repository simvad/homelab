#!/bin/bash
set -euo pipefail

# Configuration
LOG_TAG="homelab-power-profiles"

log() {
    logger -t "$LOG_TAG" "$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') $1"
}

# Validate arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <start|stop> <profile>"
    exit 1
fi

action="$1"
profile="$2"

# Define services for each profile
declare -A profile_services
profile_services=(
    ["jellyfin"]="docker-compose@jellyfin docker-compose@calibre"
    ["development"]="docker-compose@dotnet libvirt-guest@windows10"
    ["testing"]="docker-compose@waydroid"
    ["full"]="docker-compose@jellyfin docker-compose@calibre docker-compose@dotnet libvirt-guest@windows10 docker-compose@waydroid signalr-hub dashboard"
)

# Validate profile
if [[ ! "${profile_services[$profile]+isset}" ]]; then
    echo "Error: Unknown profile: $profile"
    echo "Available profiles: ${!profile_services[@]}"
    exit 1
fi

# Execute requested action
case "$action" in
    start)
        # For start, we want parallel startup where possible
        log "Starting profile: $profile"
        systemctl start --parallel ${profile_services[$profile]}
        
        # Notify SignalR if it's running
        if systemctl is-active --quiet signalr-hub; then
            curl -X POST "http://localhost:5000/homelabhub/UpdateServiceState" \
                -H "Content-Type: application/json" \
                -d "{\"profile\":\"$profile\",\"state\":{\"isRunning\":true}}"
        fi
        ;;
        
    stop)
        # For stop, we want sequential shutdown in reverse order
        log "Stopping profile: $profile"
        
        # Notify SignalR before stopping
        if systemctl is-active --quiet signalr-hub; then
            curl -X POST "http://localhost:5000/homelabhub/UpdateServiceState" \
                -H "Content-Type: application/json" \
                -d "{\"profile\":\"$profile\",\"state\":{\"isRunning\":false}}"
        fi
        
        for service in $(echo "${profile_services[$profile]}" | tr ' ' '\n' | tac); do
            systemctl stop "$service"
        done
        ;;
        
    *)
        echo "Error: Unknown action: $action"
        echo "Available actions: start, stop"
        exit 1
        ;;
esac

log "Profile $profile ${action}ed successfully"