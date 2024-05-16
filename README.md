# My RPI-K3s cluster - Automated RPI-K3s setup
Kubernetes cluster setup

Welcome to my RPI K3s repository! This space is dedicated to documenting the setup and automatic build/rebuild processes of my personal HomeLab. The primary goal is to enable anyone (including my future self) to check out this repository, create the necessary .env file, and have everything up and running smoothly with minimal manual intervention.


Design principles:
1. Simple to spin up and tear down.
2. Security-first approach with NetworkSecurityPolicies to allow for isolation and CrowdSec software to block malintentioned requests to the ingress objects.
3. Automated certificate management for all ingresses, with resilient certificate issuers.
4. Monitoring from the first day for all services and including the host.


## Pre-requisites

```bash
docker build --pull --rm -f "Dockerfile" -t ansiblecontainer:latest "."
ansible-galaxy collection install ansible.posix
```


```cmd
# Command prompt (Windows)
docker run -it --entrypoint=/bin/bash --rm -w /workspace --network=host -v %cd%:/workspace ansiblecontainer
```

```bash
# Bash (Linux)
docker run -it --entrypoint=/bin/bash --rm -w /workspace --network=host  -v `pwd`:/workspace ansiblecontainer
```

For more information on env variables as well as inventory group variables please look at:
git clone https://github.com/techno-tim/k3s-ansible/tree/master

## Setup
### Generate your env variable file and configure installation variables 
Including system_timezone, please update all variables needed, run setup.sh and generate the inventory file based on it
```bash
cp example.env .env
source setup.sh

CLUSTER=cluster01
```

### Step 1: Edit inventory/${CLUSTER}/group_vars/all.yml to match the system information gathered.

With your Ansible inventory file generated inventory/${CLUSTER}/hosts.ini with the IP addresses you need, and the variables ready run below line and it will install sshpass, kubectl, k3s and other programs for Debian and Ubuntu.
```bash

ansible-playbook playbooks/configure/install_toolchain.yml -i inventory/${CLUSTER}/hosts.ini
```


### Step 2: Copy SSH keys to Master and Worker nodes as authorized_keys and add the user to sudo group
The RSA key files will be located at: ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
```bash

ansible-playbook playbooks/configure/01-generate-rsa.yml -i inventory/${CLUSTER}/hosts.ini
ansible-playbook playbooks/configure/02-copy-rsa.yml -i inventory/${CLUSTER}/hosts.ini --ask-pass  # Ignore if play "Exchange Keys between master and nodes" is failed
ansible-playbook playbooks/configure/03-set-sudo.yml -i inventory/${CLUSTER}/hosts.ini --ask-pass --ask-become-pass
```

Then ping your nodes:
```bash
ansible -i inventory/${CLUSTER}/hosts.ini -m ping all

# If above lines do not work, then use command below per host:
ssh-copy-id -i ~/.ssh/id_rsa -f <your_user>>@<your_pi_host>
```

### Step 3: Upgrade OS 
```bash
ansible-playbook playbooks/configure/04-os-config.yaml -i inventory/${CLUSTER}/hosts.ini -t security,upgrade
```

### Step 4: Install K3s cluster and test is successfully running.
```bash
ansible-playbook k3s-ansible/site.yml -i inventory/${CLUSTER}/hosts.ini
```
Test your cluster. The context is an alias for your kubernetes cluster
```bash
source get-k3s-token.bash


# Follow the instructions of the script in the output

export KUBECONFIG=~/.kube/config
kubectl config use-context <context>
kubectl cluster-info
kubectl get nodes -o wide
kubectl get all -A -o wide
kubectl get endpoints -A
kubectl top pod --containers -A

sudo k3s check-config  # Run this on the master server only
sudo k3s crictl ps -a # Run it on the master server
```

## Uninstalling K3s cluster
To uninstall K3s from all servers and nodes, run from second repository:

```bash
ansible-playbook k3s-ansible/reset.yml -i inventory/${CLUSTER}/hosts.ini
```

# Special thanks to:
[Entechlog](https://www.entechlog.com/blog/general/how-to-set-up-kubernetes-cluster-with-raspberry-pi/#prerequisite)

[K3s](https://k3s.io/)

[k3sup](https://github.com/k3s-io/k3sup)

[K3s-ansible](https://github.com/k3s-io/k3s-ansible)

[TecnoTim's K3s-ansible](https://github.com/techno-tim/k3s-ansible)
