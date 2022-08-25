#!/bin/bash

# Install dependency (recommended for performance)
sudo apt install rsync

# Install Log2Ram with APT
echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ bullseye main" | sudo tee /etc/apt/sources.list.d/azlux.list
sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg  https://azlux.fr/repo.gpg
sudo apt update
sudo apt install log2ram

# # Install Log2Ram manually (not recommended)
# wget https://github.com/azlux/log2ram/archive/master.tar.gz -O log2ram.tar.gz
# tar xf log2ram.tar.gz

# (cd /home/${USER}/log2ram-master && sudo ./install.sh)