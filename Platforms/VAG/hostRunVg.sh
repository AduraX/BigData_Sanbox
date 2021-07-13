#!/usr/bin/env bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

source ../../AduraxFtns.sh
source hostFtns.sh

hostType=$1
StackExt=$2
isBastion=$3
NumMasters=$4
NumSlaves=$5

#[** Set variables
lbAZ=""
StackName=BdCluster$isBastion$StackExt && $ECHO "$StackName" > StackNameFile
hdpBucket=adurax.hdpcluster
KeyNameEc2=SingaporeKeyEc2.pem

AnsUSER=vagrant
HD_USER=hduser
HD_GROUP=hdgroup
HD_PASS=hduser001
PathToKey=/home/$USER/.ssh
PROJ_DIR=/vagrant/bdplat
ARCH_DIR=$PROJ_DIR/Archive
DATA_DIR=/vagrant/bdData # /var/bdData
JAVA_DIR=/usr/lib/jvm/java-8-openjdk-amd64/jre # /usr/lib/jvm/java-8-oracle

if test ! -f $PathToKey/id_rsa; then
  ssh-keygen -t rsa -N "" -f $PathToKey/id_rsa
  chmod 400 $PathToKey/id_rsa
  chmod 400 $PathToKey/id_rsa.pub
  touch $PathToKey/config; chmod 600 $PathToKey/config
fi
if test ! -f $PathToKey/$KeyNameEc2; then cp $KeyNameEc2 $PathToKey/$KeyNameEc2; chmod 400 $PathToKey/$KeyNameEc2; fi
if [ $NumSlaves -le 5 ]; then nSEEDS=2; else nSEEDS=3; fi
#**] Set variables


#[** Creating cluster on AWS and Checking if the Hadoop Cluster is ready
sTime1=$(date +%s)
CreateHost $NumMasters $NumSlaves # $lbAZ $NumMasters $NumSlaves $isBastion $clusterType
$ECHO "\nExecuting vagrant up  command for Vagrant Cluster provisioning:"
vagrant up
timeDiff $sTime1 $(date +%s)
#**] Creating cluster on AWS and Checking if the Hadoop Cluster is ready

#[** Get Stack Outputs
lbCS_SEEDS=""
lbKF_NODES=""
lbZK_NODES=""
lbHosts="\n"
lbInventory=""
lbInvenZK=""
lbVarFiles="---\nnodes:"

$ECHO "\n#~~~~~~~~ Connectivity configurations on .ssh/config file ~~~~~~~~~~" > $PathToKey/config
sshCmd="none"
if [ $isBastion == "Y" ]; then
  outIp="Bastion${lbAZ}Ip"
  outDns="Bastion${lbAZ}Dns"
  Host_Ip="${IP_BASE}.100"  # "#{IP_BASE}.#{i}"
  Host_Dns="127.0.0.1"
  Host_Port=2200
  LogDns=$Host_Dns
  $ECHO "\nHost LogHost  \n\tHostName $Host_Dns  \n\tUser $HD_USER \n\tIdentityFile $PathToKey/id_rsa.pub \n\tProxyCommand none" >> $PathToKey/config
  sshCmd="ssh BastionA -W %h:%p"

  lbInventory="$lbInventory \n[Bastion]\n"
  lbHosts="${lbHosts}$Host_Ip bastion$lbAZ bastion$lbAZ.adurax.org \n"
  lbInventory="$lbInventory bastion$lbAZ ansible_ssh_host=$Host_Dns ansible_port=$Host_Port ansible_user=$AnsUSER  ansible_private_key_file=$PathToKey/$KeyNameEc2 \n"
fi

lbInventory="$lbInventory \n[masters]\n"
for ((i=1; i<=NumMasters; i++)); do
  Psn=$(echo `printf "%2.0d\n" $i |sed "s/ /0/"`)
  outIp="Master$Psn${lbAZ}Ip"
  outDns="Master$Psn${lbAZ}Dns"
  Host_Ip="${IP_BASE}.10$i"
  Host_Dns="127.0.0.1"
  Host_Port="220$i"
  if [ $isBastion == "N" ] && [ $i -eq 1 ]; then
    LogDns=$Host_Dns
    $ECHO "\nHost LogHost  \n\tHostName $Host_Dns  \n\tUser $HD_USER \n\tIdentityFile $PathToKey/id_rsa.pub \n\tProxyCommand none" >> $PathToKey/config
  fi
  #$ECHO "\nHost Master$Psn${lbAZ}  \n\tHostName $Host_Dns  \n\tUser $HD_USER \n\tIdentityFile $PathToKey/id_rsa.pub \n\tProxyCommand $sshCmd" >> $PathToKey/config

  #lbCS_SEEDS=${lbCS_SEEDS},master$Psn$lbAZ
  #lbKF_NODES=${lbKF_NODES},master$Psn$lbAZ:90$Psn
  #lbZK_NODES=${lbZK_NODES},master$Psn$lbAZ:2181
  lbHosts="${lbHosts}$Host_Ip  master$Psn$lbAZ  master$Psn$lbAZ.adurax.org \n"
  lbInventory="$lbInventory master$Psn$lbAZ ansible_ssh_host=$Host_Dns ansible_port=$Host_Port ansible_user=$AnsUSER  ansible_private_key_file=$PathToKey/$KeyNameEc2 \n"

  lbVarSection="""
  - hostname: master$Psn$lbAZ
    dns: $Host_Dns
    ip: $Host_Ip
    bkid: $Psn
    kfPort: 90$Psn
    esPort: 92$Psn
    isMaster: true """
  lbVarFiles="$lbVarFiles $lbVarSection"
done

lbInventory="$lbInventory \n[slaves]\n"
lbInvenZK="$lbInvenZK \n[zookeeps]\n"
for ((i=1; i<=NumSlaves; i++)); do
  Psn=`echo "$i + 10" | bc`
  outIp="Slave$Psn${lbAZ}Ip"
  outDns="Slave$Psn${lbAZ}Dns"
  Host_Ip="${IP_BASE}.10$Psn"
  Host_Dns="127.0.0.1"
  Host_Port="22$Psn"
  #$ECHO "\nHost Slave$Psn${lbAZ}  \n\tHostName $Host_Dns  \n\tUser $HD_USER \n\tIdentityFile $PathToKey/id_rsa.pub \n\tProxyCommand  $sshCmd" >> $PathToKey/config

  lbKF_NODES=${lbKF_NODES},slave$Psn$lbAZ:90$Psn
  lbZK_NODES=${lbZK_NODES},slave$Psn$lbAZ:2181
  lbHosts="${lbHosts}$Host_Ip slave$Psn$lbAZ  slave$Psn$lbAZ.adurax.org \n"
  lbInventory="$lbInventory slave$Psn$lbAZ ansible_ssh_host=$Host_Dns ansible_port=$Host_Port ansible_user=$AnsUSER  ansible_private_key_file=$PathToKey/$KeyNameEc2 \n"

  if [ $i -le 3 ]; then lbInvenZK="$lbInvenZK slave$Psn$lbAZ ansible_ssh_host=$Host_Dns ansible_port=$Host_Port ansible_user=$AnsUSER ansible_private_key_file=$PathToKey/$KeyNameEc2 \n"; fi
  if [ $i -le $nSEEDS ]; then lbCS_SEEDS=${lbCS_SEEDS},$Host_Ip; fi

  lbVarSection="""
  - hostname: slave$Psn$lbAZ
    dns: $Host_Dns
    ip: $Host_Ip
    bkid: $Psn
    kfPort: 90$Psn
    esPort: 92$Psn
    isMaster: false """
  lbVarFiles="$lbVarFiles $lbVarSection"
done

cat $PathToKey/config && chmod 600 $PathToKey/config
#**]  Get Stack Outputs

#[** Creating Ansible Files
$ECHO "\nCreating Ansible files ...."
cp $PathToKey/id_rs*  ../../roles/common/templates
cp downloadApp.sh  ../../roles/common/templates/downloadApp.sh.j2
$ECHO "StrictHostKeyChecking no \nUserKnownHostsFile=/dev/null" > ../../roles/common/templates/config

$ECHO """---
hdp_Bucket: $hdpBucket
hd_user: $HD_USER
hd_group: $HD_GROUP
hd_pass: $HD_PASS
proj_dir: $PROJ_DIR
data_dir: $DATA_DIR
arch_dir: $ARCH_DIR
java_dir: $JAVA_DIR
CS_SEEDS: ${lbCS_SEEDS:1}
KF_NODES: ${lbKF_NODES:1}
ZK_NODES: ${lbZK_NODES:1} """ > ../../group_vars/all.yml

$ECHO """127.0.0.1 localhost {{nodes[host_index|int]['hostname']}}
$lbHosts
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts """ > ../../roles/common/templates/hosts.j2

$ECHO "$lbInventory $lbInvenZK" > ../../AnsibleInventory
$ECHO "$lbVarFiles" > ../../nodes.yaml
#**]  Creating Ansible Files

#[** Creating AnsibleRun.sh file
$ECHO "Creating connect.sh ..."
cat <<-strDOC > ../../connect.sh
#!/usr/bin/env bash
eval \`ssh-agent -s\` # ssh-add -D # Remove all identities ==> Agent pid 5434
ssh-add -D  &&  ssh-add -k $PathToKey/$KeyNameEc2 # add your key to the SSH agent

$ECHO "\nRuning Ansible code ..."
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i AnsibleInventory bdplat_pb.yml
$ECHO "\n\nJupyter url:  http://$LogDns:8899"
ssh LogHost
strDOC
chmod +x ../../connect.sh
#**] Creating connect.sh file
