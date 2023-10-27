#!/bin/bash
#References:
# https://alexellisuk.medium.com/walk-through-install-kubernetes-to-your-raspberry-pi-in-15-minutes-84a8492dc95a
# https://github.com/alexellis/k3sup#download-k3sup-tldr
# https://blog.alexellis.io/raspberry-pi-homelab-with-k3sup/

# https://medium.com/karlmax-berlin/how-to-install-kubernetes-on-raspberry-pi-53b4ce300b58

source  <(cat inventory  | python py-ini-parser.py)

user=$1
if [[ -z "$user" ]]; then
    echo "Please specify a user"
    return
fi
for dst in "${master[@]}";
do    
    # Note: the --write-kubeconfig-mode 644 option is passed to Rancher K3s installer is needed to avoid kubectl permission denied error later on.
    # Note: --ipsec use to enforce Rancher K3s to use Flannel as alightweight network fabric that implements the Kubernetes Container Network Interface (CNI)
    k3sup install --ip $dst --user $user --k3s-extra-args '--write-kubeconfig-mode 644'
    

    k3sup ready \
        --context default \
        --kubeconfig ${HOME}/.kube/config
done

