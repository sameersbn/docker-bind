FROM sameersbn/ubuntu:12.04.20140418
MAINTAINER sameer@damagehead.com

RUN apt-get update && \
		apt-get install -y bind9 perl libnet-ssleay-perl openssl \
			libauthen-pam-perl libpam-runtime libio-pty-perl \
			apt-show-versions python && \
		apt-get clean # 20140418

ADD assets/ /app/
RUN chmod 755 /app/init /app/setup/install
RUN /app/setup/install

ADD authorized_keys /root/.ssh/

EXPOSE 53
EXPOSE 10000

VOLUME ["/app/data"]

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
