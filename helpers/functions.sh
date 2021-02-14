#!/bin/bash
source $(dirname -- "$(readlink -f -- "$BASH_SOURCE")")/variables.sh

function ensure_path() {
  local filepath=${1}
  local dirpath=${file%/*}
  [ ! -f $filepath ] && mkdir -p $dirpath && touch -a $filepath
}

function has_command() {
  local cmd=${1}
  command -v "$cmd" >/dev/null 2>&1
}

function execute() {
  local path
  local quiet=1 # false

  # https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
  while (( "$#" )); do
    case "$1" in
      -q|--quiet) quiet=0 && shift ;;
      -*|--*=) echo "${red}Error${reset}: Unsupported flag $1" >&2 && shift ;;
      *) path=$1 && shift ;;
    esac
  done

  if [ ! -e $path ]; then
    [ $quiet -eq 0 ] || printf "%s\n" "${red}ERROR${reset}: $path not found"
    return 1
  fi

  [ -x $path ] || sudo chmod +x $path
  bash $path
}