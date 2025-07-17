#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/config/install.config"
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/checker.sh"
source "${INSTALL_HOME}/lib/progress.sh"

USER="conse"
mode="${1:-manager}"

step 3 "Crontab (${mode}) initiating"

check_user_exists "$USER"

case "$mode" in
  manager)
    CRON_FILE="${RESOURCE_DIR}/cron.tab"
    ;;
  scalar)
    CRON_FILE="${RESOURCE_DIR}/cron.tab.s"
    ;;
  *)
    log_error "mode argument error: [manager|scalar] required"
    exit 1
    ;;
esac

if [[ ! -f "$CRON_FILE" ]]; then
  log_error "crontab 파일 없음: $CRON_FILE"
  exit 1
fi

sudo su - "$USER" -c "crontab < $CRON_FILE"
log_success "Crontab 적용 완료: $CRON_FILE"
