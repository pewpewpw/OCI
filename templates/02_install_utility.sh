#!/bin/bash
set -eEuo pipefail

# 설치 루트 및 설정 파일 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/install.config"

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "[ERROR] install.config 설정 파일이 없습니다: $CONFIG_FILE" >&2
  exit 1
fi

# 공통 함수 로드
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/progress.sh"

step 2 "이용 복잡성 확인 및 기본 패키지 설치"

OS_VER=$(lsb_release -rs)

sudo apt-get update -y

# 필수 패키지 설치
PACKAGES=(
  git
  python3-pip
  python3-setuptools
  libmysqlclient-dev
  curl
  jq
  sqlite3
  sysstat
  traceroute
  unzip
  net-tools
)

for pkg in "${PACKAGES[@]}"; do
  sudo apt-get install -y "$pkg"
  log_info "설치한 패키지: $pkg"
done

# Python 개발 패키지 버전별 분기
if [[ "$OS_VER" == "22.04" ]]; then
  sudo apt-get install -y python3-dev
else
  sudo apt-get install -y python-dev || true
fi

# elasticsearch-py 라이브러리 설치
case "$OS_VER" in
  12.04)
    sudo pip install elasticsearch
    sudo apt-get install -y libpam-cracklib
    ;;
  16.04)
    sudo pip install "elasticsearch>=1.0.0,<2.0.0"
    sudo pip install --upgrade pip
    ;;
  18.04)
    sudo pip install --upgrade pip --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org
    sudo pip install "elasticsearch>=5.0.0,<6.0.0"
    ;;
  20.04|22.04)
    sudo pip install "elasticsearch>=5.0.0,<6.0.0"
    ;;
esac

# Elasticsearch Curator 설치
if [[ -f "$ES_VERSION_FILE" ]]; then
  ES_VER=$(cat "$ES_VERSION_FILE")
  case "$ES_VER" in
    5)
      [[ "$OS_VER" == "16.04" ]] && sudo python -m easy_install --upgrade pyOpenSSL
      [[ "$OS_VER" == "18.04" ]] && sudo pip install --upgrade cryptography
      sudo pip install elasticsearch-curator==5.6.0
      ;;
    7)
      sudo pip install elasticsearch-curator==5.7.0
      ;;
    *)
      sudo pip install elasticsearch-curator==3.5.1
      ;;
  esac
else
  sudo pip install elasticsearch-curator==3.5.1
fi

# MySQL 라이브러리 설치
if [[ "$OS_VER" != "20.04" && "$OS_VER" != "22.04" ]]; then
  sudo pip install MySQL-python || true
fi
sudo pip install pymysql

# 로그로테이트 설정 복사
sudo cp "$INSTALL_HOME/resource/logstash_rotate2" /etc/logrotate.d/logstash_rotate
sudo cp "$INSTALL_HOME/resource/tomcat_rotate" /etc/logrotate.d/tomcat_rotate

log_success "기본 패키지 설치 완료"
