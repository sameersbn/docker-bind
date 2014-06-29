FROM sameersbn/ubuntu:12.04.20140628
MAINTAINER sameer@damagehead.com

ENV WEBMIN_VERSION 1.690
RUN apt-get update && \
		apt-get install -y bind9 perl libnet-ssleay-perl openssl \
			libauthen-pam-perl libpam-runtime libio-pty-perl \
			apt-show-versions python && \
		wget "http://prdownloads.sourceforge.net/webadmin/webmin_${WEBMIN_VERSION}_all.deb" -P /tmp/ && \
		dpkg -i /tmp/webmin_${WEBMIN_VERSION}_all.deb && rm -rf /tmp/webmin_${WEBMIN_VERSION}_all.deb && \
		apt-get clean # 20140625

ADD init /init
RUN chmod 755 /init

EXPOSE 53/udp
EXPOSE 10000
VOLUME ["/data"]
CMD ["/init"]
