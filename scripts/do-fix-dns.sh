#!/bin/bash
# Script updates dns servers via /etc/dhcpcd.conf for Raspbian
# Reference https://pimylifeup.com/raspberry-pi-dns-settings/

DEBUG=false

DHCPCD_PATH="/etc/dhcpcd.conf"
DEFAULT_DNS=("1.1.1.1" "1.0.0.1")
DNS1="${1:-${DEFAULT_DNS[0]}}"
DNS2="${2:-${DEFAULT_DNS[1]}}"

FIND_LINE="static domain_name_servers="
INSERT_LINE="static domain_name_servers=${DNS1} ${DNS2}"

# Show proposed changes
if grep -q "$FIND_LINE" "$DHCPCD_PATH"; then
  echo "Existing DNS configuration found:"
  grep "$FIND_LINE" "$DHCPCD_PATH"
  echo "Proposed change:"
  echo "$INSERT_LINE"
else
  echo "No existing DNS configuration found. Adding:"
  echo "$INSERT_LINE"
fi

# Debug or apply changes
if $DEBUG; then
  echo "DEBUG MODE: No changes applied."
else
  read -p "Approve changes? (y/N): " REPLY
  if [[ "${REPLY,,}" == "y" || "${REPLY,,}" == "yes" ]]; then
    sudo sed -i "/$FIND_LINE/d" "$DHCPCD_PATH"
    echo "$INSERT_LINE" | sudo tee -a "$DHCPCD_PATH" > /dev/null
    echo "Changes applied. Restarting DHCP service..."
    sudo service dhcpcd restart
  else
    echo "No changes made."
  fi
fi
