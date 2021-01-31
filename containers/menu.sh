#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location

# CLI Text styling
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

menu_title=$'Container Selection'
menu_message=$'Use the [SPACEBAR] to select which containers you would like to run'
menu_options=()

docker_compose_path="${CURDIR}/docker-compose.yml"

# Read all "./" directory names into an array
readarray -t container_array < <(find $CURDIR -mindepth 1 -maxdepth 1 -type d -printf '%P\n')

####################
#       Menu       #
####################
for container in "${container_array[@]}"; do
  ## Tests if ./docker-compose.yml exists and container matches inside
  [ -f $docker_compose_path ] && (< $docker_compose_path grep --silent "$container:") && status="ON" || status="OFF"
  menu_options+=("$container" "$container" "$status")
done

container_selection=$(whiptail --title "$menu_title" --notags --separate-output --checklist \
  "$menu_message" 20 78 12 \
  -- "${menu_options[@]}" \
  3>&1 1>&2 2>&3)

# Exit if no selection
[ -z "$container_selection" ] && echo "No containers selected" && exit 1

## Build docker-compose.yml
echo "Generating docker-compose.yml"
for container in ${container_selection[@]}; do
  path="${CURDIR}/${container}/docker-compose.yml"
  # Check if container docker-compose.yml file is found
  if [ ! -f $path ]; then
    printf "%s\n" "${red}Unable to locate ${container}/docker-compose.yml - Skipped${reset}"
  else
    container_compose_configs+=" -f ${CURDIR}/${container}/docker-compose.yml"
  fi
done

echo -e "$(docker-compose$container_compose_configs config)" >$docker_compose_path
