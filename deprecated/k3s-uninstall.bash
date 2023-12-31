#!/bin/bash

source  <(cat inventory  | python py-ini-parser.py)

user=$1
if [[ -z "$user" ]]; then
    echo "Please specify a user"
    return
fi


for dst in "${master[@]}";
do
    ssh $user@$dst '/usr/local/bin/k3s-uninstall.sh;sudo rm -rf /var/lib/rancher/k3s/ /etc/rancher/k3s || true'
    
done

for dst in "${node[@]}";
do
    ssh-keyscan -H -t rsa ${dst} >> $HOME/.ssh/known_hosts
    ssh $user@$dst '/usr/local/bin/k3s-agent-uninstall.sh || true'
    
done
