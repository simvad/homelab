#!/bin/bash

# Default configuration
HOMELAB_CONFIG_DIR="$HOME/.config/homelab"
HOMELAB_CONFIG_FILE="$HOMELAB_CONFIG_DIR/config"
DEFAULT_TIMEOUT=60

# Load configuration
load_config() {
    if [ -f "$HOMELAB_CONFIG_FILE" ]; then
        source "$HOMELAB_CONFIG_FILE"
    else
        echo "No config file found at $HOMELAB_CONFIG_FILE"
        exit 1
    fi
}

# Save configuration
save_config() {
    mkdir -p "$HOMELAB_CONFIG_DIR"
    cat > "$HOMELAB_CONFIG_FILE" << EOF
HOMELAB_MAC="$HOMELAB_MAC"
HOMELAB_IP="$HOMELAB_IP"
HOMELAB_USER="$HOMELAB_USER"
SSH_KEY_PATH="$SSH_KEY_PATH"
MVS_PORT="$MVS_PORT"
EOF
}