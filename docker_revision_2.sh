#!/bin/bash
# Обновлённая версия Docker installer
# Работает на Hetzner Ubuntu 22.04+ без ошибок

dive="false"
function="install"

# === Проверка необходимых пакетов ===
if ! command -v wget &> /dev/null; then
    echo "🧩 Устанавливаем wget..."
    sudo apt update && sudo apt install -y wget
fi

if ! command -v jq &> /dev/null; then
    echo "🧩 Устанавливаем jq..."
    sudo apt update
    sudo apt install -y jq
fi

# Цвета (если скрипт colors.sh недоступен — не критично)
if command -v wget &> /dev/null; then
    . <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) -- 2>/dev/null || true
fi

option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }

# === Аргументы ===
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		echo "Использование: docker.sh [OPTIONS]"
		echo "  -d, --dive       установить Dive (анализатор образов)"
		echo "  -u, --uninstall  полностью удалить Docker и данные"
		exit 0
		;;
	-d|--dive)
		dive="true"
		shift
		;;
	-u|--uninstall)
		function="uninstall"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# === Установка Docker ===
install() {
	cd

	if ! command -v docker &>/dev/null; then
		echo -e "⚙️  Устанавливаем Docker..."
		sudo apt update
		sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https apparmor

		sudo install -m 0755 -d /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
		echo \
		  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
		  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
		  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

		sudo apt update
		sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	fi

	# === Docker Compose (новый встроенный плагин) ===
	if ! docker compose version &>/dev/null; then
		echo -e "⚙️  Настраиваем Docker Compose..."
		sudo apt install -y docker-compose-plugin
	fi

	# === Dive (по желанию) ===
	if [ "$dive" = "true" ] && ! dpkg -s dive >/dev/null 2>&1; then
		echo -e "📦 Устанавливаем Dive..."
		wget -q https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb
		sudo apt install -y ./dive_0.9.2_linux_amd64.deb
		rm -f dive_0.9.2_linux_amd64.deb
	fi

	sudo systemctl enable docker
	sudo systemctl start docker
	echo -e "✅ Docker успешно установлен!"
}

# === Удаление Docker ===
uninstall() {
	echo -e "🧹 Удаляем Docker..."
	sudo systemctl stop docker.service docker.socket
	sudo systemctl disable docker.service docker.socket
	sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
	sudo apt autoremove -y --purge
	sudo rm -rf /var/lib/docker /etc/docker /etc/apt/keyrings/docker.gpg /etc/apt/sources.list.d/docker.list
	sudo groupdel docker 2>/dev/null || true
	echo -e "✅ Docker полностью удалён."
}

# === Запуск ===
$function
echo -e "🎯 Готово!"
