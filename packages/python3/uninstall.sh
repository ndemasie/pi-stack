#!/bin/bash

echo "Uninstalling python3 and pip3..."

sudo apt purge -y python3 python3-pip
sudo apt autoremove -y

echo "python3/pip3 were uninstalled"