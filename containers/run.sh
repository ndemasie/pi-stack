#!/bin/bash
export CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh
export TZ=${TZ}

compose_file="${CURDIR}/.tmp/.cmd.docker-compose"
[ -f $compose_file ] || ${CURDIR}/generate.sh

echo "$(< $compose_file) up -d"