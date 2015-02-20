FROM sameersbn/ubuntu:14.04.20150220
MAINTAINER sameer@damagehead.com

ENV WEBMIN_VERSION 1.720
RUN rm -rf /etc/apt/apt.conf.d/docker-gzip-indexes \
 && apt-get update \
 && apt-get install -y bind9 perl libnet-ssleay-perl openssl \
      libauthen-pam-perl libpam-runtime libio-pty-perl \
      apt-show-versions python pwgen \
 && wget "http://prdownloads.sourceforge.net/webadmin/webmin_${WEBMIN_VERSION}_all.deb" -P /tmp/ \
 && dpkg -i /tmp/webmin_${WEBMIN_VERSION}_all.deb \
 && rm -rf /tmp/webmin_${WEBMIN_VERSION}_all.deb \
 && rm -rf /var/lib/apt/lists/* # 20150220

ADD start /start
RUN chmod 755 /start

EXPOSE 53/udp
EXPOSE 10000
VOLUME ["/data"]
CMD ["/start"]
