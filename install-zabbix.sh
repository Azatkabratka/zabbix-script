#!/bin/bash
set -e

# Настраиваемые параметры (можно поменять перед запуском)
DB_USER="zabbix"
DB_PASSWORD="zabbixpass"
ZBX_HOSTNAME="localhost"
ZBX_PORT="8080"

echo "==== Установка зависимостей и синхронизация времени ===="
apt update -y
apt install -y chrony wget curl gnupg
systemctl enable chrony --now

echo "==== Установка PostgreSQL 16 ===="
install -d /usr/share/postgresql-common/pgdg
curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc

echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list

apt update -y
apt install -y postgresql-16 -t bookworm-pgdg

echo "==== Установка Zabbix 7.0 ===="
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-2+debian12_all.deb
dpkg -i zabbix-release_7.0-2+debian12_all.deb
apt update -y
apt install -y zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent -t bookworm

echo "==== Инициализация базы данных Zabbix ===="
sudo -u postgres psql <<EOF
CREATE ROLE $DB_USER WITH LOGIN PASSWORD '$DB_PASSWORD';
CREATE DATABASE zabbix WITH OWNER=$DB_USER;
EOF

zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | PGPASSWORD="$DB_PASSWORD" psql -U $DB_USER -d zabbix -h localhost

echo "==== Настройка Zabbix Server ===="
sed -i "s/^# DBPassword=.*/DBPassword=$DB_PASSWORD/" /etc/zabbix/zabbix_server.conf
grep -q '^DBPassword=' /etc/zabbix/zabbix_server.conf || echo "DBPassword=$DB_PASSWORD" >> /etc/zabbix/zabbix_server.conf

echo "==== Настройка Zabbix Nginx ===="
sed -i "s|^# listen .*|listen $ZBX_PORT;|" /etc/zabbix/nginx.conf
sed -i "s|^# server_name .*|server_name $ZBX_HOSTNAME;|" /etc/zabbix/nginx.conf

echo "==== Запуск служб Zabbix и Nginx ===="
systemctl enable zabbix-server zabbix-agent php8.2-fpm nginx --now
systemctl restart nginx

echo "==== Установка завершена. Открой http://$ZBX_HOSTNAME:$ZBX_PORT в браузере ===="
