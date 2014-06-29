FROM sameersbn/ubuntu:12.04.20140628
MAINTAINER sameer@damagehead.com

RUN apt-get update && \
		apt-get install -y bind9 perl libnet-ssleay-perl openssl \
			libauthen-pam-perl libpam-runtime libio-pty-perl \
			apt-show-versions python && \
		apt-get clean # 20140625

ADD assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install
RUN /app/setup/install

ADD assets/init /app/init
RUN chmod 755 /app/init

EXPOSE 53/udp
EXPOSE 10000

VOLUME ["/app/data"]

CMD ["/app/init"]
