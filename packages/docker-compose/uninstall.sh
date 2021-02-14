#!/bin/bash
# https://phoenixnap.com/kb/install-docker-compose-on-ubuntu-20-04

echo "Uninstalling docker-compose"
sudo rm /usr/local/bin/docker-compose
sudo apt remove docker-compose
sudo apt autoremove
