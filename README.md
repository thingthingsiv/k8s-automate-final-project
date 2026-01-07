This project provides a zero-manual-work solution to deploy a High Availability (HA) Kubernetes cluster using Kubespray. It includes automated installation of the K8s Dashboard and ArgoCD with custom domain mapping.

## 🏗️ Cluster Architecture
* **Nodes:** 3 VMs (Master + Worker roles combined for HA).
* **CNI:** Calico (Networking).
* **Load Balancer:** Internal API LB (standard in Kubespray HA).
* **Ingress:** Nginx Ingress Controller.

---

## 🚀 Quick Start (Total Automation)

Run these commands on your **Jump Host** (or `vm-01`) to prepare the environment and launch the installation.

### 1. Prepare Environment
```bash
# Clone the automation tool
git clone [https://github.com/kubernetes-sigs/kubespray.git](https://github.com/kubernetes-sigs/kubespray.git)
cd kubespray

# Install required python packages
pip3 install -r requirements.txt
2. Configure InventoryUpdate the IPS variable below with your actual VM IP addresses.Bash# Set your node IPs
declare -a IPS=(10.0.0.1 10.0.0.2 10.0.0.3)

# Generate inventory
cp -rfp inventory/sample inventory/mycluster
CONFIG_FILE=inventory/mycluster/hosts.yml python3 \
contrib/inventory_builder/inventory.py ${IPS[@]}
3. Enable Add-ons & DomainsTo automate the Dashboard and Ingress, edit inventory/mycluster/group_vars/k8s_cluster/addons.yml:Set dashboard_enabled: trueSet ingress_nginx_enabled: trueSet argocd_enabled: true (if using latest Kubespray) or use the Helm script below.🌐 Domain ConfigurationServiceTarget DomainK8s Dashboardk8s-dashboard.yourdomain.comArgoCDargocd.yourdomain.comPost-Install: Automated Ingress SetupAfter the cluster is up, run this block to map your domains to the services:Bash# Dashboard Ingress
kubectl create ingress k8s-dashboard --rule="[k8s-dashboard.yourdomain.com/*=kubernetes-dashboard:443,tls](https://k8s-dashboard.yourdomain.com/*=kubernetes-dashboard:443,tls)" -n kube-system

# ArgoCD Ingress
kubectl create ingress argocd-server --rule="[argocd.yourdomain.com/*=argocd-server:443,tls](https://argocd.yourdomain.com/*=argocd-server:443,tls)" -n argocd
🛠️ ExecutionExecute the full deployment with a single command. This includes a timeout fix to prevent the "TLS Handshake" error you encountered earlier.Bashansible-playbook -i inventory/mycluster/hosts.yml \
--become --become-user=root \
--extra-vars "ansible_timeout=60" \
cluster.yml
📝 Important NotesTLS Handshake Errors: If the play fails at Calico again, ensure your VMs have at least 2 vCPUs and 4GB RAM. The API server times out when resources are too low.Firewall: Ensure ports 6443, 2379-2380 (etcd), and 10250 are open between all nodes.DNS: Point your A-records for the domains above to the IP of any node in the cluster (or your Load Balancer IP).

# By Siv Thingthing
