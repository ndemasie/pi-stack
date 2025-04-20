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
  do_validate_arm_sys_arch
  do_rotate_screen
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
  if whiptail --title "Software updates" --yesno "Update pi?" 12 60; then
    echo "${BOLD}Updating Pi${RESET}"
    sudo apt update -y
    sudo apt full-upgrade -y
  fi
}

function do_confirm_tz() {
  if whiptail --title "Timezone" --yesno "$(timedatectl | sed -nr '/Time zone|Universal time/p')\n\n\nSet new Timezone?" 12 60; then
    sudo raspi-config
  fi
}

function do_set_term_font() {
  FONTSIZE=$(whiptail --title "Font Size" --menu "Choose a font size" 12 60 5 \
      "16x32" "Large Font (16x32)" \
      "8x16" "Medium Font (8x16)" 3>&1 1>&2 2>&3)

  # Check if the user selected a font size
  if [ $? -eq 0 ]; then
      # Change the font size based on user selection
      sudo sed -i "s/FONTSIZE=\"[^\"]*\"/FONTSIZE=\"$FONTSIZE\"/" /etc/default/console-setup
      echo "Font size changed to $FONTSIZE. You may need to restart your terminal or system for changes to take effect."
  else
      echo "No font size selected. Continuing..."
  fi
}

function do_rotate_screen() {
  if whiptail --title "Screen Orientation" --yesno "Do you want to rotate the screen?" 12 60; then
    ROTATION=$(whiptail --title "Screen Orientation" --menu "Rotation:" 12 60 5 \
        "1" "(90deg)" \
        "2" "(180deg)" \
        "3" "(270deg)" 3>&1 1>&2 2>&3)

    if grep -q "^display_rotate=" /boot/config.txt; then
        sudo sed -i "s/^display_rotate=.*/display_rotate=$ROTATION/" /boot/config.txt
    else
        sudo sed -i "\$a\display_rotate=$ROTATION" /boot/config.txt
    fi
  fi
}

function do_add_bluetooth_group_to_user() {
  if id -nG "$USER" | grep -qw "bluetooth"; then
    sudo usermod -a -G bluetooth $USER
  fi
}

function do_add_env_file {
  if whiptail --title "Add .env file?" --yesno "Add .env file?" 12 60; then
    [[ ! -f .env ]] && touch .env
  fi
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


# Check if a function name is passed as an argument
if [[ -n $1 ]]; then
  $1
else
  ## RUN
  echo "${YELLOW}INFO${RESET}: Setting up your pi-stack"
  for step in ${steps[@]}; do $step; done
  echo "Setup completed!"
fi


