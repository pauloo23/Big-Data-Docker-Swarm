#!/bin/bash
read -p 'Enter Docker Leader Machine hostname: ' namenode_host


read -p 'Enter Docker worker1 Machine hostnam: ' datanode1_host


read -p 'Enter Docker worker2 Machine hostnam: ' datanode2_host


read -p 'Enter Docker Swarm network name: ' network




##Replace text in shell script files
cd ./services
sed -i "s/node.hostname==hadoop-namenode/$namenode_host/g" *
sed -i "s/node.hostname==hadoop-datanode1/$datanode1_host/g" *
sed -i "s/node.hostname==hadoop-datanode2/$datanode2_host/g" *
sed -i "s/hadoop-net/$network/g" *

##Up all services 

    #Portainer
echo starting Portainer
sh portainer_build.sh
sleep 60    

    #Hadoop
echo starting hadoop services
sh hadoop_build.sh
sleep 60

    #Spark
echo starting spark services
sh spark_build.sh
sleep 60

    #Hive
echo starting Hive services
sh hive_build.sh 
sleep 60

    #Presto
echo starting Presto services
sh presto_build.sh 
sleep 60

    #Superset
echo starting Superset services
sh superset_build.sh 
sleep 60