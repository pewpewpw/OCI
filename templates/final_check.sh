#!/bin/bash
set -eEuo pipefail

# 설치 루트 및 설정 파일 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config/install.config"

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "[ERROR] install.config 파일이 존재하지 않습니다: $CONFIG_FILE" >&2
  exit 1
fi

# 공통 함수 로드
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/progress.sh"

step 6 "최종 설치 확인 시작"

# 1. 설치 로그 확인
if [[ -f "$LOG_FILE" ]]; then
  log_info "설치 로그 위치: $LOG_FILE"
else
  log_warn "설치 로그가 존재하지 않습니다."
fi

# 2. 주요 디렉토리 확인
for dir in \
  /data/db \
  /data/connectome \
  /app/kibana \
  /app/tomcat-connectome \
  /app/neo4j \
  /app/elasticsearch;
  do
  if [[ -d "$dir" ]]; then
    log_success "디렉토리 존재 확인: $dir"
  else
    log_error "디렉토리 없음: $dir"
  fi
  done

# 3. 필수 서비스 확인
for svc in kafka-server.service zookeeper-service.service;
  do
    if systemctl is-active --quiet "$svc"; then
      log_success "서비스 실행 중: $svc"
    else
      log_error "서비스 비활성화 또는 실패: $svc"
    fi
  done

log_success "최종 설치 확인 완료"

