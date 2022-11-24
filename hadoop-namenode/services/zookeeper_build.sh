#!/bin/bash
mkdir /data/zookeeper
mkdir /data/zookeeper/data/
mkdir /data/zookeeper/data/node1
mkdir /data/zookeeper/logs
mkdir /data/zookeeper/logs/node1
docker pull zookeeper:3.4
docker service create \
	--name zookeeper-node1 \
	--hostname zookeeper-node1 \
	--detach=true \
	--replicas 1 \
	--network hadoop-net \
    --constraint node.hostname==hadoop-namenode \
	-p 2181:2181 \
	--env ZOO_MY_ID=1 \
	--env ZOO_SERVERS="server.1=zookeeper-node1:2888:3888 server.2=zookeeper-node2:2888:3888 server.3=zookeeper-node3:2888:3888" \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
	--mount type=bind,source=/data/zookeeper/data/node1,target=/data \
	--mount type=bind,source=/data/zookeeper/logs/node1,target=/datalog \
	zookeeper:3.4

docker service create \
	--name zookeeper-node2 \
	--hostname zookeeper-node2 \
	--detach=true \
	--replicas 1 \
	--network hadoop-net \
    --constraint node.hostname==hadoop-datanode1 \
	-p 2182:2181 \
	--env ZOO_MY_ID=2 \
	--env ZOO_SERVERS="server.1=zookeeper-node1:2888:3888 server.2=zookeeper-node2:2888:3888 server.3=zookeeper-node3:2888:3888" \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
	--mount type=bind,source=/data/zookeeper/data/node2,target=/data \
	--mount type=bind,source=/data/zookeeper/logs/node2,target=/datalog \
	zookeeper:3.4

docker service create \
	--name zookeeper-node3 \
	--hostname zookeeper-node3 \
	--replicas 1 \
	--detach=true \
	--network hadoop-net \
    --constraint node.hostname==hadoop-datanode2 \
	-p 2183:2181 \
	--env ZOO_MY_ID=3 \
	--env ZOO_SERVERS="server.1=zookeeper-node1:2888:3888 server.2=zookeeper-node2:2888:3888 server.3=zookeeper-node3:2888:3888" \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
	--mount type=bind,source=/data/zookeeper/data/node3,target=/data \
	--mount type=bind,source=/data/zookeeper/logs/node3,target=/datalog \
	zookeeper:3.4

docker run \
  -d --network hadoop-net \
  -e HTTP_PORT=1090 \
  -p 1090:1090 \
  --name zoonavigator \
  --restart unless-stopped \
  elkozmon/zoonavigator:latest