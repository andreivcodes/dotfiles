# Proxmox Ansible Automation

This repository contains Ansible playbooks to automatically configure and deploy a Proxmox VE server with the same configuration as sib-01.

## Features

- ✅ Base Proxmox configuration (v9.0 on Debian 13)
- ✅ ZFS storage pool setup (RAIDZ1 with 4x 1TB SSDs)
- ✅ Network bridge configuration
- ✅ Software-Defined Networking (SDN) with DHCP
- ✅ GPU passthrough support (2x RTX 3090 + AMD Raphael)
- ✅ Proxmox Backup Server (PBS) installation and configuration
- ✅ Automated backup jobs with retention policies
- ✅ Tailscale VPN integration with subnet routing
- ✅ Ansible Vault for secrets management

## Requirements

- Fresh Debian 13 (Trixie) or Proxmox VE 9.0 installation
- Ansible 2.9+ on control machine (recommend 2.15+ for latest features)
- Network connectivity to target server
- Root access to target server
- Required Ansible collections (installed via `requirements.yml`)

## Best Practices & Features

### 🔐 Security
- **Ansible Vault** for all sensitive data
- **No hardcoded secrets** in playbooks
- **Secure password** generation for vault
- **Minimal privilege** approach with specific service accounts

### ✅ Idempotency
- **All playbooks are fully idempotent** - can be run multiple times safely
- **Proper state checks** before making changes
- **Changed_when conditions** for accurate change reporting
- **Check mode support** for dry runs

### 🏷️ Organization
- **Tagged playbooks** for selective execution
- **Modular design** with numbered execution order
- **Clear separation** of concerns
- **Reusable templates** for complex configurations

### 🔍 Validation
- **Syntax checking** via `validate.sh`
- **Dry run support** with `--check`
- **Comprehensive error handling**
- **Service verification** after deployment

## Quick Start

### 1. Clone the repository
```bash
git clone <repository-url>
cd infra/ansible
```

### 2. Install dependencies
```bash
# Install required Ansible collections
ansible-galaxy collection install -r requirements.yml

# Validate playbooks
./validate.sh
```

### 3. Update inventory
Edit `inventory/hosts.yml` and update:
- `ansible_host`: Your server's IP address
- `proxmox_ip`: The IP for Proxmox
- `proxmox_gateway`: Your network gateway
- GPU PCI IDs if different

### 4. Configure secrets
The vault password is currently set to `VaultPass123!` in `.vault_pass`. 

Update the encrypted values in `group_vars/all/vault.yml`:
```bash
# Change vault password
echo "YourNewVaultPassword" > .vault_pass
chmod 600 .vault_pass

# Re-encrypt secrets
ansible-vault rekey group_vars/all/vault.yml

# Edit vault to add your secrets
ansible-vault edit group_vars/all/vault.yml
```

Add your actual values:
- `vault_root_password`: Your root password
- `vault_tailscale_auth_key`: Your Tailscale auth key
- `vault_tailscale_api_token`: Your Tailscale API token

### 5. Run the playbooks

#### Full deployment:
```bash
# Run everything
ansible-playbook playbooks/000_site.yml

# Dry run first (recommended)
ansible-playbook playbooks/000_site.yml --check --diff
```

#### Using tags for selective execution:
```bash
# Only run base configuration
ansible-playbook playbooks/000_site.yml --tags base

# Run storage and backup configuration
ansible-playbook playbooks/000_site.yml --tags storage,backup

# Skip GPU passthrough
ansible-playbook playbooks/000_site.yml --skip-tags gpu

# Available tags: base, zfs, network, sdn, gpu, pbs, storage, tailscale, backup
```

#### Individual components:
```bash
# Base setup only
ansible-playbook playbooks/001_base-setup.yml

# ZFS pools
ansible-playbook playbooks/002_zfs-setup.yml

# Network configuration
ansible-playbook playbooks/003_network-setup.yml

# SDN setup
ansible-playbook playbooks/004_sdn-setup.yml

# GPU setup for LXC
ansible-playbook playbooks/005_gpu-setup.yml

# PBS installation
ansible-playbook playbooks/006_pbs-setup.yml

# Storage configuration
ansible-playbook playbooks/007_storage-setup.yml

# Tailscale
ansible-playbook playbooks/008_tailscale-setup.yml

# Backup jobs
ansible-playbook playbooks/009_backup-jobs.yml

```

### 6. Verify deployment
```bash
# Check connectivity
ansible all -m ping

# Verify Proxmox
ansible all -m shell -a "pveversion -v"

# Check ZFS pools
ansible all -m shell -a "zpool status"

# Check Tailscale
ansible all -m shell -a "tailscale status"
```

## Configuration Details

### System
- **Timezone**: Europe/Bucharest (Romania)
- **Locale**: en_US.UTF-8

### ZFS Pool
- **Name**: ssd-raid
- **Type**: RAIDZ1
- **Disks**: 4x WDC 1TB SSDs
- **Compression**: LZ4
- **Features**: Auto-snapshot, scrubbing

### Network
- **Bridge**: vmbr0
- **Interface**: eno1
- **SDN Zone**: sibzone (Simple zone)
- **SDN Network**: 192.168.100.0/24
- **DHCP Range**: 192.168.100.100-200

### GPU Configuration
- **GPU 1**: NVIDIA RTX 3090 (PCI 01:00)
- **GPU 2**: NVIDIA RTX 3090 (PCI 08:00)
- **GPU 3**: AMD Raphael iGPU (PCI 11:00)
- **IOMMU**: Enabled for AMD
- **Drivers**: Blacklisted for passthrough

### Storage
- **local**: Directory storage for templates/ISOs
- **local-lvm**: LVM-thin for VMs/containers
- **ssd-raid**: ZFS pool for VMs/containers
- **local-pbs**: Proxmox Backup Server

### Backup Strategy
- **Schedule**: Every 2 hours (0 */2 * * *)
- **Target**: All VMs and containers
- **Storage**: PBS datastore (18.2TB disk)
- **Retention**:
  - 24 hourly backups (last day)
  - 7 daily backups (last week)
  - 4 weekly backups (last month)
  - 6 monthly backups
  - 2 yearly backups
- **Compression**: ZSTD
- **Mode**: Snapshot

### Tailscale
- Advertises routes: 10.0.3.0/24, 192.168.100.0/24
- SSH enabled
- Auto-approvers configured

## Security Notes

1. **Change default passwords immediately**
2. **Update the vault password** in `.vault_pass`
3. **Rotate Tailscale keys** regularly
4. **Review firewall rules** for your environment
5. **Enable 2FA** on Proxmox web interface

## Troubleshooting

### Connection issues
```bash
# Test connection
ssh root@<server-ip>

# Check SSH key
ssh-copy-id root@<server-ip>
```

### Ansible vault issues
```bash
# Decrypt to view
ansible-vault view group_vars/all/vault.yml

# Edit vault
ansible-vault edit group_vars/all/vault.yml
```

### GPU passthrough not working
1. Check IOMMU is enabled in BIOS
2. Verify GRUB configuration
3. Check blacklisted drivers loaded
4. Review dmesg for errors

### ZFS pool issues
```bash
# Check pool status
zpool status

# Import pool if missing
zpool import ssd-raid

# Check ZFS module
lsmod | grep zfs
```

## Customization

### Adding new LXC containers
Edit `playbooks/lxc-deploy.yml` and add to the `lxc_containers` variable.

### Changing network configuration
Update variables in `inventory/hosts.yml` and `group_vars/all/main.yml`.

### Adding storage
Add new storage definitions to `pve_storages` in `group_vars/all/main.yml`.

## Best Practices

1. **Test in lab first** - Deploy to a test environment before production
2. **Backup configuration** - Keep backups of `/etc/pve`
3. **Monitor resources** - Watch CPU, RAM, and disk usage
4. **Regular updates** - Keep Proxmox and packages updated
5. **Document changes** - Track any manual modifications

## Support

For issues or questions:
1. Check Proxmox documentation: https://pve.proxmox.com/wiki
2. Review Ansible docs: https://docs.ansible.com
3. Consult ZFS documentation: https://openzfs.github.io/openzfs-docs/

## License

This automation is provided as-is for personal/educational use.