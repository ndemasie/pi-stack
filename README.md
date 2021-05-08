# Pi-Stack

Automated setup and management for open source packages and Docker containers on a rasberrypi.

Many thanks to the [gcgarner/IOTstack](https://github.com/gcgarner/IOTstack) and forked [SensorsIot/IOTstack](https://github.com/SensorsIot/IOTstack) projects for much of the inspiration.

## Containers

| Image | Name | Description | Notes |
| --- | --- | --- | --- |
| [homeassistant](https://hub.docker.com/r/homeassistant/home-assistant) | [Home Assistant](https://www.home-assistant.io) | Home automation server | [docs](https://www.home-assistant.io/docs) <br>[github](https://github.com/home-assistant/core) |
| [homebridge](https://hub.docker.com/r/oznu/homebridge) | [Homebridge](https://homebridge.io) | iOS HomeKit API emulator | [docs](https://github.com/homebridge/homebridge/wiki) <br>[github](https://github.com/oznu/docker-homebridge) |
| [mosquitto](https://hub.docker.com/_/eclipse-mosquitto) | [Eclipse-Mosquitto](https://mosquitto.org) | MQTT message broker | [github](https://github.com/eclipse/mosquitto) |
| [pihole](https://hub.docker.com/r/pihole/pihole) | [Pi-Hole](https://pi-hole.net) | Network-wide Ad Blocking | [github](https://github.com/pi-hole/pi-hole) |
| [portainer-ce](https://hub.docker.com/r/portainer/portainer-ce) | [Portainer CE (Community Edition)](https://www.portainer.io) | Container management service | [docs](https://documentation.portainer.io) <br>[github](https://github.com/portainer/portainer) |
| [zigbee2mqtt](https://hub.docker.com/r/koenkk/zigbee2mqtt) | [Zigbee2MQTT](https://www.zigbee2mqtt.io) | Zigbee to MQTT bridge | [github](https://github.com/koenkk/zigbee2mqtt) |


<sub>More container ideas available from [IOTstack](https://github.com/SensorsIot/IOTstack/tree/master/.templates)</sub>

## Packages

| Command | Name | Description |
| --- | --- | --- |
| docker | [Docker](https://docs.docker.com/) | Containers |
| docker-compose | [Docker Compose](https://github.com/docker/compose) | Tool for running multi-container applications |
| git | [Git](https://git-scm.com/) | Version contral system |
| libwidevinecdm0 | Widevine | DRM library used by Netflix et. al. |
| log2ram | [log2ram](https://github.com/azlux/log2ram) | Like ramlog for systemd. <br> Reduces SD card writes on RaspberryPi. |
| micro | [micro](https://github.com/zyedidia/micro) | Minimal text editor |
| python3 | Python3 | Python3 with Pip3 |

