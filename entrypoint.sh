#!/bin/bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

file_env 'ROOT_PASSWORD'

ROOT_PASSWORD=${ROOT_PASSWORD:-password}
WEBMIN_ENABLED=${WEBMIN_ENABLED:-true}
WEBMIN_INIT_SSL_ENABLED=${WEBMIN_INIT_SSL_ENABLED:-true}
WEBMIN_INIT_REDIRECT_PORT=${WEBMIN_INIT_REDIRECT_PORT:-10000}
WEBMIN_INIT_REFERERS=${WEBMIN_INIT_REFERERS:-NONE}

BIND_DATA_DIR=${DATA_DIR}/bind
WEBMIN_DATA_DIR=${DATA_DIR}/webmin

create_bind_data_dir() {
  mkdir -p ${BIND_DATA_DIR}

  # populate default bind configuration if it does not exist
  if [ ! -d ${BIND_DATA_DIR}/etc ]; then
    mv /etc/bind ${BIND_DATA_DIR}/etc
  fi
  rm -rf /etc/bind
  ln -sf ${BIND_DATA_DIR}/etc /etc/bind
  chmod -R 0775 ${BIND_DATA_DIR}
  chown -R ${BIND_USER}:${BIND_USER} ${BIND_DATA_DIR}

  if [ ! -d ${BIND_DATA_DIR}/lib ]; then
    mkdir -p ${BIND_DATA_DIR}/lib
    chown ${BIND_USER}:${BIND_USER} ${BIND_DATA_DIR}/lib
  fi
  rm -rf /var/lib/bind
  ln -sf ${BIND_DATA_DIR}/lib /var/lib/bind
}

create_webmin_data_dir() {
  mkdir -p ${WEBMIN_DATA_DIR}
  chmod -R 0755 ${WEBMIN_DATA_DIR}
  chown -R root:root ${WEBMIN_DATA_DIR}

  # populate the default webmin configuration if it does not exist
  if [ ! -d ${WEBMIN_DATA_DIR}/etc ]; then
    mv /etc/webmin ${WEBMIN_DATA_DIR}/etc
  fi
  rm -rf /etc/webmin
  ln -sf ${WEBMIN_DATA_DIR}/etc /etc/webmin
}

disable_webmin_ssl() {
  sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
}

set_webmin_redirect_port() {
  echo "redirect_port=$WEBMIN_INIT_REDIRECT_PORT" >> /etc/webmin/miniserv.conf
}

set_webmin_referers() {
  echo "referers=$WEBMIN_INIT_REFERERS" >> /etc/webmin/config
}

set_root_passwd() {
  echo "root:$ROOT_PASSWORD" | chpasswd
}

create_pid_dir() {
  mkdir -p /var/run/named
  chmod 0775 /var/run/named
  chown root:${BIND_USER} /var/run/named
}

create_bind_cache_dir() {
  mkdir -p /var/cache/bind
  chmod 0775 /var/cache/bind
  chown root:${BIND_USER} /var/cache/bind
}

first_init() {
  if [ ! -f /data/.initialized ]; then
    set_webmin_redirect_port
    if [ "${WEBMIN_INIT_SSL_ENABLED}" == "false" ]; then
      disable_webmin_ssl
    fi
    if [ "${WEBMIN_INIT_REFERERS}" != "NONE" ]; then
      set_webmin_referers
    fi
    touch /data/.initialized
  fi
}

create_pid_dir
create_bind_data_dir
create_bind_cache_dir

# allow arguments to be passed to named
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$*"
  set --
elif [[ ${1} == named || ${1} == "$(command -v named)" ]]; then
  EXTRA_ARGS="${*:2}"
  set --
fi

# default behaviour is to launch named
if [[ -z ${1} ]]; then
  if [ "${WEBMIN_ENABLED}" == "true" ]; then
    create_webmin_data_dir
    first_init
    set_root_passwd
    echo "Starting webmin..."
    /etc/init.d/webmin start
  fi

  echo "Starting named..."
  exec "$(command -v named)" -u ${BIND_USER} -g ${EXTRA_ARGS}
else
  exec "$@"
fi
