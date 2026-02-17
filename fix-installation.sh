#!/bin/bash

# Quick fix script for existing FusionPBX installation on Baota Panel
# This script fixes the "Cannot redeclare" error and psql path issues

echo "=== FusionPBX Baota Installation Fix ==="
echo ""

# 1. Remove old FusionPBX installation
if [ -d /var/www/fusionpbx ]; then
    echo "[*] Removing old FusionPBX installation from /var/www/fusionpbx..."
    sudo rm -rf /var/www/fusionpbx
    echo "[✓] Old installation removed"
else
    echo "[✓] No old installation found at /var/www/fusionpbx"
fi

# 2. Find psql binary
echo ""
echo "[*] Locating PostgreSQL psql binary..."

PSQL_CMD=""
if [ -f /www/server/pgsql/bin/psql ]; then
    PSQL_CMD="/www/server/pgsql/bin/psql"
elif [ -f /www/server/postgresql/bin/psql ]; then
    PSQL_CMD="/www/server/postgresql/bin/psql"
elif [ -f /usr/bin/psql ]; then
    PSQL_CMD="/usr/bin/psql"
elif which psql >/dev/null 2>&1; then
    PSQL_CMD=$(which psql)
else
    echo "[!] ERROR: Could not find psql binary"
    echo "PostgreSQL may not be installed or not in expected locations"
    exit 1
fi

echo "[✓] Found psql at: $PSQL_CMD"

# 3. Set permissions on FusionPBX directory
echo ""
echo "[*] Setting correct permissions on /www/wwwroot/fusionpbx..."
if [ -d /www/wwwroot/fusionpbx ]; then
    sudo chown -R www:www /www/wwwroot/fusionpbx
    sudo chmod -R 755 /www/wwwroot/fusionpbx
    echo "[✓] Permissions set"
else
    echo "[!] WARNING: /www/wwwroot/fusionpbx directory not found"
fi

# 4. Clear PHP cache (if applicable)
echo ""
echo "[*] Clearing web application cache..."
if [ -d /www/wwwroot/fusionpbx/resources/cache ]; then
    sudo rm -rf /www/wwwroot/fusionpbx/resources/cache/*
    echo "[✓] Cache cleared"
fi

# 5. Test database connection
echo ""
echo "[*] Testing PostgreSQL connection..."
if $PSQL_CMD -U postgres -c "SELECT 1" >/dev/null 2>&1; then
    echo "[✓] PostgreSQL connection successful"
else
    echo "[!] WARNING: Could not connect to PostgreSQL"
    echo "    This might be normal if postgres is not running or needs password"
fi

# 6. Restart services
echo ""
echo "[*] Restarting web services..."

# Restart Nginx (Baota managed)
if systemctl is-active --quiet nginx; then
    sudo systemctl restart nginx
    echo "[✓] Nginx restarted"
fi

# Restart PHP-FPM (detect version)
if systemctl is-active --quiet php-fpm; then
    sudo systemctl restart php-fpm
    echo "[✓] PHP-FPM restarted"
else
    # Try versioned PHP-FPM
    for php_svc in php-fpm-74 php-fpm-81 php-fpm-82; do
        if systemctl is-active --quiet $php_svc; then
            sudo systemctl restart $php_svc
            echo "[✓] $php_svc restarted"
            break
        fi
    done
fi

# Restart FreeSwitch
if systemctl is-active --quiet freeswitch; then
    sudo systemctl restart freeswitch
    echo "[✓] FreeSwitch restarted"
fi

echo ""
echo "=== Fix Complete ==="
echo ""
echo "Next steps:"
echo "1. Access FusionPBX at: http://your_server_ip/fusionpbx"
echo "2. If you still see errors, check:"
echo "   - Nginx error logs: tail -f /www/server/nginx/logs/error.log"
echo "   - PHP error logs: tail -f /www/server/php/XX/var/log/php-fpm.log"
echo ""
echo "PostgreSQL psql location: $PSQL_CMD"
