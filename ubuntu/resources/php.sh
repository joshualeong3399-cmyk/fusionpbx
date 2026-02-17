#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ./config.sh
. ./colors.sh
. ./environment.sh

#send a message
verbose "Configuring PHP with BaoTA paths"

# BaoTA (宝塔) paths
# Skip PHP installation as it's already installed by BaoTA
verbose "BaoTA PHP is already installed, skipping installation and package setup"

# Set PHP configuration file path for BaoTA
# BaoTA typically uses /www/server/php/xx/etc/php.ini (where xx is version like 74, 81, 82, etc)
if [ ."$php_version" = ."5.6" ]; then
	verbose "PHP 5.6"
	php_ini_file='/www/server/php/56/etc/php.ini'
	php_fpm_service='php-fpm-56'
fi
if [ ."$php_version" = ."7.0" ]; then
	verbose "PHP 7.0"
	php_ini_file='/www/server/php/70/etc/php.ini'
	php_fpm_service='php-fpm-70'
fi
if [ ."$php_version" = ."7.1" ]; then
	verbose "PHP 7.1"
	php_ini_file='/www/server/php/71/etc/php.ini'
	php_fpm_service='php-fpm-71'
fi
if [ ."$php_version" = ."7.2" ]; then
	verbose "PHP 7.2"
	php_ini_file='/www/server/php/72/etc/php.ini'
	php_fpm_service='php-fpm-72'
fi
if [ ."$php_version" = ."7.4" ]; then
	verbose "PHP 7.4"
	php_ini_file='/www/server/php/74/etc/php.ini'
	php_fpm_service='php-fpm-74'
fi
if [ ."$php_version" = ."8.1" ]; then
	verbose "PHP 8.1"
	php_ini_file='/www/server/php/81/etc/php.ini'
	php_fpm_service='php-fpm-81'
fi
if [ ."$php_version" = ."8.2" ]; then
	verbose "PHP 8.2"
	php_ini_file='/www/server/php/82/etc/php.ini'
	php_fpm_service='php-fpm-82'
fi
if [ ."$php_version" = ."8.3" ]; then
	verbose "PHP 8.3"
	php_ini_file='/www/server/php/83/etc/php.ini'
	php_fpm_service='php-fpm-83'
fi
if [ ."$php_version" = ."8.4" ]; then
	verbose "PHP 8.4"
	php_ini_file='/www/server/php/84/etc/php.ini'
	php_fpm_service='php-fpm-84'
fi

# Update PHP configuration if file exists
if [ -f "$php_ini_file" ]; then
	verbose "Updating PHP configuration at $php_ini_file"
	sed 's#post_max_size = .*#post_max_size = 80M#g' -i "$php_ini_file"
	sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i "$php_ini_file"
	sed 's#;max_input_vars = .*#max_input_vars = 8000#g' -i "$php_ini_file"
	sed 's#; max_input_vars = .*#max_input_vars = 8000#g' -i "$php_ini_file"
else
	verbose "Warning: PHP configuration file not found at $php_ini_file"
fi

#install ioncube - only for x86 architecture
if [ .$cpu_architecture = .'x86' ]; then
	verbose "Installing IonCube for x86 architecture"
	. ./ioncube.sh
fi

#restart php-fpm through BaoTA
verbose "Restarting PHP-FPM"
systemctl daemon-reload
if [ ! -z "$php_fpm_service" ]; then
	systemctl restart "$php_fpm_service" || systemctl restart php-fpm
fi

#update config if source is being used
if [ ."$php_version" = ."5" ]; then
        verbose "version 5.x"
        php_ini_file='/www/server/php/56/etc/php.ini'
fi
if [ ."$php_version" = ."7.0" ]; then
        verbose "version 7.0"
        php_ini_file='/www/server/php/70/etc/php.ini'
fi
if [ ."$php_version" = ."7.1" ]; then
        verbose "version 7.1"
        php_ini_file='/www/server/php/71/etc/php.ini'
fi
if [ ."$php_version" = ."7.2" ]; then
        verbose "version 7.2"
        php_ini_file='/www/server/php/72/etc/php.ini'
fi
if [ ."$php_version" = ."7.4" ]; then
        verbose "version 7.4"
        php_ini_file='/www/server/php/74/etc/php.ini'
fi
if [ ."$php_version" = ."8.1" ]; then
        verbose "version 8.1"
        php_ini_file='/www/server/php/81/etc/php.ini'
fi
if [ ."$php_version" = ."8.2" ]; then
        verbose "version 8.2"
        php_ini_file='/www/server/php/82/etc/php.ini'
fi
if [ ."$php_version" = ."8.3" ]; then
        verbose "version 8.3"
        php_ini_file='/www/server/php/83/etc/php.ini'
fi
if [ ."$php_version" = ."8.4" ]; then
        verbose "version 8.4"
        php_ini_file='/www/server/php/84/etc/php.ini'
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i $php_ini_file
sed 's#;max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file
sed 's#; max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file

#install ioncube
if [ .$cpu_architecture = .'x86' ]; then
	. ./ioncube.sh
fi

#restart php-fpm
systemctl daemon-reload
if [ ."$php_version" = ."5.6" ]; then
        systemctl restart php5-fpm
fi
if [ ."$php_version" = ."7.0" ]; then
        systemctl restart php7.0-fpm
fi
if [ ."$php_version" = ."7.1" ]; then
        systemctl restart php7.1-fpm
fi
if [ ."$php_version" = ."7.2" ]; then
        systemctl restart php7.2-fpm
fi
if [ ."$php_version" = ."7.4" ]; then
        systemctl restart php7.4-fpm
fi
if [ ."$php_version" = ."8.1" ]; then
        systemctl restart php8.1-fpm
fi
if [ ."$php_version" = ."8.2" ]; then
        systemctl restart php8.2-fpm
fi
if [ ."$php_version" = ."8.3" ]; then
        systemctl restart php8.3-fpm
fi
if [ ."$php_version" = ."8.4" ]; then
        systemctl restart php8.4-fpm
fi
#init.d
#/usr/sbin/service php5-fpm restart
#/usr/sbin/service php7.0-fpm restart
