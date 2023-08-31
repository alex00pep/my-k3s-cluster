#!/bin/bash
#References:
# https://alexellisuk.medium.com/walk-through-install-kubernetes-to-your-raspberry-pi-in-15-minutes-84a8492dc95a
# https://github.com/alexellis/k3sup#download-k3sup-tldr
# https://blog.alexellis.io/raspberry-pi-homelab-with-k3sup/

# https://medium.com/karlmax-berlin/how-to-install-kubernetes-on-raspberry-pi-53b4ce300b58

source  <(cat inventory  | python py-ini-parser.py)

export MASTER=${masters[host1]}
for worker in "${nodes[@]}";
do
    k3sup join --host $worker --server-host $MASTER --user pi
done

