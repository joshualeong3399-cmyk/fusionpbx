#!/usr/bin/env bash
# Baota (BT Panel) helper: detect BT paths and export common vars

BT_NGINX_PATH=""
BT_PHP_BASE=""
BT_PHP_VERSION=""
BT_PGSQL_PATH=""
BT_WEBROOT="/www/wwwroot/fusionpbx"

if [ -d /www/server/nginx ]; then
  BT_NGINX_PATH="/www/server/nginx"
fi

if [ -d /www/server/php ]; then
  php_ver=$(ls /www/server/php 2>/dev/null | grep -E '^[0-9]' | sort -V | tail -n1 2>/dev/null || true)
  if [ -n "$php_ver" ]; then
    BT_PHP_BASE="/www/server/php/${php_ver}"
    BT_PHP_VERSION="$php_ver"
  fi
fi

if [ -d /www/server/pgsql ]; then
  BT_PGSQL_PATH="/www/server/pgsql"
else
  # Try alternative PostgreSQL locations on Baota
  if [ -d /www/server/postgresql ]; then
    BT_PGSQL_PATH="/www/server/postgresql"
  elif [ -d /usr/lib/postgresql ]; then
    BT_PGSQL_PATH="/usr/lib/postgresql"
  elif which psql >/dev/null 2>&1; then
    BT_PGSQL_PATH=$(dirname $(which psql))
  fi
fi

find_psql() {
  if [ -n "$BT_PGSQL_PATH" ] && [ -f "${BT_PGSQL_PATH}/psql" ]; then
    echo "${BT_PGSQL_PATH}/psql"
    return 0
  elif [ -n "$BT_PGSQL_PATH" ] && [ -f "${BT_PGSQL_PATH}/bin/psql" ]; then
    echo "${BT_PGSQL_PATH}/bin/psql"
    return 0
  elif which psql >/dev/null 2>&1; then
    which psql
    return 0
  fi
  echo ""
  return 1
}

find_php_ini() {
  if [ -n "$BT_PHP_BASE" ]; then
    if [ -f "${BT_PHP_BASE}/etc/php.ini" ]; then
      echo "${BT_PHP_BASE}/etc/php.ini"
      return 0
    fi
    if [ -f "${BT_PHP_BASE}/lib/php.ini" ]; then
      echo "${BT_PHP_BASE}/lib/php.ini"
      return 0
    fi
  fi
  echo ""
  return 1
}

export BT_NGINX_PATH BT_PHP_BASE BT_PHP_VERSION BT_PGSQL_PATH BT_WEBROOT
export -f find_psql
