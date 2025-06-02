#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}

SAVED_SELECTIONS_PATH="${PROJECT_DIR}/containers/.containers.selections"
SAVED_DOCKER_COMPOSE_PATH="${PROJECT_DIR}/containers/docker-compose.yml"

source "${PROJECT_DIR}/scripts/helpers/functions.sh"
source "${PROJECT_DIR}/scripts/helpers/variables.sh"
[ -z ${NO_COLOR} -o -z ${NOCOLOR} ] && source "${PROJECT_DIR}/scripts/helpers/.colors.conf"

function print_help() {
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

function get_compose_files() {
  readarray -t containers < "${SAVED_SELECTIONS_PATH}"
  for container in ${containers[@]}; do
    compose_files+=" --file ${PROJECT_DIR}/containers/${container}/docker-compose.yml"
  done
  echo "$compose_files"
}

function get_container_list() {
  # Reads all "./" directory names into an array
  find $PROJECT_DIR/containers -maxdepth 1 -path ''$PROJECT_DIR'/containers/*' -type d -printf '%P\n' | sort
}

function get_selections() {
  readarray -t saved_selections < "${SAVED_SELECTIONS_PATH}"
  readarray -t container_list < <(get_container_list)

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

function save_compose() {
  compose_files=$(get_compose_files)
  docker compose $compose_files config > $SAVED_DOCKER_COMPOSE_PATH
}

# MAIN
[[ $# -eq 0 ]] && print_help

while (("$#")); do
  case "${1,,}" in
  menu)
    selections=$(get_selections)
    [ -z "$selections" ] && echo "No containers selected" && exit 1
    printf "%s\n" ${selections[@]} > "${SAVED_SELECTIONS_PATH}"

    save_compose
    ;;
  save)
    save_compose
    ;;
  config)
    sudo docker compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      config
    ;;
  down)
    sudo docker compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      down \
      --remove-orphans
    ;;
  up)
    sudo docker compose \
      --file $SAVED_DOCKER_COMPOSE_PATH \
      up \
      --build \
      --detach
    ;;
  * | -* | --* | -h | --help)
    print_help
    exit 1
    ;;
  esac
  shift
done
