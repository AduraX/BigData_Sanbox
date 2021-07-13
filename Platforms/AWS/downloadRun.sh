#!/usr/bin/env bash
# chmod u+x downloadRun.sh && ./downloadRun.sh
# hdpBucket=adurax.bdstack && aws s3 ls s3://$hdpBucket/lib/  | aws s3 rb s3://$hdpBucket/lib/ --force # delete a bucket # include --force for no-empty bucket

# library Versions
sparVer="3.1.1"
scalVer="2.12.13"
cassVer="3.11.10"
kafkVer="2.8.0"
zooVer="3.6.3"
elasVer="7.6.2" #  7.12.1
janusVer="0.5.3"

downloadLibs(){
  echo "Downloading Spark ... 224.4mb"
  curl "https://apache.mirror.digitalpacific.com.au/spark/spark-$sparVer/spark-$sparVer-bin-hadoop2.7.tgz" | aws s3 cp - s3://$hdp_Bucket/lib/spark.tgz

  echo "Downloading Scala ... 153.8mb"
  curl "https://downloads.lightbend.com/scala/$scalVer/scala-$scalVer.deb" | aws s3 cp - s3://$hdp_Bucket/lib/scala.deb

  echo "Downloading cassandra ... 38.8mb"
  curl "https://apache.mirror.digitalpacific.com.au/cassandra/$cassVer/apache-cassandra-$cassVer-bin.tar.gz" | aws s3 cp - s3://$hdp_Bucket/lib/cassandra.tar.gz

  echo "Downloading Kafka ... 65.7mb"
  curl "https://apache.mirror.digitalpacific.com.au/kafka/$kafkVer/kafka_2.12-$kafkVer.tgz" | aws s3 cp - s3://$hdp_Bucket/lib/kafka.tgz

  echo "Downloading Zookeeper ... 12.5mb"
  curl "http://apache.mirror.digitalpacific.com.au/zookeeper/zookeeper-$zooVer/apache-zookeeper-$zooVer-bin.tar.gz" | aws s3 cp - s3://$hdp_Bucket/lib/zookeeper.tar.gz

  echo "Downloading elasticsearch ... 114.1mb"
  curl "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$elasVer-linux-x86_64.tar.gz" | aws s3 cp - s3://$hdp_Bucket/lib/elasticsearch.tar.gz

  echo "Downloading Janusgraph ... 12.5mb"
  curl "http://apache.mirror.digitalpacific.com.au/zookeeper/zookeeper-$zooVer/apache-zookeeper-$zooVer-bin.tar.gz" | aws s3 cp - s3://$hdp_Bucket/lib/Janusgraph.tar.gz

  # https://dist.apache.org/repos/dist/dev/incubator/toree/0.5.0-incubating-rc2/toree/toree-0.5.0-incubating-bin.tar.gz
}

# Url: http://docs.aws.amazon.com/cli/latest/reference/s3api/head-bucket.html
# This operation is useful to determine if a bucket exists and you have permission to access it.
# The operation returns a 200 OK if the bucket exists and you have permission to access it.
# Otherwise, the operation might return responses such as 404 Not Found and 403 Forbidden .
hdp_Bucket=${1:-adurax.bdstack}
bucketStatus=$(aws s3api head-bucket --bucket "$hdp_Bucket" 2>&1)  && echo $bucketStatus
sleep 2
bucketExists=$(echo "$bucketStatus" | egrep -o '404|403|400')  && echo $bucketExists
echo -e '\nChecking for bucket existence ...'
if [ -z "$bucketExists" ]; then
  echo -e "OK! Bucket owned and exists."
  bucketExists="200"
elif [ $bucketExists == "404" ]; then
  echo -e "Not Found! Bucket doesn't exist. \nCreating Bucket ..."
  aws s3 mb s3://$hdpBucket
elif [ $bucketExists == "403" ]; then
  echo -e "Forbidden! Bucket exists but not owned. \nExiting ...\n"
  exit
elif [ $bucketExists == "400" ]; then
  # "Bucket name specified is less than 3 or greater than 63 characters"
  echo -e "Bad Request! Complex situation. \nExiting ...\n"
  exit
else
  echo "Unknown error!"
  exit
fi

downloadLibs

# https://www.apache.org/dyn/closer.lua/zookeeper/zookeeper-3.6.2/apache-zookeeper-3.6.2-bin.tar.gz
# https://www.apache.org/dyn/closer.lua/spark/spark-3.1.1/spark-3.1.1-bin-hadoop2.7.tgz
# https://downloads.lightbend.com/scala/2.12.13/scala-2.12.13.deb
# https://apache.mirror.digitalpacific.com.au/cassandra/3.11.10/apache-cassandra-3.11.10-bin.tar.gz
# https://apache.mirror.digitalpacific.com.au/kafka/2.6.1/kafka_2.12-2.6.1.tgz
# https://archive.apache.org/dist/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.6.0.tar.gz
# https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.2-linux-x86_64.tar.gz
