#!/bin/bash
set -e

userId="$(id --user)"

if [[ "$userId" == '0' ]] && [[ -d "/mosquitto" ]]; then
   rsync -arp --ignore-existing /volumes/ "/mosquitto"
   chown -R mosquitto:mosquitto /mosquitto
fi

exec "$@"
