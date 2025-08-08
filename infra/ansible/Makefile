.PHONY: help test deploy deploy-base deploy-zfs deploy-network deploy-sdn deploy-gpu deploy-tailscale deploy-storage deploy-pbs deploy-backup check encrypt decrypt

help:
	@echo "Proxmox Ansible Automation"
	@echo ""
	@echo "Available targets:"
	@echo "  deploy           - Run complete deployment"
	@echo "  deploy-base      - Deploy base Proxmox configuration"
	@echo "  deploy-zfs       - Configure ZFS pools"
	@echo "  deploy-network   - Configure network interfaces"
	@echo "  deploy-sdn       - Setup Software-Defined Networking"
	@echo "  deploy-gpu       - Configure GPU passthrough"
	@echo "  deploy-pbs       - Install and configure Proxmox Backup Server"
	@echo "  deploy-backup    - Configure backup jobs"
	@echo "  deploy-tailscale - Install and configure Tailscale"
	@echo "  deploy-storage   - Configure Proxmox storage"
	@echo "  check            - Check connectivity and configuration"
	@echo "  test             - Run playbook in check mode"
	@echo "  encrypt          - Encrypt a string for vault"
	@echo "  decrypt          - View vault contents"

test:
	ansible-playbook playbooks/000_site.yml --check

deploy:
	ansible-playbook playbooks/000_site.yml

deploy-base:
	ansible-playbook playbooks/001_base-setup.yml

deploy-zfs:
	ansible-playbook playbooks/002_zfs-setup.yml

deploy-network:
	ansible-playbook playbooks/003_network-setup.yml

deploy-sdn:
	ansible-playbook playbooks/004_sdn-setup.yml

deploy-gpu:
	ansible-playbook playbooks/005_gpu-setup.yml

deploy-pbs:
	ansible-playbook playbooks/006_pbs-setup.yml

deploy-storage:
	ansible-playbook playbooks/007_storage-setup.yml

deploy-backup:
	ansible-playbook playbooks/008_backup-jobs.yml

deploy-tailscale:
	ansible-playbook playbooks/009_tailscale-setup.yml

check:
	@echo "Checking connectivity..."
	@ansible all -m ping
	@echo ""
	@echo "Checking Proxmox version..."
	@ansible all -m shell -a "pveversion -v | head -1"
	@echo ""
	@echo "Checking ZFS pools..."
	@ansible all -m shell -a "zpool list"
	@echo ""
	@echo "Checking network interfaces..."
	@ansible all -m shell -a "ip -br a"

encrypt:
	@read -p "Enter string to encrypt: " string && \
	ansible-vault encrypt_string "$$string" --name "vault_variable"

decrypt:
	ansible-vault view group_vars/all/vault.yml