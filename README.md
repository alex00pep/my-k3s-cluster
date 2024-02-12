# My K3s cluster - Automated K3s setup
Kubernetes cluster setup


## Step 1: Use an isolated container based on Ansible as your management station and install the ansible.posix collection

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
## Step 2: Generate your inventory hosts.ini with the IP addresses you need. Second, edit inventory/my-cluster/hosts.ini to match the system information gathered:
```bash
cp -R inventory/sample inventory/my-cluster
```
Install sshpass, kubectl, k3s and other programs for Debian and Ubuntu.
```bash
ansible-playbook playbooks/configure/install_toolchain.yml -i inventory/my-cluster/hosts.ini
```


## Step 3: Copy SSH keys to Master and Worker nodes as authorized_keys and add the user to sudo group
The RSA key files will be located at: ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
```bash
ansible-playbook playbooks/configure/01-generate-rsa.yml -i inventory/my-cluster/hosts.ini
ansible-playbook playbooks/configure/02-copy-rsa.yml -i inventory/my-cluster/hosts.ini --ask-pass  # Ignore if play "Exchange Keys between master and nodes" is failed
ansible-playbook playbooks/configure/03-set-sudo.yml -i inventory/my-cluster/hosts.ini --ask-pass --ask-become-pass
```


Then ping your nodes:
```bash
ansible -i inventory/my-cluster/hosts.ini -m ping all

# If above lines do not work, then use command below per host:
ssh-copy-id -i ~/.ssh/id_rsa -f pi@<your_pi_host>
```

## Step 4: Upgrade Pis with Ansible playbook
```bash
ansible-playbook playbooks/configure/04-os-config.yaml -i inventory/my-cluster/hosts.ini -t upgrade
```

## Step 5: Install K3s using the following k3-ansible project
```bash
git clone https://github.com/techno-tim/k3s-ansible/tree/master
```

Go back to the previous local repository

Test your cluster. The context is an alias for your kubernetes cluster
```bash
source get-k3s-token.bash <MASTER_IP> <your user> <context>


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

## Step 6: [Optional] Run some kubernetes tools 
Open the kube-tools folder and follow the instructions


## Uninstalling K3s cluster
To uninstall K3s from all servers and nodes, run from second repository:

```bash
ansible-playbook reset.yml -i inventory/my-cluster/hosts.ini
```

# Special thanks to:
[Entechlog](https://www.entechlog.com/blog/general/how-to-set-up-kubernetes-cluster-with-raspberry-pi/#prerequisite)

[K3s](https://k3s.io/)

[k3sup](https://github.com/k3s-io/k3sup)

[K3s-ansible](https://github.com/k3s-io/k3s-ansible)

[TecnoTim's K3s-ansible](https://github.com/techno-tim/k3s-ansible)