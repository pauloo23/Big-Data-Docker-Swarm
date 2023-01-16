cd helpers
curl -L https://downloads.portainer.io/ce2-16/portainer-agent-stack.yml -o portainer-agent-stack.yml
sed -i "s/agent_network/hadoop-net/g" portainer-agent-stack.yml
sed -i "s/driver: overlay/external:/g" portainer-agent-stack.yml
sed -i "s/attachable: true/  name: hadoop-net/g" portainer-agent-stack.yml
docker stack deploy -c portainer-agent-stack.yml portainer