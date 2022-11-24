
# Create a docker overlay network called hadoop-net
docker pull pauloo23/pyspark-notebook:2.4.5
mkdir /jupyter-pyspark
mkdir /jupyter-pyspark/work
chmod 777 -R /jupyter-pyspark

#svn export https://github.com/pauloo23/Dockerfiles/trunk/hadoop/2.9.1/spark_conf /data/spark/conf
#Bring up all the nodes

#  master
docker service create \
  --name sparkmaster \
  --hostname sparkmaster \
  --constraint node.hostname==hadoop-namenode \
  --network hadoop-net \
  --endpoint-mode dnsrr \
  --replicas 1 \
  --detach=true \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  pauloo23/pyspark-notebook:2.4.5 bin/spark-class org.apache.spark.deploy.master.Master

#worker1
docker service create \
  --name sparkworker1 \
  --hostname sparkworker1 \
  --constraint node.hostname==hadoop-namenode \
  --network hadoop-net \
  --endpoint-mode dnsrr \
  --replicas 1 \
  --detach=true \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  pauloo23/pyspark-notebook:2.4.5 bin/spark-class org.apache.spark.deploy.worker.Worker spark://sparkmaster:7077

#worker2 
docker service create \
  --name sparkworker2 \
  --hostname sparkworker2 \
  --constraint node.hostname==hadoop-datanode1 \
  --network hadoop-net \
  --detach=true \
  --replicas 1 \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  pauloo23/pyspark-notebook:2.4.5 bin/spark-class org.apache.spark.deploy.worker.Worker spark://sparkmaster:7077

#worker3
docker service create \
  --name sparkworker3 \
  --hostname sparkworker3 \
  --constraint node.hostname==hadoop-datanode2 \
  --network hadoop-net \
  --detach=true \
  --replicas 1 \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  pauloo23/pyspark-notebook:2.4.5 bin/spark-class org.apache.spark.deploy.worker.Worker spark://sparkmaster:7077

#Jupyterlab 
docker service create \
  --name jupyterlab\
  --hostname jupyterlab \
  --constraint node.hostname==hadoop-namenode \
  --network hadoop-net \
  --detach=true \
  --replicas 1 \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime \
  --mount type=bind,source=/data/hadoop/config,target=/config/hadoop \
  --mount type=bind,source=/jupyter-pyspark/work,target=/usr/spark-2.4.5/work \
  pauloo23/pyspark-notebook:2.4.5 jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token='' --NotebookApp.password=''


##EXPOSE INTERFACES

docker service create \
        --name spark-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=sparkmaster \
        --env REMOTE_PORT=8080 \
        --env LOCAL_PORT=8080 \
        --publish mode=host,published=8080,target=8080 \
        newnius/port-forward

docker service create \
        --name spark-master-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=sparkmaster \
        --env REMOTE_PORT=7077 \
        --env LOCAL_PORT=7077 \
        --publish mode=host,published=7077,target=7077 \
        newnius/port-forward

docker service create \
        --name spark-worker1-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=sparkworker1 \
        --env REMOTE_PORT=8081 \
        --env LOCAL_PORT=8081 \
        --publish mode=host,published=8081,target=8081 \
        newnius/port-forward

docker service create \
        --name spark-worker2-forwarder \
        --constraint node.hostname==hadoop-datanode1 \
        --network hadoop-net \
        --env REMOTE_HOST=sparkworker2 \
        --env REMOTE_PORT=8081 \
        --env LOCAL_PORT=8081 \
        --publish mode=host,published=8081,target=8081 \
        newnius/port-forward

docker service create \
        --name spark-worker3-forwarder \
        --constraint node.hostname==hadoop-datanode2 \
        --network hadoop-net \
        --env REMOTE_HOST=sparkworker3 \
        --env REMOTE_PORT=8081 \
        --env LOCAL_PORT=8081 \
        --publish mode=host,published=8081,target=8081 \
        newnius/port-forward



docker service create \
        --name jupyterlab-forwarder\
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=jupyterlab \
        --env REMOTE_PORT=8888 \
        --env LOCAL_PORT=8888 \
        --publish mode=host,published=8888,target=8888 \
        newnius/port-forward

