mkdir /data/airflow
mkdir /data/airflow/dags
chmod 777 -R /data/airflow
docker stack deploy -c ./helpers/airflow.yml airflow

sleep 30

##Create airflow user with credentials admin admin

docker exec -it airflow_webserver.1.$(docker service ps \
airflow_webserver --no-trunc | grep Running | awk '{print $1}' ) bash -c "airflow users create \
    --username admin \
    --password admin \
    --firstname admin \
    --lastname admin \
    --role Admin \
    --email admin@email.pt"

##Install redis WebUI 
docker run -d -p 5001:5001 --network hadoop-net --link airflow_redis.1..$(docker service ps \
airflow_redis --no-trunc | grep Running | awk '{print $1}' ):airflow_redis.1..$(docker service ps \
airflow_redis --no-trunc | grep Running | awk '{print $1}' ) marian/rebrow