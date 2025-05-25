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

LOG_FILE="/etc/syslog_cleaner_service/syslog_cleaner.log"
MAX_SIZE=\$((5 * 1024 * 1024 * 1024))  # 5GB

total_size=\$(find /var/log -maxdepth 1 -name "syslog*" -type f -exec du -cb {} + | tail -n 1 | awk '{print \$1}')

echo "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S') Total syslog* size: \$total_size bytes" >> "\$LOG_FILE"

if [[ "\$total_size" =~ ^[0-9]+$ ]] && [ "\$total_size" -gt "\$MAX_SIZE" ]; then
  echo "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S') [!] Total syslog* > 5GB, cleaning..." | tee -a "\$LOG_FILE"
  find /var/log -maxdepth 1 -name "syslog*" -type f -exec truncate -s 0 {} +
  systemctl kill -s HUP rsyslog
  echo "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S') [✔] rsyslog reloaded" | tee -a "\$LOG_FILE"
fi
  sleep 5m
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
