# HomeLab Usage Guide

## Basic Commands

### System Control
```bash
# Wake system and start media services
wake-homelab jellyfin

# Start development environment
wake-homelab development

# Start testing environment
wake-homelab testing

# Start all services
wake-homelab full
```

### Service Access
- Jellyfin: http://homelab:8096
- Calibre: http://homelab:8083
- System Dashboard: http://homelab:5001
- Netdata Monitoring: http://homelab:19999

## Media Management

### Jellyfin
1. Access web interface
2. Add media libraries:
   - Movies: /media/movies
   - TV Shows: /media/tv
   - Music: /media/music

### Calibre
1. Access web interface
2. Initial setup:
   - Library path: /books
   - Choose metadata sources
   - Set up user account

## Development Environment

### .NET Development
1. Connect to development container:
```bash
ssh homelab
docker exec -it dotnet-dev bash
```

2. Build artifacts are shared at:
   - Container: /build
   - Windows VM: B:\
   - Host: /mnt/data/build

### Windows VM
1. Connect via RDP:
```bash
xfreerdp /v:homelab /u:Administrator
```

2. Development tools available:
   - Visual Studio Build Tools
   - VS Code
   - Git
   - .NET SDK
   - Node.js

## Monitoring

### System Metrics
Netdata provides:
- CPU/Memory usage
- Network traffic
- Container stats
- Service health

### Build Notifications
Windows system tray app shows:
- Build status
- Completion notifications
- Error alerts

## Power Management

### Manual Control
```bash
# Wake system
wake-homelab [profile]

# Graceful shutdown
ssh homelab "sudo systemctl poweroff"
```

### Automatic Management
System will:
- Start on WoL packet
- Load requested profile
- Monitor for inactivity
- Shutdown when idle

## Troubleshooting

### Service Issues
```bash
# Check service status
systemctl status homelab-profile@[profile]

# View service logs
journalctl -u homelab-profile@[profile]

# Container logs
docker logs [container-name]
```

### Network Issues
```bash
# Test WoL
wakeonlan [MAC]

# Verify SSH
ssh -i ~/.ssh/homelab homelab@[IP]

# Check network config
ip addr show
```

### VM Issues
```bash
# List VMs
virsh list --all

# VM status
virsh dominfo win10

# Start/stop VM
virsh start win10
virsh shutdown win10
```