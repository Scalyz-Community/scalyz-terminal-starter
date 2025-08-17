#!/usr/bin/env bash
set -euo pipefail

BRAND_NAME="${BRAND_NAME:-scalyz.com}"
BRAND_COLOR="${BRAND_COLOR:-#407EC9}"

info() { printf "\033[1;34m[info]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m[ ok ]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err()  { printf "\033[1;31m[err ]\033[0m %s\n" "$*"; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || return 1; }

OS="$(uname -s)"
PKG=""
install_pkgs() {
  case "$OS" in
    Darwin)
      if ! need_cmd brew; then
        err "Homebrew is required. Install from https://brew.sh and re-run."; exit 1
      fi
      brew install zsh tmux git curl ripgrep fzf jq
      ;;
    Linux)
      if need_cmd apt; then PKG=apt; fi
      if need_cmd apt-get; then PKG=apt-get; fi
      if need_cmd dnf; then PKG=dnf; fi
      if need_cmd yum; then PKG=yum; fi
      if need_cmd apk; then PKG=apk; fi
      case "$PKG" in
        apt|apt-get)
          sudo $PKG update -y
          sudo $PKG install -y zsh tmux git curl ca-certificates ripgrep fzf jq xclip || true
          ;;
        dnf|yum)
          sudo $PKG install -y zsh tmux git curl ripgrep fzf jq xclip || true
          ;;
        apk)
          sudo $PKG add --no-cache zsh tmux git curl ripgrep fzf jq xclip || true
          ;;
        *)
          warn "Unknown package manager. Please install zsh tmux git curl manually."
          ;;
      esac
      ;;
    *) warn "Unsupported OS: $OS" ;;
  esac
}

backup() {
  local f="$1"; [[ -f "$f" ]] && cp "$f" "$f.bak" && info "Backed up $f to $f.bak" || true
}

write_tmux() {
  backup "$HOME/.tmux.conf"
  sed "s/#407EC9/${BRAND_COLOR}/g; s/scalyz.com/${BRAND_NAME}/g" tmux.conf > "$HOME/.tmux.conf"
  ok "Installed ~/.tmux.conf (brand: $BRAND_NAME $BRAND_COLOR)"
}

install_ohmyzsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh (unattended)"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
      err "Oh My Zsh install failed"; exit 1; }
  else
    info "Oh My Zsh already present"
  fi
}

install_theme_and_rc() {
  mkdir -p "$HOME/.oh-my-zsh/custom/themes"
  sed "s/#407EC9/${BRAND_COLOR}/g; s/scalyz.com/${BRAND_NAME}/g" zsh/scalyz.zsh-theme > "$HOME/.oh-my-zsh/custom/themes/scalyz.zsh-theme"
  ok "Theme installed: ~/.oh-my-zsh/custom/themes/scalyz.zsh-theme"

  # Ensure ZSH_THEME="scalyz"
  if [[ -f "$HOME/.zshrc" ]]; then backup "$HOME/.zshrc"; fi
  if [[ ! -f "$HOME/.zshrc" ]]; then echo "export ZSH=\"$HOME/.oh-my-zsh\"" > "$HOME/.zshrc"; fi
  if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
    sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="scalyz"/' "$HOME/.zshrc"
  else
    printf '\nZSH_THEME="scalyz"\n' >> "$HOME/.zshrc"
  fi

  # Append our config block once
  if ! grep -q '>>> scalyz-terminal-starter >>>' "$HOME/.zshrc"; then
    {
      printf '\n# >>> scalyz-terminal-starter >>>\n'
      sed "s/#407EC9/${BRAND_COLOR}/g; s/scalyz.com/${BRAND_NAME}/g" zsh/zshrc.append
      printf '\n# <<< scalyz-terminal-starter <<<\n'
    } >> "$HOME/.zshrc"
  fi
  ok "Configured ~/.zshrc"
}

maybe_chsh() {
  if [[ "$SHELL" != *"zsh"* ]]; then
    if command -v chsh >/dev/null 2>&1; then
      info "Changing default shell to zsh (you may be prompted for your password)"
      sudo chsh -s "$(command -v zsh)" "$(whoami)" || warn "Could not change shell. Do it manually with: chsh -s $(command -v zsh)"
    else
      warn "chsh not available; set your shell to zsh manually."
    fi
  fi
}

main() {
  info "Installing base packages…"; install_pkgs
  info "Installing/Configuring Oh My Zsh…"; install_ohmyzsh
  info "Writing tmux config…"; write_tmux
  info "Writing zsh theme/config…"; install_theme_and_rc
  maybe_chsh
  ok "Done! Restart your terminal or run: exec zsh"
}

main "$@"