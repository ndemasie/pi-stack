#!/bin/bash
export CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/functions.sh
source $(dirname "$CURDIR")/helpers/variables.sh

saved_selections_path="${CURDIR}/.tmp/.save.selections"

# Read all non-dot container directories into an array
readarray -t container_list < <(find $CURDIR -maxdepth 1 -path ''$CURDIR'/[^\.]*' -type d -printf '%P\n')
readarray -t saved_selections < $saved_selections_path

for container in "${container_list[@]}"; do
  description=$(grep -oP "description=\K.*" "${CURDIR}/${container}/.conf")
  [ -z "$description" ] && description=$container
  [[ " ${saved_selections[@]} " =~ " ${container} " ]] && status="ON" || status="OFF"
  menu_options+=("$container" "$description" "$status")
done

selections=$(whiptail --title "Container Selection" --notags --separate-output --checklist \
  "Use the [SPACEBAR] to select which containers you would like to run" 20 78 12 \
  -- "${menu_options[@]}" \
  3>&1 1>&2 2>&3)

# Exit if no selection
[ -z "$selections" ] && echo "No containers selected" && exit 1

## Build docker-compose.yml
for container in ${selections[@]}; do
  docker_compose_path="${CURDIR}/${container}/docker-compose.yml"

  if [ ! -f $docker_compose_path ]; then
    echo "${red}ERROR${reset}: Unable to locate ${container}/docker-compose.yml - Skipped"
    continue
  fi
  
  echo "Validating $container/docker-compose.yml config"
  docker-compose --file $docker_compose_path config --quiet

  selection+=($container)
done

ensure_path $saved_selections_path
echo "Saving selections"
printf "%s\n" "${selection[@]}" >$saved_selections_path