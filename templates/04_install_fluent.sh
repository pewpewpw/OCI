#!/bin/bash
set -eEuo pipefail

# 설치 루트 및 설정 파일 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/install.config"

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "[ERROR] install.config 배포 신뢰없음: $CONFIG_FILE" >&2
  exit 1
fi

# 공통 함수 로드
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/progress.sh"

step 4 "Fluentd 및 플러그인 설치"

# RVM 및 Ruby 설치
if ! command -v rvm >/dev/null 2>&1; then
  log_info "RVM 설치 중..."
  command curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -
  \curl -sSL https://get.rvm.io | sudo bash -s stable --ruby
  log_success "RVM 설치 완료"
else
  log_info "RVM 이미 설치됨"
fi

sleep 3

# Ruby 버전 확인
/usr/local/rvm/rubies/ruby-*/bin/ruby --version || true
sleep 3

# conse 유저를 rvm 그룹에 추가
sudo adduser "$INSTALL_USER" rvm || true
sleep 3

# Fluentd 및 플러그인 설치
log_info "Fluentd 및 플러그인 설치 중..."
sg rvm -c "gem install fluentd -v '~> 0.12.0' --no-document"
sg rvm -c "gem install fluent-plugin-elasticsearch --no-document"
sg rvm -c "gem install fluent-plugin-datacounter -v 0.4.5 --no-document"
sg rvm -c "gem install fluent-plugin-secure-forward --no-document"
sg rvm -c "gem install fluent-plugin-amqp2 --no-document"
sg rvm -c "gem install fluent-plugin-grep --no-document"
sg rvm -c "gem install fluent-plugin-record-modifier --no-document"

log_success "Fluentd 및 플러그인 설치 완료"
