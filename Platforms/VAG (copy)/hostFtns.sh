#!/usr/bin/env bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

CreateHost() { # para: NumMasters NumSlaves
if test ! -e "Vagrantfile"; then
#[**
declare -a arrPar=()
i=0; j=0 #Starting reading fro line 5 | parItem = 1st Item, OtherItem=2nd item after splitting with '#'
while IFS="#" read -r parItem OtherItem ; do
  if [ $i -gt 5 ]; then
    arrPar[j]=`echo $parItem | sed 's/ *$//g'`
    j=$((j+1))
  fi
  i=$((i+1))
done < parameters.lt

# declare -a arrPar=() #===
# i=0; j=0 #Starting reading fro line 5 | parItem = 1st Item, OtherItem=2nd item after splitting with '#'
# while IFS="#" read -r parItem OtherItem ; do
#   if [ $i -gt 5 ]; then
#     arrPar[j]=`echo $parItem | sed 's/ *$//g'`
#     echo -e "Line $i [$j]: $parItem => $OtherItem \t\tArr[$j] = ${arrPar[$j]}"
#     j=$((j+1))
#   fi
#   i=$((i+1))
# done < $1 # parameters.lt

#**]

#[**
cat >> "Vagrantfile" <<- EndOfVagrantfile
# -*- mode: ruby -*- \n# vi: set ft=ruby :

MASTERS_NUM=$1
SLAVES_NUM=$2
MASTERS_MEM=arrPar[0]
SLAVES_MEM=arrPar[1]
MASTERS_CPU=arrPar[2]
SLAVES_CPU=arrPar[3]
IP_BASE=arrPar[4]
SSH_PORT=arrPar[5]

VAGRANT_DISABLE_VBOXSYMLINKCREATE=1
IMAGE_NAME = "bento/ubuntu-20.04"

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    (1..MASTERS_NUM).each do |i|
        config.vm.define "Master0#{i}" do |master|
            master.vm.box = IMAGE_NAME
            master.vm.network "private_network", ip: "#{IP_BASE}.10#{i}"
        		master.vm.network :forwarded_port, guest: 22, host: "220#{j}".to_i(), id: "ssh"
            master.vm.hostname = "Master0#{i}"
            master.vm.provider "virtualbox" do |v|
                v.memory = MASTERS_MEM
                v.cpus = MASTERS_CPU
            end
        end
    end

    (1..SLAVES_NUM).each do |j|
        config.vm.define "Slave#{10 + j}" do |slave|
            slave.vm.box = IMAGE_NAME
            slave.vm.network "private_network", ip: "#{IP_BASE}.10#{10 + j}"
        		slave.vm.network "forwarded_port", guest: 22, host: "22#{10 + j}".to_i(), id: "ssh"
            slave.vm.hostname = "Slave#{10 + j}"
            slave.vm.provider "virtualbox" do |v|
                v.memory = SLAVES_MEM
                v.cpus = SLAVES_CPU
            end
        end
    end
end
EndOfVagrantfile
#**]
fi
}
