#!/bin/bash
cp inventory inventory.orig
source  <(cat inventory  | python py-ini-parser.py)

for host in "${masters[@]}" "${nodes[@]}";
do
   result=$(nslookup "$host" 2> /dev/null | awk '/Name:/{val=$NF;flag=1;next} /Address:/ && flag{print $NF,val;val=""}')
   all_ips=${result}
   
   ipv4_only=$(echo $all_ips | sed -r '/\n/!s/[0-9.]+/\n&\n/;/^([0-9]{1,3}\.){3}[0-9]{1,3}\n/P;D')
   echo "Replacing ${host} with ${ipv4_only} on file inventory"
   sed -i "s/${host}/${ipv4_only}/g" inventory
done

echo "********Inventory file modified**********"
cat inventory