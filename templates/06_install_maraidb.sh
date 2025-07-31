#!/bin/bash

set -eEuo pipefail

# 설치 루트 및 설정 파일 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/install.config"

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "[ERROR] install.config 누락됨: $CONFIG_FILE" >ㅁ&2
  exit 1:ㅂ!
  :ㅂ
fi

# 공통 함수 로드
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/progress.sh"

step 6 "MariaDB systemd 서비스 구성"

SYSTEMD_TARGET_DIR="/etc/systemd/system"

# install.config에서 설정된 경로 사용
SERVICE_FILES=(
  "$MARIADB_SERVICE_UNIT"
  "$MARIADB_SOCKET_UNIT"
  "$MARIADB_EXTRA_SOCKET_UNIT"
)

# 서비스 파일 복사
for src in "${SERVICE_FILES[@]}"; do
  file_name="$(basename "$src")"
  dst="$SYSTEMD_TARGET_DIR/$file_name"

  if [[ -f "$src" ]]; then
    log_info "$file_name 복사 중 → $dst"
    sudo cp "$src" "$dst"
    sudo chmod 644 "$dst"
  else
    log_error "$src 파일이 존재하지 않아 복사 중단"
    exit 1
  fi
  sleep 1
done

# systemd 데몬 리로드
log_info "systemd 데몬 리로드"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sleep 1

# mariadb 관련 서비스 enable 및 start
log_info "mariadb 관련 서비스 enable 및 start"
SERVICES=(
  "$(basename "$MARIADB_SERVICE_UNIT")"
  "$(basename "$MARIADB_SOCKET_UNIT")"
  "$(basename "$MARIADB_EXTRA_SOCKET_UNIT")"
)
for svc in "${SERVICES[@]}"; do
  sudo systemctl enable "$svc"
  sudo systemctl start "$svc"
  if systemctl is-active --quiet "$svc"; then
    log_success "✅ $svc 정상 구동 중"
  else
    log_warn "⚠️ $svc 비정상 상태, 확인 필요"
  fi
  sleep 1
done

log_success "MariaDB systemd 서비스 구성 완료"

