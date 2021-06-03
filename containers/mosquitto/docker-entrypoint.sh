#!/bin/bash
set -e

userId="$(id -u)"

if [[ "$userId" == '0' ]] && [[ -d "/mosquitto" ]]; then
   rsync -arp --ignore-existing /${INITIAL_VOLUMES}/ "/mosquitto"
   chown -R mosquitto:mosquitto /mosquitto
fi

exec "$@"