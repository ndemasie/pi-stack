# CREDIT: https://github.com/SensorsIot/IOTstack/blob/master/.templates/zigbee2mqtt/Dockerfile
# Download base image
FROM koenkk/zigbee2mqtt

# change default configuration.yaml
# 1. expect the MQTT service to be in the Mosquitto container
# 2. enable the web front end on port 8080
RUN sed -i.bak \
   -e 's/mqtt:\/\/localhost/mqtt:\/\/mosquitto/' \
   -e '$s/$/\n\nfrontend:\n  port: 8080\n/' \
   /app/configuration.yaml

# EOF