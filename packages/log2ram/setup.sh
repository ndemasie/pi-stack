# CONFIG /etc/log2ram.conf

while true; do
  read -p "What size? (Default 40; Max 128) " SIZE
  SIZE=${SIZE:-40}
  if [ $SIZE -le "128" ]; then
    sudo sed -i "s/SIZE=40M/SIZE=${SIZE}M/" /etc/log2ram.conf
    break
  fi
done

# Detect rsync and disable if not found
if ( ! command -v rsync &> /dev/null ); then
  sudo sed -i "s/#USE_RSYNC=false/USE_RSYNC=false/" /etc/log2ram.conf
fi

# Ask to use rsync
# while true; do
#   read -p "User rsync? (Y/n) " RSYNC
#   RSYNC=${RSYNC:-Y}
#   case "${RSYNC,,}" in
#     y ) break;;
#     * )
#       sudo sed -i "s/#USE_RSYNC=false/USE_RSYNC=false/" /etc/log2ram.conf
#       break;;
#   esac
# done
