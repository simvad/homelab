# HomeLab Setup Guide

## Prerequisites

### Hardware Requirements
- Laptop with:
  - CPU supporting virtualization (for KVM/VM support)
  - Network card with Wake-on-LAN support
  - Sufficient storage for media and VMs
  - Minimum 8GB RAM recommended

### Initial OS Installation
1. Download Debian netinst ISO
2. Create bootable USB with preseed file for automated installation
3. Boot from USB and follow installation
4. After installation, verify:
   - Network connectivity
   - SSH access
   - Wake-on-LAN functionality

## Configuration

### Environment Setup
Create a `.env` file with required configuration:
```bash
# Network Configuration
HOMELAB_IP          # IP address of your homelab server
HOMELAB_INTERFACE   # Network interface name (default: eth0)
HOMELAB_PUBLIC_URL  # Public URL for Jellyfin

# VM Configuration
WIN10_MEMORY        # Memory allocation for Windows VM in GB
WIN10_CPUS          # CPU cores for Windows VM

# Storage Configuration
MEDIA_PATH          # Path to media storage
BOOKS_PATH          # Path to books storage
CONFIG_PATH         # Path to config storage
DEV_PATH            # Path to development storage
VM_PATH            # Path to VM storage
BUILD_ARTIFACTS_PATH # Path to build artifacts
```

### Installation

1. Clone repository:
```bash
git clone https://github.com/yourusername/homelab.git
cd homelab
```

2. Run client installer:
```bash
./client/install.sh
```

3. Deploy server configuration:
```bash
source .env
ansible-playbook -i inventory/homelab.yml site.yml
```

## Service Profiles

### Media Profile
Sets up:
- Jellyfin media server
- Calibre web interface
```bash
wake-homelab jellyfin
```

### Development Profile
Sets up:
- .NET development environment
- Windows 10 VM
- Shared build artifacts
```bash
wake-homelab development
```

### Testing Profile
Sets up:
- Waydroid environment
```bash
wake-homelab testing
```

### Full Profile
Starts all services:
```bash
wake-homelab full
```

## Power Management

### Wake-on-LAN Setup
1. Enable WoL in BIOS/UEFI
2. Configure network interface:
```bash
sudo ethtool -s INTERFACE wol g
```

### Automatic Shutdown
System will automatically shutdown after:
- 30 minutes of inactivity
- No active SSH connections
- No active containers
- Low system load

## Monitoring

### Dashboard Access
- System metrics: http://homelab:19999
- SignalR dashboard: http://homelab:5001

### Log Locations
- System services: `journalctl`
- Docker containers: `/var/log/docker/`
- VM logs: `/var/log/libvirt/`