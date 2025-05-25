#!/bin/bash

curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/display_logo.sh | bash

YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[38;5;81m'
NC='\033[0m'


# Шлях для встановлення
INSTALL_DIR="/etc/syslog_cleaner_service"
SERVICE_NAME="syslog-cleaner"

echo -e "${YELLOW}📁 Создание папки $INSTALL_DIR...${NC}"
mkdir -p "$INSTALL_DIR"

# Шлях до файлу логування
LOG_FILE="/etc/syslog_cleaner_service/syslog_cleaner.log"

# Створюємо директорію, якщо її немає
mkdir -p "$(dirname "$LOG_FILE")"

# Створюємо файл логування, якщо він не існує
touch "$LOG_FILE"

# Надаємо права на запис у файл
chmod 644 "$LOG_FILE"

COMPOSE_FILE="/var/log/syslog"

# Створення скрипта моніторингу контейнерів
echo -e "${YELLOW}📝 Создание файла мониторинга...${NC}"
cat <<EOF > "$INSTALL_DIR/monitor.sh"
#!/bin/bash

# Кольорові змінні
YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[38;5;81m'
NC='\033[0m'

COMPOSE_FILE="/var/log/syslog"

LOG_FILE="/etc/syslog_cleaner_service/syslog_cleaner.log"

MAX_SIZE=$((2 * 1024 * 1024 * 1024))

if [ -f "$COMPOSE_FILE" ]; then
  actual_size=$(stat -c %s "$COMPOSE_FILE")
  if [ "$actual_size" -gt "$MAX_SIZE" ]; then
    echo "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S')[!] /var/log/syslog > 2GB, clearing..." | tee -a "$LOG_FILE"
    truncate -s 0 "$COMPOSE_FILE"
    systemctl kill -s HUP rsyslog
  fi
fi
sleep 5m
done
EOF
chmod +x /etc/syslog_cleaner_service/monitor.sh

# Створення systemd-сервісу
echo -e "${YELLOW}📝 Создание systemd-сервиса...${NC}"
cat <<EOF > "/etc/systemd/system/$SERVICE_NAME.service"
[Unit]
Description=Syslog Cleaner Service
After=docker.service
Requires=docker.service

[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/bin/bash /etc/syslog_cleaner_service/monitor.sh
Restart=always
User=root
StandardOutput=append:/etc/syslog_cleaner_service/syslog_cleaner.log
StandardError=append:/etc/syslog_cleaner_service/syslog_cleaner.log

[Install]
WantedBy=multi-user.target
EOF

systemctl enable "$SERVICE_NAME.service"

# Оновлення systemd
echo -e "${YELLOW}🔄 Обновление systemd...${NC}"
systemctl daemon-reload

# Запуск сервісу
echo -e "${YELLOW}🚀 Запуск сервиса...${NC}"
systemctl start "$SERVICE_NAME.service"

echo -e "${GREEN}✅ Установка завершена!${NC}"
