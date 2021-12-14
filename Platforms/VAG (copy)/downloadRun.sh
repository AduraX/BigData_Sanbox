#!/usr/bin/env bash
# chmod u+x downloadRun.sh && ./downloadRun.sh

# library Versions
sparVer="3.1.2"
scalVer="2.12.13"
cassVer="3.11.11"
kafkVer="2.8.1"
zooVer="3.6.3"
elasVer="7.6.2" #  7.12.1
janusVer="0.5.3"

downloadLibs(){
  echo -e "\nDownloading Spark ... 224.4mb" 
  curl -Lko libVag/spark.tgz "https://dlcdn.apache.org/spark/spark-$sparVer/spark-$sparVer-bin-hadoop3.2.tgz"

  echo -e "\nDownloading Scala ... 153.8mb"
  curl -Lko libVag/scala.deb "https://downloads.lightbend.com/scala/$scalVer/scala-$scalVer.deb"

  echo -e "\nDownloading cassandra ... 38.8mb"
  curl -Lko libVag/cassandra.tar.gz "https://dlcdn.apache.org/cassandra/$cassVer/apache-cassandra-$cassVer-bin.tar.gz"

  echo -e "\nDownloading Kafka ... 65.7mb"
  curl -Lko libVag/kafka.tgz "https://archive.apache.org/dist/kafka/$kafkVer/kafka_2.12-$kafkVer.tgz"

  echo -e "\nDownloading Zookeeper ... 12.5mb"
  curl -Lko libVag/zookeeper.tar.gz "http://apache.mirror.digitalpacific.com.au/zookeeper/zookeeper-$zooVer/apache-zookeeper-$zooVer-bin.tar.gz"

  echo -e "\nDownloading elasticsearch ... 114.1mb"
  curl -Lko libVag/elasticsearch.tar.gz "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$elasVer-linux-x86_64.tar.gz"

  echo -e "\nDownloading Janusgraph ... 12.5mb"
  curl -Lko libVag/Janusgraph.tar.gz "http://apache.mirror.digitalpacific.com.au/zookeeper/zookeeper-$zooVer/apache-zookeeper-$zooVer-bin.tar.gz"

  # https://dist.apache.org/repos/dist/dev/incubator/toree/0.5.0-incubating-rc2/toree/toree-0.5.0-incubating-bin.tar.gz
}

echo -e '\nChecking for folder existence ...'
if test -d "libVag_"; then
  echo -e "OK! folder exists ...\nExiting ..."
  exit
else
  echo -e "Folder doesn't exist. \nCreating folder ..."
  mkdir libVag
  echo -e "downloading libraries ..."
  downloadLibs
fi
