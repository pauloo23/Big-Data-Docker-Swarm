#! /bin/bash
mkdir /data/hbase
mkdir /data/hbase/logs
mkdir /data/hbase/logs/master
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -mkdir -p /hbase"
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -chmod g+w /hbase"

docker stack deploy -c ./helpers/hbase.yml hbase