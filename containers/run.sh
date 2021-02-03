#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location

env_path="${CURDIR}/.env.prod"
[ ! -f $env_path ] && env_path="${CURDIR}/.env"
[ ! -f $env_path ] && echo "${red}ERROR: No \".env\" file found${reset}" && exit 1

save_path="${CURDIR}/.save"
[ ! -f $save_path ] && echo "No \".save\" file found. Sending to menu..." && bash ${CURDIR}/menu.sh

echo "docker-compose --env-file ${env_path} $(< ${CURDIR}/.save) up"