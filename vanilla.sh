#!/bin/ash
# Vanilla MC Installation Script
#
# Server Files: /mnt/server
mkdir -p /mnt/server
cd /mnt/server

echo "test"

LATEST_VERSION=`curl https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.release'`
LATEST_SNAPSHOT_VERSION=`curl https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.snapshot'`

echo "test2"

echo -e "latest version is $LATEST_VERSION"
echo -e "latest snapshot is $LATEST_SNAPSHOT_VERSION"

echo "test3"

if [ -z "$MC_VERSION" ] || [ "$MC_VERSION" == "latest" ]; then
  MANIFEST_URL=$(curl -sSL https://launchermeta.mojang.com/mc/game/version_manifest.json | jq --arg VERSION $LATEST_VERSION -r '.versions | .[] | select(.id== $VERSION )|.url')
elif [ "$MC_VERSION" == "snapshot" ]; then
  MANIFEST_URL=$(curl -sSL https://launchermeta.mojang.com/mc/game/version_manifest.json | jq --arg VERSION $LATEST_SNAPSHOT_VERSION -r '.versions | .[] | select(.id== $VERSION )|.url')
else
  MANIFEST_URL=$(curl -sSL https://launchermeta .mojang.com/mc/game/version_manifest.json | jq --arg VERSION $MC_VERSION -r '.versions | .[] | select(.id== $VERSION )|.url')
fi

echo "test4"

DOWNLOAD_URL=$(curl ${MANIFEST_URL} | jq .downloads.server | jq -r '. | .url')

echo "test5"

echo -e "running: curl -o ${SERVER_JARFILE} $DOWNLOAD_URL"
curl -o ${SERVER_JARFILE} $DOWNLOAD_URL

echo "test6"


echo -e "Install Complete"
