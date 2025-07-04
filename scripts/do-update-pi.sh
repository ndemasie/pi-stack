#!/bin/bash

if whiptail --title "Software updates" --yesno "Update pi?" 12 40; then
  echo "${BOLD}Updating Pi${RESET}"
  sudo apt update -y
  sudo apt full-upgrade -y
fi