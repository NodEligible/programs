#!/bin/bash

curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/display_logo.sh | bash

YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Создание файла подкачки...${NC}"
# Создаем файл подкачки на 4GB
sudo dd if=/dev/zero of=/swapfile bs=1024 count=4096k

# Создаем права доступа к файлу подкачки
sudo chmod 600 /swapfile

# Создаем область подкачки
sudo mkswap /swapfile

# Включение файла подкачки
sudo swapon /swapfile

# Настройка для постоянной активации
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# Делаем значение Swappiness равным 10 и сохраняем
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Применяем изменения Swappiness
sudo sysctl -p
echo -e "${GREEN}Создание файла подкачки завершено${NC}"
