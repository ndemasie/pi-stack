#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source ${PROJECT_DIR}/scripts/helpers/index.sh


STATE_SELECTIONS_PATH="${PROJECT_DIR}/.containers.selections"
readarray -t state_selections < $STATE_SELECTIONS_PATH

# Read all non-dot container directories into an array
readarray -t container_list < <( find $PROJECT_DIR/containers -maxdepth 1 -path ''$PROJECT_DIR'/containers/*' -type d -printf '%P\n'| sort )

## Present menu
for container in "${container_list[@]}"; do
  name=$( grep -oP 'name="\K.*(?=")' "${PROJECT_DIR}/containers/${container}/.conf" || echo $container )
  status=$( [[ "${state_selections[@]}" =~ "${container}" ]] && echo "ON" || echo "OFF" )
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
    echo "${RED}ERROR${RESET} Unable to locate ${container}/docker-compose.yml - Skipped"
    continue
  fi
  
  echo "Validating $container/docker-compose.yml config"
  docker-compose --file $docker_compose_path config --quiet

  selection+=($container)
done

## Save selections state
ensure_path $STATE_SELECTIONS_PATH
echo "Saving selections"
printf "%s\n" "${selection[@]}" >$STATE_SELECTIONS_PATH