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

# Set PHP version based on OS if needed
if [ ."$cpu_architecture" = ."arm" ]; then
	#Pi2 and Pi3 Raspbian, #Odroid
	if [ ."$os_codename" = ."buster" ]; then
	      php_version=7.3
	fi
	if [ ."$os_codename" = ."bullseye" ]; then
	      php_version=7.4
	fi
	if [ ."$os_codename" = ."bookworm" ]; then
	      php_version=8.2
	fi
fi

# Set PHP configuration file path for BaoTA
# BaoTA typically uses /www/server/php/xx/etc/php.ini (where xx is version like 71, 73, 74, 81, 82, etc)
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
if [ ."$php_version" = ."7.3" ]; then
	verbose "PHP 7.3"
	php_ini_file='/www/server/php/73/etc/php.ini'
	php_fpm_service='php-fpm-73'
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


	apt-get install -y --no-install-recommends php8.2 php8.2-common php8.2-cli php8.2-dev php8.2-fpm php8.2-pgsql php8.2-sqlite3 php8.2-odbc php8.2-curl php8.2-imap php8.2-xml php8.2-gd php8.2-mbstring php8.2-ldap php8.2-inotify php8.2-snmp
fi
if [ ."$php_version" = ."8.3" ]; then
	apt-get install -y --no-install-recommends php8.3 php8.3-common php8.3-cli php8.3-dev php8.3-fpm php8.3-pgsql php8.3-sqlite3 php8.3-odbc php8.3-curl php8.3-imap php8.3-xml php8.3-gd php8.3-mbstring php8.3-ldap php8.3-inotify php8.3-snmp
fi
if [ ."$php_version" = ."8.4" ]; then
	apt-get install -y --no-install-recommends php8.4 php8.4-common php8.4-cli php8.4-dev php8.4-fpm php8.4-pgsql php8.4-sqlite3 php8.4-odbc php8.4-curl php8.4-imap php8.4-xml php8.4-gd php8.4-mbstring php8.4-ldap php8.4-inotify php8.4-snmp
fi

#update config if source is being used
if [ ."$php_version" = ."7.1" ]; then
        verbose "version 7.1"
        php_ini_file='/etc/php/7.1/fpm/php.ini'
fi
if [ ."$php_version" = ."7.2" ]; then
        verbose "version 7.2"
        php_ini_file='/etc/php/7.2/fpm/php.ini'
fi
if [ ."$php_version" = ."7.3" ]; then
        verbose "version 7.3"
        php_ini_file='/etc/php/7.3/fpm/php.ini'
fi
if [ ."$php_version" = ."7.4" ]; then
        verbose "version 7.4"
        php_ini_file='/etc/php/7.4/fpm/php.ini'
fi
if [ ."$php_version" = ."8.1" ]; then
        verbose "version 8.1"
        php_ini_file='/etc/php/8.1/fpm/php.ini'
fi
if [ ."$php_version" = ."8.2" ]; then
        verbose "version 8.2"
        php_ini_file='/etc/php/8.2/fpm/php.ini'
fi
if [ ."$php_version" = ."8.3" ]; then
        verbose "version 8.3"
        php_ini_file='/etc/php/8.3/fpm/php.ini'
fi
if [ ."$php_version" = ."8.4" ]; then
        verbose "version 8.4"
        php_ini_file='/etc/php/8.4/fpm/php.ini'
fi
sed 's#post_max_size = .*#post_max_size = 80M#g' -i $php_ini_file
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i $php_ini_file
sed 's#;max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file
sed 's#; max_input_vars = .*#max_input_vars = 8000#g' -i $php_ini_file

#install ioncube
if [ .$cpu_architecture = .'x86' ]; then
	. ./ioncube.sh
fi

#restart php-fpm
systemctl daemon-reload
if [ ."$php_version" = ."7.1" ]; then
        systemctl restart php7.1-fpm
fi
if [ ."$php_version" = ."7.2" ]; then
        systemctl restart php7.2-fpm
fi
if [ ."$php_version" = ."7.3" ]; then
        systemctl restart php7.3-fpm
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

