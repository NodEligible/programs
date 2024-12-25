#!/bin/bash

curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/display_logo.sh | bash

  echo -e "${YELLOW}Установка Main...${NC}"
  bash <(curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/main.sh)
  if [ $? -eq 0 ]; then
      echo -e "${GREEN}Main успешно установлен!${NC}"
  else
      echo -e "${RED}Ошибка при установке Main!${NC}"
  fi
  
  echo -e "${YELLOW}Установка Ufw...${NC}" 
  bash <(curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/ufw.sh)
  if [ $? -eq 0 ]; then
      echo -e "${GREEN}Ufw успешно установлено!${NC}"
  else
      echo -e "${RED}Ошибка при установке Ufw!${NC}"
  fi
  
  echo -e "${YELLOW}Установка Docker...${NC}"
  bash <(curl -s https://raw.githubusercontent.com/NodEligible/programs/refs/heads/main/docker.sh)
  if [ $? -eq 0 ]; then
      echo -e "${GREEN}Docker успешно установлено!${NC}"
  else
      echo -e "${RED}Ошибка при установке Docker!${NC}"
  fi

  echo -e "${YELLOW}Установка RPC Holesky...${NC}"

if ! id "geth_holesky" &>/dev/null; then
    useradd -s /bin/bash -m geth_holesky
    sudo usermod -aG sudo geth_holesky
    sudo usermod -aG docker geth_holesky
    sudo passwd geth_holesky
else
    echo "User 'geth_holesky' already exists."
fi

if [ ! -d "/home/geth_holesky/eth-docker" ]; then
        sudo -u geth_holesky git clone https://github.com/eth-educators/eth-docker.git /home/geth_holesky/eth-docker
    else
        echo "Directory '/home/geth_holesky/eth-docker' already exists."
fi


sudo -u geth_holesky cp /home/geth_holesky/eth-docker/default.env /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/COMPOSE_FILE=.*/COMPOSE_FILE=lighthouse-cl-only.yml:geth.yml:grafana.yml:grafana-shared.yml:el-shared.yml/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/EL_P2P_PORT=.*/EL_P2P_PORT=40303/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/CL_P2P_PORT=.*/CL_P2P_PORT=49000/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/CL_QUIC_PORT=.*/CL_QUIC_PORT=49001/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/GRAFANA_PORT=.*/GRAFANA_PORT=43000/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/EL_RPC_PORT=.*/EL_RPC_PORT=48545/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/EL_WS_PORT=.*/EL_WS_PORT=48546/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/NETWORK=.*/NETWORK=holesky/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/RAPID_SYNC_URL=.*/RAPID_SYNC_URL=\"https:\/\/holesky.beaconstate.info\"/g' /home/geth_holesky/eth-docker/.env
sudo -u geth_holesky sed -i 's/FEE_RECIPIENT=.*/FEE_RECIPIENT=0xd9264738573E25CB9149de0708b36527d56B59bd/g' /home/geth_holesky/eth-docker/.env


export COMPOSE_PROJECT_NAME=holesky
sudo -u geth_holesky /home/geth_holesky/eth-docker/ethd up

echo -e "${GREEN}Установка RPC Holesky завершена${NC}"
