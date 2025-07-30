#!/usr/bin/bash
# Arclight Installation Script

# Server Files: /mnt/server
if [[ ! -d /mnt/server ]]; then
  mkdir /mnt/server
fi
cd /mnt/server

# Get branch name, loader type, and version from {LOADER_VERSION} by split by ':'
IFS=':' read -r BRANCH_NAME LOADER_TYPE VERSION <<< "$LOADER_VERSION"
# Remove spaces from the version number to avoid issues with curl
BRANCH_NAME="$(echo "$BRANCH_NAME" | tr -d ' ')"
LOADER_TYPE="$(echo "$LOADER_TYPE" | tr -d ' ')"
VERSION="$(echo "$VERSION" | tr -d ' ')"

# Set the download link based on the loader type
DOWNLOAD_LINK="https://files.hypertention.cn/v1/files/arclight/branches/${BRANCH_NAME}/loaders/${LOADER_TYPE}/versions-snapshot/${VERSION}"

# Start downloading the jar file
echo -e "Downloading Arclight version ${VERSION} from branch ${BRANCH_NAME} with loader type ${LOADER_TYPE}"
curl -sSL -o ${SERVER_JARFILE} ${DOWNLOAD_LINK}
# Check if the downloaded jar file exists
if [ ! -f ./${SERVER_JARFILE} ]; then
  echo "!!! Error downloading Arclight version ${VERSION} !!!"
  exit 1
fi
# If the download was successful, print a success message
echo "Arclight version ${VERSION} downloaded successfully from branch ${BRANCH_NAME} with loader type ${LOADER_TYPE}"
# Install end
echo "-----------------------------------------"
echo "Installation completed..."
