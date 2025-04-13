# Zabbix 7.0 Auto-Installer (Debian 12 + PostgreSQL 16)

📦 Bash-скрипт для автоматической установки Zabbix 7.0 Server, Web-интерфейса, агента и PostgreSQL 16 на Debian 12. (Тестировалась еще на Астра, всё работает)
Не тестировал на убунту.
Данный скрипт создан после моего обучения по заббикс.

---

## 🚀 Установка

```bash
git clone https://github.com/yourname/zabbix-installer.git
cd zabbix-installer
chmod +x install-zabbix.sh
sudo ./install-zabbix.sh

DB_USER	zabbix	Имя пользователя PostgreSQL
DB_PASSWORD	zabbixpass	Пароль пользователя PostgreSQL
ZBX_HOSTNAME	localhost	Hostname, используемый Nginx
ZBX_PORT	8080	Порт веб-интерфейса Zabbix

Можете изменить данные в скрипте под себя.

После установки
Открой браузер и перейди по адресу:

arduino
Копировать
Редактировать
http://localhost:8080
На первом экране веб-интерфейса укажи:

Тип базы данных: PostgreSQL

Хост БД: localhost

Пользователь БД: zabbix

Пароль БД: zabbixpass

Назначение	Значение
Веб-интерфейс Zabbix	Admin / zabbix
