#!/bin/bash
set -e

# script variables
BIND_DATA_DIR=${DATA_DIR}/bind
WEBMIN_DATA_DIR=${DATA_DIR}/webmin

# configuration variables
WEBMIN_ENABLED=${WEBMIN_ENABLED:-true}

## ...and here we go
chmod 755 ${DATA_DIR}

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

# create /var/run/named
mkdir -m 0775 -p /var/run/named
chown root:${BIND_USER} /var/run/named

if [ "${WEBMIN_ENABLED}" == "true" ]; then
  # create directory for webmin
  mkdir -p ${WEBMIN_DATA_DIR}

  # populate the default webmin configuration if it does not exist
  if [ ! -d ${WEBMIN_DATA_DIR}/etc ]; then
    mv /etc/webmin ${WEBMIN_DATA_DIR}/etc
  fi
  rm -rf /etc/webmin
  ln -sf ${WEBMIN_DATA_DIR}/etc /etc/webmin

  # generate a random password for root
  if [ -z "${ROOT_PASSWORD}" ]; then
    ROOT_PASSWORD=$(pwgen -c -n -1 12)
    echo User: root Password: $ROOT_PASSWORD
  fi
  echo "root:$ROOT_PASSWORD" | chpasswd

  echo "Starting webmin..."
  /etc/init.d/webmin start
fi

if [ -z "$@" ]; then
  echo "Starting named..."
  exec /usr/sbin/named -u ${BIND_USER} -g
else
  exec "$@"
fi
