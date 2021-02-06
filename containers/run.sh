#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location

compose_file="${CURDIR}/.cmd.docker-compose"
[ ! -f $compose_file ] && ${CURDIR}/generate.sh

echo "$(< $compose_file) up -d"