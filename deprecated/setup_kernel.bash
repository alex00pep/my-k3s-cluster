#!/bin/bash

source  <(cat inventory  | python py-ini-parser.py)

user=$1
if [[ -z "$user" ]]; then
    echo "Please specify a user"
    return
fi

# Grab the password
IFS= read -rsp "${user}'s password: " sshpass && echo

for dst in "${master[@]}" "${node[@]}";
do
    # Using the password we entered at the beginning, copy the keys everywhere
    SSHPASS=$sshpass sshpass -e -v -P "password" ssh $user@$dst 'echo " cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1" | sudo tee -a  /boot/cmdline.txt;sudo reboot || true'
    echo "Waiting for $dst to startup again"
    sleep 5
    until ping -c1 $dst >/dev/null 2>&1; do :; done
done




#xargs -a inventory -t -I {} ssh pi@{} 'echo "cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1" | sudo tee -a  /boot/cmdline.txt || true'
