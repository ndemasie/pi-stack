#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
source "$(dirname $SCRIPT_PATH)/.conf"

echo "Installing python3 and pip3..."
# dependencies
sudo apt install libffi-dev libssl-dev
sudo apt install -y python3 python3-pip

echo "python3/pip3 were installed"