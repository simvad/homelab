# HomeLab Setup Guide

## Prerequisites

### Hardware Requirements
- Computer with:
  - CPU with virtualization support
  - Network card with Wake-on-LAN support
  - 2+ GB RAM
  - 20+ GB storage

### Initial OS Installation
1. Download Debian netinst ISO
2. Install Debian with SSH server enabled
3. After installation, verify:
   - Network connectivity
   - SSH access
   - Wake-on-LAN functionality (in BIOS/UEFI)

## Configuration

### Environment Setup
Create a `.env` file with required configuration:
```bash
# Server Configuration
HOMELAB_HOSTNAME=homelab           # Server hostname
HOMELAB_USERNAME=homelab           # Server username
HOMELAB_IP=192.168.1.100           # IP address of your homelab server
HOMELAB_INTERFACE=eth0             # Network interface name
HOMELAB_MAC=00:11:22:33:44:55      # MAC address for Wake-on-LAN

# Storage Configuration
DATA_PATH=/mnt/data                # Path to data storage
BACKUP_PATH=/mnt/backup            # Path to backup storage
CONFIG_PATH=/mnt/data/config       # Path to config storage

# Service Selection (true/false)
ENABLE_MVS=true                    # Enable Hercules MVS
ENABLE_MONITORING=true             # Enable Netdata monitoring
ENABLE_BACKUP=true                 # Enable automatic backups
ENABLE_POWER_MGMT=true             # Enable power management

# Backup Configuration
BACKUP_REPO=sftp:user@backup-server:/backup  # Restic backup repository
BACKUP_PASSWORD=your-secure-password         # Restic repository password
BACKUP_RETENTION="7d 4w 3m"                  # Keep backups for 7 days, 4 weeks, 3 months

# MVS Configuration
MVS_CONSOLE_PORT=3270              # Port for MVS console
MVS_TERMINAL_PORT=3505             # Port for 3270 terminal emulator
```

### Server Installation

1. Clone repository and prepare environment:
```bash
git clone https://github.com/yourusername/homelab-mvs.git
cd homelab-mvs
cp .env.example .env
# Edit .env with your values
source .env
```

2. Generate SSH key (if not already done):
```bash
ssh-keygen -t ed25519 -f ~/.ssh/homelab -N "" -C "homelab-server"
```

3. Copy SSH key to server:
```bash
ssh-copy-id -i ~/.ssh/homelab.pub homelab@$HOMELAB_IP
```

4. Deploy server configuration:
```bash
ansible-playbook -i ansible/inventory/homelab.yml ansible/site.yml --ask-become-pass
```

### Client Installation

1. Run client installer:
```bash
./client/install.sh
```

2. Follow the prompts to configure connection to your server

## Data Directories

The Ansible playbook creates these directories:
- `/mnt/data`: Main data storage
- `/mnt/backup`: Backup storage
- `/mnt/data/config`: Configuration files
- `/mnt/data/mvs`: MVS system files

## Wake-on-LAN Setup

1. Enable WoL in BIOS/UEFI
2. The server is automatically configured to enable WoL on boot

## Firewall Configuration

The server is secured with UFW firewall, which allows only:
- Port 22 (SSH)
- Port 3270 (MVS Console)
- Port 3505 (3270 Terminal)
- Port 19999 (Netdata monitoring)

## Backup Setup

The system is configured to perform daily backups at 3 AM using restic:
- Data is backed up to the configured repository
- Backup retention policy keeps backups for 7 days, 4 weeks, and 3 months
- Integrity checks are performed weekly

## Monitoring

Netdata provides real-time monitoring at http://[server-ip]:19999