# build-env container
FROM maven:3-jdk-8-slim AS build-env

# Additional tools required for the build
RUN apt-get update -q -y && \
    apt-get install -q -y bzip2 git

# Pull and build
RUN cd /usr/src && \
    git clone https://github.com/pwm-project/pwm.git && \
    cd /usr/src/pwm && \
    mvn --batch-mode clean package

# application container
FROM adoptopenjdk/openjdk11:jre

WORKDIR /app/libs
VOLUME /config
# TLS port
EXPOSE 8443
# HTTP port
EXPOSE 8080

COPY --from=build-env /usr/src/pwm/onejar/target/* /app/libs/
COPY --from=build-env /usr/src/pwm/docker/src/main/image-files/app/* /app/
RUN chmod a+x /app/*.sh

ENTRYPOINT ["/app/startup.sh"]
