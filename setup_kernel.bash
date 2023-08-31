#!/bin/bash

source  <(cat inventory  | python py-ini-parser.py)


# Grab the password
#
IFS= read -rsp "Pi password: " sshpass && echo


for dst in "${masters[@]}" "${nodes[@]}";
do
    # Using the password we entered at the beginning, copy the keys everywhere
    SSHPASS=$sshpass sshpass -P "password" -e -v ssh pi@$dst 'echo " cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1" | sudo tee -a  /boot/cmdline.txt;sudo reboot || true'
    echo "Waiting for $dst to startup again"
    sleep 5
    until ping -c1 $dst >/dev/null 2>&1; do :; done
done




#xargs -a inventory -t -I {} ssh pi@{} 'echo "cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1" | sudo tee -a  /boot/cmdline.txt || true'
