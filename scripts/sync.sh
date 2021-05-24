#!/bin/bash
SCRIPT_PATH=$(readlink -f -- "$BASH_SOURCE")
PROJECT_DIR=${SCRIPT_PATH/pi-stack*/pi-stack}
source ${PROJECT_DIR}/scripts/helpers/index.sh

cd ${PROJECT_DIR}

echo "Checking if branch is up to date"
git fetch origin master

if [ $(git status | grep --count "Your branch is up to date") -eq 1 ]; then
	echo "Your branch is up to date"
else
	while true; do
		read -p "${YELLOW}New version available. Would you like to sync to the latest commit on master? (y/n)${RESET} " REPLY
		case "${REPLY,,}" in
		y | yes) git pull origin master && break ;;
		n | no) break ;;
		*) echo "${YELLOW}WARN${RESET} Invalid input: '${REPLY}'" ;;
		esac
	done
fi
