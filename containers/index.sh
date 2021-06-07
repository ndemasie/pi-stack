#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source "${PROJECT_DIR}/containers/helpers.sh"

[[ $# -eq 0 ]] && showMenu

while (("$#")); do
  case "${1,,}" in
  menu)
    selections=$(showMenu)
    [ -z "$selections" ] && echo "No containers selected" && exit 1
    saveCompose
    exit 0
    ;;
  config)
    sudo docker-compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      config
    exit 0
    ;;
  down)
    sudo docker-compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      down \
      --remove-orphans
    exit 0
    ;;
  up)
    sudo docker-compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      up \
      --detach
    exit 0
    ;;
  * | -* | --* | -h | --help)
    printHelp
    exit 1
    ;;
  esac
  shift
done
