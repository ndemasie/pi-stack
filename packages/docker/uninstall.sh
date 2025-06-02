# Stop and remove running docker objects
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}

echo "Stopping docker containers"
docker container stop $(docker container ls -aq)
docker system prune -a --volumes

echo "Uninstalling docker..."
sudo apt purge docker
sudo apt autoremove -y

echo "docker was uninstalled"