FROM ubuntu:20.04 AS add-apt-repositories

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y curl gnupg \
 && curl -sSL http://www.webmin.com/jcameron-key.asc | apt-key add \
 && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list

FROM ubuntu:20.04

ENV BIND_USER=bind \
    BIND_VERSION=9.16.1 \
    WEBMIN_VERSION=2.010 \
    DATA_DIR=/data

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg
COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list
COPY entrypoint.sh /entrypoint.sh

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
      webmin=${WEBMIN_VERSION}* \
      cron \
 && rm -rf /var/lib/apt/lists/* \
 && chmod 755 /entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/sbin/named"]
