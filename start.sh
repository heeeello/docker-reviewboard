#!/bin/bash

MYSQL_USER="${MYSQL_USER:-reviewboard}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-reviewboard}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-reviewboard}"
MYSQL_DATABASE="${MYSQL_DATABASE:-reviewboard}"

# Get these variables either from MYSQLPORT and MYSQLHOST, or from
# linked "mysql" container.
MYSQL_PORT="${MYSQL_PORT:-$( echo "${MYSQL_PORT_3306_TCP_PORT:-3306}" )}"
MYSQL_HOST="${MYSQL_HOST:-$( echo "${MYSQL_PORT_3306_TCP_ADDR:-127.0.0.1}" )}"

# Get these variable either from MEMCACHED env var, or from
# linked "memcached" container.
MEMCACHED_LINKED_NOTCP="${MEMCACHED_PORT#tcp://}"
MEMCACHED="${MEMCACHED:-$( echo "${MEMCACHED_LINKED_NOTCP:-127.0.0.1}" )}"

DOMAIN="${DOMAIN:localhost}"
DEBUG="$DEBUG"

mkdir -p /var/www/

CONFFILE=/var/www/reviewboard/conf/settings_local.py

if [[ ! -d /var/www/reviewboard ]]; then
    rb-site install --noinput \
        --domain-name="$DOMAIN" \
        --site-root=/ --static-url=static/ --media-url=media/ \
        --db-type=mysql \
        --db-name="$MYSQL_DATABASE" \
        --db-host="$MYSQL_HOST" \
        --db-user="$MYSQL_USER" \
        --db-pass="$MYSQL_PASSWORD" \
        --cache-type=memcached --cache-info="$MEMCACHED" \
        --web-server-type=lighttpd --web-server-port=8000 \
        --admin-user=admin --admin-password=admin --admin-email=admin@example.com \
        /var/www/reviewboard/
fi
if [[ "$DEBUG" ]]; then
    sed -i 's/DEBUG *= *False/DEBUG=True/' "$CONFFILE"
fi

cat "$CONFFILE"

exec uwsgi --ini /uwsgi.ini
