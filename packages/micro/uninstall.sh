#!/bin/bash

echo "Uninstalling micro..."
if [ -f  /usr/bin/micro ]; then sudo rm /usr/bin/micro; fi
if [ -d  ~/.config/micro ]; then sudo rm -r ~/.config/micro; fi

echo "micro was uninstalled"