


/usr/local/bin/limit-syslog.sh

#!/bin/bash

LOG_FILE="/var/log/syslog"
MAX_SIZE=$((1024 * 1024 * 1024))  # 1GB

if [ -f "$LOG_FILE" ]; then
  actual_size=$(stat -c %s "$LOG_FILE")
  if [ "$actual_size" -gt "$MAX_SIZE" ]; then
    echo "[!] /var/log/syslog > 1GB, clearing..."
    truncate -s 0 "$LOG_FILE"
    systemctl restart rsyslog
  fi
fi


chmod +x /usr/local/bin/limit-syslog.sh


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

