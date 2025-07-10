#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/../lib/logger.sh"

log_info "🧹 Connectome 구성 요소 제거 시작"

# 1. 서비스 비활성화 및 종료
for service in kafka-server zookeeper-service rabbitmq-server chrony; do
  if systemctl is-active --quiet "$service"; then
    sudo systemctl stop "$service"
    log_info "$service 중지됨"
  fi
  if systemctl is-enabled --quiet "$service"; then
    sudo systemctl disable "$service"
    log_info "$service 부팅 자동시작 해제"
  fi
done

# 2. 서비스 유닛 제거
for unit in /etc/systemd/system/kafka-server.service \
            /etc/systemd/system/zookeeper-service.service; do
  if [[ -f "$unit" ]]; then
    sudo rm -f "$unit"
    log_info "$unit 삭제됨"
  fi
done

sudo systemctl daemon-reload

# 3. 심볼릭 링크 및 rc 등록 파일 제거
sudo rm -f /etc/init.d/connectome_stop.sh
sudo rm -f /etc/rc0.d/K99connectome_stop.sh
sudo rm -f /etc/rc6.d/K99connectome_stop.sh

# 4. 주요 디렉토리 제거 (선택적으로 주석 해제)
for dir in \
  /data/rabbitmq \
  /data/db \
  /data/logstash \
  /data/logstash-2 \
  /data/cq_find \
  /data/mysqlbackup \
  /data/connectome \
  /app/kibana \
  /app/kibana-* \
  /app/elasticsearch \
  /app/neo4j; do
  if [[ -d "$dir" ]]; then
    sudo rm -rf "$dir"
    log_info "$dir 삭제됨"
  fi
done

# 5. 사용자 프로파일 정리 (선택사항)
sudo sed -i '/CONNECTOME_HOME/d' /home/conse/.profile || true
sudo sed -i '/CONNECTOME_HOME/d' /root/.profile || true

# 6. 기타 설정 초기화
sudo sed -i '/vm.max_map_count/d' /etc/sysctl.conf || true
sudo sed -i '/pam_limits.so/d' /etc/pam.d/common-session || true
sudo sed -i '/nofile/d' /etc/security/limits.conf || true

log_success "🧽 Connectome 언인스톨 완료 (수동 롤백)"
