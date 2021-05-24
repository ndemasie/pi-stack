#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source ${PROJECT_DIR}/scripts/helpers/index.sh


# Read all "./" directory names into an array
readarray -t package_list < <(find $PROJECT_DIR/packages -mindepth 1 -maxdepth 1 -type d -printf '%P\n' | sort)

## Present menu
for package in "${package_list[@]}"; do
  status=$(has_package $package && echo "ON" || echo "OFF")
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
  is_pkg_selected=$([[ "${selections[@]}" =~ "${package}" ]] && echo true || echo false)
  is_pkg_installed=$(has_package $package &&  echo true || echo false)

  $is_pkg_selected && ! $is_pkg_installed && script=install
  $is_pkg_selected && $is_pkg_installed && script=update
  ! $is_pkg_selected && $is_pkg_installed && script=uninstall

  package_script[$package]=$script
done

## Execute action
recommend_reboot=false
for package in ${!package_script[@]}; do
  script="${package_script[$package]}"
  path="${PROJECT_DIR}/packages/${package}/${script}.sh"

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

