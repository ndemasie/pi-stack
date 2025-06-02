#!/bin/bash

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