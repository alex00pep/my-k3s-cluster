#!/bin/bash

source  <(cat inventory  | python py-ini-parser.py)

# Check if SSH Agent is running. 
echo "SSH Agent is running: "
eval "$(ssh-agent -s)"
# Add the Keys to SSH Agent. 
ssh-add $2
# Verify Keys Added to SSH Agent.
ssh-add -l



# Grab the password
#
IFS= read -rsp "Pi password: " sshpass && echo

# Generate SSH keys if not found 
#
if [[ ! -f "$HOME/.ssh/id_rsa" ]] || [[ ! -f "$HOME/.ssh/id_rsa.pub" ]]
then
    # Start clean
    rm -f "$HOME/.ssh/id_rsa" "$HOME/.ssh/id_rsa.pub"
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -P ""
fi

for dst in "${masters[@]}" "${nodes[@]}";
do
    # Using the password we entered at the beginning, copy the keys everywhere
    SSHPASS=$sshpass sshpass -P "password" -e -v ssh-copy-id -i "$HOME/.ssh/id_rsa" "$dst"
done


# export SSHPASS=<yourpass>


# while IFS='' read -u5 -r line || [[ -n "$line" ]]; do
#   ssh-keyscan -H -t rsa ${line} >> ~/.ssh/known_hosts
#   sshpass -e -v -P "password" ssh-copy-id -i $2 -f pi@${line}
  
# done 5< $1


# ssh-keyscan -H -t rsa rpipn4.local >> ~/.ssh/known_hosts
# sshpass -e -v -P "password" ssh-copy-id -i ~/.ssh/id_rsa -f pi@rpipn4.local