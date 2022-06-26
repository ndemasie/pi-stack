ARG hacs

FROM ghcr.io/home-assistant/raspberrypi4-homeassistant:stable

# Install HACS: https://hacs.xyz/docs/installation/installation/
RUN cd /config
RUN \
if [[ "$hacs" == true ]] && [[ ! -d /config/custom_components ]]; then \
  echo "INFO: Installing HACS..."; \
  wget -q -O - https://get.hacs.xyz | bash -; \
fi
