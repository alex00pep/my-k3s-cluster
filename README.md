# My K3s cluster - Automated K3s setup on RaspberryPi
Kubernetes cluster setup on Raspberry Pi


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
## Step 2: Generate your inventory/hosts.ini with the IP addresses you need. Also install necessary packages:
```bash
cp -R inventory/sample.ini inventory/hosts.ini
```

Install Kubectl
```bash
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl
# Download the public signing key for the Kubernetes package repositories
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

Install K3sup
```
curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/

k3sup --help
```


## Step 3: Copy SSH keys to Master and Worker nodes as authorized_keys and add the user to sudo group
The RSA key files will be located at: ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
```bash
ansible-playbook rpi-k3/configure/01-generate-rsa.yml -i inventory/hosts.ini
ansible-playbook rpi-k3/configure/02-copy-rsa.yml -i inventory/hosts.ini --ask-pass
ansible-playbook rpi-k3/configure/03-set-sudo.yml -i inventory/hosts.ini --ask-pass --ask-become-pass
```


Then ping your nodes:
```bash
ansible -i inventory/hosts.ini -m ping all

# If above lines do not work, then use command below per host:
ssh-copy-id -i ~/.ssh/id_rsa -f pi@<your_pi_host>
```

## Step 4: Upgrade Pis with Ansible playbook
```bash
ansible-playbook rpi-k3/configure/05-os-config.yaml -i inventory/hosts.ini -t upgrade
```

## Step 5: Install K3s using the following k3-ansible project
```bash
git clone https://github.com/k3s-io/k3s-ansible.git
# Copy and modify the inventory yml file to match your cluster setup and also adjust the version of K3S to install.
cp inventory-sample.yml inventory.yml
ansible-playbook k3s-ansible-master/site.yml -i inventory.yml
```



Test your cluster with:
```bash
source get-k3s-token.bash <MASTER_IP> <your user>
# Follow the instructions of the script in the output

export KUBECONFIG=/workspace/kubeconfig
kubectl config use-context default
kubectl cluster-info
kubectl get nodes -o wide
kubectl get all -A -o wide
kubectl get endpoints -A
kubectl top pod --containers -A

sudo k3s check-config  # Run this on the master server only
sudo k3s crictl ps -a # Run it on the master server
```

## Step 7: [Optional] Run some kubernetes tools 
Open the kube-tools folder and follow the instructions


## Uninstalling K3s cluster
To uninstall K3s from all servers and nodes, run:

```bash
ansible-playbook k3s-ansible-master/reset.yml -i inventory/hosts.ini
```

# Special thanks to:
[Entechlog](https://www.entechlog.com/blog/general/how-to-set-up-kubernetes-cluster-with-raspberry-pi/#prerequisite)

[K3s](https://k3s.io/)

[k3sup](https://github.com/k3s-io/k3sup)

[K3s-ansible](https://github.com/k3s-io/k3s-ansible)