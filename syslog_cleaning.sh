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

MAX_SIZE=$((2048 * 2048 * 2048))  # 2GB

if [ -f "$COMPOSE_FILE" ]; then
  actual_size=$(stat -c %s "$COMPOSE_FILE")
  if [ "$actual_size" -gt "$MAX_SIZE" ]; then
    echo "[!] /var/log/syslog > 1GB, clearing..."
    truncate -s 0 "$COMPOSE_FILE"
    systemctl restart rsyslog
  fi
fi

done
EOF
chmod +x /etc/syslog_cleaner_service/monitor.sh


[Unit]
Description=Syslog Size Limiter
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/limit-syslog.sh

[Unit]
Description=Run syslog limiter every 15 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=15min
Persistent=true

[Install]
WantedBy=timers.target

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now limit-syslog.timer

# Перевірка
systemctl list-timers | grep limit-syslog
journalctl -u limit-syslog.service

