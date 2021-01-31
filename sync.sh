#!/bin/bash

# CLI Text styling
yellow=$(tput setaf 3)
reset=$(tput sgr0)

echo "Checking if branch is up to date"
git fetch origin master

if [ $(git status | grep -c "Your branch is up to date") -eq 1 ]; then
	echo "Your branch is up to date"
else
	while true; do
		read -p "${yellow}New version available. Would you like to sync to the latest commit on master? (y/n)${reset} " REPLY
		case "${REPLY,,}" in
		y | yes)
			git pull origin master
			break
			;;
		n | no) break ;;
		*) echo "Invalid input: '${REPLY}'" ;;
		esac
	done
fi
