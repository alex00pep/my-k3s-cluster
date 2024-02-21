#!/bin/bash

# Function to add hosts to the inventory file
add_hosts() {
    local section=$1
    local ips=(${2//,/ })
    
    # Check if the section exists, if not, add it
    if ! grep -q "^\[${section}\]$" "${INVENTORY_FILE}"; then
        echo "[${section}]" >> "${INVENTORY_FILE}"
    fi

    # Add IPs to the section if they're not already present
    for ip in "${ips[@]}"; do
        if ! grep -q "^${ip}$" "${INVENTORY_FILE}" -A1 | grep -q "^${ip}$"; then
            echo "Adding ${ip} to [${section}]"
            # Insert IPs before the next section starts or at the end of the file
            sed -i "/^\[${section}\]$/a ${ip}" "${INVENTORY_FILE}"
        fi
    done
}

# Function to add a section if it doesn't exist
add_section_if_not_exists() {
    local section="$1"
    local content="$2"
    local file="$3"

    # Check if the file contains the unique identifier of the section you want to add/ensure exists
    if ! grep -qF "$section" "$file"; then
        # If the unique identifier isn't found, append the required lines to the file
        echo -e "\n$content" >> "$file"
        echo "Added section $section to $file."
    else
        echo "The section $section already exists in $file."
    fi
}

# Function to retrieve k3s cluster config
retrieve_k3s_cluster_config() {
    # Validate the number of arguments passed to the function
    if [ "$#" -ne 3 ]; then
        echo "Usage: install_k3s_cluster <master_ip> <master_user> <context>"
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


# Source the .env file if it exists
if [ -f .env ]; then
    source .env
    echo ".env file exists and sourced."
else
    echo ".env file does not exist. Creating from example..."
    # Create .env file from example
    cp example.env .env
    echo ".env file created from example."
    echo "Please edit the .env file and run the script again."
    exit 0  # Exit script if .env was just created from example
fi

# Check if already in the repository directory
if [ -d "$REPO_NAME/.git" ]; then
    echo "Already in the repository directory."
    cd $REPO_NAME
elif [ "$(basename "$(pwd)")" = "$REPO_NAME" ]; then
    echo "Already in the repository directory."
else
    echo "Not in the repository directory. Cloning..."
    # Clone your GitHub repository
    git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git
    cd $REPO_NAME
fi


echo "Initializing localhost..."
ansible-playbook homelab.yml

# Check if K3s is enabled
if [ "${K3S_ENABLED}" == "true" ]; then
    echo "K3s is enabled."
    ## Clone K3s Ansible Repo
    echo "Cloning K3s Ansible Repo..."
    git clone https://github.com/techno-tim/k3s-ansible.git  # Additional actions for configuring K3s can be added here
    echo "K3s Ansible Repo cloned."
    # Check and create ANSIBLE_INVENTORY_PATH directory if it doesn't exist
    echo "Checking and creating ANSIBLE_INVENTORY_PATH directory..."
    if [ ! -d "${ANSIBLE_INVENTORY_PATH}" ]; then
        mkdir -p "${ANSIBLE_INVENTORY_PATH}"
    fi
    # Check and create ANSIBLE_INVENTORY_FILE if it doesn't exist
    echo "Checking and creating ANSIBLE_INVENTORY_FILE..."
    INVENTORY_FILE="${ANSIBLE_INVENTORY_PATH}/${ANSIBLE_INVENTORY_FILE}"
    if [ ! -f "${INVENTORY_FILE}" ]; then
        touch "${INVENTORY_FILE}"
    fi
    # Define localhost
    # Define local section 
    REQUIRED_LOCAL_SECTION="[local]\nlocalhost ansible_connection=local ansible_user=${K3S_USERNAME}"
    # Ensure the [local] section is present
    echo "Checking and creating [local] section... ${REQUIRED_LOCAL_SECTION}"
    add_section_if_not_exists "[local]" "$REQUIRED_LOCAL_SECTION" "${INVENTORY_FILE}"

    # Check if K3S_MASTERS and K3S_NODES are not empty, and then update the inventory file accordingly
    if [ -n "${K3S_MASTERS}" ]; then
        add_hosts "master" "${K3S_MASTERS}"
    fi
    if [ -n "${K3S_NODES}" ]; then
        add_hosts "node" "${K3S_NODES}"
    fi
    
    # Check if the K3s Cluster is defined 
    # Define the second section you want to ensure is present in the file
    REQUIRED_CLUSTER_SECTION="[k3s_cluster:children]\nmaster\nnode"
    # Ensure the [k3s_cluster:children] section is present
    echo "Checking and creating [k3s_cluster:children] section... ${REQUIRED_CLUSTER_SECTION}"
    add_section_if_not_exists "[k3s_cluster:children]" "$REQUIRED_CLUSTER_SECTION" "${INVENTORY_FILE}"

    echo "ANSIBLE_INVENTORY_FILE created."
    # Check and create ANSIBLE Group Vars if it doesn't exist
    echo "Checking and creating ANSIBLE Group Vars..."
    if [ ! -d "${ANSIBLE_INVENTORY_PATH}/group_vars" ]; then
        mkdir -p "${ANSIBLE_INVENTORY_PATH}/group_vars"
    fi
    if [ ! -f "${ANSIBLE_INVENTORY_PATH}/group_vars/all.yml" ]; then
        cp k3s-ansible/inventory/sample/group_vars/all.yml "${ANSIBLE_INVENTORY_PATH}/group_vars/all.yml" 
    fi
    echo "ANSIBLE Group Vars created."
    # update Ansible User in Group Vars
    echo "Updating Ansible User in Group Vars..."
    sed -i "s/{{ ansible_user }}/${ANSIBLE_USER}/g" "${ANSIBLE_INVENTORY_PATH}/group_vars/all.yml"
    echo "Ansible User updated in Group Vars."
    # Initialize K3s
    echo "Initializing K3s..."
    ansible-playbook -i "${ANSIBLE_INVENTORY_PATH}/${ANSIBLE_INVENTORY_FILE}" k3s-ansible/site.yml
    echo "K3s initialized."
    echo "retrieving k3s cluster config..."
    # Extract the first IP address from K3S_MASTERS
    first_master_ip=$(echo $K3S_MASTERS | cut -d',' -f1)
    retrieve_k3s_cluster_config "$first_master_ip" "${K3S_USERNAME}" "${K3S_CONTEXT}"
    echo "k3s cluster config retrieved."
    echo "exporting k3s cluster config..."
    export KUBECONFIG=~/.kube/config
    echo "k3s cluster config exported."
    kubectl config use-context "${K3S_CONTEXT}"
    echo "k3s cluster info:"
    kubectl cluster-info
    echo "k3s nodes:"
    kubectl get nodes -o wide

else
    echo "K3s is not enabled."
fi

if [ "$SYNOLOGY_ENABLED" = true ]; then
    echo "Synology is enabled."
    # Additional actions for configuring Synology can be added here
else
    echo "Synology is not enabled."
fi

if [ "$DOCKER_SERVER_ENABLED" = true ]; then
    echo "Docker server is enabled."
    # Additional actions for configuring Docker server can be added here
    if [ -n "$DOCKER_IMAGES" ]; then
        echo "Running Docker images: $DOCKER_IMAGES"
        # Run Docker images listed in DOCKER_IMAGES
        for image in $DOCKER_IMAGES; do
            docker run -d $image
        done
    else
        echo "No Docker images specified to run."
    fi
else
    echo "Docker server is not enabled."
fi