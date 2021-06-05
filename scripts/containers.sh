#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source "${PROJECT_DIR}/scripts/helpers/functions.sh"
source "${PROJECT_DIR}/scripts/helpers/variables.sh"
[ -z ${NO_COLOR} -o -z ${NOCOLOR} ] && source "${PROJECT_DIR}/scripts/helpers/.colors.conf"
source "${PROJECT_DIR}/scripts/helpers/container_helpers.sh"

function printHelp() {
  echo ""
  echo "Usage:"
  echo "  run"
  echo "    Run a docker compose command on the containers"
  echo ""
  echo "  -h | --help"
  echo "    Print options"
  echo ""
  exit 0
}

[[ $# -eq 0 ]] && echo "${RED}ERROR:${RESET} Must pass a command" && printHelp

while (( "$#" )); do
  case "${1,,}" in
    menu)
      runMenu
      exit 0
      ;;
    run)
      runRun $2
      exit 0
      ;;
    -h|--help)
      printHelp
      ;;
    *|-*|--*)
      echo "${RED}ERROR:${RESET} Bad option '$1'" >&2
      printHelp
      exit 1
      ;;
  esac
  shift
done