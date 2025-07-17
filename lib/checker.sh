#!/bin/bash

source "$(dirname "$0")/../lib/logger.sh"

check_user_exists() {
  local user="$1"
  if ! id "$user" &>/dev/null; then
    log_error "user '$user' not found"
    exit 1
  fi
}

check_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    log_error "file not found: $file"
    exit 1
  fi
}

check_crontab_syntax() {
  local file="$1"
  if ! crontab "$file" -l &>/dev/null; then
    log_warn "⚠ crontab syntax check failed: $file"
  fi
}
