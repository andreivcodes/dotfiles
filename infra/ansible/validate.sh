#!/bin/bash
# Ansible Playbook Validation Script

set -e

echo "======================================"
echo "Ansible Playbook Validation"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Install required collections
echo -e "${YELLOW}Installing required Ansible collections...${NC}"
ansible-galaxy collection install -r requirements.yml

# Syntax check all playbooks
echo -e "${YELLOW}Checking playbook syntax...${NC}"
for playbook in playbooks/*.yml; do
    echo "Checking: $playbook"
    ANSIBLE_CONFIG=./ansible.cfg ansible-playbook --syntax-check "$playbook"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $playbook syntax OK${NC}"
    else
        echo -e "${RED}✗ $playbook has syntax errors${NC}"
        exit 1
    fi
done

# Lint playbooks
echo -e "${YELLOW}Running ansible-lint...${NC}"
if command -v ansible-lint &> /dev/null; then
    ansible-lint playbooks/*.yml || true
else
    echo -e "${YELLOW}ansible-lint not installed, skipping...${NC}"
fi

# Dry run check
echo -e "${YELLOW}Performing dry run check...${NC}"
ANSIBLE_CONFIG=./ansible.cfg ansible-playbook playbooks/000_site.yml --check --diff

echo -e "${GREEN}======================================"
echo "Validation Complete!"
echo "======================================${NC}"