 #!/bin/bash
# Forge Installation Script
#
# Server Files: /mnt/server
if [[ ! -d /mnt/server ]]; then
  mkdir /mnt/server
fi

cd /mnt/server

# Remove spaces from the version number to avoid issues with curl
MC_VERSION="$(echo "$MC_VERSION" | tr -d ' ')"
LOADER_VERSION="$(echo "$LOADER_VERSION" | tr -d ' ')"


FORGE_VERSION="${MC_VERSION}-${LOADER_VERSION}"
DOWNLOAD_LINK=https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_VERSION}/forge-${FORGE_VERSION}
FORGE_JAR=forge-${FORGE_VERSION}*.jar

#Adding .jar when not eding by SERVER_JARFILE
if [[ ! $SERVER_JARFILE = *\.jar ]]; then
  SERVER_JARFILE="$SERVER_JARFILE.jar"
fi

#Downloading jars
echo -e "Downloading forge version ${FORGE_VERSION}"
echo -e "Download link is ${DOWNLOAD_LINK}"

if [[ ! -z "${DOWNLOAD_LINK}" ]]; then
  if curl --output /dev/null --silent --head --fail ${DOWNLOAD_LINK}-installer.jar; then
    echo -e "installer jar download link is valid."
  else
    echo -e "link is invalid. Exiting now"
    exit 2
  fi
else
  echo -e "no download link provided. Exiting now"
  exit 3
fi

curl -s -o installer.jar -sS ${DOWNLOAD_LINK}-installer.jar

#Checking if downloaded jars exist
if [[ ! -f ./installer.jar ]]; then
  echo "!!! Error downloading forge version ${FORGE_VERSION} !!!"
  exit
fi

function  unix_args {
  echo -e "Detected Forge 1.17 or newer version. Setting up forge unix args."
  ln -sf libraries/net/minecraftforge/forge/*/unix_args.txt unix_args.txt
}

# Delete args to support downgrading/upgrading
rm -rf libraries/net/minecraftforge/forge
rm unix_args.txt

#Installing server
echo -e "Installing forge server.\n"
java -jar installer.jar --installServer || { echo -e "\nInstall failed using Forge version ${FORGE_VERSION} and Minecraft version ${MINECRAFT_VERSION}.\nShould you be using unlimited memory value of 0, make sure to increase the default install resource limits in the Wings config or specify exact allocated memory in the server Build Configuration instead of 0! \nOtherwise, the Forge installer will not have enough memory."; exit 4; }

# Check if we need a symlink for 1.17+ Forge JPMS args
if [[ $MC_VERSION =~ ^1\.(1[7-9]|[2-9][0-9]+) || $FORGE_VERSION =~ ^1\.(1[7-9]|[2-9][0-9]+) ]]; then
  unix_args

# Check if someone has set MC to latest but overwrote it with older Forge version, otherwise we would have false positives
elif [[ $MC_VERSION == "latest" && $FORGE_VERSION =~ ^1\.(1[7-9]|[2-9][0-9]+) ]]; then
  unix_args
else
  # For versions below 1.17 that ship with jar
  mv $FORGE_JAR $SERVER_JARFILE
fi

echo -e "Deleting installer.jar file.\n"
rm -rf installer.jar
echo -e "Installation process is completed"