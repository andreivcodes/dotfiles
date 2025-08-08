.PHONY: deploy deploy-ollama-lxc

deploy:
	ansible-playbook playbooks/000_site.yml

# Optional: pass overrides via ANSIBLE_ARGS, e.g.:
#   make deploy-ollama-lxc ANSIBLE_ARGS='-e lxc_vmid=120 -e lxc_hostname=myct'
deploy-ollama-lxc:
	ansible-playbook playbooks/lxcs/010_lxc-ollama.yml $(ANSIBLE_ARGS)