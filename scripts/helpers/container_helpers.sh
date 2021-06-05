#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}

SAVED_SELECTIONS_PATH="${PROJECT_DIR}/.containers.selections"

source "${PROJECT_DIR}/scripts/helpers/functions.sh"
source "${PROJECT_DIR}/scripts/helpers/variables.sh"
[ -z ${NO_COLOR} -o -z ${NOCOLOR} ] && source "${PROJECT_DIR}/scripts/helpers/.colors.conf"


function getComposeFiles() {
  SELECTIONS_PATH="${PROJECT_DIR}/.containers.selections"
  readarray -t containers < "${SELECTIONS_PATH}"

  for container in ${containers[@]}; do
    compose_files+=" --file ${PROJECT_DIR}/containers/${container}/docker-compose.yml"
  done
  echo "$compose_files"
}

function getContainerList() {
  find $PROJECT_DIR/containers -maxdepth 1 -path ''$PROJECT_DIR'/containers/*' -type d -printf '%P\n'| sort
}

function printRunHelp() {
  echo ""
  echo "Usage:"
  echo "  -c | --config"
  echo "    Check docker compose configs with selected containers"
  echo ""
  echo "  -d | --down"
  echo "    Run docker compose down with selected containers"
  echo ""
  echo "  -u | --up"
  echo "    Run docker compose up with selected containers"
  echo ""
  echo "  -h | --help"
  echo "    Print options"
  echo ""
  exit 0
}

function runMenu() {
  readarray -t saved_selections < $SAVED_SELECTIONS_PATH
  readarray -t container_list < <(getContainerList)

  for container in "${container_list[@]}"; do
    name=$( grep -oP 'name="\K.*(?=")' "${PROJECT_DIR}/containers/${container}/.conf" || echo $container )
    status=$( [[ "${saved_selections[@]}" =~ "${container}" ]] && echo "ON" || echo "OFF" )
    menu_options+=("$container" "$name" "$status")
  done

  selections=$(whiptail --title "Container Selection" --notags --separate-output --checklist \
    "Use the [SPACEBAR] to select which containers you would like to run" 20 78 12 \
    -- "${menu_options[@]}" \
    3>&1 1>&2 2>&3)

  [ -z "$selections" ] && echo "No containers selected" && exit 1

  ## Validate selections
  for container in ${selections[@]}; do
    docker_compose_path="${PROJECT_DIR}/containers/${container}/docker-compose.yml"

    if [ ! -f $docker_compose_path ]; then
      echo "${RED}ERROR:${RESET} Unable to locate ${container}/docker-compose.yml - Skipped"
      continue
    fi
    
    echo "Validating $container/docker-compose.yml config"
    docker-compose --file $docker_compose_path config --quiet

    valid_selections+=($container)
  done

  ensure_path $SAVED_SELECTIONS_PATH
  printf "%s\n" "${valid_selections[@]}" >$SAVED_SELECTIONS_PATH
}

function runRun() {
  local param="${1}"
  case "$param" in
    -c|--config) compose_cmd="config"
      ;;
    -d|--down) compose_cmd="down --remove-orphans"
      ;;
    -u|--up) compose_cmd="up --detach"
      ;;
    -h|--help) printRunHelp
      ;;
    *|-*|--*)
      echo "${RED}ERROR:${RESET} Option '$2' not recognized"
      printRunHelp
      exit 1
      ;;
  esac

  compose_files="$(getComposeFiles)"
  sudo docker-compose $compose_files $compose_cmd
}