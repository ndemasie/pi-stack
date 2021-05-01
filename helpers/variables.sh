#!/bin/bash
SELF_CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location

export version=0.0.1

SYS_ARCH=$(uname -m)  # System Architecture
TZ=$(cat /etc/timezone) # Timezone

[ -z ${NO_COLOR} -o -z ${NOCOLOR} ] && source "${SELF_CURDIR}/.colors.conf"