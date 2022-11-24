
docker run -d --name superset --network hadoop-net -p 8089:9777 -e SUPERSET_PORT=9777 apache/superset

docker exec -it superset superset fab create-admin \
              --username admin \
              --firstname Superset \
              --lastname Admin \
              --email admin@superset.com \
              --password admin
              
docker exec -it superset superset db upgrade

docker exec -it superset superset load_examples

docker exec -it superset superset init