#!/bin/bash

source "$(dirname "$0")/logger.sh"

check_user_exists() {
  local user="$1"
  if ! id "$user" &>/dev/null; then
    log_error "사용자 '$user' 가 존재하지 않습니다."
    exit 1
  fi
}

check_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    log_error "파일이 존재하지 않습니다: $file"
    exit 1
  fi
}

check_crontab_syntax() {
  local file="$1"
  if ! crontab "$file" -l &>/dev/null; then
    log_warn "⚠ crontab 문법 확인 실패: $file"
  fi
}
