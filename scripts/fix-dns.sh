#!/bin/bash
# Script updates dns servers via /etc/dhcpcd.conf for Raspbian
# Reference https://pimylifeup.com/raspberry-pi-dns-settings/

DEBUG=false

DHCPCD_PATH=/etc/dhcpcd.conf
DEFAULT_DNS=(
  offset
  1.1.1.1
  1.0.0.1
)

ips=(
  $([[ "${1}" == *.*.*.* ]] && echo "${1}" || echo "${DEFAULT_DNS[1]}")
  $([[ "${2}" == *.*.*.* ]] && echo "${2}" || echo "${DEFAULT_DNS[2]}")
)
find_line="static domain_name_servers="
insert_line="static domain_name_servers=${ips[@]}"

# Print '%p' and confirm diff
diff -T --color --unified=10 \
  <(printf "%s\n" %p | ex $DHCPCD_PATH) \
  <(printf "%s\n" "0?${find_line}?a" "${insert_line}" . %p | ex $DHCPCD_PATH)

while true; do
  read -p "Approve? (y/N) " REPLY
  case "${REPLY,,}" in
  y | yes)
    [[ ! "$DEBUG" == false ]] && echo "DEBUG=true skipping write..." && break
    printf "%s\n" "0?${find_line}?a" "${insert_line}" . x | sudo ex $DHCPCD_PATH
    sudo service dhcpcd restart
    break ;;
  *)
    echo "No changes made"
    break ;;
  esac
done