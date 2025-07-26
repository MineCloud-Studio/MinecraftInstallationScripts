#!/bin/ash
# Bungeecord Installation Script
#
# Server Files: /mnt/server

cd /mnt/server

if [ -z "${LOADER_VERSION}" ] || [ "${LOADER_VERSION}" == "latest" ]; then
    LOADER_VERSION="lastStableBuild"
fi

curl -o ${SERVER_JARFILE} https://ci.md-5.net/job/BungeeCord/${LOADER_VERSION}/artifact/bootstrap/target/BungeeCord.jar