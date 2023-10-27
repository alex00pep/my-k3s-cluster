#!/bin/bash
#References:
# https://alexellisuk.medium.com/walk-through-install-kubernetes-to-your-raspberry-pi-in-15-minutes-84a8492dc95a
# https://github.com/alexellis/k3sup#download-k3sup-tldr
# https://blog.alexellis.io/raspberry-pi-homelab-with-k3sup/

# https://medium.com/karlmax-berlin/how-to-install-kubernetes-on-raspberry-pi-53b4ce300b58

master_ip=$1
if [[ -z "$master_ip" ]]; then
    echo "First argument is missing. Please specify one master host of the Kubernetes cluster"
    return
fi

master_user=$2
if [[ -z "$master_user" ]]; then
    echo "Second argument is missing. Please specify a user"
    return
fi


k3sup install  \
    --user $master_user \
    --skip-install \
    --host $master_ip \
    --context default \
    --local-path /workspace/kubeconfig \
    --ssh-key ~/.ssh/id_rsa \
    --k3s-version v1.28.2+k3s1
