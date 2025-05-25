#!/bin/bash

# Кольори
YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Папка і файли
INSTALL_DIR="/etc/syslog_cleaner_service"
SCRIPT_PATH="$INSTALL_DIR/monitor.sh"
SERVICE_NAME="syslog-cleaner"
TIMER_NAME="syslog-cleaner.timer"
LOG_FILE="$INSTALL_DIR/syslog_cleaner.log"
SYSLOG_FILE="/var/log/syslog"

# Створення директорій і лог-файлу
echo -e "${YELLOW}📁 Створення папки $INSTALL_DIR...${NC}"
mkdir -p "$INSTALL_DIR"
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Створення скрипта моніторингу
echo -e "${YELLOW}📝 Створення скрипта...${NC}"
cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash

YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[38;5;81m'
NC='\033[0m'

MAX_SIZE=\$((2 * 1024 * 1024 * 1024))  # 2GB

if [ -f "$SYSLOG_FILE" ]; then
  actual_size=\$(stat -c %s "$SYSLOG_FILE")
  if [ "\$actual_size" -gt "\$MAX_SIZE" ]; then
    echo "[\$(date)] /var/log/syslog > 2GB, clearing..." >> "$LOG_FILE"
    truncate -s 0 "$SYSLOG_FILE"
    systemctl restart rsyslog
    echo "[\$(date)] rsyslog restarted." >> "$LOG_FILE"
  fi
fi
EOF
chmod +x "$SCRIPT_PATH"

# Створення systemd service
echo -e "${YELLOW}⚙️ Створення systemd service...${NC}"
cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=Syslog Cleaner Service
After=network.target

[Service]
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Type=oneshot
ExecStart=$SCRIPT_PATH
EOF

# Створення systemd таймера
echo -e "${YELLOW}⏱ Створення systemd timer...${NC}"
cat <<EOF > /etc/systemd/system/$TIMER_NAME
[Unit]
Description=Run syslog cleaner every 15 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=15min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Активація
echo -e "${GREEN}🚀 Активація systemd...${NC}"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now $TIMER_NAME

# Перевірка
echo -e "${GREEN}✅ Готово. Таймер активний:${NC}"
systemctl list-timers | grep $SERVICE_NAME
