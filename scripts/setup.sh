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

SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source ${PROJECT_DIR}/scripts/helpers/index.sh

# Setup steps in order of execution
steps=(
  do_update_pi
  do_confirm_tz
  do_fix_dns
  # do_add_bluetooth_group_to_user
  do_add_env_file
  do_packages_menu
  do_containers_menu
)

function do_validate_arm_sys_arch() {
  if [ $(echo "$SYS_ARCH" | grep -v "arm") ]; then
    echo "${RED}ERROR${RESET} Only ARM architecture is supported: detected '${SYS_ARCH}'"
    exit 1
  fi
}

function do_update_pi() {
  echo "${BOLD}Updating Pi${RESET}"
  sudo apt update -y
  sudo apt full-upgrade -y
}

function do_confirm_tz() {
  if whiptail --title "Timezone" --yesno "$(timedatectl | sed -nr '/Time zone|Universal time/p')\n\n\nSet new Timezone?" 12 75; then
    sudo raspi-config
  fi
}

function do_add_bluetooth_group_to_user() {
  if id -nG "$USER" | grep -qw "bluetooth"; then
    sudo usermod -a -G bluetooth $USER
  fi
}

function do_add_env_file {
  [[ ! -f .env ]] && touch .env
}

function do_packages_menu() {
  execute "${PROJECT_DIR}/packages/main.sh"
}

function do_containers_menu() {
  execute "${PROJECT_DIR}/containers/main.sh"
}

function do_fix_dns() {
  execute "${PROJECT_DIR}/scripts/fix-dns.sh"
}

## RUN
do_validate_arm_sys_arch
echo "${YELLOW}INFO${RESET}: Setting up your pi-stack"
for step in ${steps[@]}; do $step; done
echo "Setup completed!"
