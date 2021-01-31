#!/bin/bash

echo "Downloading Docker"
curl -sSL https://get.docker.com | sh
echo "Adding docker group to ${USER}"
sudo usermod -aG docker $USER
sudo su - $USER # Logout/in for user groups to take effect
echo "Checking ${USER} groups"
groups $USER
echo "Verifying docker"
docker run hello-world
echo "Docker was successfully installed"