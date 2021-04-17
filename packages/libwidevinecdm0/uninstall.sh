#!/bin/bash

echo "Uninstalling widevine..."
sudo apt purge -y libwidevinecdm0
sudo apt autoremove -y
echo "widevine was uninstalled"