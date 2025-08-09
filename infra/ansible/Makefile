.PHONY: deploy deploy-ollama-lxc

deploy:
	ansible-playbook playbooks/000_site.yml

# Optional: pass overrides via ANSIBLE_ARGS, e.g.:
#   make deploy-ollama-lxc ANSIBLE_ARGS='-e lxc_vmid=120 -e lxc_hostname=myct'
deploy-ollama-lxc:
	ansible-playbook playbooks/lxcs/010_lxc-ollama.yml $(ANSIBLE_ARGS)

# Deploy ProposalsApp-Infra LXC with Docker, Tailscale, and optional GPU support
#   make deploy-proposalsapp-infra-lxc ANSIBLE_ARGS='-e lxc_vmid=111 -e enable_gpu_passthrough=false'
deploy-proposalsapp-infra-lxc:
	ansible-playbook playbooks/lxcs/011_lxc-proposalsapp-infra.yml $(ANSIBLE_ARGS)