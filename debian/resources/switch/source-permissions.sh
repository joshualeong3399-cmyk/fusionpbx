#old

#setup owner and group, permissions and sticky
#chmod -R ug+rw /usr/local/freeswitch
#touch /usr/local/freeswitch/freeswitch.log
#chown -R www:www /usr/local/freeswitch
#find /usr/local/freeswitch -type d -exec chmod 2770 {} \;


#current (same paths as package)

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#default permissions
chown -R www:www /etc/freeswitch
chown -R www:www /var/lib/freeswitch
chown -R www:www /usr/share/freeswitch
chown -R www:www /var/log/freeswitch
chown -R www:www /var/run/freeswitch
chown -R www:www /var/cache/fusionpbx
