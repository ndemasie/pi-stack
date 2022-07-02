FROM ghcr.io/home-assistant/raspberrypi4-homeassistant:stable

# Must be declared after FROM: https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG HACS

# BUG: Seems to be a network issue while setting up the container
#  I can both curl and wget in the container after it's built
#  but fails with a DNS resolution error while building
# 
# Install HACS: https://hacs.xyz/docs/installation/installation/
# RUN \
# if [[ "$HACS" == true ]] && [[ ! -d /config/custom_components ]]; then \
#   echo "INFO: Installing HACS..."; \
#   cd /config; \
#   # curl -L https://get.hacs.xyz; \
#   # wget --quiet -O - https://get.hacs.xyz | bash -; \
# fi