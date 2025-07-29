#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

setup_rc_local() {
  local mode="$1"
  local rc_file_var="RC_LOCAL_${mode^^}"  # 대문자로 변환 (manager → RC_LOCAL_MANAGER)
  local rc_file="${!rc_file_var}"

  if [[ -f "$rc_file" ]]; then
    sudo cp "$rc_file" /etc/rc.local
    sudo chmod +x /etc/rc.local
    log_info "/etc/rc.local complete ($mode)"
  else
    log_warn "rc.local can't find: $rc_file"
  fi
}

setup_profile() {
  local mode="$1"
  local profile_var="PROFILE_${mode^^}"
  local profile_file="${!profile_var}"

  if [[ -f "$profile_file" ]]; then
    if ! grep -q "CONNECTOME_HOME" /home/conse/.profile; then
      cat "$profile_file" >> /home/conse/.profile
      sudo su -c "cat $profile_file >> /root/.profile"
      log_info ".profile complete ($mode)"
    else
      log_info ".profile already complete"
    fi
  else
    log_warn ".profile can't find: $profile_file"
  fi
}

setup_connectome_stop() {
  local stop_script="/app/Accessories/bin/connectome_stop.sh"

  sudo ln -sf "$stop_script" /etc/init.d/connectome_stop.sh
  sudo ln -sf "$stop_script" /etc/rc0.d/K99connectome_stop.sh
  sudo ln -sf "$stop_script" /etc/rc6.d/K99connectome_stop.sh
  sudo update-rc.d connectome_stop.sh defaults

  log_info "connectome_stop complete"
}

setup_vm_max_map() {
  sudo sysctl -w vm.max_map_count=262144
  echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf > /dev/null
  log_info "vm.max_map_count complete"
}

setup_mongodb_data_dir() {
  sudo mkdir -p /data/db
  sudo chown conse:conse /data/db
  log_info "/data/db dir auth complete"
}

setup_file_limits() {
  local limits_file="/etc/security/limits.conf"
  local pam_file="/etc/pam.d/common-session"

  grep -q 'nofile' "$limits_file" || cat "$INSTALL_HOME/resource/max_open_file.txt" | sudo tee -a "$limits_file" > /dev/null
  grep -q 'pam_limits.so' "$pam_file" || echo "session required pam_limits.so" | sudo tee -a "$pam_file" > /dev/null

  log_info "file and PAM complete"
}

disable_swap() {
  sudo cp /etc/fstab /etc/fstab.bak
  awk '{ if ($3 == "swap") print "#" $0; else print $0 }' /etc/fstab.bak | sudo tee /etc/fstab > /dev/null
  log_info "disable swap complete (fstab)"
}

create_directories() {
  for dir in \
    /app/tomcat-connectome/logs \
    /data/connectome \
    /data/logstash/old_log \
    /data/logstash-2/old_log \
    /data/mysqlbackup \
    /data/cq_find \
    /app/neo4j/logs \
    /app/elasticsearch/logs; do
    sudo mkdir -p "$dir"
  done

  log_info "Log And data dir complete"
}

setup_chrony() {
  sudo apt-get install -y chrony
  sudo cp "$INSTALL_HOME/resource/chrony.conf" /etc/chrony/chrony.conf
  sudo timedatectl set-timezone Asia/Seoul
  sudo timedatectl set-ntp true
  sudo systemctl restart chrony
  log_info "chrony complete"
}

disable_ssl_for_logstash() {
  local mode="$1"
  local file="/app/logstash/conf.d/10_input.conf"
  if [[ "$mode" == "allinone" && -f "$file" ]]; then
    sed -i 's/^ssl =>/#ssl =>/g' "$file"
    sed -i 's/^ssl_certi/#ssl_certi/g' "$file"
    sed -i 's/^ssl_key/#ssl_key/g' "$file"
    log_info "allinone mode logstash SSL inactive"
  fi
}

setup_nano_syntax() {
  local syntax_file="$INSTALL_HOME/resource/nano-syntax-highlighter.tar.gz"
  if [[ -f "$syntax_file" ]]; then
    sudo tar -zxf "$syntax_file" -C /usr/share/nano/
    log_info "nano syntax highlighter complete"
  fi
}

delete_unnecessary_users() {
  if [[ -x "$INSTALL_HOME/resource/userdelete.sh" ]]; then
    "$INSTALL_HOME/resource/userdelete.sh"
    log_info "unnecessary users complete"
  else
    log_warn "userdelete.sh can't find"
  fi
}

cleanup_packages() {
  sudo apt-get -y autoremove
  sudo apt-get -y autoclean
  sudo apt -y remove unattended-upgrades
  log_info "package clean up"
}

