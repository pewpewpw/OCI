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

# 공통 함수 불러오기
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/progress.sh"
source "${INSTALL_HOME}/lib/config_utils.sh"

MODE="${1:-manager}"

case "$MODE" in
  manager|allinone|scalar)
    log_info "설정 모드: $MODE"
    ;;
  *)
    log_error "사용법: $0 [manager|allinone|scalar]"
    exit 1
    ;;
esac

step 1 "Crontab (${MODE}) 설정 시작"

# 크론탭 파일 경로 설정
case "$MODE" in
  manager)
    CRON_FILE="$CRONTAB_MANAGER"
    ;;
  scalar)
    CRON_FILE="$CRONTAB_SCALAR"
    ;;
  *)
    log_error "지원되지 않는 모드: $MODE"
    exit 1
    ;;
esac

# 유저 확인 및 크론탭 적용
check_user_exists "$INSTALL_USER"

if [[ -f "$CRON_FILE" ]]; then
  crontab -u "$INSTALL_USER" "$CRON_FILE"
  log_success "Crontab 적용 완료: $CRON_FILE"
else
  log_error "Crontab 파일 없음: $CRON_FILE"
  exit 1
fi

