# HomeLab

A single-node Debian-based homelab setup with:

- Media streaming (Jellyfin)
- Ebook management (Calibre)
- Development environment (.NET)
- Windows 10 VM 
- Basic VPN functionality (WireGuard)
- Power management with Wake-on-LAN
- Real-time monitoring (Netdata)
- SignalR server with dashboard
- Automated backups with Restic

## Configuration

The following environment variables need to be set before running the ansible playbook:

```bash
# Network Configuration
HOMELAB_IP          # IP address of your homelab server
HOMELAB_INTERFACE   # Network interface name (default: eth0)
HOMELAB_PUBLIC_URL  # Public URL for Jellyfin (default: http://homelab.local:8096)

# VM Configuration
WIN10_MEMORY        # Memory allocation for Windows VM in GB (default: 4)
WIN10_CPUS          # CPU cores for Windows VM (default: 2)

# Storage Configuration
MEDIA_PATH          # Path to media storage (default: /mnt/data/media)
BOOKS_PATH          # Path to books storage (default: /mnt/data/books)
CONFIG_PATH         # Path to config storage (default: /mnt/data/config)
DEV_PATH            # Path to development storage (default: /mnt/data/dev)
VM_PATH            # Path to VM storage (default: /mnt/data/vm)
```

## Quick Start
```bash
# 1. Clone repository
git clone https://github.com/simvad/homelab.git
cd homelab

# 2. Set up environment
cp .env.example .env
# Edit .env with your values
source .env

# 3. Run ansible
ansible-playbook -i inventory/homelab.yml site.yml
```
# Design notes
This has been backwards designed from a lot of experimentation done on my homelab and is mostly made to gain familiarity with Ansible and Docker. For those reasons, I have also chosen to keep quite tightly to conventions, even when they might seem superflous due to the relatively small project size.