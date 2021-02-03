#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/.variables

menu_title=$'Install Packages'
menu_message=$'Use the [SPACEBAR] to select which packages you would like to install'
menu_options=()

# Read all "./" directory names into an array
readarray -t package_array < <(find $CURDIR -mindepth 1 -maxdepth 1 -type d -printf '%P\n')

function hasCommand() {
  local cmd=$@
  command -v "$cmd" >/dev/null 2>&1
}

function execute() {
  local path=${1}
  [ ! -x $path ] && sudo chmod +x $path
  $path
}

####################
#       Menu       #
####################
for package in "${package_array[@]}"; do
  (hasCommand $package) && status=("ON") || status=("OFF")
  menu_options+=("$package" "$package" "${status}")
done

package_selection=$(whiptail --title "$menu_title" --notags --separate-output --checklist \
  "$menu_message" 20 78 12 \
  -- "${menu_options[@]}" \
  3>&1 1>&2 2>&3)

# Exit if no selection
[ -z "$package_selection" ] && echo "No packages selected" && exit 1

## Install
for package in ${package_selection[@]}; do
  script="install"
  (hasCommand $package) && script="update"
  path=${CURDIR}/${package}/${script}.sh

  if [ ! -f $path ]; then
    printf "%s\n" "${path} not found"
    printf "%s\n" "${yellow}WARN: Skipping ${package} ${script}${reset}"
    continue
  fi

  printf "%s\n" "${green}Running ${script} script ${path}...${reset}"
  # execute $path
  echo "Successfully ran script"
done

if (whiptail --title "Restart Required" --yesno "Would you like to reboot the device?" 20 78); then
  sudo reboot
fi
