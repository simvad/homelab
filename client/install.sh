#!/bin/bash
set -euo pipefail

# Configuration
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/homelab"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure directories exist
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR/lib"

# Install dependencies
if command -v apt-get >/dev/null 2>&1; then
    echo "Installing dependencies with apt..."
    sudo apt-get update
    sudo apt-get install -y wakeonlan openssh-client c3270
elif command -v brew >/dev/null 2>&1; then
    echo "Installing dependencies with brew..."
    brew install wakeonlan openssh x3270
elif command -v pacman >/dev/null 2>&1; then
    echo "Installing dependencies with pacman..."
    sudo pacman -Sy wakeonlan openssh x3270
else
    echo "Please install wakeonlan, openssh and a 3270 terminal emulator manually"
fi

# Copy scripts
echo "Installing wake-homelab script..."
cp "$SCRIPT_DIR/scripts/wake-homelab" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/wake-homelab"

# Copy library files
echo "Installing support libraries..."
cp "$SCRIPT_DIR/scripts/lib/"* "$CONFIG_DIR/lib/"

# Create SSH key if it doesn't exist
if [ ! -f "$HOME/.ssh/homelab" ]; then
    echo "Creating new SSH key for homelab..."
    ssh-keygen -t ed25519 -f "$HOME/.ssh/homelab" -N "" -C "homelab-client"
    echo "Created new SSH key at $HOME/.ssh/homelab"
fi

# Configuration wizard
echo ""
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
MVS_PORT="3505"
EOF

# Add to PATH if needed
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    shell_rc="$HOME/.$(basename "$SHELL")rc"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$shell_rc"
    echo "Added $INSTALL_DIR to PATH in $shell_rc"
fi

echo ""
echo "Installation complete!"
echo "Public key to add to homelab:"
cat "$HOME/.ssh/homelab.pub"
echo ""
echo "Use 'wake-homelab' to start your homelab server"
echo "Connect to MVS via: c3270 ${ip_address}:${MVS_PORT}"