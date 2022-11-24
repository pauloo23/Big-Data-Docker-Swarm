#open ports to allow connection between worker and manager
sudo apt -y install subversion
sudo apt update
sudo apt -y install firewalld
sudo ufw disable
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --add-port=2376/tcp --permanent
sudo firewall-cmd --add-port=2377/tcp --permanent
sudo firewall-cmd --add-port=7946/tcp --permanent
sudo firewall-cmd --add-port=7946/udp --permanent
sudo firewall-cmd --add-port=4789/udp --permanent
sudo firewall-cmd --add-port=16020/tcp --permanent
sudo firewall-cmd --add-port=8020/tcp --permanent
sudo firewall-cmd --add-port=8020/udp --permanent
sudo firewall-cmd --add-port=16000/tcp --permanent
sudo firewall-cmd --add-port=16000/udp --permanent
sudo firewall-cmd --reload

systemctl restart docker

# Create a docker overlay network called hadoop-net
docker network prune
docker network create --driver overlay --attachable hadoop-net
docker network create --ingress --driver overlay ingress
