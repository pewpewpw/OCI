#!/bin/bash

# 로그 파일 디렉토리 및 파일명 설정
LOG_DIR="/app/Accessories/install/logs"
mkdir -p "$LOG_DIR"

LOG_FILE="${LOG_FILE:-$LOG_DIR/connectome_install.log}"

log_info() {
  echo -e "\e[32m[INFO]\e[0m $1" | tee -a "$LOG_FILE"
}

log_warn() {
  echo -e "\e[33m[WARN]\e[0m $1" | tee -a "$LOG_FILE"
}

log_error() {
  echo -e "\e[31m[ERROR]\e[0m $1" | tee -a "$LOG_FILE" >&2
}

log_success() {
  echo -e "\e[36m[SUCCESS]\e[0m $1" | tee -a "$LOG_FILE"
}
