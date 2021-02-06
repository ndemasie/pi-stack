#!/bin/bash
# CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
SYS_ARCH=$(uname -m)  # System Architecture
TZ=$(cat /etc/timezone) # Timezone

# CLI Text styling
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
bold=$(tput bold)
reset=$(tput sgr0)