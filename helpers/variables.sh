#!/bin/bash
export version=0.0.1

# CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
SYS_ARCH=$(uname -m)  # System Architecture
TZ=$(cat /etc/timezone) # Timezone

if [ -z ${NO_COLOR} -o -z ${NOCOLOR} ]; then
	# ANSI COLORS: https://en.wikipedia.org/wiki/ANSI_escape_code
	BLACK=$'\e[0;30m'
	RED=$'\e[0;31m'
	GREEN=$'\e[0;32m'
	YELLOW=$'\e[01;33m'
	BLUE=$'\e[0;34m'
	MAGENTA=$'\e[0;35m'
	CYAN=$'\e[0;36m'
	WHITE=$'\e[0;37m'

	BRIGHT_BLACK=$'\e[0;90m'
	BRIGHT_RED=$'\e[0;91m'
	BRIGHT_GREEN=$'\e[0;92m'
	BRIGHT_YELLOW=$'\e[01933m'
	BRIGHT_BLUE=$'\e[0;94m'
	BRIGHT_MAGENTA=$'\e[0;95m'
	BRIGHT_CYAN=$'\e[0;96m'
	BRIGHT_WHITE=$'\e[0;97m'

  BOLD=$(tput bold)
  NC=$'\e[0m'
fi