# Stop and remove running docker objects
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location

docker container stop $(docker container ls -aq)
docker system prune -a --volumes

# Remove docker-compose
$(dirname "$CURDIR")/docker-compose/uninstall.sh

sudo apt purge docker
sudo apt autoremove