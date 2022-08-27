FROM eclipse-mosquitto:latest

# Add support tools
RUN apk update && apk add --no-cache rsync tzdata
COPY --chown=mosquitto:mosquitto ./volumes /volumes
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 755 /docker-entrypoint.sh

VOLUME ["/mosquitto/config", "/mosquitto/pwfile"]
