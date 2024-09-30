#!/bin/bash

function logo {
  curl -s (силка на логотип) | bash
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function echo_start_install {
  echo "${RED} Начинаем установку ${NORMAL}"
}

function echo_start_update {
  echo "${RED} Начинаем обновление ${NORMAL}"
}

function echo_finish {
  echo "${RED} Скрипт завершил свою работу ${NORMAL}"
}
