FROM eclipse-mosquitto:latest

# Add support tools
RUN apk update && apk add --no-cache rsync tzdata

ENV INITIAL_VOLUMES="initial_volumes"

COPY --chown=mosquitto:mosquitto volumes /${INITIAL_VOLUMES}
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh
