#!/bin/bash
CURDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")") # Sets current directory agnostic of run location
source ${CURDIR}/helpers/variables.sh

echo "Checking if branch is up to date"
git fetch origin master

if [ $(git status | grep --count "Your branch is up to date") -eq 1 ]; then
	echo "Your branch is up to date"
else
	while true; do
		read -p "${GREEN}New version available. Would you like to sync to the latest commit on master? (y/n)${NC} " REPLY
		case "${REPLY,,}" in
		y | yes) git pull origin master && break ;;
		n | no) break ;;
		*) echo "${YELLOW}Invalid input${NC}: '${REPLY}'" ;;
		esac
	done
fi
