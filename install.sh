#!/usr/bin/env bash
set -euo pipefail

info() {
  printf '\033[1;34m%s\033[0m\n' "$*"
}

warn() {
  printf '\033[1;33m%s\033[0m\n' "$*"
}

error() {
  printf '\033[1;31m%s\033[0m\n' "$*"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_claude_cli() {
  info "Installing Claude CLI using Anthropic's approved curl installer..."
  if ! command_exists curl; then
    error "curl is not installed. Please install curl and try again."
  fi

  local urls=(
    "https://cli.anthropic.com/install.sh"
    "https://claude.ai/install.sh"
    "https://claude.ai/cli/install.sh"
    "https://anthropic.com/cli/install.sh"
    "https://raw.githubusercontent.com/anthropic/claude/main/install.sh"
    "https://raw.githubusercontent.com/anthropic/claude-cli/main/install.sh"
  )
  local installer_url="${CLAUDE_INSTALL_URL:-}"

  if [ -n "$installer_url" ]; then
    info "Using Claude installer URL from CLAUDE_INSTALL_URL: $installer_url"
  else
    for url in "${urls[@]}"; do
      info "Checking Claude installer URL: $url"
      if curl -fsSL -o /dev/null -w "%{http_code}" -L "$url" >/dev/null 2>&1; then
        installer_url="$url"
        break
      fi
    done
  fi

  if [ -z "$installer_url" ]; then
    error "Unable to find a working Claude CLI installer URL. Checked: ${urls[*]}. Please verify the current Anthropic CLI installer location and set CLAUDE_INSTALL_URL if needed."
  fi

  info "Downloading Claude installer from $installer_url"
  curl -fsSL "$installer_url" | sh
}

link_gitconfig() {
  local src="$PWD/.gitconfig"
  local dest="$HOME/.gitconfig"

  if [ ! -f "$src" ]; then
    error "Missing .gitconfig in the repository root."
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup="$HOME/.gitconfig.backup.$(date +%s)"
    mv "$dest" "$backup"
    info "Existing ~/.gitconfig backed up to $backup"
  fi

  ln -sf "$src" "$dest"
  info "Linked $src -> $dest"
}

link_gitconfig

install_claude_cli

info "Claude CLI installation complete."
info "The repository .gitconfig is now linked to ~/.gitconfig."
info "Run 'claude --help' after opening a new shell session."
