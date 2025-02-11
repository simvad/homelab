#!/bin/bash
set -euo pipefail

# Configuration
ISO_URL="https://www.microsoft.com/software-download/windows10ISO"
VIRTIO_URL="https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
VM_PATH="${VM_PATH:-/mnt/data/vm}"
WIN_ISO="${VM_PATH}/iso/windows10.iso"
VIRTIO_ISO="${VM_PATH}/iso/virtio-win.iso"
DISK_PATH="${VM_PATH}/images/win10.qcow2"
DISK_SIZE="50G"
ANSWER_FILE="${VM_PATH}/win10/autounattend.xml"

# Ensure directories exist
mkdir -p "${VM_PATH}/iso"
mkdir -p "${VM_PATH}/images"

# Check for Windows ISO
if [[ ! -f "$WIN_ISO" ]]; then
    echo "Please download Windows 10 ISO from $ISO_URL and place it at $WIN_ISO"
    exit 1
fi

# Download VirtIO drivers
if [[ ! -f "$VIRTIO_ISO" ]]; then
    echo "Downloading VirtIO drivers..."
    curl -L "$VIRTIO_URL" -o "$VIRTIO_ISO"
fi

# Create disk image
if [[ ! -f "$DISK_PATH" ]]; then
    echo "Creating disk image..."
    qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
fi

# Check for answer file
if [[ ! -f "$ANSWER_FILE" ]]; then
    echo "Answer file not found at $ANSWER_FILE"
    exit 1
fi

# Check for required tools
command -v virt-install >/dev/null 2>&1 || { echo "virt-install is required but not installed"; exit 1; }
command -v virsh >/dev/null 2>&1 || { echo "virsh is required but not installed"; exit 1; }

# Remove existing VM if it exists
if virsh dominfo win10 >/dev/null 2>&1; then
    echo "Removing existing VM..."
    virsh destroy win10 2>/dev/null || true
    virsh undefine win10 --nvram
fi

# Install using virt-install
echo "Starting Windows 10 installation..."
virt-install \
    --name=win10 \
    --memory=4096 \
    --vcpus=2 \
    --cpu host-passthrough \
    --boot uefi \
    --disk path="$DISK_PATH",format=qcow2,bus=virtio \
    --disk path="$WIN_ISO",device=cdrom \
    --disk path="$VIRTIO_ISO",device=cdrom \
    --network network=default,model=virtio \
    --os-variant=win10 \
    --graphics spice \
    --video qxl \
    --channel unix,target_type=virtio,name=org.qemu.guest_agent.0 \
    --unattended "device=sda,answer-file=$ANSWER_FILE"

echo "Installation started. Connect using virt-viewer to monitor progress."