#!/bin/bash

curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/display_logo.sh | bash

YELLOW='\e[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Запит у користувача розміру файлу підкачки
echo -e "${YELLOW}Выберите размер файла подкачки:${NC}"
echo "1) 4GB"
echo "2) 8GB"
echo "3) 12GB"
echo "4) 16GB"
read -p "Введите номер (1-4): " choice

# Встановлюємо розмір файлу підкачки відповідно до вибору
case $choice in
    1) size="4096k";;
    2) size="8192k";;
    3) size="12288k";;
    4) size="16384k";;
    *) 
        echo -e "${RED}Неверный выбор. Выход.${NC}"
        exit 1
        ;;
esac

echo -e "${YELLOW}Создание файла подкачки на $(( ${size%k} / 1024 ))GB...${NC}"
# Створення файлу підкачки
sudo dd if=/dev/zero of=/swapfile bs=1024 count=$size

# Налаштування прав доступу до файлу підкачки
sudo chmod 600 /swapfile

# Створення області підкачки
sudo mkswap /swapfile

# Увімкнення файлу підкачки
sudo swapon /swapfile

# Налаштування для постійної активації
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# Встановлення swappiness у 10
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Застосування змін swappiness
sudo sysctl -p

echo -e "${GREEN}Создание файла подкачки на $(( ${size%k} / 1024 ))GB завершено.${NC}"
