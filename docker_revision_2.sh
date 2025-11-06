#!/bin/bash
# Благодарность Let's Node!
# Переменные по умолчанию
dive="false"
function="install"

# Проверка наличия wget и jq
if ! command -v wget &> /dev/null; then
    echo "Устанавливаем wget..."
    sudo apt update && sudo apt install -y wget
fi
if ! command -v jq &> /dev/null; then
    echo "Устанавливаем jq..."
    sudo apt install -y jq
fi

# Цветовые настройки и логотип
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }

# Обработка опций командной строки
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Функциональность${RES}: скрипт устанавливает или удаляет Docker"
		echo -e "${C_LGn}Использование${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Опции${RES}:"
		echo -e "  -h, --help       показать справку"
		echo -e "  -d, --dive       установить Dive (анализатор образов)"
		echo -e "  -u, --uninstall  удалить Docker (${C_R}полностью удалить все образы и контейнеры${RES})"
		return 0 2>/dev/null; exit 0
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

# Функция установки
install() {
	cd
	if ! docker --version; then
		echo -e "${C_LGn}Установка Docker...${RES}"
		sudo apt update
		sudo apt install -y curl apt-transport-https ca-certificates gnupg lsb-release apparmor
		. /etc/*-release
  		if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
		    wget -qO- "https://download.docker.com/linux/${DISTRIB_ID,,}/gpg" | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
		fi
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt update
		sudo apt install -y docker-ce docker-ce-cli containerd.io
	fi
	
	# Установка Docker Compose
	if ! docker-compose --version; then
		echo -e "${C_LGn}Установка Docker Compose...${RES}"
		docker_compose_version=$(wget -qO- https://api.github.com/repos/docker/compose/releases/latest | jq -r ".tag_name")
		sudo wget -O /usr/bin/docker-compose "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-$(uname -s)-$(uname -m)"
		sudo chmod +x /usr/bin/docker-compose
		DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
		mkdir -p $DOCKER_CONFIG/cli-plugins
		curl -SL "https://github.com/docker/compose/releases/download/${docker_compose_version}/docker-compose-linux-$(uname -m)" -o "$DOCKER_CONFIG/cli-plugins/docker-compose"
		chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"
	fi

	# Установка Dive
	if [ "$dive" = "true" ] && ! dpkg -s dive | grep -q "ok installed"; then
		echo -e "${C_LGn}Установка Dive...${RES}"
		wget https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb
		sudo apt install -y ./dive_0.9.2_linux_amd64.deb
		rm -rf dive_0.9.2_linux_amd64.deb
	fi
}

# Функция удаления
uninstall() {
	echo -e "${C_LGn}Удаление Docker...${RES}"
	sudo dpkg -r dive
	sudo systemctl stop docker.service docker.socket
	sudo systemctl disable docker.service docker.socket
	sudo apt purge -y docker-engine docker docker.io docker-ce docker-ce-cli
	sudo apt autoremove --purge -y
	sudo rm -rf /var/lib/docker /etc/docker
	sudo groupdel docker
}

# Выполнение команды
$function
echo -e "${C_LGn}Готово!${RES}"
