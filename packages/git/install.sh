#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
source "$(dirname $SCRIPT_PATH)/.conf"

echo "Installing ${name}..."
sudo apt install git -y

echo "${name} was installed"