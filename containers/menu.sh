#!/bin/bash
export CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh
source $(dirname "$CURDIR")/helpers/functions.sh
export TZ

menu_title=$'Container Selection'
menu_message=$'Use the [SPACEBAR] to select which containers you would like to run'
menu_options=()

saved_selections_file="${CURDIR}/.save.selections"
readarray -t saved_selections < $saved_selections_file

# Read all "./" directory names into an array
readarray -t container_array < <(find $CURDIR -mindepth 1 -maxdepth 1 -type d -printf '%P\n')

####################
#       Menu       #
####################
for container in "${container_array[@]}"; do
  description=$(grep -oP "description=\K.*" "${CURDIR}/${container}/.config")
  
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
  if [ ! -f $path ]; then
    printf "%s\n" "${red}Unable to locate ${container}/docker-compose.yml - Skipped${reset}"
  else
    selection+=($container)
  fi
done

printf "%s\n" "${selection[@]}" >$saved_selections_file

execute "${CURDIR}/generate.sh"