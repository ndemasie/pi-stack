#!/bin/bash
export CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/functions.sh
source $(dirname "$CURDIR")/helpers/variables.sh

menu_title=$'Container Selection'
menu_message=$'Use the [SPACEBAR] to select which containers you would like to run'
menu_options=()

saved_selections_file="${CURDIR}/.tmp/.save.selections"
readarray -t saved_selections < $saved_selections_file

# Read all non-dot container directories into an array
readarray -t container_array < <(find $CURDIR -maxdepth 1 -path ''$CURDIR'/[^\.]*' -type d -printf '%P\n')

####################
#       Menu       #
####################
for container in "${container_array[@]}"; do
  description=$(grep -oP "description=\K.*" "${CURDIR}/${container}/.conf")
  
  [ -z "$description" ] && description=$container
  [[ " ${saved_selections[@]} " =~ " ${container} " ]] && status="ON" || status="OFF"

  menu_options+=("$container" "$description" "$status")
done

container_selection=$(whiptail --title "$menu_title" --notags --separate-output --checklist \
  "$menu_message" 20 78 12 \
  -- "${menu_options[@]}" \
  3>&1 1>&2 2>&3)

# Exit if no selection
[ -z "$container_selection" ] && echo "No containers selected" && exit 1

## Build docker-compose.yml
echo "Saving selection"
for container in ${container_selection[@]}; do
  path="${CURDIR}/${container}/docker-compose.yml"
  [ ! -f $path ] && echo "${red}ERROR${reset}: Unable to locate ${container}/docker-compose.yml - Skipped" && continue
  
  echo "Validating $container/docker-compose.yml config"
  test=$(docker-compose -f $path config | grep "DEBUG|INFO|WARNING|ERROR|CRITICAL" -c)

  echo "TEST: $test"

  selection+=($container)
done

ensure_path $saved_selections_file
printf "%s\n" "${selection[@]}" >$saved_selections_file