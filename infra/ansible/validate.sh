#\!/bin/bash
# Proxmox Ansible Deployment Validation Script

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Proxmox Deployment Validation ==="
echo ""

# Check if we can connect to the host
echo -n "Checking connectivity... "
if ansible proxmox -m ping &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Cannot connect to Proxmox hosts. Check inventory and SSH keys."
    exit 1
fi

# Run validation playbook
echo "Running validation checks..."
cat > /tmp/validate_playbook.yml << 'EOF'
---
- name: Validate Proxmox Deployment
  hosts: proxmox
  gather_facts: yes
  tasks:
    - name: Check ZFS pools
      command: zpool list -H -o name
      register: zfs_pools
      changed_when: false
      failed_when: false

    - name: Check PVE storages
      command: pvesm status
      register: pve_storages
      changed_when: false
      failed_when: false

    - name: Check PBS service
      systemd:
        name: proxmox-backup-proxy
      register: pbs_service
      failed_when: false

    - name: Check NVIDIA drivers
      command: nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
      register: nvidia_status
      changed_when: false
      failed_when: false

    - name: Check Tailscale status
      command: tailscale status
      register: tailscale_status
      changed_when: false
      failed_when: false

    - name: Check backup jobs
      command: pvesh get /cluster/backup --output-format json
      register: backup_jobs
      changed_when: false
      failed_when: false

    - name: Validation Summary
      debug:
        msg:
          - "=== VALIDATION RESULTS ==="
          - "ZFS Pools: {{ zfs_pools.stdout_lines | length }} pool(s)"
          - "  {{ zfs_pools.stdout_lines | join(', ') if zfs_pools.stdout_lines else 'None' }}"
          - ""
          - "PVE Storages: {{ pve_storages.stdout_lines | select('match', '^[a-z]') | list | length }} storage(s)"
          - "  PBS Storage: {{ 'Configured' if 'local-pbs' in pve_storages.stdout and 'active' in pve_storages.stdout else 'Not configured/inactive' }}"
          - "  ZFS Storage: {{ 'Configured' if 'ssd-raid' in pve_storages.stdout and 'active' in pve_storages.stdout else 'Not configured/inactive' }}"
          - ""
          - "PBS Service: {{ 'Running' if pbs_service.status.ActiveState == 'active' else 'Not running' }}"
          - ""
          - "NVIDIA GPUs: {{ 'Configured' if nvidia_status.rc == 0 else 'Not configured' }}"
          - "  {{ nvidia_status.stdout if nvidia_status.rc == 0 else 'No GPUs detected' }}"
          - ""
          - "Tailscale: {{ 'Connected' if tailscale_status.rc == 0 and 'peerapi' in tailscale_status.stdout else 'Not connected' }}"
          - ""
          - "Backup Jobs: {{ (backup_jobs.stdout | from_json | length) if backup_jobs.rc == 0 else 0 }} job(s) configured"
EOF

ansible-playbook /tmp/validate_playbook.yml

echo ""
echo "=== Quick Commands ==="
echo "Check ZFS status:     ssh root@<ip> 'zpool status'"
echo "Check PBS web UI:     https://<ip>:8007"
echo "Check PVE web UI:     https://<ip>:8006"
echo "List storages:        ssh root@<ip> 'pvesm status'"
echo "Test backup:          ssh root@<ip> 'vzdump 100 --storage local-pbs --mode snapshot'"
echo ""

rm -f /tmp/validate_playbook.yml
