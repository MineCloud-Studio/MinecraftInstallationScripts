#!/bin/bash
# Fabric MC Installation Script
#
# Server Files: /mnt/server
apt update
apt install -y curl jq unzip dos2unix wget
mkdir -p /mnt/server
cd /mnt/server

# Enable snapshots
if [ -z "$MC_VERSION" ] || [ "$MC_VERSION" == "latest" ]; then
  MC_VERSION=$(curl -sSL https://meta.fabricmc.net/v2/versions/game | jq -r '.[] | select(.stable== true )|.version' | head -n1)
elif [ "$MC_VERSION" == "snapshot" ]; then
  MC_VERSION=$(curl -sSL https://meta.fabricmc.net/v2/versions/game | jq -r '.[] | select(.stable== false )|.version' | head -n1)
fi


FABRIC_VERSION=$(curl -sSL https://meta.fabricmc.net/v2/versions/installer | jq -r '.[0].version')


if [ -z "$LOADER_VERSION" ] || [ "$LOADER_VERSION" == "latest" ]; then
  LOADER_VERSION=$(curl -sSL https://meta.fabricmc.net/v2/versions/loader | jq -r '.[] | select(.stable== true )|.version' | head -n1)
elif [ "$LOADER_VERSION" == "snapshot" ]; then
  LOADER_VERSION=$(curl -sSL https://meta.fabricmc.net/v2/versions/loader | jq -r '.[] | select(.stable== false )|.version' | head -n1)
fi

wget -O fabric-installer.jar https://maven.fabricmc.net/net/fabricmc/fabric-installer/$FABRIC_VERSION/fabric-installer-$FABRIC_VERSION.jar
java -jar fabric-installer.jar server -mcversion $MC_VERSION -loader $LOADER_VERSION -downloadMinecraft
mv server.jar minecraft-server.jar
mv fabric-server-launch.jar server.jar
echo "serverJar=minecraft-server.jar" > fabric-server-launcher.properties
echo -e "Install Complete"
