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

step 5 "Kibana 설치 시작"

KIBANA_TAR="kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz"
KIBANA_DIR="/app/kibana-${KIBANA_VERSION}-linux-x86_64"
KIBANA_LINK="/app/kibana"
KIBANA_URL="https://artifacts.elastic.co/downloads/kibana/${KIBANA_TAR}"

# 기존 디렉토리 삭제
log_info "기존 Kibana 디렉토리 제거"
sudo rm -rf "$KIBANA_LINK" "$KIBANA_DIR"

# Kibana 패키지 다운로드 및 압축 해제
log_info "Kibana 다운로드 중: $KIBANA_URL"
wget --no-check-certificate "$KIBANA_URL"
tar -xvf "$KIBANA_TAR" -C /app
ln -s "$KIBANA_DIR" "$KIBANA_LINK"

# 시작/중지 스크립트 복사
cp "${INSTALL_HOME}/resource/kibana/start.sh" "$KIBANA_LINK"
cp "${INSTALL_HOME}/resource/kibana/stop.sh" "$KIBANA_LINK"
chmod +x "$KIBANA_LINK/start.sh" "$KIBANA_LINK/stop.sh"

# 압축 파일 삭제
rm "$KIBANA_TAR"

# Kibana 설정 변경
sed -i'' -r -e "/#server.host/a\server.host: \"0.0.0.0\"" "$KIBANA_LINK/config/kibana.yml"

log_success "Kibana ${KIBANA_VERSION} 설치 완료"

