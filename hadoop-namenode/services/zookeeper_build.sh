#!/bin/bash
mkdir /data/zookeeper
mkdir /data/zookeeper/data/
mkdir /data/zookeeper/data/node1
mkdir /data/zookeeper/logs
mkdir /data/zookeeper/logs/node1
docker pull zookeeper:3.4
docker stack deploy --compose-file ./helpers/zookeeper.yml zookeeper