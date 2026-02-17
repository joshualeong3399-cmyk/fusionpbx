#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring PostgreSQL with BaoTA paths"

#generate a random password
password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64)

#install message
verbose "Configure PostgreSQL database, users and permissions (BaoTA version)\n"

# BaoTA (宝塔) paths
pgsql_dir="/www/server/pgsql"

# Skip PostgreSQL installation as it's already installed by BaoTA
verbose "BaoTA PostgreSQL is already installed, skipping installation"

#systemd
systemctl daemon-reload

# Check if PostgreSQL service is running through BaoTA
if systemctl is-active --quiet postgresql; then
	verbose "PostgreSQL is running"
elif systemctl is-active --quiet pgsql; then
	verbose "PostgreSQL (pgsql) is running via BaoTA"
else
	verbose "Starting PostgreSQL service"
	systemctl start postgresql || systemctl start pgsql
fi

#init.d
#/usr/sbin/service postgresql restart

#install the database backup
#cp backup/fusionpbx-backup /etc/cron.daily
#cp backup/fusionpbx-maintenance /etc/cron.daily
#chmod 755 /etc/cron.daily/fusionpbx-backup
#chmod 755 /etc/cron.daily/fusionpbx-maintenance
#sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-backup
#sed -i "s/zzz/$password/g" /etc/cron.daily/fusionpbx-maintenance

#move to /tmp to prevent a red herring error when running sudo with psql
cwd=$(pwd)
cd /tmp

if [ ."$database_host" = ."127.0.0.1" ] || [ ."$database_host" = ."::1" ] ; then
	#reload the config
	verbose "Configuring PostgreSQL databases and users..."
  	sudo -u postgres psql -c "SELECT pg_reload_conf();"

	#set client encoding
	sudo -u postgres psql -c "SET client_encoding = 'UTF8';";

	#add the database users and databases
	sudo -u postgres psql -c "CREATE DATABASE fusionpbx;";
	sudo -u postgres psql -c "CREATE DATABASE freeswitch;";

 	#add the users and grant permissions
	sudo -u postgres psql -c "CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$password';"
	sudo -u postgres psql -c "CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$password';"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;"
	sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;"

 	#update the fusionpbx user password
	#ALTER USER fusionpbx WITH PASSWORD 'newpassword';

	verbose "PostgreSQL configuration completed"
