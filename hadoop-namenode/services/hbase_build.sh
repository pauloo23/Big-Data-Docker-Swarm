#! /bin/bash
mkdir /data/hbase
mkdir /data/hbase/config/
mkdir /data/hbase/logs
mkdir /data/hbase/logs/master
docker pull pauloo23/hbase:1.2.6
svn export https://github.com/pauloo23/Big-Data-Docker-Swarm/trunk/hadoop-namenode/HBase/conf/ /data/hbase/config/ --force
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -mkdir -p /hbase"
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -chmod g+w /hbase"

docker service create \
	--name hbase-master \
	--hostname hbase-master \
	--network hadoop-net \
	--replicas 1 \
	--detach=true \
	--publish 16010:16010 \
	--publish 9090:9090 \
    --publish 6000:6000 \
    --publish 7001:7001 \
    --constraint node.hostname==hadoop-namenode \
   	--mount type=bind,source=/data/hbase/logs/master,target=/usr/local/hbase/logs \
    --mount type=bind,source=/data/hbase/config,target=/config/hbase \
	pauloo23/hbase:1.2.6

    docker service create \
	--name hbase-slave1 \
	--hostname hbase-slave1 \
	--network hadoop-net \
	--replicas 1 \
    --constraint node.hostname==hadoop-datanode1 \
    --mount type=bind,source=/data/hbase/logs/slave1,target=/usr/local/hbase/logs \
    --mount type=bind,source=/data/hbase/config,target=/config/hbase \
	pauloo23/hbase:1.2.6

docker service create \
	--name hbase-slave2 \
	--hostname hbase-slave2 \
	--network hadoop-net \
	--replicas 1 \
	--detach=true \
    --constraint node.hostname==hadoop-datanode2 \
    --mount type=bind,source=/data/hbase/logs/slave2,target=/usr/local/hbase/logs \
    --mount type=bind,source=/data/hbase/config,target=/config/hbase \
	pauloo23/hbase:1.2.6

sleep 60

##Init Hbase
docker exec -it hbase-master.1.$(docker service ps \
hbase-master --no-trunc | grep Running | awk '{print $1}' ) bash -c "bin/start-hbase.sh"
#Start Thrift service
docker exec -it hbase-master.1.$(docker service ps \
hbase-master --no-trunc | grep Running | awk '{print $1}' ) bash -c "bin/hbase-daemon.sh start thrift"

