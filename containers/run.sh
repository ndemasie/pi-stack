#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh

STATE_SELECTIONS_PATH="${CURDIR}/.state.selections"
readarray -t state_selections < $STATE_SELECTIONS_PATH

for container in ${state_selections[@]}; do
  compose_files+=" --file ${CURDIR}/${container}/docker-compose.yml"
done

# sudo docker-compose $compose_files config
sudo docker-compose $compose_files up --detach