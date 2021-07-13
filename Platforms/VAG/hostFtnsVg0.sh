#!/usr/bin/env bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi

CreateHost() { # para: NumMasters NumSlaves
if test ! -e "Vagrantfile"; then
$ECHO "\nCreating Prefile.rb to create ansible inventory & nodes.yml files ...."
#[**
cat > "Prefile.rb" <<- EndOfPrefile
#!/usr/bin/env ruby

linePsn=5
lines = File.readlines("parameters.lt")
MASTERS_MEM=(lines[linePsn+1].split(" ")[0]).to_i() # Memory for master and slave nodes
SLAVES_MEM=(lines[linePsn+2].split(" ")[0]).to_i()
MASTERS_CPU=(lines[linePsn+3].split(" ")[0]).to_i() # Number of CPUs for master and slave nodes
SLAVES_CPU=(lines[linePsn+4].split(" ")[0]).to_i()
IP_BASE=(lines[linePsn+5].split(" ")[0]).to_i()

puts "\nCreating Vagrantfile ...."
File.open("Vagrantfile", "w"){ |f|
f.puts "# -*- mode: ruby -*- \n# vi: set ft=ruby : \n \n"
f.puts "MASTERS_MEM = #{MASTERS_MEM} \n"
f.puts "SLAVES_MEM = #{SLAVES_MEM} \n"
f.puts "MASTERS_CPU = #{MASTERS_CPU} \n"
f.puts "SLAVES_CPU = #{SLAVES_CPU} \n"
f.puts "IP_BASE = #{IP_BASE} \n"
}
EndOfPrefile
#**]
chmod +x Prefile.rb
./Prefile.rb
rm "Prefile.rb"

#[**
cat >> "Vagrantfile" <<- EndOfVagrantfile
# -*- mode: ruby -*- \n# vi: set ft=ruby :

MASTERS_NUM=$1
SLAVES_NUM=$2
# MASTERS_MEM=$
# SLAVES_MEM=$
# MASTERS_CPU=$
# SLAVES_CPU=$
# IP_BASE=$

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
}
