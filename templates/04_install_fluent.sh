#!/bin/bash
set -eEuo pipefail

source "$(dirname "$0")/config/install.config"
source "$(dirname "$0")/../lib/logger.sh"
source "$(dirname "$0")/../lib/progress.sh"

step 3 "Fluentd & plugin install start"

# 1. Ruby 설치 확인
if ! command -v ruby &>/dev/null; then
  log_info "RVM & Ruby install start"
  curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -
  curl -sSL https://get.rvm.io | sudo bash -s stable --ruby
else
  log_info "Ruby already installed: $(ruby --version)"
fi

# 2. RVM 환경 로드
if [[ -s "/etc/profile.d/rvm.sh" ]]; then
  source /etc/profile.d/rvm.sh
else
  log_error "RVM environment not found"
  exit 1
fi

# 3. 사용자 그룹 추가
if id -nG conse | grep -qw "rvm"; then
  log_info "user conse already in rvm group"
else
  sudo usermod -aG rvm conse
  log_info "user conse added to rvm group"
fi

# 4. Fluentd 및 플러그인 설치
declare -A plugins=(
  ["fluentd"]="~> 0.12.0"
  ["fluent-plugin-elasticsearch"]=""
  ["fluent-plugin-datacounter"]="0.4.5"
  ["fluent-plugin-secure-forward"]=""
  ["fluent-plugin-amqp2"]=""
  ["fluent-plugin-grep"]=""
  ["fluent-plugin-record-modifier"]=""
)

for plugin in "${!plugins[@]}"; do
  version="${plugins[$plugin]}"
  if gem list "$plugin" -i >/dev/null; then
    log_info "$plugin already installed"
  else
    if [[ -n "$version" ]]; then
      gem install "$plugin" -v "$version" --no-document
    else
      gem install "$plugin" --no-document
    fi
    log_info "$plugin install complete"
  fi
done

log_success "Fluentd & plugin install complete"
