#open ports to allow connection between worker and manager
sudo apt update
sudo apt -y install firewalld
sudo apt -y install subversion
sudo ufw disable
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --add-port=2376/tcp --permanent
sudo firewall-cmd --add-port=7946/tcp --permanent
sudo firewall-cmd --add-port=7946/udp --permanent
sudo firewall-cmd --add-port=4789/udp --permanent
sudo firewall-cmd --add-port=16020/tcp --permanent
sudo firewall-cmd --add-port=50075/tcp --permanent
sudo firewall-cmd --add-port=50075/udp --permanent
sudo firewall-cmd --add-port=2181/udp --permanent
sudo firewall-cmd --add-port=2181/tcp --permanent
sudo firewall-cmd --add-port=2888/udp --permanent
sudo firewall-cmd --add-port=2888/tcp --permanent
sudo firewall-cmd --reload
systemctl restart docker


#Remove docker image to avoid conflits 
docker rmi -f `docker images -qa `

##Important --> need to install svn 
apt-get install subversion

#Pull docker hadoop image and spark image
docker pull pauloo23/hadoop:2.7.4
docker pull pauloo23/pyspark-notebook:2.4.5
docker pull pauloo23/presto-worker1:0.251
docker pull newnius/port-forward

#delete data dir if exists
rm -rf /data

#Create dir /data
mkdir -p /data
chmod 777 /data

# create dir for data perist.
mkdir -p /data/hadoop/hdfs/slave1
mkdir -p /data/hadoop/logs/slave1

# create dir for config files.
mkdir -p /data/hadoop/config
# Use subversion to download config files from github 
svn export https://github.com/pauloo23/Dockerfiles/trunk/hadoop/2.9.1/config /data/hadoop/config --force

#create dir for spark config
mkdir /data/spark
mkdir /data/spark/config
svn export https://github.com/pauloo23/Dockerfiles/trunk/hadoop/2.9.1/spark_conf /data/spark/conf --force

#create dir for nifi persist 
mkdir /data/nifi
mkdir /data/nifi/state
mkdir /data/nifi/drivers
mkdir /data/nifi/logs
mkdir /data/nifi/database_repository
mkdir /data/nifi/flowfile_repository
mkdir /data/nifi/content_repository
mkdir /data/nifi/provenance_repository
docker pull apache/nifi:1.19.0

##zookeper
mkdir /data/zookeeper
mkdir /data/zookeeper/data/
mkdir /data/zookeeper/data/node2
mkdir /data/zookeeper/logs
mkdir /data/zookeeper/logs/node2
docker pull zookeeper:3.4.10

##Hbase
mkdir /data/hbase
mkdir /data/hbase/config/
mkdir /data/hbase/logs
mkdir /data/hbase/logs/slave1
docker pull pauloo23/hbase:1.2.6
svn export https://github.com/pauloo23/Big-Data-Docker-Swarm/trunk/hadoop-namenode/HBase/conf /data/hbase/config/ --force

##Airflow 
mkdir /data/airflow
mkdir /data/airflow/dags
docker pull pauloo23/airflow-spark:2.2.5

#change data dir permissions
chmod 777 -R /data 

#Get hdfs-site.xml to insert in spark worker
mkdir /data/hive
mkdir /data/hive/conf
chmod 777 -R /data
svn export https://github.com/pauloo23/Big-Data-Docker-Swarm/trunk/hadoop-namenode/HiveMetastore/conf /data/hive/conf/ --force
svn export https://github.com/pauloo23/Dockerfiles/trunk/hadoop/2.9.1/config /data/hive/conf --force



