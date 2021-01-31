#!/bin/bash

echo "Downloading micro"
curl https://getmic.ro | bash
echo "Moving ./micro to ${USER}/usr/bin folder"
sudo mv ./micro /usr/bin