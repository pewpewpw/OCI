#!/bin/bash
set -eEuo pipefail

source "$(dirname "$0")/config/install.config"
source "$(dirname "$0")/../lib/logger.sh"
source "$(dirname "$0")/../lib/progress.sh"
source "$(dirname "$0")/../config/install.config"

step 6 "Kafka & Zookeeper systemd service setup"

setup_service() {
  local name="$1"     # Kafka
  local unit="$2"     # kafka-server.service
  local unit_file="$INSTALL_HOME/resource/$unit"

  log_info "$name systemd unit copy: $unit"
  if [[ -f "$unit_file" ]]; then
    sudo cp "$unit_file" /etc/systemd/system/
  else
    log_error "$unit_file file not found"
    exit 1
  fi

  log_info "$name service reload and register"
  sudo systemctl daemon-reload
  sudo systemctl enable "$unit"
  sudo systemctl restart "$unit"

  if systemctl is-active --quiet "$unit"; then
    log_success "$name service start success"
  else
    log_error "$name service start failed"
    exit 1
  fi
}

setup_service "Zookeeper" "zookeeper-service.service"
setup_service "Kafka" "kafka-server.service"

log_success "Kafka & Zookeeper serivce setup complete"
