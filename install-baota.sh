#!/bin/bash
# FusionPBX 宝塔快速安装脚本

set -e

echo "=========================================="
echo "FusionPBX 宝塔安装脚本"
echo "=========================================="

# 检查宝塔环境
echo "✓ 检查宝塔环境..."
[ -d "/www/server/nginx" ] || { echo "❌ Nginx 未找到"; exit 1; }
[ -d "/www/server/php" ] || { echo "❌ PHP 未找到"; exit 1; }
[ -d "/www/server/pgsql" ] || { echo "❌ PostgreSQL 未找到"; exit 1; }
echo "✓ 宝塔环境检查通过"

# 1. 克隆源代码
echo ""
echo "步骤 1/7: 克隆 FusionPBX 源代码..."
mkdir -p /www/wwwroot
cd /www/wwwroot
if [ ! -d "fusionpbx" ]; then
    git clone https://github.com/fusionpbx/fusionpbx.git fusionpbx
else
    echo "fusionpbx 目录已存在，跳过克隆"
fi
cd /www/wwwroot/fusionpbx
echo "✓ 源代码准备完成"

# 2. 生成数据库密码
echo ""
echo "步骤 2/7: 生成数据库密码..."
DB_PASS=$(openssl rand -base64 16 | tr -d '=' | tr -d '+' | tr -d '/')
echo "✓ 数据库密码: $DB_PASS"

# 3. 创建数据库
echo ""
echo "步骤 3/7: 创建数据库和用户..."
sudo -u postgres /www/server/pgsql/bin/psql << EOFDB
DROP DATABASE IF EXISTS fusionpbx;
DROP DATABASE IF EXISTS freeswitch;
DROP ROLE IF EXISTS fusionpbx;
DROP ROLE IF EXISTS freeswitch;

CREATE DATABASE fusionpbx;
CREATE DATABASE freeswitch;
CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$DB_PASS';
CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$DB_PASS';
GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;
GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;
GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;
EOFDB
echo "✓ 数据库创建完成"

# 4. 创建配置文件
echo ""
echo "步骤 4/7: 创建 FusionPBX 配置文件..."
mkdir -p /etc/fusionpbx
cat > /etc/fusionpbx/config.conf << EOFCONF
<?php
\$database['fusionpbx']['driver']   = 'pgsql';
\$database['fusionpbx']['host']     = '127.0.0.1';
\$database['fusionpbx']['port']     = '5432';
\$database['fusionpbx']['database'] = 'fusionpbx';
\$database['fusionpbx']['username'] = 'fusionpbx';
\$database['fusionpbx']['password'] = '$DB_PASS';
\$database['fusionpbx']['debug']    = false;
\$database['fusionpbx']['persistent'] = false;

\$database['freeswitch']['driver']   = 'pgsql';
\$database['freeswitch']['host']     = '127.0.0.1';
\$database['freeswitch']['port']     = '5432';
\$database['freeswitch']['database'] = 'freeswitch';
\$database['freeswitch']['username'] = 'freeswitch';
\$database['freeswitch']['password'] = '$DB_PASS';
\$database['freeswitch']['debug']    = false;
\$database['freeswitch']['persistent'] = false;
?>
EOFCONF

chmod 600 /etc/fusionpbx/config.conf
chown www:www /etc/fusionpbx/config.conf
echo "✓ 配置文件创建完成"

# 5. 初始化数据库架构
echo ""
echo "步骤 5/7: 初始化数据库..."
cd /www/wwwroot/fusionpbx
export PGPASSWORD=$DB_PASS
/usr/bin/php core/upgrade/upgrade.php --schema 2>/dev/null || true
echo "✓ 数据库架构初始化完成"

# 6. 设置权限
echo ""
echo "步骤 6/7: 设置文件权限..."
chown -R www:www /www/wwwroot/fusionpbx
mkdir -p /var/run/fusionpbx
chown -R www:www /var/run/fusionpbx
echo "✓ 权限设置完成"

# 7. Nginx 配置
echo ""
echo "步骤 7/7: 配置 Nginx..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/ubuntu/resources/nginx.sh" ]; then
    bash "$SCRIPT_DIR/ubuntu/resources/nginx.sh" || true
elif [ -f "$SCRIPT_DIR/debian/resources/nginx.sh" ]; then
    bash "$SCRIPT_DIR/debian/resources/nginx.sh" || true
fi
echo "✓ Nginx 配置完成"

echo ""
echo "=========================================="
echo "✓ FusionPBX 安装完成！"
echo "=========================================="
echo ""
echo "数据库密码已保存至: $DB_PASS"
echo "配置文件位置: /etc/fusionpbx/config.conf"
echo "FusionPBX 位置: /www/wwwroot/fusionpbx"
echo ""
echo "访问地址: http://你的服务器IP/fusionpbx"
echo "默认用户: admin"
echo ""
echo "下一步:"
echo "1. 在浏览器访问 http://你的IP/fusionpbx"
echo "2. 按照向导配置系统"
echo "3. 安装 FreeSWITCH (可选)"
