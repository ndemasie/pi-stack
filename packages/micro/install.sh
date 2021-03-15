#!/bin/bash

echo "Installing micro..."
curl https://getmic.ro | bash
echo "Moving ./micro to ${USER}/usr/bin folder"
sudo mv ./micro /usr/bin

echo "micro was installed"