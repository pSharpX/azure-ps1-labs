#!/bin/bash

# **************** Install Ansible Engine on Ubuntu ****************

# Installing Ansible Dependencies
installing_dependencies(){    
    #  Install tools and dependencies
    sudo apt install -y software-properties-common python3-pip
}

installing_ansible(){
  echo ">>>>>>>>>> Installing Ansible"

  # Upgrade pip3.
  sudo pip3 install --upgrade pip

  # Install Ansible.
  pip3 install "ansible==2.9.17"

  # Install Ansible azure_rm module for interacting with Azure.
  pip3 install ansible[azure]
  

  echo ">>>>>>>>>> Ansible Version"
  ansible --version

  echo "Ansible is now installed on your Ubuntu system"
}


export DEBIAN_FRONTEND=noninteractive

PROVISIONED_ON=/etc/vm_provision_for_ansible_on_timestamp
if [ -f "$PROVISIONED_ON" ]
then
  echo "VM was already provisioned at: $(cat $PROVISIONED_ON)"
  echo "To run system updates manually login via 'vagrant ssh' and run 'sudo apt update && sudo apt upgrade -y'"
  exit
fi

lsb_release -ds

# sudo apt update && sudo apt upgrade -y
apt update && apt upgrade -y 

# Installing dependencies
echo "******** Installating Ansible Dependencies..."
installing_dependencies

echo "******** Installating Ansible..."
installing_ansible


# Tag the provision time:
date > "$PROVISIONED_ON"

echo "******** Installation completed successfully !"