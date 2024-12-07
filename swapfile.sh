#  Создаем файл подкачки на 4gb
sudo dd if=/dev/zero of=/swapfile bs=1024 count=4096k
# Создаем права доступа к файлу подкачки
sudo chmod 600 /swapfile
# Создаем область подкачки
sudo mkswap /swapfile
# Включение файла подкачки
sudo swapon /swapfile
# Настройка для постоянной активации
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
# Делаем значение Swappiness равным 10
