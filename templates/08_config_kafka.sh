#!/bin/bash
set -eEuo pipefail

# 설치 루트 및 설정 파일 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/install.config"

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "[ERROR] install.config 누락됨: $CONFIG_FILE" >&2
  exit 1
fi

# 공통 함수 로드
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/progress.sh"

step 5 "Kafka & Zookeeper 서비스 등록"

# systemd unit 파일 확인 및 복사
for unit in "$ZOOKEEPER_UNIT" "$KAFKA_UNIT"; do
  if [[ -f "$unit" ]]; then
    sudo cp "$unit" /etc/systemd/system/
    log_info "systemd unit 복사 완료: $(basename "$unit")"
  else
    log_error "unit 파일 없음: $unit"
    exit 1
  fi
  sleep 1
  done

# systemctl 데몬 리로드
sudo systemctl daemon-reload

# 서비스 시작 및 enable 설정
for service in zookeeper-service.service kafka-server.service; do
  sudo systemctl start "$service"
  sudo systemctl enable "$service"
  sudo systemctl status "$service" --no-pager || true
  log_info "$service 서비스 시작 및 enable 설정 완료"
  sleep 2
done

log_success "Kafka & Zookeeper 설정 완료"
