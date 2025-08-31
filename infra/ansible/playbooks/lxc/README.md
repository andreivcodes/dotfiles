# LXC Container Playbooks

This directory contains Ansible playbooks for managing LXC containers with specialized configurations.

## Available Playbooks

### 010_ollama-setup.yml

Creates an LXC container with Ollama and Open WebUI, configured with NVIDIA GPU passthrough for local LLM inference.

#### Features
- **LXC Container**: ID 300, Debian 12.7-1 template
- **Resources**: 8 CPU cores, 16GB RAM, 100GB disk (ssd-raid storage)
- **Network**: Connected to sibnet SDN with DHCP
- **GPU Support**: NVIDIA GPU passthrough for AI acceleration
- **Services**: 
  - Ollama API server (port 11434)
  - Open WebUI interface (port 3000)
- **Models**: Automatically downloads llama3.2:3b and mistral:7b
- **Backup**: Integrated with Proxmox backup system

#### Prerequisites
1. Proxmox GPU setup playbook must be run first (`005_gpu-setup.yml`)
2. SDN must be configured (`004_sdn-setup.yml`)
3. Debian 12.7-1 template should be available (auto-downloaded if missing)

#### Usage

```bash
# Deploy Ollama container
cd /Users/andrei/git/dotfiles/infra/ansible
make deploy-ollama-lxc

# Or run directly
ansible-playbook playbooks/lxc/010_ollama-setup.yml
```

#### Access
- **Open WebUI**: http://[container-ip]:3000
- **Ollama API**: http://[container-ip]:11434
- Container will get IP via DHCP from sibnet (192.168.100.100-200 range)

#### Configuration

Key variables in the playbook:
- `lxc_id`: Container ID (default: 300)
- `lxc_hostname`: Container hostname (default: ollama)
- `lxc_cores`: CPU cores (default: 8)
- `lxc_memory`: RAM in MB (default: 16384)
- `lxc_disk_size`: Disk size in GB (default: 100)

#### Troubleshooting

1. **GPU not detected**: Ensure host GPU setup is complete and `nvidia-smi` works on host
2. **Container creation fails**: Check if container ID 300 is already in use
3. **Network issues**: Verify sibnet SDN is properly configured
4. **Model download fails**: Check internet connectivity and disk space
5. **Docker GPU access**: Verify `no-cgroups = true` in nvidia-container-runtime config

#### Security Notes
- Container runs unprivileged for better security
- Docker nesting is enabled (required but reduces isolation)
- GPU passthrough requires specific device permissions
- Backup jobs are automatically configured

#### File Structure
```
templates/lxc/
├── ollama-docker-compose.yml.j2     # Docker Compose configuration
└── nvidia-container-runtime-config.toml.j2  # NVIDIA runtime config

tasks/
├── lxc_container_create.yml         # Reusable LXC creation task
└── proxmox_lxc_gpu_tun.yml         # GPU and TUN device passthrough
```

#### Models Included
- **llama3.2:3b**: Lightweight 3 billion parameter model
- **mistral:7b**: 7 billion parameter model with good performance

Additional models can be installed via the Open WebUI interface or by running:
```bash
pct exec 300 -- docker exec ollama ollama pull [model-name]
```