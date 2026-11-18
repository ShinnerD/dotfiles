# dotfiles

Personal terminal and shell setup for Arch Linux: **kitty** + **zsh** with **Powerlevel10k**, managed with [GNU Stow](https://www.gnu.org/software/stow/).

One script installs everything, generates locales, backs up any existing config, and symlinks the dotfiles into place.

## What's included

| Directory | Contents |
|-----------|----------|
| `zsh/`    | `.zshrc`, `.p10k.zsh` |
| `kitty/`  | `kitty.conf`, `current-theme.conf` |
| `herdr/`  | `config.toml` |
| `bin/`    | `arch-maintain` |
| `nvim/`    | `NeoVim configuration` |

### Packages installed

#### From the official repos (pacman)

- base-devel git github-cli lazygit stow
- nodejs npm go
- kitty zsh neovim
- zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
- fzf zoxide fd
- ttf-meslo-nerd ttf-hack-nerd

#### From the AUR (yay)

- `zsh-theme-powerlevel10k-git`
`yay` is bootstrapped automatically if it isn't already installed.

#### Other

- [`herdr`](https://herdr.dev) — terminal workspace manager for coding agents, installed with its official script (`curl -fsSL https://herdr.dev/install.sh | sh`). Skipped if already installed. Its `config.toml` is stowed from `herdr/`.

## Quick start

On a fresh Arch install:

```bash
sudo pacman -S --needed git
git clone https://github.com/ShinnerD/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x terminal-shell-setup.sh
./terminal-shell-setup.sh
```

Log out and back in afterwards so the default shell change takes effect.

## What the script does

1. Runs a full system update (`pacman -Syu`) and installs all official packages in one transaction.
2. Generates the `en_US.UTF-8` and `en_DK.UTF-8` locales. Without these, tools like fzf's Perl-based shell integration print locale warnings.
3. Installs `yay` if missing, then installs the AUR packages.
4. Installs the `herdr` CLI via its install script if it isn't already installed.
5. Prompts for `gh auth login` if you aren't already logged in to GitHub.
6. Clones this repo to `~/dotfiles`, or pulls if it already exists.
7. Moves any existing `.zshrc`, `.p10k.zsh`, `kitty.conf`, `current-theme.conf` and herdr's `config.toml` to `~/.dotfiles-backup/<timestamp>/`.
8. Runs `stow --no-folding zsh kitty bin herdr` and `stow nvim` to symlink the files into `$HOME`.
9. Sets zsh as the default shell with `chsh`.
The script is safe to re-run: packages are installed with `--needed`, herdr is skipped if present, locale lines that are already enabled are left alone, and the repo is pulled rather than re-cloned.

## Manual usage

Once the packages are installed, you can manage the dotfiles directly with Stow:

```bash
cd ~/dotfiles
stow --no-folding zsh kitty bin herdr # link
stow -D zsh kitty bin herdr           # unlink
stow --no-folding -R zsh        # re-link one package
```

`--no-folding` makes Stow link individual files rather than whole directories, so other programs (and herdr's sockets, logs and session state) can still write into `~/.config/kitty/` and `~/.config/herdr/` without ending up inside this repo.

## Notes

- **Fonts:** set your terminal font to a Nerd Font (e.g. `MesloLGS Nerd Font` or `Hack Nerd Font`) so Powerlevel10k icons render correctly. The kitty config should already do this.
- **Prompt:** run `p10k configure` to regenerate `.p10k.zsh`, then commit the result.
- **AUR trust:** the script installs AUR packages with `--noconfirm`, which skips PKGBUILD review. Remove that flag if you'd like to inspect them first.
- **Locales:** if you want different locales, edit the list in the "Generating locales" section of the script and make sure `/etc/locale.conf` matches.

## Requirements

- Arch Linux (or an Arch-based distro using `pacman`)

## System maintenance

`arch-maintain` is available for keeping an installed system tidy. It needs `yay` and installs `pacman-contrib` itself if it's missing.

```bash
arch-maintain        # run everything (same as "all")
arch-maintain update # news + full system update
arch-maintain clean  # orphans, caches, journal
arch-maintain check  # read-only health checks
```

| Mode | What it does |
| ------ | -------------- |
| `update` | Shows the latest Arch news (`yay -Pw`), then runs `yay -Syu` for repo and AUR packages. |
| `clean` | Lists orphaned packages and asks before removing them, trims the pacman cache to the 3 latest versions per package, removes cached versions of uninstalled packages, clears yay's build files, and vacuums the journal to 2 weeks. |
| `check` | Reports failed systemd units, unmerged `.pacnew`/`.pacsave` files, packages with missing files, foreign (AUR) packages, whether a reboot is needed after a kernel update, and cache disk usage. |

Nothing is removed without confirmation except cache and journal cleanup. `check` never changes anything, so it's safe to run at any time. Merge any `.pacnew` files it finds with `sudo pacdiff`.
