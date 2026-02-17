#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#default permissions
chown -R www:www /etc/freeswitch
chown -R www:www /var/lib/freeswitch/recordings
chown -R www:www /var/lib/freeswitch/storage
chown -R www:www /var/lib/freeswitch/db
chown -R www:www /usr/share/freeswitch
chown -R www:www /var/log/freeswitch
chown -R www:www /var/run/freeswitch
chown -R www:www /var/cache/fusionpbx
