#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

STRICT_TOOLS="${STRICT_TOOLS:-false}"
CODEX_CLOUD="${CODEX_CLOUD:-false}"
SKIP_TERRAFORM="${SKIP_TERRAFORM:-false}"
SKIP_CLOUDFLARED="${SKIP_CLOUDFLARED:-false}"
SKIP_GH="${SKIP_GH:-false}"
SKIP_PYTHON_DEPS="${SKIP_PYTHON_DEPS:-false}"

log(){ printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
info(){ log "INFO: $*"; }
warn(){ log "WARN: $*" >&2; }
die(){ log "ERROR: $*" >&2; exit 1; }
has(){ command -v "$1" >/dev/null 2>&1; }

require_or_skip(){
  local cmd="$1"
  if has "$cmd"; then
    return 0
  fi
  [[ "$STRICT_TOOLS" == "true" ]] && die "required command missing: $cmd"
  warn "command missing: $cmd; skipping dependent operation"
  return 1
}

apt_available(){ has apt-get && has sudo; }

apt_install(){
  if ! apt_available; then
    [[ "$STRICT_TOOLS" == "true" ]] && die "sudo/apt-get unavailable"
    warn "sudo or apt-get unavailable; skipped package install: $*"
    return 0
  fi
  sudo apt-get install -y "$@"
}

apt_update(){
  if ! apt_available; then
    [[ "$STRICT_TOOLS" == "true" ]] && die "sudo/apt-get unavailable"
    warn "sudo or apt-get unavailable; skipped apt-get update"
    return 0
  fi
  sudo apt-get update
}

install_core(){
  info "installing core dependencies"
  apt_update
  apt_install curl wget unzip jq git make python3 python3-pip python3-venv ca-certificates gnupg lsb-release software-properties-common
}

install_terraform(){
  [[ "$SKIP_TERRAFORM" == "true" ]] && { warn "SKIP_TERRAFORM=true; skipped Terraform install"; return 0; }
  has terraform && { info "terraform already installed: $(terraform version | head -n 1)"; return 0; }
  apt_available || { warn "sudo/apt-get unavailable; skipped Terraform install"; return 0; }
  require_or_skip wget || return 0
  require_or_skip gpg || return 0
  require_or_skip lsb_release || return 0

  info "installing Terraform"
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  apt_update
  apt_install terraform
  terraform version || warn "terraform verification failed"
}

install_python_deps(){
  [[ "$SKIP_PYTHON_DEPS" == "true" ]] && { warn "SKIP_PYTHON_DEPS=true; skipped Python deps"; return 0; }
  require_or_skip python3 || return 0
  info "installing Python test dependencies"
  python3 -m pip install --user --upgrade pip || warn "pip upgrade failed"
  python3 -m pip install --user pytest pytest-cov requests pyyaml || warn "Python dependency install failed"
}

install_cloudflared(){
  [[ "$SKIP_CLOUDFLARED" == "true" ]] && { warn "SKIP_CLOUDFLARED=true; skipped cloudflared install"; return 0; }
  has cloudflared && { info "cloudflared already installed: $(cloudflared --version 2>/dev/null | head -n 1)"; return 0; }
  apt_available || { warn "sudo/apt-get unavailable; skipped cloudflared install"; return 0; }
  require_or_skip wget || return 0

  info "installing cloudflared"
  local deb="/tmp/cloudflared-linux-amd64.deb"
  wget -q -O "$deb" https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb || { warn "cloudflared download failed"; return 0; }
  sudo dpkg -i "$deb" || warn "cloudflared install failed"
}

install_gh(){
  [[ "$SKIP_GH" == "true" ]] && { warn "SKIP_GH=true; skipped GitHub CLI install"; return 0; }
  has gh && { info "gh already installed: $(gh --version | head -n 1)"; return 0; }
  apt_available || { warn "sudo/apt-get unavailable; skipped GitHub CLI install"; return 0; }
  require_or_skip curl || return 0

  info "installing GitHub CLI"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none || { warn "GitHub CLI key download failed"; return 0; }
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  apt_update
  apt_install gh
}

print_versions(){
  echo
  echo "========================================="
  echo "Installed Versions"
  echo "========================================="
  has terraform && terraform version | head -n 1 || warn "terraform not installed"
  has python3 && python3 --version || warn "python3 not installed"
  has pytest && pytest --version || warn "pytest not installed"
  has cloudflared && cloudflared --version || warn "cloudflared not installed"
  has gh && gh --version | head -n 1 || warn "gh not installed"
  echo
}

main(){
  info "bootstrap-system start"
  [[ "$CODEX_CLOUD" == "true" ]] && info "CODEX_CLOUD=true"
  install_core
  install_terraform
  install_python_deps
  install_cloudflared
  install_gh
  print_versions
  info "bootstrap complete"
}

main "$@"
