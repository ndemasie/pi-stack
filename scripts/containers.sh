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
  echo "  menu"
  echo "    Open menu to select container set"
  echo ""
  echo "  config"
  echo "    Check docker compose configs with selected containers"
  echo ""
  echo "  down"
  echo "    Run docker compose down with selected containers"
  echo ""
  echo "  up"
  echo "    Run docker compose up with selected containers"
  echo ""
  echo "  -h | --help"
  echo "    Print options"
  echo ""
  exit 0
}

[[ $# -eq 0 ]] && echo "${RED}ERROR${RESET}: Must pass a command" && printHelp

while (("$#")); do
  case "${1,,}" in
  menu)
    runMenu
    exit 0
    ;;
  config)
    compose_files="$(getComposeFiles)"
    sudo docker-compose $compose_files config
    exit 0
    ;;
  down)
    compose_files="$(getComposeFiles)"
    sudo docker-compose $compose_files down --remove-orphans
    exit 0
    ;;
  up)
    compose_files="$(getComposeFiles)"
    sudo docker-compose $compose_files up --detach
    exit 0
    ;;
  -h | --help)
    printHelp
    ;;
  * | -* | --*)
    echo "${RED}ERROR${RESET}: Bad option '$1'" >&2
    printHelp
    exit 1
    ;;
  esac
  shift
done
