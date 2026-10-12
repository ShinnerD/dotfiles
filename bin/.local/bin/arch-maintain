#!/usr/bin/env bash
set -euo pipefail

# Usage: ./arch-maintenance.sh [update|clean|check|all]
# Needs: yay, pacman-contrib (paccache, pacdiff)

REQUIRED=(pacman-contrib)

ensure_deps() {
  local missing=()
  for pkg in "${REQUIRED[@]}"; do
    pacman -Qq "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done
  if ((${#missing[@]})); then
    echo "Installing missing tools: ${missing[*]}"
    sudo pacman -S --needed "${missing[@]}"
  fi
}

do_update() {
  echo "==> Latest Arch news (read before updating!)"
  yay -Pw || true
  echo
  read -rp "Continue with the update? [Y/n] " ans
  [[ "${ans,,}" == "n" ]] && return

  echo "==> Updating repo + AUR packages"
  yay -Syu
}

do_clean() {
  echo "==> Orphaned packages"
  mapfile -t orphans < <(pacman -Qdtq || true)
  if ((${#orphans[@]})); then
    printf '  %s\n' "${orphans[@]}"
    read -rp "Remove these (with configs and unneeded deps)? [y/N] " ans
    [[ "${ans,,}" == "y" ]] && sudo pacman -Rns "${orphans[@]}"
  else
    echo "  none"
  fi

  echo "==> Pacman cache (keeping the 3 latest versions of each package)"
  sudo paccache -r
  echo "==> Pacman cache (removing versions of uninstalled packages)"
  sudo paccache -ruk0

  echo "==> yay build cache (src dirs, pkg dirs, built packages)"
  if [ -d "$HOME/.cache/yay" ]; then
    find "$HOME/.cache/yay" -mindepth 2 -maxdepth 2 \( -name src -o -name pkg \) -type d -exec rm -rf {} +
    find "$HOME/.cache/yay" -mindepth 2 -maxdepth 2 -name '*.pkg.tar.*' -delete
  fi

  echo "==> Journal (keeping 2 weeks)"
  sudo journalctl --vacuum-time=2weeks
}

do_check() {
  echo "==> Failed systemd units"
  systemctl --failed --no-legend || true

  echo "==> Unmerged .pacnew / .pacsave files"
  pacdiff -o || true

  echo "==> Packages with missing files"
  pacman -Qk 2>/dev/null | grep -v ' 0 missing files' || echo "  none"

  echo "==> Foreign (AUR / manually installed) packages"
  pacman -Qm || true

  echo "==> Reboot needed?"
  if [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
    echo "  YES: the running kernel was replaced by an update"
  else
    echo "  no"
  fi

  echo "==> Disk usage"
  df -h / /home 2>/dev/null | awk 'NR==1 || !seen[$1]++'
  du -sh /var/cache/pacman/pkg "$HOME/.cache/yay" 2>/dev/null || true
}

main() {
  ensure_deps
  case "${1:-all}" in
    update) do_update ;;
    clean)  do_clean ;;
    check)  do_check ;;
    all)    do_update; do_clean; do_check ;;
    *) echo "Usage: $0 [update|clean|check|all]"; exit 1 ;;
  esac
  echo "Done."
}

main "$@"
