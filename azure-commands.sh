#When running CustomExtensionScripts or RunCommands on Virtual Machines to see executed code go to the following log files in agent folder:
cat /var/lib/waagent/custom-script/download/0/install_ansible.sh
cat /var/lib/waagent/run-command/download/0/script.sh
cat /var/lib/waagent/run-command-handler/download/ansiblevmqrpaymentsansiblecommand/0/script.sh

#When working with Ansible use the following command to run ad-hoc commands or playbooks
ansible localhost -m azure_rm_resourcegroup -a "name=ansible-test location=eastus"
ansible-playbook playbook.yaml
ansible-playbook 00_delete_azure_rg.yaml # --extra-vars "name=<resource_group>"
ansible-playbook playbook.yaml  --syntax-check