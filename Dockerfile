FROM ubuntu:xenial-20180525
MAINTAINER sameer@damagehead.com

ENV BIND_USER=bind \
    BIND_VERSION=9.10.3 \
    WEBMIN_VERSION=1.8 \
    DATA_DIR=/data

RUN apt-key adv --fetch-keys http://www.webmin.com/jcameron-key.asc \
 && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list \
 && rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      bind9=1:${BIND_VERSION}* bind9-host=1:${BIND_VERSION}* dnsutils \
      webmin=${WEBMIN_VERSION}* \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/named"]
