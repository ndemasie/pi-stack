#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh

SCRIPT_RUN_CMD=${1,,}

STATE_SELECTIONS_PATH="${CURDIR}/.state.selections"
readarray -t state_selections < $STATE_SELECTIONS_PATH

for container in ${state_selections[@]}; do
  compose_files+=" --file ${CURDIR}/${container}/docker-compose.yml"
done

case $SCRIPT_RUN_CMD in
  c|config) compose_cmd="config";;
  d|down) compose_cmd="down";;
  u|up) compose_cmd="up --detach";;
  *) echo "${RED}ERROR${RESET}: Script docker-compose command '$SCRIPT_RUN_CMD' not recognized" && exit 1;;
esac

sudo docker-compose $compose_files $compose_cmd