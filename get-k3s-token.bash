#!/bin/bash
source .env
# Function to retrieve k3s cluster config
retrieve_k3s_cluster_config() {
    # Validate the number of arguments passed to the function
    if [ "$#" -ne 3 ]; then
        echo "Usage: retrieve_k3s_cluster_config <master_ip> <master_user> <context>"
        return 1
    fi

    local master_ip=$1
    local master_user=$2
    local context=$3

    # Create the .kube directory and config file if they don't exist
    mkdir -p ~/.kube
    touch ~/.kube/config

    # Execute k3sup install command with the provided arguments
    k3sup install \
        --user "$master_user" \
        --skip-install \
        --host "$master_ip" \
        --context "$context" \
        --merge \
        --local-path ~/.kube/config \
        --ssh-key ~/.ssh/id_rsa
}

first_master_ip=$(echo $K3S_MASTERS | cut -d',' -f1)
retrieve_k3s_cluster_config "$first_master_ip" "${K3S_USERNAME}" "${K3S_CONTEXT}"