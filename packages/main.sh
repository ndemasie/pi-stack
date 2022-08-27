#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}

source "${PROJECT_DIR}/scripts/helpers/functions.sh"
source "${PROJECT_DIR}/scripts/helpers/variables.sh"
[ -z ${NO_COLOR} -o -z ${NOCOLOR} ] && source "${PROJECT_DIR}/scripts/helpers/.colors.conf"

function get_package_list() {
  # Read all "./" directory names into an array
  find $PROJECT_DIR/packages -mindepth 1 -maxdepth 1 -type d -printf '%P\n' | sort
}

function get_selections() {
  readarray -t packages < <(get_package_list)
  ## Present menu
  for package in "${packages[@]}"; do
    name=$(grep -oP 'name="\K.*(?=")' "${PROJECT_DIR}/packages/${package}/.conf" || echo $package)
    status=$(has_package $package && echo "ON" || echo "OFF")
    menu_options+=("$package" "$name" "$status")
  done

  selections=$(whiptail --title "Install Packages" --notags --separate-output --checklist \
    "Use the [SPACEBAR] to select which packages you would like to install" 20 78 12 \
    -- "${menu_options[@]}" \
    3>&1 1>&2 2>&3)

  echo ${selections[@]}
}

# MAIN
selections=$(get_selections)

[ -z "$selections" ] && echo "No packages selected" && exit 1

## Apply menu selection logic
declare -A package_script
for package in "${packages[@]}"; do
  is_pkg_selected=$([[ "${selections[@]}" =~ "${package}" ]] && echo true || echo false)
  is_pkg_installed=$(has_package $package && echo true || echo false)

  if $is_pkg_selected && ! $is_pkg_installed; then
    package_script[$package]=install
  elif $is_pkg_selected && $is_pkg_installed; then
    package_script[$package]=update
  elif ! $is_pkg_selected && $is_pkg_installed; then
    package_script[$package]=uninstall
  fi
done

## Execute action
for package in ${!package_script[@]}; do
  script="${package_script[$package]}"
  path="${PROJECT_DIR}/packages/${package}/${script}.sh"

  case $script in
  install) recommend_reboot=true && execute $path ;;
  update) execute $path --quiet ;;
  uninstall) execute $path --quiet ;;
  *) ;;
  esac
done

if [[ "${recommend_reboot:-false}" == true ]]; then
  if (whiptail --title "Reboot Recommended" --yesno "Would you like to reboot the device?" 20 78); then
    sudo reboot
  fi
fi
