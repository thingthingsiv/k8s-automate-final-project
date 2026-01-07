#!/bin/bash
set -e

./scripts/install-deps.sh

ansible-playbook -i inventory/ha-cluster/hosts.yaml playbooks/01-bootstrap.yml
ansible-playbook -i inventory/ha-cluster/hosts.yaml playbooks/02-kubespray.yml
ansible-playbook playbooks/03-ingress.yml
ansible-playbook playbooks/04-dashboard.yml
ansible-playbook playbooks/05-argocd.yml
