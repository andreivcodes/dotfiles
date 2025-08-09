#!/bin/bash
# GPU Verification and Fix Script for Proxmox

set -e

echo "========================================="
echo "GPU Verification Script for Proxmox"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
   echo "Please run as root (use sudo)"
   exit 1
fi

echo "1. Checking for NVIDIA GPUs..."
if lspci | grep -i nvidia > /dev/null; then
    echo "✓ NVIDIA GPU(s) detected:"
    lspci | grep -i nvidia
else
    echo "✗ No NVIDIA GPUs detected"
    exit 1
fi

echo ""
echo "2. Checking nouveau blacklist..."
if [ -f /etc/modprobe.d/blacklist-nouveau.conf ]; then
    echo "✓ Nouveau blacklist exists"
else
    echo "✗ Nouveau not blacklisted - creating blacklist..."
    cat > /etc/modprobe.d/blacklist-nouveau.conf << EOF
blacklist nouveau
options nouveau modeset=0
EOF
    update-initramfs -u
    echo "! Reboot required after blacklisting nouveau"
fi

echo ""
echo "3. Checking NVIDIA driver installation..."
if which nvidia-smi > /dev/null 2>&1; then
    echo "✓ nvidia-smi command found"
    
    echo ""
    echo "4. Testing nvidia-smi..."
    if nvidia-smi > /dev/null 2>&1; then
        echo "✓ NVIDIA drivers are working!"
        echo ""
        nvidia-smi
    else
        echo "✗ nvidia-smi failed - drivers may need to be loaded"
        echo ""
        echo "5. Attempting to load NVIDIA kernel modules..."
        modprobe nvidia || true
        modprobe nvidia_uvm || true
        modprobe nvidia_modeset || true
        modprobe nvidia_drm || true
        
        echo ""
        echo "6. Checking loaded modules..."
        if lsmod | grep -i nvidia > /dev/null; then
            echo "✓ NVIDIA modules loaded:"
            lsmod | grep -i nvidia
        else
            echo "✗ Failed to load NVIDIA modules"
            echo "! A reboot is likely required"
        fi
    fi
else
    echo "✗ nvidia-smi not found - NVIDIA drivers not installed"
    echo "Run: ansible-playbook playbooks/proxmox/005_gpu-setup.yml"
fi

echo ""
echo "7. Checking NVIDIA devices..."
if ls /dev/nvidia* > /dev/null 2>&1; then
    echo "✓ NVIDIA devices found:"
    ls -la /dev/nvidia* | head -10
else
    echo "✗ No NVIDIA devices found in /dev/"
    echo "! Drivers may not be loaded - try rebooting"
fi

echo ""
echo "8. Checking dmesg for NVIDIA errors..."
if dmesg | grep -i "nvidia.*error" > /dev/null 2>&1; then
    echo "⚠ NVIDIA errors found in dmesg:"
    dmesg | grep -i "nvidia.*error" | tail -5
else
    echo "✓ No NVIDIA errors in dmesg"
fi

echo ""
echo "========================================="
echo "Summary:"
echo "========================================="

if nvidia-smi > /dev/null 2>&1; then
    echo "✅ GPU setup is WORKING"
    echo ""
    echo "Next steps:"
    echo "1. LXC containers can now use GPU passthrough"
    echo "2. Use helper script: lxc-gpu-passthrough <container_id>"
    echo "3. Install NVIDIA drivers inside containers from CUDA repo"
else
    echo "⚠️  GPU setup needs attention"
    echo ""
    echo "Recommended actions:"
    echo "1. Reboot the system: reboot"
    echo "2. After reboot, run this script again: ./verify-gpu.sh"
    echo "3. If still not working, re-run the playbook:"
    echo "   ansible-playbook playbooks/proxmox/005_gpu-setup.yml -e auto_reboot=true"
fi

echo ""
echo "========================================="