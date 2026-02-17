#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#make sure unzip is install
apt-get install -y unzip

#remove the ioncube directory if it exists
if [ -d "ioncube" ]; then
        rm -Rf ioncube;
fi

#get the ioncube load and unzip it
if [ .$cpu_architecture = .'x86' ]; then
	#get the ioncube 64 bit loader
	wget --no-check-certificate https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip

	#uncompress the file
	unzip ioncube_loaders_lin_x86-64.zip

	#remove the zip file
	rm ioncube_loaders_lin_x86-64.zip
elif [ ."$cpu_architecture" = ."arm" ]; then
	if [ .$cpu_name = .'armv7l' ]; then
		#get the ioncube 64 bit loader
		wget --no-check-certificate https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_armv7l.zip

		#uncompress the file
		unzip ioncube_loaders_lin_armv7l.zip

		#remove the zip file
		rm ioncube_loaders_lin_armv7l.zip
	fi
fi

#copy the loader to the correct directory
if [ ."$php_version" = ."5.6" ]; then
        cp ioncube/ioncube_loader_lin_5.6.so /www/server/php/56/lib
        echo "zend_extension = /www/server/php/56/lib/ioncube_loader_lin_5.6.so" > /www/server/php/56/etc/php.d/00-ioncube.ini
        systemctl restart php-fpm-56 || systemctl restart php-fpm
fi
if [ ."$php_version" = ."7.0" ]; then
        cp ioncube/ioncube_loader_lin_7.0.so /www/server/php/70/lib
        echo "zend_extension = /www/server/php/70/lib/ioncube_loader_lin_7.0.so" > /www/server/php/70/etc/php.d/00-ioncube.ini
        systemctl restart php-fpm-70 || systemctl restart php-fpm
fi
if [ ."$php_version" = ."7.1" ]; then
        cp ioncube/ioncube_loader_lin_7.1.so /www/server/php/71/lib
        echo "zend_extension = /www/server/php/71/lib/ioncube_loader_lin_7.1.so" > /www/server/php/71/etc/php.d/00-ioncube.ini
        systemctl restart php-fpm-71 || systemctl restart php-fpm
fi
if [ ."$php_version" = ."7.2" ]; then
        cp ioncube/ioncube_loader_lin_7.2.so /www/server/php/72/lib
        echo "zend_extension = /www/server/php/72/lib/ioncube_loader_lin_7.2.so" > /www/server/php/72/etc/php.d/00-ioncube.ini
        systemctl restart php-fpm-72 || systemctl restart php-fpm
fi
if [ ."$php_version" = ."7.4" ]; then
        cp ioncube/ioncube_loader_lin_7.4.so /www/server/php/74/lib
        echo "zend_extension = /www/server/php/74/lib/ioncube_loader_lin_7.4.so" > /www/server/php/74/etc/php.d/00-ioncube.ini
        systemctl restart php-fpm-74 || systemctl restart php-fpm
fi
if [ ."$php_version" = ."8.1" ]; then
        cp ioncube/ioncube_loader_lin_8.1.so /www/server/php/81/lib
        echo "zend_extension = /www/server/php/81/lib/ioncube_loader_lin_8.1.so" > /www/server/php/81/etc/php.d/00-ioncube.ini
        systemctl restart php-fpm-81 || systemctl restart php-fpm
fi
if [ ."$php_version" = ."8.3" ]; then
        cp ioncube/ioncube_loader_lin_8.3.so /www/server/php/83/lib
        echo "zend_extension = /www/server/php/83/lib/ioncube_loader_lin_8.3.so" > /www/server/php/83/etc/php.d/00-ioncube.ini
        systemctl restart php-fpm-83 || systemctl restart php-fpm
fi
