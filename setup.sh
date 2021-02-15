#!/bin/bash

# ----------------------------------------------------------------------------------------
# Scripts to maintain your pi-stack
# by Nathan DeMasie
# ----------------------------------------------------------------------------------------
#
#            _            __             __  
#     ____  (_)     _____/ /_____ ______/ /__
#    / __ \/ /_____/ ___/ __/ __ `/ ___/ //_/
#   / /_/ / /_____(__  ) /_/ /_/ / /__/ ,<   
#  / .___/_/     /____/\__/\__,_/\___/_/|_|  
# /_/                                        
#
# ----------------------------------------------------------------------------------------

CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source ${CURDIR}/helpers/functions.sh
source ${CURDIR}/helpers/variables.sh

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
}

function do_packages_menu() {
  execute "${CURDIR}/packages/menu.sh"
}

function do_containers_menu() {
  execute "${CURDIR}/containers/menu.sh"
}

## RUN
do_validate_arm_sys_arch
echo "${bold}${yellow}Setting up your IoT stack${reset}"
for step in ${RUN_STEPS[@]}; do
  $step
done
echo "Setup completed!"
