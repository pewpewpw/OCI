#!/bin/bash
set -eEuo pipefail

# 현재 install.sh 기준으로 설치 루트 계산
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config/install.config"

# 설정 파일 로드
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "[ERROR] install.config 파일이 존재하지 않습니다: $CONFIG_FILE" >&2
  exit 1
fi

# 공통 함수 스크립트 불러오기
source "${INSTALL_HOME}/lib/logger.sh"
source "${INSTALL_HOME}/lib/progress.sh"
source "${INSTALL_HOME}/lib/config_utils.sh"

MODE="${1:-}"
OS_VER=$(lsb_release -rs)

# 유효한 모드 확인
case "$MODE" in
  manager|allinone|scalar)
    log_info "설정 모드: $MODE"
    ;;
  *)
    log_error "사용법: $0 [manager|allinone|scalar]"
    exit 1
    ;;
esac

step 4 "시스템 설정 구성 시작"

setup_rc_local "$MODE"
setup_profile "$MODE"
setup_connectome_stop
setup_vm_max_map
setup_mongodb_data_dir
setup_file_limits
disable_swap
create_directories
setup_chrony
disable_ssl_for_logstash "$MODE"
setup_nano_syntax
delete_unnecessary_users
cleanup_packages
setup_ssh_keys

log_success "시스템 설정 구성 완료"


main() {
  log_info "Connectome install start"
  echo "" 

  # 사전 검사
  bash "$SCRIPT_DIR/templates/01_install_crontab.sh" "${1:-manager}"
  CURRENT_STEP=1

  #bash "$SCRIPT_DIR/templates/04_install_rabbitMQ.sh"
  #CURRENT_STEP=2

  bash "$SCRIPT_DIR/templates/02_install_utility.sh"
  CURRENT_STEP=2

  bash "$SCRIPT_DIR/templates/03_config.sh" "${1:-manager}"
  CURRENT_STEP=3

  #bash "$SCRIPT_DIR/templates/04_install_fluent.sh"
  #CURRENT_STEP=3

  bash "$SCRIPT_DIR/templates/05_install_kibana_v7.sh"
  CURRENT_STEP=4

  bash "$SCRIPT_DIR/templates/08_config_kafka.sh"
  CURRENT_STEP=5

  bash "$SCRIPT_DIR/templates/final_check.sh"
  CURRENT_STEP=6

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
