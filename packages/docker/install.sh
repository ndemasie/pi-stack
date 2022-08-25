#!/bin/bash

echo "Installing docker..."
curl -sSL https://get.docker.com | sh

echo "Adding docker group to ${USER}"
sudo usermod -aG docker $USER
sudo su - $USER # Logout/in for user groups to take effect

echo "Checking ${USER} groups"
groups $USER

echo "Verifying docker"
docker run hello-world

while true; do
  read -p "Enable docker system service on boot? (Y/n) " REPLY
  REPLY=${REPLY:-y}
  case "${REPLY,,}" in
    y ) sudo systemctl enable docker && break;;
    * ) break;;
  esac
done

echo "docker was installed"