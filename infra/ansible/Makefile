.PHONY: deploy deploy-ollama-lxc

deploy:
	ansible-playbook playbooks/000_site.yml

deploy-ollama-lxc:
	ansible-playbook playbooks/lxc/010_ollama-setup.yml
