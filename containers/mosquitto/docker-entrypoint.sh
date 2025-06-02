#!/bin/sh
set -e

userId="$(id -u)"

if [[ "$userId" == '0' ]] && [[ -d "/mosquitto" ]]; then
   rsync -arp --ignore-existing /volumes/ "/mosquitto"
   chown -Rc mosquitto:mosquitto /mosquitto
   chmod -c 600 ./mosquitto/pwfile/pwfile
fi

exec "$@"
