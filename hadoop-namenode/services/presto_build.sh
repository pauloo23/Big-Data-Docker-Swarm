mkdir /data/presto 
echo "connector.name=hive-hadoop2\nhive.metastore.uri=thrift://hive-metastore:9083" > /data/presto/hive.properties

docker pull pauloo23/presto-coordinator:0.251
docker service create \
	--name presto-coordinator \
	--hostname presto-coordinator \
	--network hadoop-net \
    --constraint node.hostname==hadoop-namenode \
	--replicas 1 \
    -p 8090:8090 \
	--mount type=bind,source=/data/presto/hive.properties,target=/presto/etc/catalog/hive.properties \
	pauloo23/presto-coordinator:0.251
	

    docker service create \
	--name presto-worker1 \
	--hostname presto-worker1 \
	--network hadoop-net \
    --constraint node.hostname==hadoop-datanode1 \
    -p 8082:8082 \
	--replicas 1 \
	pauloo23/presto-worker1:0.251 


    docker service create \
	--name presto-worker2 \
	--hostname presto-worker2 \
	--network hadoop-net \
    --constraint node.hostname==hadoop-datanode2 \
    -p 8083:8082 \
	--replicas 1 \
	pauloo23/presto-worker2:0.251 
