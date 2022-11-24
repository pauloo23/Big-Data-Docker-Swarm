curl -L https://downloads.portainer.io/ce2-16/portainer-agent-stack.yml -o portainer-agent-stack.yml
sed -i "s/hadoop-net/hadoop-net/g" *
sed -i "s/external:/external:/g" *
sed -i "s/   name: hadoop-net/   name: hadoop-net/g" *
external:
docker stack deploy -c portainer-agent-stack.yml portainer