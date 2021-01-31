#!/bin/bash

echo "Checking docker-compose dependencies"  
if ( ! command -v python3  &> /dev/null ) || ( ! command -v pip3 &> /dev/null )
then # Install python3 dependencies
  ../python3/install.sh
fi

echo "Installing docker-compose with pip3"
sudo pip3 -v install docker-compose