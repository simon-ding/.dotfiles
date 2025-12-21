#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

echo "▶ Dotfiles directory: $DOTFILES_DIR"
echo "▶ Backup directory:   $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# -------- utils --------
backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "  ↪ backing up $target"
    mv "$target" "$BACKUP_DIR/"
  fi
}

symlink() {
  local src="$1"
  local dst="$2"

  backup_if_exists "$dst"
  ln -snf "$src" "$dst"
  echo "  ✔ linked $dst → $src"
}

# -------- OS detect --------
OS="$(uname -s)"
case "$OS" in
  Darwin) PLATFORM="mac" ;;
  Linux)  PLATFORM="linux" ;;
  *)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "▶ Platform: $PLATFORM"

# -------- shell --------
echo "▶ Installing zsh configs"
symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

# -------- starship --------
echo "▶ Installing starship config"
mkdir -p "$HOME/.config"
symlink "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

# -------- git --------
if [[ -f "$DOTFILES_DIR/gitconfig" ]]; then
  echo "▶ Installing git config"
  symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
fi

# -------- vimrc --------
if [[ -f "$DOTFILES_DIR/gitconfig" ]]; then
  echo "▶ Installing vim config"
  symlink "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"
fi


# -------- platform hints --------
echo
echo "▶ Post-install notes:"

if [[ "$PLATFORM" == "mac" ]]; then
  echo "  - Recommended:"
  echo "      brew install starship coreutils grep zsh-autosuggestions zsh-syntax-highlighting"
  echo "      chsh -s /bin/zsh"
fi

if [[ "$PLATFORM" == "linux" ]]; then
  echo "  - Recommended:"
  echo "      install zsh starship zsh-autosuggestions zsh-syntax-highlighting via package manager"
  echo "      curl -sS https://starship.rs/install.sh | sh"
  echo "      chsh -s \$(which zsh)"
fi

echo
echo "✅ Dotfiles installation complete"
echo "➡ Restart terminal or run: exec zsh"
