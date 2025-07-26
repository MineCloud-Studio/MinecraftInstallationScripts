#!/bin/bash
# NeoForge Installation Script
#
# Server Files: /mnt/server

apt-get update
apt-get install -y curl xq openjdk-17-jdk

if [[ ! -d /mnt/server ]]; then
    mkdir /mnt/server
fi

cd /mnt/server

# Remove spaces from the version number to avoid issues with curl
MC_VERSION="$(echo "$MC_VERSION" | tr -d ' ')"
LOADER_VERSION="$(echo "$LOADER_VERSION" | tr -d ' ')"

NEOFORGE_VERSION="${MC_VERSION}-${LOADER_VERSION}"


# If we have a specific NeoForge version set, use that
if [[ ! -z ${NEOFORGE_VERSION} ]]; then
  # The 1.20.1 release lives in a different repository and is called "forge" instead of "neoforge"
  if [[ "${NEOFORGE_VERSION}" =~ "1.20.1-" ]]; then
    DOWNLOAD_LINK=https://maven.neoforged.net/releases/net/neoforged/forge/${NEOFORGE_VERSION}/forge-${NEOFORGE_VERSION}
    ARTIFACT_NAME="forge"
  else
    DOWNLOAD_LINK=https://maven.neoforged.net/releases/net/neoforged/neoforge/${NEOFORGE_VERSION}/neoforge-${NEOFORGE_VERSION}
    ARTIFACT_NAME="neoforge"
  fi
else
  # For NeoForge, downloading based on a Minecraft version is done by using the Maven metadata.
  # 1.20.1 is also handled differently here, because it's in a different repository and is called
  # "forge" instead of "neoforge".
  if [[ "${MC_VERSION}" == "1.20.1" ]]; then
    XML_DATA=$(curl -sSL https://maven.neoforged.net/releases/net/neoforged/forge/maven-metadata.xml)
    ARTIFACT_NAME="forge"
    NEOFORGE_OLD=1
  else
    XML_DATA=$(curl -sSL https://maven.neoforged.net/releases/net/neoforged/neoforge/maven-metadata.xml)
    ARTIFACT_NAME="neoforge"
  fi

  REPO_URL="https://maven.neoforged.net/releases/net/neoforged/${ARTIFACT_NAME}/"

  # Get the latest version of Minecraft NeoForge supports. Here XML_DATA contains the metadata for
  # the new, "neoforge" repository, which is good since 1.20.1 will never be the latest anymore.
  if [[ "${MC_VERSION}" == "latest" ]] || [[ "${MC_VERSION}" == "" ]]; then
    echo "Getting latest version of NeoForge."
    MC_VERSION="1.$(echo -e ${XML_DATA} | xq -x '/metadata/versioning/release' | cut -d'.' -f1-2)"
  fi

  echo "Minecraft version: ${MC_VERSION}"

  if [[ -z "${NEOFORGE_OLD}" ]]; then
    # For modern artifacts we cut the "1." from the Minecraft version, and search for that
    VERSION_KEY=$(echo -n ${MC_VERSION} | cut -d'.' -f2-)
  else
    # For 1.20.1, it uses the same naming scheme as Forge, so we just append a dash
    VERSION_KEY="${MC_VERSION}-"
  fi

  # Then we extract the latest the latest NeoForge version available based on the Maven metadata
  NEOFORGE_VERSION=$(echo -e ${XML_DATA} | xq -x "(/metadata/versioning/versions/*[starts-with(text(), '${VERSION_KEY}')])" | tail -n1)
  if [[ -z "${NEOFORGE_VERSION}" ]]; then
    echo "The install failed, because there is no valid version of NeoForge for the version of Minecraft selected."
    exit 1
  fi

  echo "NeoForge version: ${NEOFORGE_VERSION}"

  DOWNLOAD_LINK="${REPO_URL}${NEOFORGE_VERSION}/${ARTIFACT_NAME}-${NEOFORGE_VERSION}"
fi

echo "Downloading NeoForge version ${NEOFORGE_VERSION}"
echo "Download link is ${DOWNLOAD_LINK}"

# Check if the download link we generated is valid
if [[ ! -z "${DOWNLOAD_LINK}" ]]; then
  if curl --output /dev/null --silent --head --fail ${DOWNLOAD_LINK}-installer.jar; then
    echo -e "Installer jar download link is valid."
  else
    echo -e "Link is invalid. Exiting now"
    exit 2
  fi
else
  echo -e "No download link provided. Exiting now"
  exit 3
fi

# If so, go ahead and download the installer
curl -s -o installer.jar -sS ${DOWNLOAD_LINK}-installer.jar

if [[ ! -f ./installer.jar ]]; then
  echo "!!! Error downloading NeoForge version ${NEOFORGE_VERSION} !!!"
  exit 4
fi

# Delete args to support downgrading/upgrading
rm -rf libraries/net/neoforged/${ARTIFACT_NAME}
rm unix_args.txt

# Installing server
echo -e "Installing NeoForge server.\n"
java -jar installer.jar --installServer || {
  echo -e "\nInstall failed using NeoForge version ${NEOFORGE_VERSION} and Minecraft version ${MINECRAFT_VERSION}."
  echo -n   "Should you be using unlimited memory value of 0, make sure to increase the default install resource limits in the Wings"
  echo      "config or specify exact allocated memory in the server Build Configuration instead of 0!"
  echo      "Otherwise, the NeoForge installer will not have enough memory.";
  exit 5;
}

# Symlink the startup arguments to the server directory
ln -sf libraries/net/neoforged/${ARTIFACT_NAME}/*/unix_args.txt unix_args.txt

# And finally clean up
echo -e "Deleting installer.jar file.\n"
rm -rf installer.jar

echo "Installation process is completed!"