#!/bin/bash
set -eEuo pipefail

source "$(dirname "$0")/../lib/logger.sh"
source "$(dirname "$0")/../lib/progress.sh"
source "$(dirname "$0")/../lib/config_utils.sh"
source "$(dirname "$0")/../config/install.config"

MODE="${1:-}"
OS_VER=$(lsb_release -rs)

# 유효한 모드 확인
case "$MODE" in
  manager|allinone|scalar)
    log_info "config mode: $MODE"
    ;;
  *)
    log_error "how to use: $0 [manager|allinone|scalar]"
    exit 1
    ;;
esac

step 4 "system config start"

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

log_success "system config complete"
