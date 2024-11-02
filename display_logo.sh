 #!/bin/bash

# Функция для отображения логотипа
display_logo() {
  echo -e '\e[47m'
  echo "███╗   ██╗ ██████╗ ██████╗     ███████╗██╗     ██╗ ██████╗ ██╗██████╗ ██╗     ███████╗"
  echo "████╗  ██║██╔═══██╗██╔══██╗    ██╔════╝██║     ██║██╔════╝ ██║██╔══██╗██║     ██╔════╝"
  echo "██╔██╗ ██║██║   ██║██║  ██║    █████╗  ██║     ██║██║  ███╗██║██████╔╝██║     █████╗  "
  echo "██║╚██╗██║██║   ██║██║  ██║    ██╔══╝  ██║     ██║██║   ██║██║██╔══██╗██║     ██╔══╝  "
  echo "██║ ╚████║╚██████╔╝██████╔╝    ███████╗███████╗██║╚██████╔╝██║██████╔╝███████╗███████╗"
  echo "╚═╝  ╚═══╝ ╚═════╝ ╚═════╝     ╚══════╝╚══════╝╚═╝ ╚═════╝ ╚═╝╚═════╝ ╚══════╝╚══════╝"
  echo -e '\e[0m'

}

# Функция для логирования
log_message() {
  echo -e "\e[33m'$1'\e[0m"
}
# Отображение логотипа
display_logo
