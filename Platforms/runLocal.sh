#!/usr/bin/env bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi
# Give execute permission to the script:  chmod +x runallAmb.sh # Execute by: ./runall.sh  # cd ~/AduraXDir/hdpAmbari

export PROJ_DIR=/usr/local/hdpeco
#[**
Indx=0
while [ $Indx -lt 3 ]
do
Indx=$(( Indx+1 ))
$ECHO "\nWould you like to install the Hadoop cluster through Ambari? \nType \"y\" for yes or \"n\" for no and press [ENTER]:"
read installAmbari
export installAmbari
if [ $installAmbari = "y" ] || [ $installAmbari = "Y" ]; then
$ECHO """ \n**********************************************************************************************
sudo -i  # Change to root & Downloading the Ambari repository file
wget -O /etc/apt/sources.list.d/ambari.list http://public-repo-1.hortonworks.com/ambari/ubuntu16/2.x/updates/2.7.3.0/ambari.list  && apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD && apt-get update
apt-cache showpkg ambari-server && apt-cache showpkg ambari-agent && apt-cache showpkg ambari-metrics-assembly
apt-get install ambari-server && ambari-server setup
#~~~~~ Output needed responses:
# After this operation, 468 MB of additional disk space will be used. Do you want to continue? [Y/n] y
# Customize user account for ambari-server daemon [y/n] (n)? n
# Checking JDK... Enter choice (1): 1
# Do you accept the Oracle Binary Code License Agreement [y/n] (y)? y
# Enable Ambari Server to download and install GPL Licensed LZO packages [y/n] (n)? y
# Enter advanced database configuration [y/n] (n)? n
#~~ Outcome: Ambari Server 'setup' completed successfully.

ambari-server start && ambari-server status # Start Ambari Server host & check the Ambari Server processes. To stop: ambari-server stop
http://<your.ambari.server>:8080 # Log In to Apache Ambari Server: http://ambari.adurax.org:8080
HdpCluster # Cluster Name on Ambari Web UI

# host FDNQ list
ambari.adurax.org
master.adurax.org
slaveN.adurax.org

vagrant  # SSH User Account
**********************************************************************************************

SSHing into Amabari node ...\n """ > instruction.txt
  break
elif [ $installAmbari = "n" ] || [ $installAmbari = "N" ]; then
$ECHO """ \n**********************************************************************************************
Run [ ansible-playbook -i /vagrant/AnsibleInventory /vagrant/hdpeco_pb.yml ] command in hduser@master node
Run [ sudo su - hduser ] command in master node
Type [ exit ] to exit the master node

hduser  # SSH User Account
**********************************************************************************************

SSHing into Master node ...\n """ > instruction.txt
  break
else
if [ $Indx -eq 3 ]; then
      $ECHO "\nInvalid input exiting after the third attempt...\n"
      exit
else
    $ECHO "Invalid input try again.\n"
fi
fi
done
#**]

if test ! -e "Vagrantfile"; then
$ECHO "\nCreating & opening Response.lt file ...."
#[**
cat > "Response.lt" <<- EndOfString
# *********   Response file for questions   *********
# Edit the parameter values below as appropriate and when you are done
# Press [ctrl + X]
# Then press [y] to save
# Finally press [ENTER] to continue.

2     #NUM_SLAVES Number of slave nodes | Other option: 3, 5, 7, ...
1024  #AmbaMem Ambari node memory value | Other option: 256, 512, 1024, 2048, 3072, 4096  ...
2548  #MastMem master node memory value | Other option: 256, 512, 1024, 2048, 3072, 4096  ...
1536  #SlavMem slaveN node memory value | Other option: 256, 512, 1024, 2048, 3072, 4096  ...
10    #IP_BASE                          | Other option: 10, 100  ...
192.168.56  #IP_SUBNET                  | Other option: 192.168.33, 10.0.0, ...
2277  #SSH_PORT_BAS                     | Other option: 2222 , ...
EndOfString
nano "Response.lt"
#**]

$ECHO "\nCreating Prefile.rb to create hosts file ...."
#[**
cat > "Prefile.rb" <<- EndOfPrefile
#!/usr/bin/env ruby

linePsn=5
lines = File.readlines("Response.lt")
NUM_SLAVES=(lines[linePsn+1].split(" ")[0]).to_i()
AmbaMem=(lines[linePsn+2].split(" ")[0]).to_i() # Memory for Amabari node
MastMem=(lines[linePsn+3].split(" ")[0]).to_i() # Memory for master and slave nodes
SlavMem=(lines[linePsn+4].split(" ")[0]).to_i()
IP_BASE=(lines[linePsn+5].split(" ")[0]).to_i()
SUBNET=(lines[linePsn+6].split(" ")[0]) # master IP becomes: 192.168.56.100
SSH_PORT_BASE=(lines[linePsn+7].split(" ")[0]).to_i()

puts "\nCreating Vagrantfile ...."
File.open("Vagrantfile", "w"){ |f|
f.puts "# -*- mode: ruby -*- \n# vi: set ft=ruby : \n \n"
f.puts "NUM_SLAVES = #{NUM_SLAVES} \n"
f.puts "PKeySrc = '~/.vagrant.d/insecure_private_key' \nPKeyDes = '/home/vagrant/.ssh/id_rsa'"
f.puts "nodesList = <<~eNodes"
  if ENV['installAmbari'] == "y" || ENV['installAmbari'] == "Y"
    f.puts "#{SUBNET}.#{IP_BASE - 7}  ambari.adurax.org   ambari  #{SSH_PORT_BASE - 1}  #{AmbaMem}"
  end
  f.puts "#{SUBNET}.#{IP_BASE - 5}  master.adurax.org   master  #{SSH_PORT_BASE}  #{MastMem}"
  (1..NUM_SLAVES).each do |i|
    f.puts "#{SUBNET}.#{IP_BASE + (i - 1)*10}   slave#{i}.adurax.org slave#{i}  #{(SSH_PORT_BASE+i)}  #{SlavMem}"
  end
f.puts "eNodes"
}

puts "\nCreating hosts file...."
File.open("roles/common/templates/hosts", "w"){ |f|
  f.puts "127.0.0.1 localhost \n\n"
  if ENV['installAmbari'] == "y" || ENV['installAmbari'] == "Y"
    f.puts "#{SUBNET}.#{IP_BASE - 7}  ambari  ambari.adurax.org"
  end
  f.puts "#{SUBNET}.#{IP_BASE - 5}  master   master.adurax.org"
  (1..NUM_SLAVES).each do |i|
    f.puts "#{SUBNET}.#{IP_BASE + (i - 1)*10}  slave#{i}  slave#{i}.adurax.org"
  end
  f.puts "\n\n# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
"
}

if ENV['installAmbari'] == "n" || ENV['installAmbari'] == "N"
  puts "\nCreating nodes.yml file...."
  File.open("nodes.yml", "w"){ |fl|
  fl.puts "--- \nnodes: \n  - hostname: master \n    ip: #{SUBNET}.#{IP_BASE - 5} \n    bkid: 5   \n    kfPort: 9000    \n    esPort: 9200      \n    isMaster: true \n    isWorker: false"
  (1..NUM_SLAVES).each do |i|
    fl.puts "  - hostname: slave#{i} \n    ip: #{SUBNET}.#{IP_BASE + (i - 1)*10} \n    bkid: #{i} \n    kfPort: 900#{i} \n    esPort: 920#{i} \n    isMaster: false \n    isWorker: true"
  end
  }

  puts "\nCreating AnsibleInventory file...."
  File.open("AnsibleInventory", "w"){ |fl|
  fl.puts "[masters] \nmaster ansible_ssh_host=127.0.0.1 ansible_ssh_port=#{SSH_PORT_BASE} ansible_connection=ssh ansible_user=vagrant ansible_private_key_file=~/.vagrant.d/insecure_private_key"
  (1..NUM_SLAVES).each do |i|
    fl.puts "\n[slaves] \nslave#{i} ansible_ssh_host=127.0.0.1 ansible_ssh_port=#{(SSH_PORT_BASE+i)} ansible_connection=ssh ansible_user=vagrant ansible_private_key_file=~/.vagrant.d/insecure_private_key"
  end
  }
end
EndOfPrefile
chmod +x Prefile.rb
./Prefile.rb
sudo rm "Response.lt" "Prefile.rb"
#**]

$ECHO "\nAppending to Vagrantfile ...."
#[**
cat >> "Vagrantfile" <<- EndOfVagrantfile
Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-18.04"
  config.ssh.insert_key = false # Fixes changes from https://github.com/mitchellh/vagrant/pull/4707
  # copy private key so hosts can ssh using key authentication (the script below sets permissions to 600)
  config.vm.provision :file do |file|
    file.source      = PKeySrc
    file.destination = PKeyDes
  end

  config.vm.provision :shell, inline: <<-SHELL
   echo -e "Host * \n  StrictHostKeyChecking no \n  UserKnownHostsFile=/dev/null" >> /home/vagrant/.ssh/config
  SHELL

  nCount=0
  nodesList.split("\n").each do |line|
    nCount=nCount+1
    arrLine=line.split(" ")
    hostIP=arrLine[0]
    hostname=arrLine[1]
    server=arrLine[2]
    sshPort=arrLine[3].to_i()
    rMemory=arrLine[4].to_i()

    if server == "ambari" # Ambari Node
	    config.vm.define server, primary: true do |ambari|
    	 ambari.vm.hostname = hostname
    	 ambari.vm.network :private_network, ip: hostIP
    	 ambari.vm.network :forwarded_port, guest: 22, host: sshPort, id: "ssh"
    	 ambari.vm.provider :virtualbox do |v|
          v.memory = rMemory
          v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
          v.customize ["modifyvm", :id, "--nictype1", "virtio" ]
    	 end
       ambari.vm.network "forwarded_port", guest: 8080, host: 8080
       #ambari.vm.network "forwarded_port", guest: 80,   host: 8081
     end
    else  # Master and Slave nodes
      config.vm.define server do |node|
      	  node.vm.hostname = hostname
      	  node.vm.network :private_network, ip: hostIP
      	  node.vm.network :forwarded_port, guest: 22, host: sshPort, id: "ssh"
      	  node.vm.provider :virtualbox do |v|
             v.memory = rMemory
             v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
             v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
             v.customize ["modifyvm", :id, "--nictype1", "virtio" ]
	        end

          if server == "master"
            node.vm.network "forwarded_port", guest: 8899, host: 8899  # Jupyter
            node.vm.network "forwarded_port", guest: 5000, host: 5000  # Falsk
          end
      end
    end # if-else
  end   # nodesList each do
end     # Vagrant.configure(2)
EndOfVagrantfile
#**]

$ECHO "\nExecuting vagrant up  command ..."
$ECHO "\n**** This Vagrantfile create a Hadoop Cluster with [1-Ambari_]1-master_n-slave cluster.... ***\n "
sudo chown -R adurax .vagrant
sudo chown -R adurax /home/adurax/.vagrant.d
vagrant up

#[** Set variables

LIB_DIR=/vagrant/lib # /var/s3fshdp/lib
AnsUSER=vagrant # ubuntu
HD_USER=hduser
HD_GROUP=hdgroup
HD_PASS=hduser001
PathToKey=/home/$USER/.ssh
PROJ_DIR=/usr/local/hdpeco
JAVA_DIR=/usr/lib/jvm/java-8-openjdk-amd64/jre # /usr/lib/jvm/java-8-oracle
if test ! -f $PathToKey/id_rsa; then ssh-keygen -t rsa -N "" -f $PathToKey/id_rsa; chmod 600 $PathToKey/id_rsa; touch $PathToKey/config; chmod 600 $PathToKey/config; fi
# if test ! -f $PathToKey/$KeyNameEc2; then cp $KeyNameEc2 $PathToKey/$KeyNameEc2; chmod 400 $PathToKey/$KeyNameEc2; fi
#**] Set variables

#[** Creating Ansible Files
$ECHO "\nCreating Ansible files ...."
cp $PathToKey/id_rs*  roles/common/templates
$ECHO """StrictHostKeyChecking no""" > roles/common/templates/config

$ECHO """---
# hdp_Bucket: $hdpBucket
hd_user: $HD_USER
hd_group: $HD_GROUP
hd_pass: $HD_PASS
proj_dir: $PROJ_DIR
lib_dir: $LIB_DIR
java_dir: $JAVA_DIR
ZK_NODES: master,slave1,slave2 # default = 3 or 5 or 7
KF_NODES: master:2181,slave1:2181,slave2:2181 """ > group_vars/all.yml
#**]  Creating Ansible Files
$ECHO "\n~~~~~~~~~~~~~~~~~~~ Cluster Setup Complete ... ~~~~~~~~~~~~~~~~~~~~~~~~~~\n"

$ECHO "\n******************** Runing Ansible code ... *************************"
ansible-playbook -i AnsibleInventory hdpeco_pb.yml # sudo vagrant ssh master

cat instruction.txt
#sudo vagrant ssh

$ECHO "\n**** Mission Accomplished! \nExecuted successly!"
else
#[**
if test -f "Vagrantfile"; then
  Indx=0
  while [ $Indx -lt 3 ]
  do
    Indx=$(( Indx+1 ))
    $ECHO "\nWould you like to destroy the vagrant VMs? \nType \"y\" for yes or \"n\" for no and press [ENTER]:"
    read Yn
    if [ $Yn = "y" ] || [ $Yn = "Y" ]; then
      vagrant destroy
      #sudo rm -r .vagrant
      rm "Vagrantfile" "hosts"
      break
    elif [ $Yn = "n" ] || [ $Yn = "N" ]; then
      rm "Vagrantfile"
      break
    else
      if [ $Indx -eq 3 ]; then
        $ECHO "Invalid input exiting after the third attempt...\n"
        exit
      else
        $ECHO "Invalid input try again.\n"
      fi
    fi
  done
fi # 2nd if-else test -f "Vagrantfile";
#**]
fi # 1st if-else test -e "Vagrantfile"
