#!/bin/bash
function ensure_path() {
  local filepath=${1}
  local dirpath=${filepath%/*}
  if [ ! -f $filepath ]; then
    mkdir -p $dirpath
    touch -a $filepath
  fi
}

function has_package() {
  local pkg=${1}
  if $(command -v "$pkg" >/dev/null 2>&1) || $(apt list --installed 2>&1 | grep $pkg >/dev/null)
    then true
    else false
  fi
}

function execute() {
  local path="${1}"
  shift
  local params
  local quiet=false

  # https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
  while (( "$#" )); do
    case "$1" in
      -q|--quiet) quiet=true
        ;;
      -*|--*=) echo "${RED}ERROR:${RESET} Unsupported flag ${1}" >&2
        ;;
      *) params+="${1}"
        ;;
    esac
    shift
  done

  if [ ! -e $path ]; then
    [ "$quiet" == false ] && printf "%s\n" "${RED}ERROR:${RESET} ${path} not found"
    return 1
  fi

  [ -x $path ] || sudo chmod +x $path
  bash $path $params
}