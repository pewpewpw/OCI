#!/bin/bash
set -eEuo pipefail

source "$(dirname "$0")/config/install.config"
source "$(dirname "$0")/../lib/logger.sh"
source "$(dirname "$0")/../lib/progress.sh"
source "$(dirname "$0")/../config/install.config"

step 5 "Kibana install start"

KIBANA_FILENAME="kibana-${KIBANA_VERSION}-linux-x86_64"
KIBANA_TAR="${KIBANA_FILENAME}.tar.gz"
KIBANA_URL="https://artifacts.elastic.co/downloads/kibana/${KIBANA_TAR}"
KIBANA_INSTALL_DIR="/app"
KIBANA_PATH="${KIBANA_INSTALL_DIR}/${KIBANA_FILENAME}"
KIBANA_LINK="${KIBANA_INSTALL_DIR}/kibana"

# remove existing install
if [[ -d "$KIBANA_LINK" || -d "$KIBANA_PATH" ]]; then
  log_warn "existing Kibana install remove"
  sudo rm -rf "$KIBANA_LINK" "$KIBANA_PATH"
fi

# download
log_info "Kibana download: $KIBANA_URL"
wget --no-check-certificate "$KIBANA_URL" -P /tmp

# unpack
log_info "unpacking..."
sudo tar -xvf "/tmp/$KIBANA_TAR" -C "$KIBANA_INSTALL_DIR"

# create symbolic link
log_info "symbolic link create: /app/kibana → $KIBANA_FILENAME"
sudo ln -s "$KIBANA_PATH" "$KIBANA_LINK"

# copy start.sh & stop.sh
sudo cp "$INSTALL_HOME/resource/kibana/start.sh" "$KIBANA_LINK"
sudo cp "$INSTALL_HOME/resource/kibana/stop.sh" "$KIBANA_LINK"

# modify
log_info "kibana.yml modify (server.host: 0.0.0.0)"
sudo sed -i'' -r -e "/#server.host/a\server.host: \"0.0.0.0\"" "$KIBANA_LINK/config/kibana.yml"

# clean up temporary file
rm -f "/tmp/$KIBANA_TAR"

log_success "Kibana $KIBANA_VERSION install complete"
