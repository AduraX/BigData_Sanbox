

#=====================Git Commands =======================
git clone https://github.com/AduraX/BigData_Sanbox.git bdSanbox
#~~Cleaning Ignored Files: # Remove the files from the index (not the actual files in the working copy)
git rm -r --cached .
# Add these removals to the Staging Area...
git add .
# ...and commit them!
git commit -m "First commit of all the files"
#git remote add origin https://github.com/AduraX/BigData_Sanbox.git
git remote set-url origin https://github.com/AduraX/BigData_Sanbox.git
git push -u origin master


# ==== running Guides =====================
# Set varaible for bucket/blob/folder names
hdpBucket=adurax.bdstack &&
# Check if the libraries are already saved in the cloud:
aws s3 ls s3://$hdpBucket/lib/
# if not download them are save them in the cloud with:
chmod u+x downloadRun.sh && ./downloadRun.sh
aws s3 rb s3://$hdpBucket/lib/ --force # delete a bucket & include --force for no-empty bucket

# Run main code with
cd <main directory> # change to the main directory
chmod +x run.sh # Give execute permission to the script if needed:
./run.sh AWS X N 1 3 #Options: platType[VAG AWS AZURE] | StackExt[A..Z] | isBastion[N Y] | NumMasters[1, 2, 3, 4, 5] | NumSlaves[1, 3, 5, 7]

# Run Ansible script alone after infra provision
export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i AnsibleInventory bdpla.yml
# login into the entry machine
ssh LogHost

# Check the status of the packages if they are running properly with:
chmod +x $SPARK_HOME/bin/check-status.sh && $SPARK_HOME/bin/check-status.sh


#============================ Warning ==================================
TASK [Gathering Facts] **************************************************************************************************
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host master01A should use /usr/bin/python3, but is using
/usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release will default to using
the discovered platform python for this host. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information. This feature
will be removed in version 2.12. Deprecation warnings can be disabled by setting deprecation_warnings=False in
ansible.cfg.
ok: [master01A]


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ps -fp 1 # We can use ps to see the process that has PID 1. We’ll use the f (full-format listing) and p (PID) options
ls -hl /sbin/init #=> lrwxrwxrwx 1 root root 20 May  3  2020 /sbin/init -> /lib/systemd/systemd
ps -f --ppid 1 #Using the ppid (parent process ID) option with ps, we can see which processes have been directly launched by systemd:
systemctl --type=service --state=active # List all systemd service that are active

bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
$ bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test

kafka/bin/kafka-server-start.sh  {{proj_dir}}/kafka/config/server.properties

#===================================================================================
rm -r /usr/local/bdplat/zookeeper && rm -r /var/bdData/zookeeper
export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -i AnsibleInventory bdplat_pb.yml
#=====================================================================================

zkServer.sh  {start|start-foreground|stop|restart|status|upgrade|print-cmd} | start by default

#To verify that the ZooKeeper server has started, you can use the following | ps command:
ps -ef | grep zookeeper | grep -v grep | awk '{print $2}' #==> 5511
#If the jps command is installed on your system, you can verify the ZooKeeper
# server's status as follows:
ps -ef | grep kafka | grep -v grep | awk '{print $2}'


# Connect to the local ZooKeeper server with the following command:
bin/zkCli.sh -server 127.0.0.1:2181

cat /usr/local/bdplat/zookeeper/conf/zoo.cfg

kafka-server-start.sh  /usr/local/bdplat/kafka/config/server.properties

kafka-topics.sh --create --replication-factor 3  --partitions 5  --zookeeper slave11A:9011,slave12A:9012,slave13A:9013   --topic multiTopic

kafka-topics.sh --create --replication-factor 3  --partitions 5  --zookeeper slave11A:2181,slave12A:2181,slave13A:2181  --topic multiTopic

# For example, take a look at the next quorum:
[zoo1] $ ${ZK_HOME}/bin/zkServer.sh status
JMX enabled by default
Using config: /usr/share/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode: follower
[zoo2] $ ${ZK_HOME}/bin/zkServer.sh status
JMX enabled by default
Using config: /usr/share/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode: leader
[zoo3] $ ${ZK_HOME}/bin/zkServer.sh status
JMX enabled by default
Using config: /usr/share/zookeeper-3.4.6/bin/../conf/zoo.cfg
Mode: follower


Failed to acquire lock on file .lock in /var/bdData/kafka/logs. A Kafka instance in another process or thread is using this directory.



zkServer.sh status  # start stop status start-foreground  restart  upgrade  print-cmd
systemctl restart zookeeper
systemctl restart zookeeper
systemctl status zookeeper
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic messages

# Start Zookeeper with the command:
bin/zkServer.sh start

# Connect Zookeeper’s cluster with the command:
zkCli.sh -server 1.1.1.1:2181,2.2.2.2:2181,3.3.3.3:2181,4.4.4.4:2181


zkServer.sh start-foreground


# Test your deployment by connecting to the hosts:
# In Java, you can run the following command to execute simple operations:
$ java -cp zookeeper-3.4.14.jar:lib/log4j-1.2.17.jar:lib/slf4j-log4j12-1.7.25.jar:lib/slf4j-api-1.7.25.jar:conf org.apache.zookeeper.server.quorum.QuorumPeerMain conf/zoo.cfg

WARN  [QuorumPeer[myid=1]/0:0:0:0:0:0:0:0:2181:QuorumCnxManager@584] - Cannot open channel to 2 at election address 0.0.0.222:3888

rm -r /usr/local/bdplat/zookeeper && rm -r /var/bdData/zookeeper

Cannot open channel to 2 at election address 10.0.1.222:3888

WARN  [NIOWorkerThread-1:NIOServerCnxn@373] - Close of session 0x0 java.io.IOException: ZooKeeperServer not running
# ======== There may be several reasons ======
# First, the zoo.cfg file configuration error: the directory specified by dataLogDir is not created;
# Second, the integer format in the myid file is incorrect, or does not correspond to the server integer in zoo.cfg.
# Third, the firewall is not closed;
# Fourth, port 2181 is occupied;
# Fifth, the host name in the zoo.cfg file is incorrect.
# Sixth, in the hosts file, there are two host names for this machine, just keep the mapping between host name and ip address.

2021-04-16 10:19:13,459 [myid:1] - WARN  [main:ServerCnxnFactory@309] - maxCnxns is not configured, using default value 0.

#=====================================================================================
server.1={{groups['slaves'][0]}}:2888:3888
server.2={{groups['slaves'][1]}}:2888:3888
server.3={{groups['slaves'][2]}}:2888:3888
server.1={%- if {{myId|int}} == 1 -%}0.0.0.0{% else %}{{groups['slaves'][0]}}{% endif %}:2888:3888
server.2={%- if {{myId|int}} == 2 -%}0.0.0.0{% else %}{{groups['slaves'][1]}}{% endif %}:2888:3888
server.3={%- if {{myId|int}} == 3 -%}0.0.0.0{% else %}{{groups['slaves'][2]}}{% endif %}:2888:3888


"{%- if groups['slaves'] == inventory_hostname -%} {{loop.index0}} {% endif %}"

"{% for host in groups['slaves'] %} {%- if host == inventory_hostname -%} {{loop.index}} {% endif %} {% endfor %}"


{{groups['slaves'][1]}}
{{groups['slaves'][1]['hostname']}}

"nodes[host_index|int]['isMaster']|bool"
{{nodes[1]['hostname']}}
"{% for host in nodes %} {%- if host['hostname'] == inventory_hostname -%} {{ host['ip'] }} {% endif %} {% endfor %}"

# There is a command to directly describe the connections of your cluster :
./nodetool describecluster

{% for url in zookeeper_hosts_list %}
  {%- set url_host = url.split(':')[0] -%}
  {%- if url_host == ansible_fqdn or url_host in     ansible_all_ipv4_addresses -%}
server.{{loop.index0}}=0.0.0.0:2888:3888
{% else %}
server.{{loop.index0}}={{url_host}}:2888:3888
{% endif %}
{% endfor %}

Configuring Cassandra as a Service
Create the /etc/init.d/cassandra startup script.
Edit the contents of the file:
#********************************************************************************
#!/bin/sh
#
# chkconfig: - 80 45
# description: Starts and stops Cassandra
# update daemon path to point to the cassandra executable
DAEMON=<Cassandra installed directory>/bin/cassandra
start() {
        echo -n "Starting Cassandra... "
        $DAEMON -p /var/run/cassandra.pid
        echo "OK"
        return 0
}
stop() {
        echo -n "Stopping Cassandra... "
        kill $(cat /var/run/cassandra.pid)
        echo "OK"
        return 0
}
case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  restart)
        stop
        start
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac
exit $?
#***************************************************************************************

Make the file executable:
sudo chmod +x /etc/init.d/cassandra
Add the new service to the list:
sudo chkconfig --add cassandra
Now you can manage the service from the command line:
sudo /etc/init.d/cassandra start
sudo /etc/init.d/cassandra stop
Start/Stop Cassandra Cluster
Start the seed node and then start the rest of the Cassandra nodes sequentially:

Start: sudo service cassandra start
Stop: sudo service cassandra stop


fatal: [slave11A]: FAILED! => {"changed": true, "cmd": "hostname -F /etc/hostname",
"delta": "0:00:00.003994", "end": "2021-03-09 00:36:46.179050", "msg": "non-zero return code", "rc": 1,
"start": "2021-03-09 00:36:46.175056", "stderr": "hostname: the specified hostname is invalid",
"stderr_lines": ["hostname: the specified hostname is invalid"], "stdout": "", "stdout_lines": []}


#! /bin/bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi
# hdpBucket=adurax.hdpcluster && aws s3 ls s3://adurax.hdpcluster/lib/  | aws s3 rb s3://adurax.hdpcluster/lib/ -$

masHostname={'hdp_Bucket': 'adurax.hdpcluster', 'hd_user': 'hduser', 'hd_group': 'hdgroup', 'hd_pass': 'hduser001$'
invHostname=master01A  # $2

#[** Checking for bucket existence
# Url: http://docs.aws.amazon.com/cli/latest/reference/s3api/head-bucket.html
# This operation is useful to determine if a bucket exists and you have permission to access it.
# The operation returns a 200 OK if the bucket exists and you have permission to access it.
# Otherwise, the operation might return responses such as 404 Not Found and 403 Forbidden .
bucketStatus=$(aws s3api head-bucket --bucket "adurax.hdpcluster" 2>&1)
bucketExists=$(echo "$bucketStatus" | egrep -o '404|403|400')  && echo $bucketExists
$ECHO '\nChecking for bucket existence ...'
if [ -z "$bucketExists" ]; then
  $ECHO "OK! Bucket owned and exists."
  bucketExists="200"


#= bash -c "echo $OSTYPE"  # Only for bash/linux script
  OS	   $OSTYPE
  Linux	linux-gnu
  CYGWIN	cygwin
  Bash on Windows 10	linux-gnu
  OpenBSD	openbsd*
  FreeBSD	FreeBSD
  NetBSD	netbsd
  DragonflyBSD
  Mac OS	darwin*
  iOS	darwin9
  Solaris	solaris*
  Android (termux)	linux-android
  Android	linux-gnu
  Haiku OS	haiku
  GNU Hurd


# $OSTYPE: You can simply use pre-defined $OSTYPE variable e.g.:
case "$OSTYPE" in
  solaris*) echo "SOLARIS" ;;
  darwin*)  echo "OSX" ;;
  linux*)   echo "LINUX" ;;
  cygwin*)  echo "CYGWIN" ;;
  bsd*)     echo "BSD" ;;
  msys*)    echo "MinGW" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac

# elif [[ "$OSTYPE" == "win32" ]]; then
