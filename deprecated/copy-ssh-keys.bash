#!/bin/bash
# Configure kubectl autocomplete. If kubectl autocomplete is not set yet:
source <(kubectl completion bash)

# Make the hosts available on the global namespace for the script
source <(cat inventory  | python py-ini-parser.py)


for dst in "${master[@]}" "${node[@]}";
do
    # Overcome the unknown SSH Host fingerprint issue, by deleting the already existing keys
    ssh-keygen -R ${dst} > /dev/null 2>&1 
    # And scan the remote host for its new SSH fingerprint
    ssh-keyscan -H -t rsa ${dst} >> $HOME/.ssh/known_hosts
done

# Generate SSH keys if not found 
#
if [[ ! -f "$HOME/.ssh/id_rsa" ]] || [[ ! -f "$HOME/.ssh/id_rsa.pub" ]]
then
    # Start clean
    rm -f "$HOME/.ssh/id_rsa" "$HOME/.ssh/id_rsa.pub"
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -P ""
fi


# Check if SSH Agent is running. 
echo "SSH Agent is running: "
eval "$(ssh-agent -s)"
echo "Add the SSH Keys to SSH Agent"
ssh-add "$HOME/.ssh/id_rsa"
# Verify Keys Added to SSH Agent.
ssh-add -l
echo "**********SSH Keys Added to SSH Agent***********"

# Grab the password
#
user=$1
if [[ -z "$user" ]]; then
    echo "Please specify a user"
    return
fi
IFS= read -rsp "${user}'s password: " sshpass && echo

# Copy the SSH keys
for dst in "${master[@]}" "${node[@]}";
do
    # Using the password we entered at the beginning, copy the keys everywhere
    SSHPASS=$sshpass sshpass -e -v -P "password" ssh-copy-id -i "$HOME/.ssh/id_rsa" -f ${user}@${dst}
done


# export SSHPASS=<yourpass>


# while IFS='' read -u5 -r line || [[ -n "$line" ]]; do
#   ssh-keyscan -H -t rsa ${line} >> ~/.ssh/known_hosts
#   sshpass -e -v -P "password" ssh-copy-id -i $2 -f pi@${line}
  
# done 5< $1


# ssh-keyscan -H -t rsa rpipn4.local >> ~/.ssh/known_hosts
# sshpass -e -v -P "password" ssh-copy-id -i ~/.ssh/id_rsa -f pi@rpipn4.local