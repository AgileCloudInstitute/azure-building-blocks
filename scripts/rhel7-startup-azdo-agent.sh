#!/bin/bash

#The following command set -e will cause the script to exit the moment any error is thrown by any command in the script.  
#set -e

#####################################################################################################
#### Section One: Set environment variables, including secrets. Later, these will come from a key vault.
####              SECURITY ALERT: RE-WRITE THE FOLLOWING TO RETRIEVE THE SECRETS FROM A KEYVAULT OR 
####              FROM SOME SECURE LOCATION.  Also make sure secrets are not printed to logs.  
#####################################################################################################

echo "About to echo who am i: "
whoami

export USR_NM=$USR_NM

echo "About to set environment_variables .  "
## NOTE:  OBSCURING PASSWORDS FROM LOGS BY ADDING:  

#Set AZ_PASS environment variable:
export AZ_PASS=$AZ_PSS
echo "export AZ_PASS='$AZ_PSS'" >> /etc/environment
echo "export AZ_PASS='$AZ_PSS'" >> /etc/bashrc
echo "export AZ_PASS='$AZ_PSS'" >> /etc/profile
#Set AZ_CLIENT environment variable:
export AZ_CLIENT=$AZ_CLNT
echo "export AZ_CLIENT=$AZ_CLNT" >> /etc/environment
echo "export AZ_CLIENT=$AZ_CLNT" >> /etc/bashrc
echo "export AZ_CLIENT=$AZ_CLNT" >> /etc/profile
#Set AZ_TENANT environment variable:
export AZ_TENANT=$AZ_TNT
echo "export AZ_TENANT=$AZ_TNT" >> /etc/environment
echo "export AZ_TENANT=$AZ_TNT" >> /etc/bashrc
echo "export AZ_TENANT=$AZ_TNT" >> /etc/profile
#Set AZ_PAT environment variable: 
export AZ_PAT=$AZ_PT
echo "export AZ_PAT=$AZ_PT" >> /etc/environment
echo "export AZ_PAT=$AZ_PT" >> /etc/bashrc
echo "export AZ_PAT=$AZ_PT" >> /etc/profile
#Set AZ_SERVER environment variable:  
export AZ_SERVER=$AZ_SRVR
echo "export AZ_SERVER=$AZ_SRVR" >> /etc/environment
echo "export AZ_SERVER=$AZ_SRVR" >> /etc/bashrc
echo "export AZ_SERVER=$AZ_SRVR" >> /etc/profile
#Set AZURE_DEVOPS_EXT_PAT environment variable.  Used by az devops cli extension.  Keeping this separate from $AZ_PAT to increase customizability.  
export AZURE_DEVOPS_EXT_PAT=$AZ_PT
echo "export AZURE_DEVOPS_EXT_PAT=$AZ_PT" >> /etc/environment
echo "export AZURE_DEVOPS_EXT_PAT=$AZ_PT" >> /etc/bashrc
echo "export AZURE_DEVOPS_EXT_PAT=$AZ_PT" >> /etc/profile
  
###########################################################################################################
#### Section Two:  Create user then install dependencies.
###########################################################################################################
echo "About to check if $USR_NM exists.  1 if exists and 0 if does not exist: "
grep -c "^$USR_NM:" /etc/passwd
  
#Configure user to not require password to execute sudo commands by first deleting sudoer membership and then recreating without password requirement.
rm -f /etc/sudoers.d/waagent
  
cat << EOF > /etc/sudoers.d/waagent
$USR_NM ALL=(ALL) NOPASSWD: ALL
EOF

yum clean all 

#First update the certificate so that dnf update commands below can work properly.  If you do not update certificates with this line, the script can break.  
echo "About to dnf update -y --disablerepo='*' --enablerepo='*microsoft*'  "
dnf update -y --disablerepo='*' --enablerepo='*microsoft*'

echo "--------------------------------------------------"
echo "About to dnf update"
dnf update -y --skip-broken --allowerasing --nobest
echo "Done with dnf update. "
echo "--------------------------------------------------"
dnf install -y git 
#Check version
git --version

## Next, Install dependencies using the just updated certificate:  
dnf install -y openssl curl dos2unix

## Install Terraform
cd /home/$USR_NM
mkdir terraform-download
cd terraform-download
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
#Move the terraform binary into a folder that is listed as part of the PATH variable.  
mv terraform /usr/local/bin/
cd /home/$USR_NM

#Have to install epel using rpm because dnf could not see epel-release
echo "About to install ansible, epel, and telnet"
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y telnet
dnf -y install ansible
  
##Install the Azure CLI using the following 3 steps:  
rpm --import https://packages.microsoft.com/keys/microsoft.asc

sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

dnf install -y azure-cli

#Install Powershell in the following steps:
mkdir /home/$USR_NM/powershell-download
cd /home/$USR_NM/powershell-download
dnf install -y wget
wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-1.rhel.7.x86_64.rpm
dnf install -y powershell-7.1.3-1.rhel.7.x86_64.rpm
#You should now be able to open powershell by typing "pwsh" in the command line

#-->echo "About to add extra libraries:"
wget -P /etc/yum.repos.d/ https://packages.efficios.com/repo.files/EfficiOS-RHEL7-x86-64.repo
rpmkeys --import https://packages.efficios.com/rhel/repo.key
curl https://packages.microsoft.com/config/rhel/8/prod.repo > ./microsoft-prod.repo
cp ./microsoft-prod.repo /etc/yum.repos.d/

## Download the agent to the VM:  
cd /home/$USR_NM
ls -al
mkdir agent-download
cd agent-download
wget https://vstsagentpackage.azureedge.net/agent/2.187.2/vsts-agent-linux-x64-2.187.2.tar.gz
tar xvf vsts-agent-linux-x64-2.187.2.tar.gz

chown -R $USR_NM:$USR_NM /home/$USR_NM/terraform-download
chown -R $USR_NM:$USR_NM /home/$USR_NM/agent-download
chown -R $USR_NM:$USR_NM /home/$USR_NM

echo "About to dnf clean all "
yum clean all

##Install the agent as a systemd service using the following 8 commands, which depend on the environment variables you just set in the line above this line.  
echo "About to switch to $USR_NM, then run many install commands.  "
su - $USR_NM << EOF
echo "User from whoami is: "
whoami
echo "About to login to az.  "
#This next line works, but it prints the password to the console, so we comment it out to try other approach below it.
#az login --service-principal -u '$AZ_CLIENT' -p '$AZ_PASS' --tenant '$AZ_TENANT'
#This next line is intended tp replace the preceding line more securely and is modified from: https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli 
read -sp "Azure password: " '$AZ_PASS' && echo && az login --service-principal -u '$AZ_CLIENT' -p '$AZ_PASS' --tenant '$AZ_TENANT'
echo "About to cd into agent-download directory.  "
cd /home/$USR_NM/agent-download/
echo "The server is: $AZ_SERVER "
echo "About to run the config sh script.  "
#This next line works, but we are commenting it out to try another approach below it.
#./config.sh --unattended --url $AZ_SERVER --auth pat --token $AZ_PAT --pool default --agent rhelBox --replace --acceptTeeEula
#These next 3 lines replace the preceding line in an attempt to prevent printing the $AZ_PAT into the logs.  This is modified from: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops 
export VSTS_AGENT_INPUT_TOKEN=$AZ_PAT
export VSTS_AGENT_INPUT_URL=$AZ_SERVER
./config.sh --unattended --auth pat --pool default --agent rhelBox --replace --acceptTeeEula
echo "About to run the install dependencies sh script.  "
sudo ./bin/installdependencies.sh
#Wait for the svc.sh file to be created before running it in subsequent steps.
echo "About to begin sleeping until the svc sh script has been found.  "
while [ ! -f /home/$USR_NM/agent-download/svc.sh ]; do sleep 1; done
echo "Finished sleeping because the svc sh file has now been found.  "
echo "About to svc sh install "
sudo ./svc.sh install
echo "About to svc sh start "
sudo ./svc.sh start
echo "About to svc sh status "
sudo ./svc.sh status
echo "About to e o f "
EOF

##Install the agent as a systemd service using the following 8 commands, which depend on the environment variables you just set in the line above this line.  
echo "About to switch to $USR_NM, then install awscli.  "
su - $USR_NM << EOF
echo "User from whoami is: "
whoami
echo "About to install awscli "
pip3 install awscli --upgrade --user
echo "About to e o f "
EOF

pip3 install requests
pip3 install pyyaml
pip3 install IPy

#Cause the ansible configuration to be owned by the agent user so that pipelines can change things like hosts file, etc.  
chown -R $USR_NM:$USR_NM /etc/ansible

echo "--------------------------------------------------"
echo "About to dnf update"
dnf update -y --skip-broken --allowerasing --nobest 
echo "Done with dnf update. "
echo "--------------------------------------------------"
echo "About to echo $USR_NM : "
echo $USR_NM

dnf install python3.8 -y
dnf remove python3.6 -y
rm -rf /usr/bin/python3
mv /usr/bin/python3.8 /usr/bin/python3

python3 --version

dnf install -y python3-setuptools
dnf install python3-pip -y

python3 -m pip install pyyaml
python3 -m pip install requests
python3 -m pip install awscli
#az extension add --name azure-devops
#az extension add --upgrade -n account

#Set alias so python commands use python3
echo "alias python=python3" >> /etc/bashrc

dnf clean all
dnf update python3 -y

python3 --version
echo "DELIMITTER "
echo "About to mkdir the acmconfig directory.  "
mkdir -p /home/$USR_NM/acmconfig 

echo "About to retrieve the secrets using cli.  "
az login --service-principal -u $AZ_CLNT -p $AZ_PSS --tenant $AZ_TNT
myVar=$(az keyvault secret show --name "acmSecretsFile" --vault-name "$VAULT_NAME" --query "value")
echo "About to store the secrets in a file.  "
echo "$myVar" | base64 --decode --ignore-garbage >>/home/$USR_NM/acmconfig/keys.yaml

echo "About to retrieve the second block of secrets that are used by some of the unit tests."
mkdir /home/$USR_NM/acmconfig2/
mkdir /home/$USR_NM/acmconfig2/adminAccounts/
myVar2=$(az keyvault secret show --name "acmSecretsFileTwo" --vault-name "$VAULT_NAME" --query "value")
echo "About to store the secrets in a file.  "
echo "$myVar2" | base64 --decode --ignore-garbage >>/home/$USR_NM/acmconfig2/adminAccounts/keys.yaml

#################################################################################
### The following block installs acm source code for development purposes only. 
#################################################################################
echo "About to install ACM source code for development purposes only."
#Get git variables 
dos2unix /home/$USR_NM/acmconfig/keys.yaml  
arr=($(cat /home/$USR_NM/acmconfig/keys.yaml | grep "gitPass:"))
gitPass=${arr[1]%$'\n'}
arr2=($(cat /home/$USR_NM/acmconfig/keys.yaml | grep "gitRepo:"))
gitRepo=${arr2[1]%$'\n'}
arr3=($(cat /home/$USR_NM/acmconfig/keys.yaml | grep "gitBranch:"))
gitBranch=${arr3[1]%$'\n'}
repoPart2=$(echo "$gitRepo" | awk -F'//' '{print "@"$2}')
repoWithToken="https://"$gitPass$repoPart2
#Create directory into which to clone the repo and cd into it
mkdir /home/$USR_NM/acm 
cd /home/$USR_NM/acm 
#Clone the repo into the directory
cloneCmd='git clone --branch '$gitBranch' '$repoWithToken
$cloneCmd

#Create the directory in which acm will store keys
mkdir /usr/acm

#Next 3 lines are a test 2 August 2022
mkdir /usr/acm/keys/
mkdir /usr/acm/keys/adminAccounts
cp /home/packer/acmconfig2/adminAccounts/keys.yaml /usr/acm/keys/adminAccounts/keys.yaml

#chown to new user so that these are not owned by root
chown -R $USR_NM:$USR_NM /home/$USR_NM/acmconfig
chown -R $USR_NM:$USR_NM /home/$USR_NM/acm
chown -R $USR_NM:$USR_NM /home/$USR_NM/acmconfig2/
chown -R $USR_NM:$USR_NM /home/$USR_NM/acmconfig2/adminAccounts/

echo "All done with cloud-init.  "
