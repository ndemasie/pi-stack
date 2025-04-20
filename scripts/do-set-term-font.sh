#!/bin/bash

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