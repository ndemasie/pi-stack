#!/bin/bash
source $(dirname -- "$(readlink -f -- "$BASH_SOURCE")")/variables.sh

function hasCommand() {
  local cmd=$@
  command -v "$cmd" >/dev/null 2>&1
}

function execute() {
  local path=${1}
  [ ! -e $path ] && printf "%s\n" "${red}ERROR${reset}: $path not found" && return 1
  [ -x $path ] || sudo chmod +x $path
  $path
}