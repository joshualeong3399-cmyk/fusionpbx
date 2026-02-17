# FusionPBX 在宝塔上的安装指南

## 前置条件
- ✅ 宝塔面板已安装
- ✅ Nginx 已安装在宝塔
- ✅ PHP 已安装在宝塔（推荐 7.4 或以上）
- ✅ PostgreSQL 已安装在宝塔

## 快速安装步骤

### 1. 检查宝塔环境
```bash
# 检查关键路径
ls -la /www/server/nginx
ls -la /www/server/php
ls -la /www/server/pgsql
```

### 2. 克隆 FusionPBX 源代码
```bash
mkdir -p /www/wwwroot
cd /www/wwwroot
git clone https://github.com/fusionpbx/fusionpbx.git fusionpbx
cd fusionpbx
chown -R www:www /www/wwwroot/fusionpbx
```

### 3. 创建数据库和用户
```bash
# 生成随机密码
DB_PASS=$(openssl rand -base64 16)

# 以 postgres 用户身份运行
sudo -u postgres /www/server/pgsql/bin/psql << EOF
CREATE DATABASE fusionpbx;
CREATE DATABASE freeswitch;
CREATE ROLE fusionpbx WITH SUPERUSER LOGIN PASSWORD '$DB_PASS';
CREATE ROLE freeswitch WITH SUPERUSER LOGIN PASSWORD '$DB_PASS';
GRANT ALL PRIVILEGES ON DATABASE fusionpbx to fusionpbx;
GRANT ALL PRIVILEGES ON DATABASE freeswitch to fusionpbx;
GRANT ALL PRIVILEGES ON DATABASE freeswitch to freeswitch;
EOF

echo "数据库密码: $DB_PASS"
```

### 4. 创建 FusionPBX 配置文件
```bash
mkdir -p /etc/fusionpbx
cat > /etc/fusionpbx/config.conf << 'EOF'
<?php
$database['fusionpbx']['driver']   = 'pgsql';
$database['fusionpbx']['host']     = '127.0.0.1';
$database['fusionpbx']['port']     = '5432';
$database['fusionpbx']['database'] = 'fusionpbx';
$database['fusionpbx']['username'] = 'fusionpbx';
$database['fusionpbx']['password'] = 'YOUR_DB_PASSWORD_HERE';
$database['fusionpbx']['debug']    = false;
$database['fusionpbx']['persistent'] = false;

$database['freeswitch']['driver']   = 'pgsql';
$database['freeswitch']['host']     = '127.0.0.1';
$database['freeswitch']['port']     = '5432';
$database['freeswitch']['database'] = 'freeswitch';
$database['freeswitch']['username'] = 'freeswitch';
$database['freeswitch']['password'] = 'YOUR_DB_PASSWORD_HERE';
$database['freeswitch']['debug']    = false;
$database['freeswitch']['persistent'] = false;
?>
EOF

chmod 600 /etc/fusionpbx/config.conf
chown www:www /etc/fusionpbx/config.conf
```

### 5. 配置 Nginx（通过脚本）
```bash
cd /Users/herbertlim/fusionpbx-install.sh/ubuntu/resources
./nginx.sh
```

### 6. 配置 PHP（通过脚本）
```bash
cd /Users/herbertlim/fusionpbx-install.sh/ubuntu/resources
./php.sh
```

### 7. 初始化 FusionPBX 数据库
```bash
cd /www/wwwroot/fusionpbx
/usr/bin/php core/upgrade/upgrade.php --schema
/usr/bin/php core/upgrade/upgrade.php --defaults
/usr/bin/php core/upgrade/upgrade.php --permissions
```

### 8. 设置权限
```bash
chown -R www:www /www/wwwroot/fusionpbx
mkdir -p /var/run/fusionpbx
chown -R www:www /var/run/fusionpbx
```

### 9. 访问 FusionPBX
在浏览器中访问：
```
http://你的服务器IP/fusionpbx
```

默认用户名: admin
默认密码: 在运行升级脚本后会生成

## 故障排查

### 配置文件不存在
```bash
# 检查
ls -la /etc/fusionpbx/config.conf
cat /etc/fusionpbx/config.conf
```

### 数据库连接失败
```bash
# 测试连接
/www/server/pgsql/bin/psql -h 127.0.0.1 -U fusionpbx -d fusionpbx
```

### PHP 模块缺失
```bash
# 检查 PHP 扩展
/www/server/php/74/bin/php -m | grep -E "pdo|pgsql"
```

### Nginx 配置错误
```bash
# 检查 nginx 配置
/www/server/nginx/sbin/nginx -t
```

## 所有脚本已针对宝塔优化

已修改的文件（自动跳过宝塔已有的服务）：
- ✅ ubuntu/install.sh
- ✅ debian/install.sh
- ✅ ubuntu/resources/nginx.sh
- ✅ ubuntu/resources/php.sh
- ✅ ubuntu/resources/postgresql.sh
- ✅ debian/resources/nginx.sh
- ✅ debian/resources/php.sh
- ✅ debian/resources/postgresql.sh

所有路径已改为宝塔路径：
- Nginx: `/www/server/nginx`
- PHP: `/www/server/php/XX`
- PostgreSQL: `/www/server/pgsql`
- Web 根: `/www/wwwroot/fusionpbx`
- 配置: `/etc/fusionpbx/config.conf`
