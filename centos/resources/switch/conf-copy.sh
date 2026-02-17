#!/bin/sh

#copy the conf directory
mv /etc/freeswitch /etc/freeswitch.orig
mkdir /etc/freeswitch
cp -R /www/wwwroot/fusionpbx/app/switch/resources/conf/* /etc/freeswitch
