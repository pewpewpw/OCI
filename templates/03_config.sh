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

step 2 "시스템 구성 시작"

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

log_success "시스템 구성 완료"

