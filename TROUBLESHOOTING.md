# FusionPBX Baota Installation - Troubleshooting Guide

## Recent Fixes Applied

### Issue 1: "Cannot redeclare switch_module_is_running()" Error

**Root Cause:**
- FusionPBX was being included from TWO locations:
  - `/www/wwwroot/fusionpbx/` (correct Baota path)
  - `/var/www/fusionpbx/` (old system default path)
- PHP was declaring the same functions from both locations

**Solution:**
- Updated `finish.sh` scripts to remove the old `/var/www/fusionpbx/` directory
- Added cleanup code at the start of finish.sh

### Issue 2: "/www/server/pgsql/bin/psql: No such file or directory" Error

**Root Cause:**
- PostgreSQL might not be installed at the hardcoded Baota path
- PostgreSQL could be in alternate locations depending on Baota version

**Solution:**
- Enhanced `baota.sh` with intelligent PostgreSQL path detection
- Created `find_psql()` function that searches multiple locations:
  1. `/www/server/pgsql/bin/psql` (standard Baota)
  2. `/www/server/postgresql/bin/psql` (alternative Baota)
  3. `/usr/lib/postgresql/X/bin/psql` (system PostgreSQL)
  4. Falls back to system `which psql`
- Updated `finish.sh` to use `find_psql` function instead of hardcoded path

## Files Modified

### Script Updates:
1. **baota.sh** (Ubuntu & Debian)
   - Added `find_psql()` function for dynamic PostgreSQL detection
   - Added fallback logic for alternative PostgreSQL locations

2. **finish.sh** (Ubuntu & Debian)
   - Added: Source baota.sh helper
   - Added: Remove old `/var/www/fusionpbx/` installation
   - Updated: All psql commands now use `$(find_psql)` instead of hardcoded path

### New Files:
1. **fix-installation.sh**
   - Quick fix script for existing installations
   - Removes old FusionPBX installation
   - Restarts all services
   - Validates installation

## How to Apply Fixes

### Option 1: Re-run Installation (Clean)
```bash
cd /your/path/to/fusionpbx-install.sh
bash debian/install.sh  # or ubuntu/install.sh
```
The updated scripts will now:
- Automatically detect PostgreSQL location
- Skip old FusionPBX if it exists
- Place config.conf in correct location

### Option 2: Quick Fix for Existing Installation
```bash
cd /your/path/to/fusionpbx-install.sh
sudo bash fix-installation.sh
```

This script will:
1. Remove old `/var/www/fusionpbx/` installation
2. Locate PostgreSQL psql binary automatically
3. Set correct permissions
4. Clear cache
5. Restart all services

## PostgreSQL Path Detection

If you still get psql errors, you can manually check:

```bash
# Find where psql is installed
find /www -name psql -type f 2>/dev/null
find / -name psql -type f 2>/dev/null | grep -E "(bin|pgsql)"

# Or use which command
which psql

# Check Baota directories
ls -la /www/server/
```

Common locations on Baota:
- `/www/server/pgsql/bin/psql`
- `/www/server/postgresql/bin/psql`
- `/usr/lib/postgresql/14/bin/psql`
- `/usr/lib/postgresql/15/bin/psql`
- `/usr/lib/postgresql/16/bin/psql`

## Verification Steps

After applying fixes:

1. **Check FusionPBX loads without errors:**
   ```bash
   curl http://localhost/fusionpbx
   ```

2. **Check PHP error log:**
   ```bash
   tail -f /www/server/php/*/var/log/php-fpm.log
   ```

3. **Check Nginx error log:**
   ```bash
   tail -f /www/server/nginx/logs/error.log
   ```

4. **Verify no duplicate files:**
   ```bash
   [ -d /var/www/fusionpbx ] && echo "Old installation exists!" || echo "✓ Clean"
   ```

5. **Test PostgreSQL connection:**
   ```bash
   sudo -u postgres $(bash -c '. ./baota.sh && find_psql') -c "SELECT 1"
   ```

## What Changed

### baota.sh enhancements:
```bash
find_psql() {
  if [ -n "$BT_PGSQL_PATH" ] && [ -f "${BT_PGSQL_PATH}/psql" ]; then
    echo "${BT_PGSQL_PATH}/psql"
    return 0
  elif [ -n "$BT_PGSQL_PATH" ] && [ -f "${BT_PGSQL_PATH}/bin/psql" ]; then
    echo "${BT_PGSQL_PATH}/bin/psql"
    return 0
  elif which psql >/dev/null 2>&1; then
    which psql
    return 0
  fi
  echo ""
  return 1
}
```

### finish.sh enhancements:
```bash
# Remove old installation
if [ -d /var/www/fusionpbx ]; then
    rm -rf /var/www/fusionpbx
fi

# Use dynamic psql detection
PSQL_CMD=$(find_psql)
$PSQL_CMD -c "SQL_COMMAND"
```

## Troubleshooting

### If you still get "Cannot redeclare" errors:
```bash
# Make sure no old installation exists
sudo rm -rf /var/www/fusionpbx

# Clear PHP opcode cache
sudo rm -rf /www/wwwroot/fusionpbx/resources/cache/*

# Restart PHP-FPM
sudo systemctl restart php-fpm-*
```

### If you get "psql: command not found":
```bash
# Run the quick fix script
sudo bash fix-installation.sh

# Or manually check paths
find / -name psql -type f 2>/dev/null

# Update the psql path in the script if needed
# Edit the specific command and replace with actual path
```

### If PostgreSQL connection fails:
```bash
# Check if PostgreSQL is running
sudo systemctl status postgresql
sudo systemctl status postgres

# Or on Baota
sudo systemctl status mariadb  # if using MySQL instead

# Check PostgreSQL socket location
sudo find /var/run -name "*postgres*" 2>/dev/null
```

## Support

For additional issues, check:
- Baota Panel official documentation
- FusionPBX installation guide
- Your system logs in `/var/log/`
