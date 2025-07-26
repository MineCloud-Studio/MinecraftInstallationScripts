#!/bin/bash
# Mohist Installation Script
#
# Server Files: /mnt/server
apt update
apt -y install curl

#Go into main direction
if [ ! -d /mnt/server ]; then
    mkdir -p /mnt/server
fi

cd /mnt/server

DOWNLOAD_LINK=https://api.mohistmc.com/project/youer/${MC_VERSION}/builds/${LOADER_VERSION}/download

#Downloading jars
echo -e "Download link is ${DOWNLOAD_LINK}"
echo -e "Downloading build version ${LOADER_VERSION}"

curl -sSL -o ${SERVER_JARFILE} ${DOWNLOAD_LINK}

#Checking if downloaded jars exist
if [ ! -f ./${SERVER_JARFILE} ]; then
    echo "!!! Error downloading build version ${LOADER_VERSION} !!!"
    exit
fi

## install end
echo "-----------------------------------------"
echo "Installation completed..."
echo "-----------------------------------------"