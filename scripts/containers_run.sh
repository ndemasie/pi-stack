#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source ${PROJECT_DIR}/scripts/helpers/index.sh


SCRIPT_RUN_CMD=${1,,}

SELECTIONS_PATH="${PROJECT_DIR}/.containers.selections"
readarray -t containers < "${SELECTIONS_PATH}"

for container in ${containers[@]}; do
  compose_files+=" --file ${PROJECT_DIR}/containers/${container}/docker-compose.yml"
done

case $SCRIPT_RUN_CMD in
  c|config) compose_cmd="config";;
  d|down) compose_cmd="down";;
  u|up) compose_cmd="up --detach";;
  *) echo "${RED}ERROR${RESET}: Script docker-compose command '$SCRIPT_RUN_CMD' not recognized" && exit 1;;
esac

sudo docker-compose $compose_files $compose_cmd