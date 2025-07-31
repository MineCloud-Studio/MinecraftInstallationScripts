#!/bin/ash
# Bungeecord Installation Script
#
# Server Files: /mnt/server

cd /mnt/server

curl -o ${SERVER_JARFILE} https://ci.md-5.net/job/BungeeCord/lastStableBuild/artifact/bootstrap/target/BungeeCord.jar
