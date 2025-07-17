#!/bin/bash
set -eEuo pipefail

source "$(dirname "$0")/config/install.config"
source "$(dirname "$0")/../lib/logger.sh"
source "$(dirname "$0")/../lib/progress.sh"
source "$(dirname "$0")/../config/install.config"

step 1 "system utility & python environment setup"

OS_VER=$(lsb_release -rs)
ES_VER=$(cat "${INSTALL_HOME}/config/es_version" 2>/dev/null || echo "3")

log_info "Ubuntu version: $OS_VER"
log_info "Elasticsearch version: $ES_VER"

COMMON_PACKAGES=(
  git python3-pip python3-setuptools libmysqlclient-dev
  curl jq sqlite3 sysstat traceroute unzip net-tools
)

# 1. 기본 유틸 설치
sudo apt-get update -y
for pkg in "${COMMON_PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    log_info "$pkg installing..."
    sudo apt-get install -y "$pkg"
  else
    log_info "$pkg already installed"
  fi
done

# 2. Python2 pip 필요 시
if [[ "$OS_VER" != "20.04" && "$OS_VER" != "22.04" ]]; then
  sudo apt-get install -y python-pip python-dev
else
  sudo apt-get install -y python3-dev
fi

# 3. pip 기반 라이브러리 설치
case "$OS_VER" in
  "12.04")
    sudo pip install elasticsearch
    sudo apt-get -y install libpam-cracklib
    ;;
  "16.04")
    sudo pip install "elasticsearch>=1.0.0,<2.0.0"
    sudo pip install --upgrade pip
    ;;
  "18.04")
    sudo pip install --upgrade pip
    sudo pip install "elasticsearch>=5.0.0,<6.0.0"
    ;;
  "20.04"|"22.04")
    sudo pip install "elasticsearch>=5.0.0,<6.0.0"
    ;;
esac

# 4. Curator 설치
case "$ES_VER" in
  "5")
    sudo pip install elasticsearch-curator==5.6.0
    ;;
  "7")
    sudo pip install elasticsearch-curator==5.7.0
    ;;
  *)
    sudo pip install elasticsearch-curator==3.5.1
    ;;
esac

# 5. MySQL 관련
if [[ "$OS_VER" != "20.04" && "$OS_VER" != "22.04" ]]; then
  sudo pip install MySQL-python
fi
sudo pip install pymysql

# 6. logrotate 설정
for rotate_file in logstash_rotate2 tomcat_rotate; do
  if [[ -f "${INSTALL_HOME}/resource/${rotate_file}" ]]; then
    sudo cp "${INSTALL_HOME}/resource/${rotate_file}" /etc/logrotate.d/
    log_info "$rotate_file rotation setup complete"
  fi
done

# 7. 정리
rm -f ./erlang_solutions.asc ./rabbitmq-server*.deb
log_success "system utility & python environment setup complete"
