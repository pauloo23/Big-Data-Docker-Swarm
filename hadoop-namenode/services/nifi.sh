mkdir /data/nifi
mkdir /data/nifi/state
mkdir /data/nifi/drivers
mkdir /data/nifi/logs
mkdir /data/nifi/database_repository
mkdir /data/nifi/flowfile_repository
mkdir /data/nifi/content_repository
mkdir /data/nifi/provenance_repository
mkdir /data/nifi/nifi_registry
mkdir /data/nifi/nifi_registry/database
mkdir /data/nifi/nifi_registry/flow_storage

chmod 777 -R /data/nifi
##get jdbc from github 
docker stack deploy -c ./helpers/nifi.yml nifi


docker service create \
        --name nifi-registry-forwarder \
        --constraint node.hostname==hadoop-namenode \
        --network hadoop-net \
        --env REMOTE_HOST=registry \
        --env REMOTE_PORT=18080 \
        --env LOCAL_PORT=18080 \
        --publish mode=host,published=18080,target=18080 \
        newnius/port-forward
