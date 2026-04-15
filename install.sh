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

  curl -fsSL https://raw.githubusercontent.com/anthropic/claude-cli/main/install.sh | sh
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

if command_exists curl; then
  install_claude_cli
else
  error "curl is not installed. Please install curl and try again."
fi

info "Claude CLI installation complete."
info "The repository .gitconfig is now linked to ~/.gitconfig."
info "Run 'claude --help' after opening a new shell session."
