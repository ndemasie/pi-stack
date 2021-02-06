#!/bin/bash
export CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh
export TZ

env_file="${CURDIR}/.env.prod"
[ ! -f $env_file ] && env_file="${CURDIR}/.env"
[ ! -f $env_file ] && echo "${red}ERROR: No \".env\" file found${reset}" && exit 1

save_selections_file="${CURDIR}/.save.selections"
[ ! -f $save_selections_file ] && echo "No \".save\" file found. Sending to menu..." && bash ${CURDIR}/menu.sh

readarray -t selections < $save_selections_file

for container in $selections; do
  files+="-f ${CURDIR}/${container}/docker-compose.yml"
done

cmd=$"docker-compose --env-file $env_file $files"
echo $cmd > "${CURDIR}/.cmd.docker-compose"
$cmd config | grep --silent "DEBUG|INFO|WARNING|ERROR|CRITICAL"