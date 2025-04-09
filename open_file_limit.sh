#!/bin/bash

curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/display_logo.sh | bash

YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Смена лимита открытых файловых дескрипторов...${NC}"
# Set limits in /etc/security/limits.conf
echo "* soft nofile 100000" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 100000" | sudo tee -a /etc/security/limits.conf

# Configure systemd limits
echo "DefaultLimitNOFILE=100000" | sudo tee -a /etc/systemd/system.conf
echo "DefaultLimitNOFILE=100000" | sudo tee -a /etc/systemd/user.conf

# Ensure PAM applies limits
grep -q "pam_limits.so" /etc/pam.d/common-session || echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session
grep -q "pam_limits.so" /etc/pam.d/common-session-noninteractive || echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session-noninteractive

# Apply changes to systemd
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# Set limit in ~/.bashrc for user sessions
echo "ulimit -n 100000" >> ~/.bashrc
source ~/.bashrc

ulimit -n 100000
# Verify the new limit
echo -e "${GREEN}Обновлен лимит дескриптора:${NC} $(ulimit -n)!"
