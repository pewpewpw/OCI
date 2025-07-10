#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/logger.sh"
source "$(dirname "$0")/../lib/checker.sh"
source "$(dirname "$0")/../lib/progress.sh"

CRON_DIR="$(dirname "$0")/../resource"
USER="conse"

mode="${1:-manager}"

step 3 "Crontab (${mode}) initiating"

# user confirm
check_user_exists "$USER"

# crontab 파일 경로 결정
case "$mode" in
  manager)
    CRON_FILE="${CRON_DIR}/cron.tab"
    ;;
  scalar)
    CRON_FILE="${CRON_DIR}/cron.tab.s"
    ;;
  *)
    log_error "모드 인자 오류: [manager|scalar] 중 선택해야 합니다."
    exit 1
    ;;
esac

# 파일 존재 확인
if [[ ! -f "$CRON_FILE" ]]; then
  log_error "crontab 파일 없음: $CRON_FILE"
  exit 1
fi

# 문법 검사
if ! crontab -u "$USER" -c "$CRON_FILE" 2>/dev/null; then
  log_warn "crontab 문법 확인 실패. 적용 전 수동 검사 필요: $CRON_FILE"
fi

# 멱등성 검사: 현재 크론탭과 다를 때만 적용
TEMP_CRON=$(mktemp)
sudo su - "$USER" -c crontab -l > "$TEMP_CRON" || true
if ! diff -q "$TEMP_CRON" "$CRON_FILE" > /dev/null; then
  sudo su - "$USER" -c "crontab < $CRON_FILE"
  log_info "crontab 적용 완료: $CRON_FILE"
else
  log_info "변경 사항 없음. crontab 유지"
fi
rm -f "$TEMP_CRON"

log_success "Crontab 설정 완료"
