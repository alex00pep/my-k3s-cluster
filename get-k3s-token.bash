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

mkdir -p ~/.kube
touch ~/.kube/config

master_user=$2
if [[ -z "$master_user" ]]; then
    echo "Second argument is missing. Please specify a user"
    return
fi

context=$3

if [[ -z "$context" ]]; then
    echo "Third argument (kubernetes context) is missing. Please specify a context"
    return
fi

k3sup install  \
    --user $master_user \
    --skip-install \
    --host $master_ip \
    --context $context \
    --merge \
    --local-path ~/.kube/config \
    --ssh-key ~/.ssh/id_rsa
