#Pull docker image
docker pull pauloo23/hadoop:2.7.4

#Create dir /data
mkdir -p /data
chmod 777 /data

# create dir for data perist.
mkdir -p /data/hadoop/hdfs/master
mkdir -p /data/hadoop/logs/master

#create config folder

mkdir -p /data/hadoop/config
chmod 777 -R /data

# Dowsnload config files to config folder
 ##Important --> need to install svn 
 apt-get install subversion

 # Use subversion to download config files from github 
svn export https://github.com/pauloo23/Dockerfiles/trunk/hadoop/2.9.1/config /data/hadoop/config --force



#Bring up all the nodes

#  namenode
docker service create \
  --name hadoop-namenode \
  --hostname hadoop-namenode \
  --constraint node.hostname==hadoop-namenode \
  --network hadoop-net \
  --endpoint-mode dnsrr \
  --replicas 1 \
  --detach=true \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  --mount type=bind,source=/data/hadoop/hdfs/master,target=/tmp/hadoop-root \
  --mount type=bind,source=/data/hadoop/logs/master,target=/usr/local/hadoop/logs \
 pauloo23/hadoop:2.7.4

#datanode 1 
docker service create \
  --name hadoop-datanode1 \
  --hostname hadoop-datanode1 \
  --constraint node.hostname==hadoop-datanode1 \
  --network hadoop-net \
  --detach=true \
  --endpoint-mode dnsrr \
  --replicas 1 \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  --mount type=bind,source=/data/hadoop/hdfs/slave1,target=/tmp/hadoop-root \
  --mount type=bind,source=/data/hadoop/logs/slave1,target=/usr/local/hadoop/logs \
  pauloo23/hadoop:2.7.4

#datanode2
docker service create \
  --name hadoop-datanode2 \
  --hostname hadoop-datanode2 \
  --constraint node.hostname==hadoop-datanode2 \
  --network hadoop-net \
  --detach=true \
  --endpoint-mode dnsrr \
  --replicas 1 \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  --mount type=bind,source=/data/hadoop/hdfs/slave2,target=/tmp/hadoop-root \
  --mount type=bind,source=/data/hadoop/logs/slave2,target=/usr/local/hadoop/logs \
  pauloo23/hadoop:2.7.4

sleep 60

##START HADOOP SERVICES
docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "sbin/stop-yarn.sh;sbin/stop-dfs.sh;bin/hadoop namenode -format;sbin/start-dfs.sh;sbin/start-yarn.sh"

docker exec -it hadoop-namenode.1.$(docker service ps \
hadoop-namenode --no-trunc | grep Running | awk '{print $1}' ) bash -c "hdfs dfs -chmod 777 /user/admin"


##EXPOSE INTERFACES
docker service create \
        --name hadoop-namenode-webhdfs \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=hadoop-namenode \
        --env REMOTE_PORT=50070 \
        --env LOCAL_PORT=50070 \
        --publish mode=host,published=50070,target=50070 \
        newnius/port-forward

docker service create \
        --name hadoop-namenode-yarn \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=hadoop-namenode \
        --env REMOTE_PORT=8088 \
        --env LOCAL_PORT=8088 \
        --publish mode=host,published=8088,target=8088 \
        newnius/port-forward

docker service create \
        --name hadoop-namenode-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=hadoop-namenode \
        --env REMOTE_PORT=8020 \
        --env LOCAL_PORT=8020 \
        --publish mode=host,published=8020,target=8020 \
        newnius/port-forward

docker service create \
        --name hadoop-datanode1-forwarder \
        --constraint node.hostname==hadoop-datanode1 \
        --network hadoop-net \
        --env REMOTE_HOST=hadoop-datanode1 \
        --env REMOTE_PORT=50075 \
        --env LOCAL_PORT=50075 \
        --publish mode=host,published=50075,target=50075 \
        newnius/port-forward


docker service create \
        --name hadoop-datanode2-forwarder \
        --constraint node.hostname==hadoop-datanode2 \
        --network hadoop-net \
        --env REMOTE_HOST=hadoop-datanode2 \
        --env REMOTE_PORT=50075  \
        --env LOCAL_PORT=50075  \
        --publish mode=host,published=50075,target=50075  \
        newnius/port-forward
