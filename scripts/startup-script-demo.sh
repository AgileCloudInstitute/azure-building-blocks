#!/bin/bash

echo "Start of custom cloud-init script .  "

#Put your commands here.
sudo chown -R packer:packer /home/azureuser
sudo mkdir packer:packer /var/log/acm
sudo chown -R packer:packer /var/log/acm
sudo chown -R packer:packer /usr/bin/python3
sudo mkdir packer:packer /opt/acm/
sudo chown -R packer:packer /opt/acm/
sudo chown -R packer:packer /home/azureuser/acm
sudo chown -R packer:packer /home/azureuser/acmconfig/

#az extension add --name azure-devops
#az extension add --upgrade -n account
#NOTE: disable SSH here to secure your servers.  Then just re-create new instances when you need changes.  
# Here, we are leaving SSH open so you can debug in the dev environment.  

echo "All done with cloud-init.  "
