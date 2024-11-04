#!/bin/sh
export PATH=/usr/local/bin:$PATH;

sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install docker-ce -y
#sudo systemctl status docker
sudo usermod -aG docker ubuntu

sudo chmod 777 /var/run/docker.sock
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo chown root:docker /usr/local/bin/docker-compose

cat <<EOF >/home/ubuntu/docker-compose.yml
version: '2'
services:
  elasticsearch:
    container_name: elasticsearch
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.18
    restart: always
    environment:
      discovery.type: 'single-node'
      ELASTIC_PASSWORD: "asdf"
      cluster.name: 'amcart-search'
      node.name: 'node-master'
      bootstrap.memory_lock: 'true'
      ES_JAVA_OPTS: '-Xms512m -Xmx512m'
      xpack.security.enabled: 'true'
    ports:
      - "9200:9200"
      - "9300:9300"
    networks:
      - esnet
    expose:
      - 9200
      - 9300


networks:
  esnet:
EOF
sudo service docker restart
chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml
/usr/local/bin/docker-compose -f /home/ubuntu/docker-compose.yml up -d
