FROM eclipse-mosquitto:latest

# see https://github.com/alpinelinux/docker-alpine/issues/98
RUN sed -i 's/https/http/' /etc/apk/repositories

# Add support tools
RUN apk update && apk add --no-cache rsync tzdata

COPY --chown=mosquitto:mosquitto ./volumes /volumes
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 755 /docker-entrypoint.sh

VOLUME ["/mosquitto/config", "/mosquitto/pwfile"]
