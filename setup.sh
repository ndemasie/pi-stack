#!/bin/bash

CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
SYS_ARCH=$(uname -m)                                    # System Architecture
TZ                                                      # Timezone

# CLI Text styling
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
bold=$(tput bold)
reset=$(tput sgr0)

# Setup steps in order of execution
RUN_STEPS=(
  do_update_pi
  do_confirm_tz
  do_packages_menu
  do_containers_menu
)

function do_validate_arm_sys_arch() {
  if [ $(echo "$SYS_ARCH" | grep -v "arm") ]; then
    echo "Only ARM architecture is supported: detected '${SYS_ARCH}'"
    exit 1
  fi
}

function do_update_pi() {
  echo "${bold}Updating Pi${reset}"
  sudo apt update -y
  sudo apt full-upgrade -y
}

function do_confirm_tz() {
  if whiptail --title "Timezone" --yesno "$(timedatectl | sed -nr '/Time zone|Universal time/p')\n\n\nSet new Timezone?" 12 75; then
    sudo raspi-config
  fi
  $TZ=$(cat /etc/timezone)
}

function do_packages_menu() {
  packages_menu_path="${CURDIR}/packages/menu.sh"
  if [ ! -e $packages_menu_path ]; then
    printf "%s\n" "${red}ERROR: Packages menu script $packages_menu_path not found${reset}"
  else
    [ ! -x $packages_menu_path ] && sudo chmod +x $packages_menu_path
    $packages_menu_path
  fi
}

function do_containers_menu() {
  containers_menu_path="${CURDIR}/containers/menu.sh"
  if [ ! -e $containers_menu_path ]; then
    printf "%s\n" "${red}ERROR: Containers menu script $containers_menu_path not found${reset}"
  else
    [ ! -x $containers_menu_path ] && sudo chmod +x $containers_menu_path
    $containers_menu_path
  fi
}

## RUN
do_validate_arm_sys_arch
echo "${bold}${yellow}Setting up your IoT stack${reset}"
for step in ${RUN_STEPS[@]}; do
  $step
done
echo "Done!"
