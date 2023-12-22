# My K3s cluster - Automated K3s setup on RaspberryPi
Kubernetes cluster setup on Raspberry Pi


## Step 1: Use an isolated container based on Ansible as your management station
```bash
docker build --pull --rm -f "Dockerfile" -t ansiblecontainer:latest "."
```


```cmd
# Command prompt (Windows)
docker run -it --entrypoint=/bin/bash --rm -w /workspace --network=host -v %cd%:/workspace ansiblecontainer
```

```bash
# Bash (Linux)
docker run -it --entrypoint=/bin/bash --rm -w /workspace --network=host  -v `pwd`:/workspace ansiblecontainer
```
## Step 2: Copy the sample inventory and dit inventory/hosts.ini with the IP addresses you need, line in the following format:
```bash
cp -R inventory/sample.ini inventory/hosts.ini


```
## Step 3: Copy SSH keys to Master and Worker nodes as authorized_keys
The RSA key files will be located at: ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub
```bash
ansible-playbook rpi-k3/configure/01-generate-rsa.yml -i inventory/hosts.ini
ansible-playbook rpi-k3/configure/02-copy-rsa.yml -i inventory/hosts.ini --ask-pass

# Then ping your nodes
ansible -i inventory/hosts.ini -m ping all

# If above lines do not work, then use command below per host:
ssh-copy-id -i ~/.ssh/id_rsa -f pi@<your_pi_host>
``` 
## Step 4: Upgrade Pis with Ansible playbook
```bash
ansible-playbook rpi-k3/configure/04-os-config.yaml -i inventory/hosts.ini -t upgrade
```

## Step 5: Install K3s using the following k3-ansible project
```bash
git clone https://github.com/k3s-io/k3s-ansible.git
ansible-playbook k3s-ansible-master/site.yml -i inventory/hosts.ini
```
## Step 6 [optional]: Install Docker engine
Follow through: 
## Step 6: Check the installation and the cluster nodes
Saving KUBECONFIG file to: /workspace/kubeconfig


Test your cluster with:
```bash
source get-k3s-token.bash <MASTER_IP> pi
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

## Step 7: Run some kubernetes tools 
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