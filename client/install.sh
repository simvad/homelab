#!/bin/bash
set -euo pipefail

# Configuration
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/homelab"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure directories exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

# Install dependencies
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y wakeonlan openssh-client
elif command -v brew >/dev/null 2>&1; then
    brew install wakeonlan openssh
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy wakeonlan openssh
else
    echo "Please install wakeonlan and openssh manually"
fi

# Copy scripts
cp "$SCRIPT_DIR/scripts/wake-homelab" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/wake-homelab"

# Copy library files
mkdir -p "$CONFIG_DIR/lib"
cp "$SCRIPT_DIR/scripts/lib/"* "$CONFIG_DIR/lib/"

# Create SSH key if it doesn't exist
if [ ! -f "$HOME/.ssh/homelab" ]; then
    ssh-keygen -t ed25519 -f "$HOME/.ssh/homelab" -N "" -C "homelab-client"
    echo "Created new SSH key at $HOME/.ssh/homelab"
fi

# Configuration wizard
echo "Homelab Configuration"
echo "===================="

read -p "Enter homelab MAC address: " mac_address
read -p "Enter homelab IP address: " ip_address
read -p "Enter homelab username [homelab]: " username
username=${username:-homelab}

# Save configuration
cat > "$CONFIG_DIR/config" << EOF
HOMELAB_MAC="$mac_address"
HOMELAB_IP="$ip_address"
HOMELAB_USER="$username"
SSH_KEY_PATH="$HOME/.ssh/homelab"
EOF

# Add to PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    shell_rc="$HOME/.$(basename "$SHELL")rc"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$shell_rc"
    echo "Added $INSTALL_DIR to PATH in $shell_rc"
fi

echo "Installation complete!"
echo "Public key to add to homelab:"
cat "$HOME/.ssh/homelab.pub"