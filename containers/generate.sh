# #!/bin/bash
# export CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
# source $(dirname "$CURDIR")/helpers/functions.sh
# source $(dirname "$CURDIR")/helpers/variables.sh
# export TZ

# env_file="${CURDIR}/.env.prod"
# [ ! -f $env_file ] && env_file="${CURDIR}/.env"
# [ ! -f $env_file ] && echo "${red}ERROR${reset}: No \".env\" file found" && exit 1

# save_selections_file="${CURDIR}/.tmp/.save.selections"
# [ ! -f $save_selections_file ] && echo "${red}ERROR${reset}: No selections found. Sending to menu..." && bash ${CURDIR}/menu.sh

# readarray -t selections < $save_selections_file

# for container in ${selections[@]}; do
#   compose_files+=" -f ${CURDIR}/${container}/docker-compose.yml"
# done

# cmd=$"docker-compose --env-file $env_file $compose_files"
# # ${cmd} config | grep --silent "DEBUG|INFO|WARNING|ERROR|CRITICAL"
# ${cmd} config

# cmd_save_path="${CURDIR}/.tmp/.cmd.docker-compose"
# ensure_path $cmd_save_path
# printf "%s" "${cmd}" > $cmd_save_path