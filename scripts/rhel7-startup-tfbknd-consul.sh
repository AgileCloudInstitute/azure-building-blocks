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

echo "About to echo $USR_NM : "
export USR_NM=$USR_NM
echo $USR_NM
  
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
dnf update -y
echo "Done with dnf update. "
echo "--------------------------------------------------"
dnf install -y git 
#Check version
git --version

## Next, Install dependencies using the just updated certificate:  
dnf install -y openssl curl dos2unix

#-->echo "About to install python3"
#-->dnf install -y python3
#-->dnf install -y python3-setuptools
#-->dnf install python3-pip -y

#Have to install epel using rpm because dnf could not see epel-release
echo "About to install ansible, epel, and telnet"
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y telnet
dnf -y install ansible


## 
cd /home/$USR_NM
ls -al

chown -R $USR_NM:$USR_NM /home/$USR_NM

echo "About to dnf clean all "
yum clean all


pip3 install requests
pip3 install pyyaml
pip3 install IPy

#Cause the ansible configuration to be owned by the agent user so that pipelines can change things like hosts file, etc.  
chown -R $USR_NM:$USR_NM /etc/ansible

#////////////////////////////////////////////////////////////////////////

##Install the Azure CLI using the following 3 steps:  
rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

dnf install -y azure-cli


#Install consul
dnf install -y dnf-utils
dnf install dnf-plugins-core
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
dnf -y install consul

#generate encryption key and save it to a variable so it can be retrieved below.
export CKEY=$(consul keygen)
#create certificate authority
consul tls ca create
#create the certificates for a sample datacenter named dc1
consul tls cert create -server -dc dc1
#create the client certificated for each client in a sample datacenter named dc1
consul tls cert create -client -dc dc1

mv /home/packer/consul-agent-ca.pem /etc/consul.d
mv /home/packer/consul-agent-ca-key.pem /etc/consul.d
mv /home/packer/dc1-server-consul-0.pem /etc/consul.d/
mv /home/packer/dc1-server-consul-0-key.pem /etc/consul.d/
mv /home/packer//dc1-client-consul-0.pem /etc/consul.d/
mv /home/packer//dc1-client-consul-0-key.pem /etc/consul.d/

cat << EOF > /etc/consul.d/consul.hcl
datacenter = "dc1"
retry_join = ["127.0.0.1"]

data_dir = "/opt/consul"
log_level = "INFO"
server = true
node_name = "master"
encrypt = $CKEY
ca_file = "/etc/consul.d/consul-agent-ca.pem"
cert_file = "/etc/consul.d/dc1-server-consul-0.pem"
key_file = "/etc/consul.d/dc1-server-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
acl = {
  enabled = true
  default_policy = "allow"
  enable_token_persistence = true
}
EOF

cat << EOF > /etc/consul.d/server.hcl
server = true
bootstrap_expect = 1
ui = true
EOF

chown -R consul:consul /etc/consul.d/
chmod 640 /etc/consul.d/consul.hcl

cat << EOF >  /usr/lib/systemd/system/consul.service 
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d/
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#>>consul -autocomplete-install
#>>complete -C /usr/bin/consul consul
#>>sudo setenforce 0

#///////////////////////////////////////////////////////////////////////

echo "--------------------------------------------------"
echo "About to dnf update"
dnf update -y
echo "Done with dnf update. "
echo "--------------------------------------------------"
echo "About to echo $USR_NM : "
echo $USR_NM

#>>#The next few lines are commented because firewalld is not installed by default, so the following firewall-cmd commands would thrown errors if run.  
#>>echo "About to make firewall rules for consul"
#>>firewall-cmd  --add-port={8300,8301,8302,8400,8500,8600}/tcp --permanent
#>>firewall-cmd  --add-port={8301,8302,8600}/udp --permanent

echo "All done with cloud-init.  "
