# My K8s cluster - Automated K8s setup on RaspberryPi
Kubernetes cluster setup and cluster-apps installation using Helm charts


## Step 1: Update your local file inventory file.
The inventory file should contain all your Raspberry Pi's hostnames, one per line
## Step 2: Use an isolated container based on Ansible as your management station
```bash
docker build --pull --rm -f "Dockerfile" -t ansiblecontainer:latest "."
```

```cmd
# Command prompt (Windows)
docker run -it --entrypoint=/bin/bash --rm -w /workspace -v %cd%:/workspace ansiblecontainer
```

```bash
# Bash
docker run -it --entrypoint=/bin/bash --rm -w /workspace -v `pwd`:/workspace ansiblecontainer
```

## Step 2: Copy SSH keys to Master and Worker appliances
The RSA key files are pointed at: ~/.ssh/id_rsa 
```bash
source copy-ssh-key.bash ~/.ssh/id_rsa


# If above line does not work, then use:
ssh-copy-id -i ~/.ssh/id_rsa -f pi@<your_pi_host>
``` 

## Step 3: Modify the file /boot/cmdline.txt in all cluter nodes
In file /boot/cmdline.txt add cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1 into the end of the file.
Login via SSH, do the modification shown below and reboot

```bash
source setup_kernel.bash
```

## Step 4: Update your master node name in the Create the Master and worker instances for the K8s cluster
```bash
source k8s-cluster-master.bash
source k8s-cluster-workers.bash
```
## Step 5: Work in your cluster and inspect the nodes
Saving file to: /workspace/kubeconfig

Test your cluster with:
export KUBECONFIG=/workspace/kubeconfig
kubectl config use-context default
kubectl get node -o wide 

## Voila!