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
cat <<EOF > "$INSTALL_DIR/watcher.sh"
#!/bin/bash

# 🎨 Цвета
YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[38;5;81m'
NC='\033[0m'

LOG_FILE="/etc/syslog_cleaner_service/syslog_cleaner.log"
MAX_SIZE=\$((10 * 1024 * 1024 * 1024))  # 10GB

# 📏 Подсчет общего размера файлов syslog*
total_size=\$(find /var/log -maxdepth 1 -name "syslog*" -type f -exec du -cb {} + | tail -n 1 | awk '{print \$1}')
total_gb=\$(awk "BEGIN {printf \"%.2f\", \$total_size/1024/1024/1024}")

echo -e "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S') 💾 ${YELLOW}Общий размер логов syslog*:${NC} \${total_gb} GB (\$total_size байт)" >> "$LOG_FILE"

# 🚨 Проверка превышения порога
if [[ "\$total_size" =~ ^[0-9]+$ ]] && [ "\$total_size" -gt "\$MAX_SIZE" ]; then
  echo -e "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S')  🔥 ${RED}Размер логов превышает${NC} 10GB — ${RED}выполняем очистку...${NC}" >> "$LOG_FILE"
  find /var/log -maxdepth 1 -name "syslog*" -type f -exec truncate -s 0 {} +
  systemctl kill -s HUP rsyslog
  echo -e "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S')  ✅ ${BLUE}Служба rsyslog успешно перезапущена.${NC}" >> "$LOG_FILE"
else
  echo -e "\$(/usr/bin/date '+%Y-%m-%d %H:%M:%S')  ✅ ${GREEN}Всё в порядке. Очистка не требуется.${NC}" >> "$LOG_FILE"
fi
  sleep 20m
EOF
chmod +x /etc/syslog_cleaner_service/watcher.sh

# Створення systemd-сервісу
echo -e "${YELLOW}📝 Создание systemd-сервиса...${NC}"
cat <<EOF > "/etc/systemd/system/$SERVICE_NAME.service"
[Unit]
Description=Syslog Cleaner Service
#After=docker.service
#Requires=docker.service

[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=/bin/bash /etc/syslog_cleaner_service/watcher.sh
Restart=always
User=root

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
