#!/bin/bash
# Purpur Installation Script
#
# Server Files: /mnt/server

apt update
apt install -y curl jq

VER_EXISTS=`curl -s https://api.purpurmc.org/v2/purpur | jq -r --arg VERSION $MC_VERSION '.versions[] | contains($VERSION)' | grep true`
LATEST_PURPUR_VERSION=`curl -s https://api.purpurmc.org/v2/purpur | jq -r '.versions' | jq -r '.[0]'`

if [ "${VER_EXISTS}" == "true" ]; then
    echo -e "Version is valid. Using version ${MC_VERSION}"
else
    echo -e "Using the latest Purpur version"
    MC_VERSION=${LATEST_PURPUR_VERSION}
fi

BUILD_EXISTS=`curl -s https://api.purpurmc.org/v2/purpur/${MC_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds.all[] | contains($BUILD)' | grep true`
LATEST_PURPUR_BUILD=`curl -s https://api.purpurmc.org/v2/purpur/${MC_VERSION} | jq -r '.builds.latest'`

if [ "${BUILD_EXISTS}" == "true" ] || [ "${BUILD_NUMBER}" == "latest" ]; then
    echo -e "Build is valid. Using version ${BUILD_NUMBER}"
else
    echo -e "Using the latest Purpur build"
    BUILD_NUMBER=${LATEST_PURPUR_BUILD}
fi

echo "Version being downloaded"
echo -e "MC Version: ${MC_VERSION}"
echo -e "Build: ${BUILD_NUMBER}"
DOWNLOAD_URL=https://api.purpurmc.org/v2/purpur/${MC_VERSION}/${BUILD_NUMBER}/download 


cd /mnt/server

echo -e "running curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

if [ -f ${SERVER_JARFILE} ]; then
    mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

if [ ! -f server.properties ]; then
    echo -e "Downloading MC server.properties"
    curl -sSL -o server.properties https://raw.githubusercontent.com/parkervcp/eggs/master/minecraft/java/server.properties
fi

echo "-----------------------------------------"
echo "Installation completed..."