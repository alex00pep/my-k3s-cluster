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
for dst in "${masters[@]}";
do    
    k3sup install --ip $dst --user $user
    k3sup ready \
        --context default \
        --kubeconfig ./kubeconfig
done

