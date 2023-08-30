#!/bin/bash
#References:
# https://alexellisuk.medium.com/walk-through-install-kubernetes-to-your-raspberry-pi-in-15-minutes-84a8492dc95a
# https://github.com/alexellis/k3sup#download-k3sup-tldr
# https://blog.alexellis.io/raspberry-pi-homelab-with-k3sup/

# https://medium.com/karlmax-berlin/how-to-install-kubernetes-on-raspberry-pi-53b4ce300b58

export MASTER=devnode1.local
export WORKER1=rpi-pn3.local
export WORKER2=rpipn4.local

k3sup join --host $WORKER1 --server-host $MASTER --user pi
k3sup join --host $WORKER2 --server-host $MASTER --user pi


arkade install openfaas