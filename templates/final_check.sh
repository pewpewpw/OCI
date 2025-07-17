#!/bin/bash
set -eEuo pipefail

source "$(dirname "$0")/../lib/logger.sh"
source "$(dirname "$0")/../lib/progress.sh"

step 6 "final check start"

# check service status
check_service() {
  local svc="$1"
  if systemctl is-active --quiet "$svc"; then
    log_success "$svc service running"
  else
    log_error "$svc service inactive or failed"
  fi
}

# check port
check_port() {
  local port="$1"
  if ss -tuln | grep -q ":$port"; then
    log_success "$port port listening"
  else
    log_warn "$port port not listening"
  fi
}

# check directory exists
check_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    log_success "$dir directory exists"
  else
    log_error "$dir directory not found"
  fi
}

log_info "service check"
check_service "cron"
check_service "rabbitmq-server"
check_service "kafka-server"
check_service "zookeeper-service"
check_service "chrony"

log_info "port check"
check_port 5672     # RabbitMQ
check_port 9092     # Kafka
check_port 2181     # Zookeeper
check_port 5601     # Kibana
check_port 9200     # Elasticsearch
check_port 5044     # Logstash
check_port 5045     # logstash2

log_info "directory check"
check_dir "/data/rabbitmq"
check_dir "/data/db"
check_dir "/data/logstash"
check_dir "/app/kibana"
check_dir "/app/elasticsearch"
check_dir "/app/neo4j"
check_dir "/data/connectome"

log_success "final check complete"
