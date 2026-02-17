#!/bin/sh

mkdir -p /var/run/freeswitch
chown -R www:www /var/run/freeswitch
/usr/bin/freeswitch -nc -u www -g www -nonat
