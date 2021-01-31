# Pi-Server

Automated setup and management for open source packages and Docker containers on a rasberrypi.

Many thanks to the [IOTstack](https://github.com/gcgarner/IOTstack) project for much of the inspiration.

## Containers

| Key | Name | Description |
| --- | --- | --- |
| homeassistant | [HomeAssistant](https://www.home-assistant.io/) | Home automation server |
| mosquitto | [Eclipse Mosquitto](https://mosquitto.org/) | MQTT message broker |
| pihole | [PiHole](https://pi-hole.net/) [github](https://github.com/pi-hole/pi-hole/#one-step-automated-install) | Network-wide Add Blocking |

<sub>More container ideas from [IOTstack](https://github.com/gcgarner/IOTstack/blob/9a308a7f93f81d02e948a826cb8eac3cfe590e67/menu.sh#L9-L36)</sub>

## Packages

| Command | Name | Description |
| --- | --- | --- |
| docker | [Docker](https://docs.docker.com/) | Containers |
| docker-compose | [Docker Compose](https://github.com/docker/compose) | Tool for running multi-container applications |
| git | [Git](https://git-scm.com/) | Version contral system |
| log2ram | [log2ram](https://github.com/azlux/log2ram) | Like ramlog for systemd. <br> Usefull for RaspberryPi for not writing on the SD card all the time. |
| micro | [micro](https://github.com/zyedidia/micro) | Minimal text editor |
| python3 | Python3 | Python3 with Pip3 |
