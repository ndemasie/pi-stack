#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source $(dirname "$CURDIR")/helpers/variables.sh
source $(dirname "$CURDIR")/helpers/functions.sh

# Read all "./" directory names into an array
readarray -t package_list < <(find $CURDIR -mindepth 1 -maxdepth 1 -type d -printf '%P\n')

## Present menu
for package in "${package_list[@]}"; do
  (has_command $package) && status=("ON") || status=("OFF")
  menu_options+=("$package" "$package" "$status")
done

selections=$(whiptail --title "Install Packages" --notags --separate-output --checklist \
  "Use the [SPACEBAR] to select which packages you would like to install" 20 78 12 \
  -- "${menu_options[@]}" \
  3>&1 1>&2 2>&3)

[ -z "$selections" ] && echo "No packages selected" && exit 1

## Apply menu selection logic
declare -A package_script
for package in "${package_list[@]}"; do
  script=''
  [[ "${selections[@]}" =~ "${package}" ]] && ! (has_command $package) && script=install
  [[ "${selections[@]}" =~ "${package}" ]] && (has_command $package) && script=update
  [[ ! "${selections[@]}" =~ "${package}" ]] && (has_command $package) && script=uninstall
  package_script[$package]=$script
done

## Execute action
recommend_reboot=false
for package in ${!package_script[@]}; do
  script="${package_script[$package]}"
  path="${CURDIR}/${package}/${script}.sh"

  case $script in
    install) recommend_reboot=true && execute $path ;;
    update) execute $path --quiet;;
    uninstall) execute $path --quiet ;;
    *) ;;
  esac
done

if [ "$recommend_reboot" == true ]; then
  if (whiptail --title "Reboot Recommended" --yesno "Would you like to reboot the device?" 20 78); then
    sudo reboot
  fi
fi

