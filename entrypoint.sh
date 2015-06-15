#!/bin/bash
set -e

WEBMIN_ENABLED=${WEBMIN_ENABLED:-true}

chmod 775 ${DATA_DIR}

# create directory for bind config
mkdir -p ${BIND_DATA_DIR}
chown -R root:${BIND_USER} ${BIND_DATA_DIR}

# populate default bind configuration if it does not exist
if [ ! -d ${BIND_DATA_DIR}/etc ]; then
  mv /etc/bind ${BIND_DATA_DIR}/etc
fi
rm -rf /etc/bind
ln -sf ${BIND_DATA_DIR}/etc /etc/bind

if [ ! -d ${BIND_DATA_DIR}/lib ]; then
  mkdir -p ${BIND_DATA_DIR}/lib
  chown root:${BIND_USER} ${BIND_DATA_DIR}/lib
fi
rm -rf /var/lib/bind
ln -sf ${BIND_DATA_DIR}/lib /var/lib/bind

# create directory for webmin
mkdir -p ${WEBMIN_DATA_DIR}

# populate the default webmin configuration if it does not exist
if [ ! -d ${WEBMIN_DATA_DIR}/etc ]; then
  mv /etc/webmin ${WEBMIN_DATA_DIR}/etc
fi
rm -rf /etc/webmin
ln -sf ${WEBMIN_DATA_DIR}/etc /etc/webmin

if [ "${WEBMIN_ENABLED}" == "true" ]; then
  if [ -z "${ROOT_PASSWORD}" ]; then
    # generate a random password for root
    ROOT_PASSWORD=$(pwgen -c -n -1 12)
    echo User: root Password: $ROOT_PASSWORD
  fi
  echo "root:$ROOT_PASSWORD" | chpasswd

  echo "Starting webmin..."
  /etc/init.d/webmin start
fi

echo "Starting named..."
mkdir -m 0775 -p /var/run/named
chown root:${BIND_USER} /var/run/named

if [ -z "$@" ]; then
  exec /usr/sbin/named -u ${BIND_USER} -g
else
  exec "$@"
fi
