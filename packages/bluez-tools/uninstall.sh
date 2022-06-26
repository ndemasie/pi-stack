#!/bin/bash

echo "Uninstalling bluez-tools..."

sudo apt purge -y bluez-tools
sudo apt autoremove -y

echo "bluez-tools uninstalled"