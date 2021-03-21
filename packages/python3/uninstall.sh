#!/bin/bash

echo "Uninstalling python3 and pip3..."
# skip uninstalling dependencies
# since we don't know if another program may need them
# sudo apt install libffi-dev libssl-dev
sudo apt purge -y python3 python3-pip

echo "python3/pip3 were uninstalled"