#!/bin/bash
mkdir /data/hue
chmod 777 -R /data/hue
cd /data/hue
docker exec -it mysql.1.$(docker service ps \
mysql --no-trunc | grep Running | awk '{print $1}' ) mysql -u root -p123456 -e "drop database if exists hue;"

docker exec -it mysql.1.$(docker service ps \
mysql --no-trunc | grep Running | awk '{print $1}' ) mysql -u root -p123456 -e "create database hue;"

echo "
[desktop]
  http_host=0.0.0.0
  http_port=8899
  time_zone=Europe/Lisbon
  dev=true
#  app_blacklist=zookeeper,oozie,hbase,security,search,impala
  [[database]]
    engine=mysql
    host=mysql
    port=3306
    user=root
    password=123456
    name=hue
[hadoop]
  [[hdfs_clusters]]
    [[[default]]]
      fs_defaultfs=hdfs://hadoop-namenode:8020
      webhdfs_url=http://hadoop-namenode:50070/webhdfs/v1
      security_enabled=false
  [[yarn_clusters]]
    [[[default]]]
      resourcemanager_api_url=http://hadoop-namenode:8088
      history_server_api_url=http://hadoop-namenode:19888
[beeswax]
  beeswax_server_host=hive-server
  hive_server_host=hive-server
  hive_server_port=10000
  hive_server_http_port=10001
  hive_metastore_host=hive-metastore
  hive_metastore_port=9083
  thrift_version=7
  hive_discovery_hs2 = true
  #use_sasl=true
 
[notebook]
  [[interpreters]]
    [[[hive]]]
        name=Hive
        interface=hiveserver2"        >| hue-overrides.ini


docker service create \
	--name hue \
	--hostname hue \
	--network hadoop-net \
  --constraint node.hostname==hadoop-namenode \
	--replicas 1 \
	--detach=true \
	--publish 8899:8888 \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime \
	--mount type=bind,source=/data/hue/hue-overrides.ini,target=/usr/share/hue/desktop/conf/hue.ini \
	gethue/hue:4.4.0

