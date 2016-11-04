FROM sameersbn/ubuntu:14.04.20161014
MAINTAINER sameer@damagehead.com

ENV DATA_DIR=/data \
    BIND_USER=bind \
    WEBMIN_VERSION=1.820

RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && wget http://www.webmin.com/jcameron-key.asc -qO - | apt-key add - \
 && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 webmin=${WEBMIN_VERSION}* \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 53/udp 53/tcp 10000/tcp
VOLUME ["${DATA_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/named"]
