#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source "${PROJECT_DIR}/packages/helpers.sh"

selections=$(showMenu)

[ -z "$selections" ] && echo "No packages selected" && exit 1

## Apply menu selection logic
declare -A package_script
for package in "${packages[@]}"; do
  is_pkg_selected=$([[ "${selections[@]}" =~ "${package}" ]] && echo true || echo false)
  is_pkg_installed=$(has_package $package &&  echo true || echo false)

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

