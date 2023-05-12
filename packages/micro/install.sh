#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
source "$(dirname $SCRIPT_PATH)/.conf"

echo "Installing ${name}..."
curl https://getmic.ro | bash
echo "Moving ./micro to ${USER}/usr/bin folder"
sudo mv ./micro /usr/bin

echo "${name} was installed"