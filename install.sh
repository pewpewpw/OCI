#!/bin/bash
set -eEuo pipefail

# 공통 유틸 불러오기
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logger.sh"
source "$SCRIPT_DIR/lib/progress.sh"
source "$SCRIPT_DIR/config/install.config"

trap 'rollback_on_error $CURRENT_STEP $LINENO' ERR

CURRENT_STEP=0

main() {
  log_info "Connectome install start"
  echo ""

  # 사전 검사
  bash "$SCRIPT_DIR/templates/01_install_crontab.sh" "${1:-manager}"
  CURRENT_STEP=1

  bash "$SCRIPT_DIR/templates/04_install_rabbitMQ.sh"
  CURRENT_STEP=2

  bash "$SCRIPT_DIR/templates/05_install_utility.sh"
  CURRENT_STEP=3

  bash "$SCRIPT_DIR/templates/06_config.sh" "${1:-manager}"
  CURRENT_STEP=4

  bash "$SCRIPT_DIR/templates/07_install_kibana_v7.sh"
  CURRENT_STEP=5

  bash "$SCRIPT_DIR/templates/08_config_kafka.sh"
  CURRENT_STEP=6

  bash "$SCRIPT_DIR/templates/final_check.sh"
  CURRENT_STEP=7

  log_success "Connectome install complete"
}

# 롤백 함수: 단계별 정의 시 추가
rollback_on_error() {
  local step="$1"
  local lineno="$2"
  log_error "error occored (Step $step, Line $lineno)"
    exit 1
}

main "$@"
