docker pull pauloo23/hive:2.3.3
mkdir /data/hive
mkdir /data/hive/conf
mkdir /data/hive-server
mkdir /data/hive-server/conf
 
cp /home/adminuser/hadoop-namenode/HiveServer/conf/hive-site.xml /data/hive-server/conf
cp /home/adminuser/hadoop-namenode/HiveMetastore/conf/hive-site.xml /data/hive/conf

docker service create \
	--name mysql \
	--hostname mysql \
    --constraint node.hostname==hadoop-namenode \
	--replicas 1 \
	--network hadoop-net \
	--detach=true \
	-e MYSQL_ROOT_PASSWORD=123456 \
	-e MYSQL_DATABASE=hive \
	mysql:5.7

sleep 60

docker service create \
	--name hive-metastore \
	--hostname hive-metastore \
	--network hadoop-net \
    --constraint node.hostname==hadoop-namenode \
	--replicas 1 \
	--detach=true \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime \
    --mount type=bind,source=/data/hadoop/config,target=/usr/local/hadoop-2.7.4/etc/hadoop/ \
    --mount type=bind,source=/data/hive/conf/hive-site.xml,target=/usr/local/hive/conf/hive-site.xml \
	pauloo23/hive:2.3.3 

sleep 60

##Configure hive in pyspark
#get hive config files
docker cp  hive-metastore.1.$(docker service ps hive-metastore --no-trunc | grep Running | awk '{print $1}' ):/usr/local/apache-hive-2.3.3-bin/conf/hive-site.xml /data/hive/conf
docker cp  hive-metastore.1.$(docker service ps hive-metastore --no-trunc | grep Running | awk '{print $1}' ):/usr/local/hadoop-2.7.4/etc/hadoop/hdfs-site.xml /data/hive/conf
docker cp  hive-metastore.1.$(docker service ps hive-metastore --no-trunc | grep Running | awk '{print $1}' ):/usr/local/hadoop-2.7.4/etc/hadoop/core-site.xml /data/hive/conf

#copy hive and hadoop config files to spark container

docker cp /data/hive/conf/hive-site.xml sparkmaster.1.$(docker service ps sparkmaster --no-trunc | grep Running | awk '{print $1}' ):/usr/spark-2.4.5/conf
docker cp /data/hive/conf/hdfs-site.xml sparkmaster.1.$(docker service ps sparkmaster --no-trunc | grep Running | awk '{print $1}' ):/usr/spark-2.4.5/conf
docker cp /data/hive/conf/core-site.xml sparkmaster.1.$(docker service ps sparkmaster --no-trunc | grep Running | awk '{print $1}' ):/usr/spark-2.4.5/conf

#create a directory in HDFS for Hive managed data and initialize the metastore.
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -mkdir /tmp"
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -mkdir -p /user/hive/warehouse"
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -chmod g+w /tmp"
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -chmod g+w /user/hive/warehouse"



docker service create \
	--name hive-server \
	--hostname hive-server \
	--network hadoop-net \
    --constraint node.hostname==hadoop-namenode \
	--replicas 1 \
	--detach=true \
	--mount type=bind,source=/etc/localtime,target=/etc/localtime \
    --mount type=bind,source=/data/hadoop/config,target=/usr/local/hadoop-2.7.4/etc/hadoop/ \
    --mount type=bind,source=/data/hive-server/conf/hive-site.xml,target=/usr/local/hive/conf/hive-site.xml \
	pauloo23/hive-server:2.3.3 

	docker service create \
        --name hive-server-ui-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=hive-server \
        --env REMOTE_PORT=10002  \
        --env LOCAL_PORT=10002  \
        --publish mode=host,published=10002,target=10002  \
        newnius/port-forward

	docker service create \
        --name hive-metastore-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=hive-metastore \
        --env REMOTE_PORT=9083  \
        --env LOCAL_PORT=9083  \
        --publish mode=host,published=9083,target=9083  \
        newnius/port-forward

	docker service create \
        --name hive-server-http-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=hive-server \
        --env REMOTE_PORT=10001  \
        --env LOCAL_PORT=10001  \
        --publish mode=host,published=10001,target=10001  \
        newnius/port-forward

	docker service create \
        --name hive-server-thrift-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=hive-server \
        --env REMOTE_PORT=10000  \
        --env LOCAL_PORT=10000  \
        --publish mode=host,published=10000,target=10000  \
        newnius/port-forward

