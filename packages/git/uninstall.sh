#!/bin/bash

sudo apt purge git
sudo apt autoremove

while true; do
  read -p "Removed Git: Remove '/home/$USER/.gitconfig\'? (y/n) " -t 10 REPLY
  case "${REPLY,,}" in
  # y | yes) rm /home/$USER/.gitconfig && break ;;
  y | yes) echo "removing file" && break ;;
  n | no) break ;;
  '') break ;;
  *) echo "${yellow}Invalid input${reset}: '${REPLY}'" ;;
  esac
done