#!/bin/bash

echo "Uninstalling git..."
sudo apt purge git
sudo apt autoremove

if [ -f /home/$USER/.gitconfig ]; then
  while true; do
    read -p "Removed Git: Remove '/home/$USER/.gitconfig\'? (y/n) " -t 10 REPLY
    case "${REPLY,,}" in
    y | yes) rm /home/$USER/.gitconfig && break ;;
    n | no) break ;;
    '') break ;;
    *) echo "${yellow}Invalid input${reset}: '${REPLY}'" ;;
    esac
  done
fi

echo "git was uninstalled"