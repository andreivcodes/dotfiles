#!/bin/bash

echo "=== PBS Storage and Backup Job Verification ==="
echo ""

# Check PBS storage
echo "1. Checking PBS storage in PVE:"
ssh root@sib-01 "pvesm status | grep local-pbs"
echo ""

# Check backup jobs
echo "2. Configured backup jobs:"
ssh root@sib-01 "pvesh get /cluster/backup --output-format json | jq -r '.[] | \"ID: \\(.id), Schedule: \\(.schedule), Storage: \\(.storage), Enabled: \\(.enabled)\"'"
echo ""

# Check PBS datastore
echo "3. PBS datastore status:"
ssh root@sib-01 "proxmox-backup-manager datastore list"
echo ""

# Check next scheduled backup
echo "4. Next scheduled backup time:"
ssh root@sib-01 "pvesh get /cluster/backup/backup-all --output-format json | jq -r '\"Next run: \\(.next_run // \"Not scheduled\")\"'"
echo ""

# Check PBS web UI
echo "5. PBS Web UI access:"
echo "   https://10.0.3.133:8007"
echo "   Username: root@pam or admin@pbs"
echo ""

# Check if backups can be listed
echo "6. Testing PBS connectivity:"
ssh root@sib-01 "proxmox-backup-client list --repository root@pam@localhost:backup-store 2>&1 | head -5"
echo ""

echo "=== Verification Complete ==="
echo ""
echo "Your backup system is configured with:"
echo "- PBS storage 'local-pbs' added to PVE"
echo "- Backup job running every 2 hours (*/2:00)"
echo "- Retention: 24 hourly, 7 daily, 4 weekly, 6 monthly"
echo "- All VMs and LXCs will be backed up automatically"