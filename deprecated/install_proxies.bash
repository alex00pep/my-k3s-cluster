#!/bin/bash

source $HOME/vars.bash
echo "Honeygain Install- Residential proxy using docker"

mkdir -p $HOME/honeygain && cd $HOME/honeygain
cat <<'EOF' > $HOME/honeygain/docker-compose.yml

version: '3.7'

services:
  honeygain:
    container_name: honeygain
    image: honeygain/honeygain
    command: -tou-accept -email ${EMAIL} -pass ${HG_PASS} -device ${NODE_ALIAS}
    restart: unless-stopped


EOF

docker compose up -d --force-recreate
cd $HOME

echo "***Honeygain Install - DONE***\n\n"


echo "RePocket Install - Residential proxy using docker"

mkdir -p $HOME/repocket && cd $HOME/repocket
cat <<'EOF' > $HOME/repocket/docker-compose.yml

version: '3.7'

services:
  repocket:
    container_name: repocket
    image: rg.fr-par.scw.cloud/repocket-docker/repocket:latest
    environment:
      - RP_EMAIL=${EMAIL}
      - RP_API_KEY=${RP_API_KEY}
    restart: unless-stopped

EOF

docker compose up -d --force-recreate
cd $HOME

echo "***RePocket Install - DONE***\n\n"


echo "PacketStream Install - Residential proxy using docker"

mkdir -p $HOME/packetstream && cd $HOME/packetstream
cat <<'EOF' > $HOME/packetstream/docker-compose.yml

version: '3.7'

services:
  psclient:
    container_name: psclient
    image: packetstream/psclient
    environment:
      - CID=6CHB
    restart: unless-stopped
  watchtower:
    container_name: watchtower
    image: containrrr/watchtower
    command: --cleanup --include-stopped --include-restarting --revive-stopped --interval 60 psclient
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
EOF
docker compose up -d --force-recreate
cd $HOME

echo "***PacketStream Install - DONE***\n\n"
