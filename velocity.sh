#!/bin/ash
# Velocity Proxy Installation Script
#
# Server Files: /mnt/server
PROJECT=velocity

if [[ -z ${LOADER_VERSION} ]] || [[ ${LOADER_VERSION} == "latest" ]]; then
    LOADER_VERSION="latest"
fi

if [[ -n "${DOWNLOAD_LINK}" ]]; then
    echo -e "Using supplied download url: ${DOWNLOAD_LINK}"
    DOWNLOAD_URL=$(eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
else
    VER_EXISTS=$(curl -s https://papermc.io/api/v2/projects/${PROJECT} | jq -r --arg VERSION $LOADER_VERSION '.versions[] | contains($VERSION)' | grep true)
    LATEST_VERSION=$(curl -s https://papermc.io/api/v2/projects/${PROJECT} | jq -r '.versions' | jq -r '.[-1]')

if [[ "${VER_EXISTS}" == "true" ]]; then
    echo -e "Version is valid. Using version ${LOADER_VERSION}"
else
    echo -e "Using the latest ${PROJECT} version"
    LOADER_VERSION=${LATEST_VERSION}
fi

BUILD_EXISTS=$(curl -s https://papermc.io/api/v2/projects/${PROJECT}/versions/${LOADER_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds[] | tostring | contains($BUILD)' | grep true)
LATEST_BUILD=$(curl -s https://papermc.io/api/v2/projects/${PROJECT}/versions/${LOADER_VERSION} | jq -r '.builds' | jq -r '.[-1]')

if [[ "${BUILD_EXISTS}" == "true" ]]; then
    echo -e "Build is valid for version ${LOADER_VERSION}. Using build ${BUILD_NUMBER}"
else
    echo -e "Using the latest ${PROJECT} build for version ${LOADER_VERSION}"
    BUILD_NUMBER=${LATEST_BUILD}
fi

JAR_NAME=${PROJECT}-${LOADER_VERSION}-${BUILD_NUMBER}.jar
echo "Version being downloaded"
echo -e "Velocity Version: ${LOADER_VERSION}"
echo -e "Build: ${BUILD_NUMBER}"
echo -e "JAR Name of Build: ${JAR_NAME}"
DOWNLOAD_URL=https://papermc.io/api/v2/projects/${PROJECT}/versions/${LOADER_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}

fi
cd /mnt/server
echo -e "Running curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

if [[ -f ${SERVER_JARFILE} ]]; then
mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

if [[ -f velocity.toml ]]; then
    echo -e "velocity config file exists"
else
    echo -e "downloading velocity config file."
    curl https://raw.githubusercontent.com/parkervcp/eggs/master/game_eggs/minecraft/proxy/java/velocity/velocity.toml -o velocity.toml
fi

if [[ -f forwarding.secret ]]; then
    echo -e "velocity forwarding secret file already exists"
else
    echo -e "creating forwarding secret file"
    touch forwarding.secret
    date +%s | sha256sum | base64 | head -c 12 > forwarding.secret
fi

echo -e "install complete"