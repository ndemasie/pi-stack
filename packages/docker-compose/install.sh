#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source ${PROJECT_DIR}/scripts/helpers/variables.sh

echo "Installing docker-compose..."
DOCKER_COMPOSE_VERSION="2.10.1"
# For 64-bit OS use:
# DOCKER_COMPOSE_ARCH="aarch64"
# For 32-bit OS use:
DOCKER_COMPOSE_ARCH=${SYS_ARCH::-1}

sudo curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${DOCKER_COMPOSE_ARCH}" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

echo "Verifying docker-compose"
docker-compose --version

echo "docker-compose was installed"