#!/bin/bash

if whiptail --title "Pi LCD Hat" --yesno "Are you using the LCD hat?" 12 40; then
  if whiptail --title "Install LCD Driver" --yesno "Would you like to install the LCD driver?" 12 40; then
    sudo rm -rf LCD-show
    git clone https://github.com/goodtft/LCD-show.git
    chmod -R 755 LCD-show
    cd LCD-show/
    sudo ./MHS35-show
  fi
fi

