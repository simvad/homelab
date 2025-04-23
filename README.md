# HomeLab MVS

Energy-efficient homelab with Hercules MVS mainframe emulation, auto power management, and remote access.

## Features

- Energy-saving design: auto-shutdown after 30 minutes of inactivity
- Wake-on-LAN support for remote power-on
- Hercules mainframe emulation with MVS 3.8j
- Automated backups
- Real-time monitoring with Netdata
- Easy client-server installation

## Requirements

- Computer with WoL-capable network card
- Debian-based OS
- 2+ GB RAM, 20+ GB storage

## Quick Start

1. Clone this repository
2. Create `.env` file (see `docs/SETUP.md`)
3. Deploy server: `ansible-playbook -i ansible/inventory/homelab.yml ansible/site.yml`
4. Install client: `./client/install.sh`
5. Wake server: `wake-homelab`

For complete setup instructions, see [SETUP.md](docs/SETUP.md).