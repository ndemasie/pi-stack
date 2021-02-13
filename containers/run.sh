#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh

save_selections_file="${CURDIR}/.tmp/.save.selections"
[ -f $save_selections_file ] || ${CURDIR}/generate.sh

readarray -t selections < $save_selections_file
for container in ${selections[@]}; do
  compose_files+=" --file ${CURDIR}/${container}/docker-compose.yml"
done

sudo docker-compose $compose_files config
# sudo docker-compose $compose_files up --detach