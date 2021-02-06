#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
echo "$(< ${CURDIR}/.cmd.docker-compose) up -d"