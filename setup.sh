#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/ShinnerD/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

PACMAN_PACKAGES=(
  base-devel git github-cli lazygit stow
  nodejs npm go
  kitty zsh neovim
  zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
  fzf zoxide fd luarocks tree-sitter-cli
  ttf-meslo-nerd ttf-hack-nerd
)

AUR_PACKAGES=(
  zsh-theme-powerlevel10k-git
)

echo "Updating system and installing packages.."
sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"

if ! command -v yay >/dev/null 2>&1; then
  echo "Installing yay.."
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

echo "Installing AUR packages.."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

if ! gh auth status >/dev/null 2>&1; then
  echo "Please login to GitHub.."
  gh auth login
fi

echo "Generating locales.."
for loc in en_US.UTF-8 en_DK.UTF-8; do
  sudo sed -i "s/^#\s*\(${loc//./\\.} UTF-8\)/\1/" /etc/locale.gen
done
sudo locale-gen

echo "Fetching dotfiles.."
if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" pull
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

echo "Backing up existing files to $BACKUP_DIR.."
mkdir -p "$BACKUP_DIR"
for f in \
  "$HOME/.zshrc" \
  "$HOME/.p10k.zsh" \
  "$HOME/.config/kitty/kitty.conf" \
  "$HOME/.config/kitty/current-theme.conf" \
  "$HOME/.local/bin/arch-maintain" \
  "$HOME/.config/nvim"; do
  if [ -e "$f" ] || [ -L "$f" ]; then
    mv "$f" "$BACKUP_DIR/"
  fi
done

echo "Stowing files.."
cd "$DOTFILES_DIR"
stow --no-folding zsh kitty bin
stow nvim

if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo "Setting zsh as default shell.."
  chsh -s "$(command -v zsh)"
fi

echo "Done."
