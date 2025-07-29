#!/bin/bash
set -eEuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_HOME="$(dirname "$SCRIPT_DIR")"

source "${INSTALL_HOME}/lib/logger.sh"

log_info "불필요 사용자 삭제 및 system 계정 nologin 설정 시작"

# 삭제할 사용자 목록
USERS_TO_DELETE=("games" "news" "irc")
for user in "${USERS_TO_DELETE[@]}"; do
  if id "$user" &>/dev/null; then
    sudo deluser "$user" && log_info "$user 계정 삭제 완료"
  else
    log_warn "$user 계정이 존재하지 않음"
  fi
done

# nologin 설정할 시스템 계정 목록
SYSTEM_USERS=("daemon" "bin" "sys" "sync" "man" "lp" "mail" "uucp" "proxy" "www-data" "backup" "list" "gnats" "nobody" "libuuid")
for user in "${SYSTEM_USERS[@]}"; do
  if id "$user" &>/dev/null; then
    sudo usermod -s /usr/sbin/nologin "$user" && log_info "$user 계정 nologin 설정 완료"
  else
    log_warn "$user 계정이 존재하지 않음"
  fi
done

# 제거할 디렉토리 및 파일
DIRS_TO_REMOVE=(
  "/usr/games"
  "/usr/local/games"
  "/usr/share/doc/netcat-openbsd/examples/irc"
)

for path in "${DIRS_TO_REMOVE[@]}"; do
  if [[ -e "$path" ]]; then
    sudo rm -rf "$path" && log_info "$path 제거 완료"
  else
    log_warn "$path 경로 없음"
  fi
done

log_success "사용자/디렉터리 정리 완료"

