#!/bin/bash

xargs -a inventory -t -I {} ssh pi@{} 'echo "cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1" | sudo tee -a  /boot/cmdline.txt; sudo reboot'
