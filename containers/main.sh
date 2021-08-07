#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}

SAVED_SELECTIONS_PATH="${PROJECT_DIR}/containers/.containers.selections"
SAVED_DOCKER_COMPOSE_PATH="${PROJECT_DIR}/containers/docker-compose.yml"

source "${PROJECT_DIR}/scripts/helpers/functions.sh"
source "${PROJECT_DIR}/scripts/helpers/variables.sh"
[ -z ${NO_COLOR} -o -z ${NOCOLOR} ] && source "${PROJECT_DIR}/scripts/helpers/.colors.conf"

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

function getComposeFiles() {
  readarray -t containers <"${SAVED_SELECTIONS_PATH}"
  for container in ${containers[@]}; do
    compose_files+=" --file ${PROJECT_DIR}/containers/${container}/docker-compose.yml"
  done
  echo "$compose_files"
}

function getContainerList() {
  # Reads all "./" directory names into an array
  find $PROJECT_DIR/containers -maxdepth 1 -path ''$PROJECT_DIR'/containers/*' -type d -printf '%P\n' | sort
}

function showMenu() {
  readarray -t saved_selections <$SAVED_SELECTIONS_PATH
  readarray -t container_list < <(getContainerList)

  for container in "${container_list[@]}"; do
    name=$(grep -oP 'name="\K.*(?=")' "${PROJECT_DIR}/containers/${container}/.conf" || echo $container)
    status=$([[ "${saved_selections[@]}" =~ "${container}" ]] && echo "ON" || echo "OFF")
    menu_options+=("$container" "$name" "$status")
  done

  selections=$(whiptail --title "Container Selection" --notags --separate-output --checklist \
    "Use the [SPACEBAR] to select which containers you would like to run" 20 78 12 \
    -- "${menu_options[@]}" \
    3>&1 1>&2 2>&3)

  echo ${selections[@]}
}

function saveCompose() {
  compose_files=$(getComposeFiles)
  docker-compose $compose_files config >$SAVED_DOCKER_COMPOSE_PATH
}

# MAIN
[[ $# -eq 0 ]] && showMenu

while (("$#")); do
  case "${1,,}" in
  menu)
    selections=$(showMenu)
    [ -z "$selections" ] && echo "No containers selected" && exit 1
    saveCompose
    ;;
  config)
    sudo docker-compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      config
    ;;
  down)
    sudo docker-compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      down \
      --remove-orphans
    ;;
  up)
    sudo docker-compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      up \
      --detach
    ;;
  * | -* | --* | -h | --help)
    printHelp
    exit 1
    ;;
  esac
  shift
done
