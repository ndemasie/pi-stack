#!/bin/bash
export version=0.0.1

# CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
SYS_ARCH=$(uname -m)  # System Architecture
TZ=$(cat /etc/timezone) # Timezone

if [ -z ${NO_COLOR} -o -z ${NOCOLOR} ]; then
	# ANSI COLORS: https://en.wikipedia.org/wiki/ANSI_escape_code
	BLACK=$'\e[30m'
	RED=$'\e[31m'
	GREEN=$'\e[32m'
	YELLOW=$'\e[01;33m'
	BLUE=$'\e[34m'
	MAGENTA=$'\e[35m'
	CYAN=$'\e[36m'
	WHITE=$'\e[37m'

	BRIGHT_BLACK=$'\e[90m'
	BRIGHT_RED=$'\e[91m'
	BRIGHT_GREEN=$'\e[92m'
	BRIGHT_YELLOW=$'\e[01933m'
	BRIGHT_BLUE=$'\e[94m'
	BRIGHT_MAGENTA=$'\e[95m'
	BRIGHT_CYAN=$'\e[96m'
	BRIGHT_WHITE=$'\e[97m'

	# SGR (Select Graphic Rendition) parameters
  NC=$'\e[0m'
  BOLD=$'\e[1m'
	FAINT=$'\e[2m'
	ITALIC=$'\e[3m'
	UNDERLINE=$'\e[4m'
fi