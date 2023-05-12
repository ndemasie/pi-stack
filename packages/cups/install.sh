#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
source "$(dirname $SCRIPT_PATH)/.conf"

echo "Installing ${name}..."
sudo apt install -y cups
sudo apt install -y avahi-daemon
echo "${name} dependencies installed"

echo "Enable web interface on port ${port}"
sudo sed -i "s/Listen localhost:${port}/Port ${port}/" /etc/cups/cupsd.conf
sudo sed -i '/DefaultAuthType Basic/a DefaultEncryption Never' /etc/cups/cupsd.conf
sudo sed -i '/<\/Location>/i Allow @local' /etc/cups/cupsd.conf

echo "Spinning up ${name} on port ${port}"
sudo service cups restart