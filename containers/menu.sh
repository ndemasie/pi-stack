#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh
source $(dirname "$CURDIR")/helpers/functions.sh

STATE_SELECTIONS_PATH="${CURDIR}/.state.selections"
readarray -t state_selections < $STATE_SELECTIONS_PATH

# Read all non-dot container directories into an array
readarray -t container_list < <(find $CURDIR -maxdepth 1 -path ''$CURDIR'/[^\.]*' -type d -printf '%P\n')

## Present menu
for container in "${container_list[@]}"; do
  name=$(grep -oP "name=\K.*" "${CURDIR}/${container}/.conf")
  [ -z "$name" ] && name=$container
  [[ " ${state_selections[@]} " =~ " ${container} " ]] && status="ON" || status="OFF"
  menu_options+=("$container" "$name" "$status")
done

selections=$(whiptail --title "Container Selection" --notags --separate-output --checklist \
  "Use the [SPACEBAR] to select which containers you would like to run" 20 78 12 \
  -- "${menu_options[@]}" \
  3>&1 1>&2 2>&3)

[ -z "$selections" ] && echo "No containers selected" && exit 1

## Validate selections
for container in ${selections[@]}; do
  docker_compose_path="${CURDIR}/${container}/docker-compose.yml"

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