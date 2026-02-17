#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring the web server with BaoTA paths"

# Source Baota helper if present to detect BT paths and PHP version
BAOTA="$(dirname "$0")/baota.sh"
if [ -f "$BAOTA" ]; then
	# shellcheck source=/dev/null
	. "$BAOTA"
fi

# Default BaoTA (宝塔) paths (can be overridden by baota.sh)
nginx_dir="/www/server/nginx"
nginx_config_dir="/www/server/nginx/conf"
nginx_sites_available="/www/server/nginx/conf/sites-available"
nginx_sites_enabled="/www/server/nginx/conf/sites-enabled"
nginx_ssl_private_dir="/www/server/nginx/conf/ssl"
nginx_ssl_certs_dir="/www/server/nginx/conf/ssl"

if [ -n "$BT_NGINX_PATH" ]; then
	nginx_dir="$BT_NGINX_PATH"
	nginx_config_dir="$BT_NGINX_PATH/conf"
	nginx_sites_available="$BT_NGINX_PATH/conf/sites-available"
	nginx_sites_enabled="$BT_NGINX_PATH/conf/sites-enabled"
	nginx_ssl_private_dir="$BT_NGINX_PATH/conf/ssl"
	nginx_ssl_certs_dir="$BT_NGINX_PATH/conf/ssl"
	verbose "Detected Baota nginx at $BT_NGINX_PATH — skipping installation"
fi

# Create necessary directories if they don't exist
mkdir -p "$nginx_sites_available"
mkdir -p "$nginx_sites_enabled"
mkdir -p "$nginx_ssl_private_dir"

#enable fusionpbx nginx config
if [ -f "nginx/fusionpbx" ]; then
	cp nginx/fusionpbx "$nginx_sites_available/fusionpbx"
else
	verbose "Warning: nginx/fusionpbx configuration file not found"
fi

#prepare socket name for BaoTA PHP paths
if [ -f "$nginx_sites_available/fusionpbx" ]; then
	# Determine socket path. Prefer BT detected PHP version, fallback to php_version variable.
	if [ -n "$BT_PHP_VERSION" ]; then
		pv="$BT_PHP_VERSION"
	else
		pv="$php_version"
	fi
	case "$pv" in
		7.4|74)
			sed -i -e 's#unix:.*;#unix:/www/server/php/74/var/run/php-fpm.sock;#g' "$nginx_sites_available/fusionpbx"
			;;
		8.1|81)
			sed -i -e 's#unix:.*;#unix:/www/server/php/81/var/run/php-fpm.sock;#g' "$nginx_sites_available/fusionpbx"
			;;
		8.2|82)
			sed -i -e 's#unix:.*;#unix:/www/server/php/82/var/run/php-fpm.sock;#g' "$nginx_sites_available/fusionpbx"
			;;
		8.3|83)
			sed -i -e 's#unix:.*;#unix:/www/server/php/83/var/run/php-fpm.sock;#g' "$nginx_sites_available/fusionpbx"
			;;
		8.4|84)
			sed -i -e 's#unix:.*;#unix:/www/server/php/84/var/run/php-fpm.sock;#g' "$nginx_sites_available/fusionpbx"
			;;
		*)
			echo "No PHP socket mapping for version $pv, leaving config as-is" || true
			;;
	esac

	# Create symlink if it doesn't exist
	if [ ! -L "$nginx_sites_enabled/fusionpbx" ]; then
		ln -s "$nginx_sites_available/fusionpbx" "$nginx_sites_enabled/fusionpbx"
	fi
fi

# Remove default BaoTA configuration if it exists
if [ -f "$nginx_sites_enabled/default" ]; then
	rm "$nginx_sites_enabled/default"
fi

# Create self-signed certificate directories
mkdir -p "$nginx_ssl_private_dir"
mkdir -p "$nginx_ssl_certs_dir"

# Create self-signed certificate if it doesn't exist
if [ ! -f "$nginx_ssl_private_dir/nginx.key" ] || [ ! -f "$nginx_ssl_certs_dir/nginx.crt" ]; then
	verbose "Generating self-signed certificate for nginx"
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$nginx_ssl_private_dir/nginx.key" -out "$nginx_ssl_certs_dir/nginx.crt" -subj "/CN=localhost"
fi

#update config if LetsEncrypt folder is unwanted
if [ .$letsencrypt_folder = .false ]; then
	# Remove letsencrypt lines from config if present
	sed -i '/letsencrypt/d' "$nginx_sites_available/fusionpbx"
fi

#add the letsencrypt directory
if [ .$letsencrypt_folder = .true ]; then
	mkdir -p /www/wwwroot/letsencrypt/
fi

#flush systemd cache
systemctl daemon-reload

#restart nginx using BaoTA
verbose "Restarting nginx"
systemctl restart nginx || /www/server/nginx/sbin/nginx -s reload
