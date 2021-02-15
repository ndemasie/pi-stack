#!/bin/bash
export version=0.0.1

# CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
SYS_ARCH=$(uname -m)  # System Architecture
TZ=$(cat /etc/timezone) # Timezone

if [ -z ${NO_COLOR} -o -z ${NOCOLOR} ]; then
	#COLOR OUTPUT FOR RICH OUTPUT
	ORANGE=$'\e[1;33m'
	RED=$'\e[1;31m'
	NC=$'\e[0m'
	GREEN=$'\e[1;32m'
	PURPLE=$'\e[1;35m'
	BLUE=$'\e[1;34m'
	CYAN=$'\e[1;36m'
	YELLOW=$'\e[01;33m'
	REPEAT=$'\e[1A'
  red=$(tput setaf 1)
  green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  bold=$(tput bold)
  reset=$(tput sgr0)
fi