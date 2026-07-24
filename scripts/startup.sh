#!/usr/bin/env bash
# Setup script for future unix machines.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STOW_PACKAGES=(zsh git tmux nvim alacritty starship sioyek)

stow_configs() {
	echo "Stowing packages: ${STOW_PACKAGES[*]}"
	mkdir -p "$HOME/.config"
	stow -d "$DOTFILES_DIR" -t "$HOME/.config" "${STOW_PACKAGES[@]}"

	echo "Linking dotfiles that live in \$HOME (zsh, git, tmux)."
	rm -f "$HOME/.gitconfig" "$HOME/.tmux.conf" "$HOME/.zshrc"
	ln -sfn "$HOME/.config/git/gitconfig" "$HOME/.gitconfig"
	ln -sfn "$HOME/.config/zsh/zshrc" "$HOME/.zshrc"
	ln -sfn "$HOME/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
}

download_font() {
	echo "Downloading Meslo nerd font (install manually after)."
	mkdir -p "$HOME/Downloads"
	wget -P "$HOME/Downloads" \
		https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFont-Regular.ttf
}

run_with_brew() {
	command -v stow >/dev/null 2>&1 || brew install stow
	stow_configs
	echo "Installing Brewfile bundle."
	brew bundle --file="$DOTFILES_DIR/homebrew/Brewfile"
	download_font
	echo "Done. Enjoy your kickass dotfiles."
}

run_without_brew() {
	if ! command -v stow >/dev/null 2>&1; then
		echo "Error: stow not installed. Install via your package manager (apt/pacman/apk/pkg_add) then rerun." >&2
		exit 1
	fi
	stow_configs
	command -v wget >/dev/null 2>&1 && download_font || echo "wget missing, skipping font download."
	echo "Done (brew-less path). Install apps manually per your OS."
}

install_brew() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	echo "Homebrew installed. Re-run this script and choose Y."
	exit 0
}

echo "Hello. Time to get the best goddamn setup script on the planet."
echo "Choose install path:"
echo "  y — Homebrew already installed (macOS full setup)"
echo "  n — Homebrew not installed, install it now"
echo "  s — Skip Homebrew entirely (Linux/BSD/manual, stow-only)"

while true; do
	read -rp "Choice [y/n/s]: " choice
	case "$choice" in
	[Yy]*) run_with_brew; break ;;
	[Nn]*) install_brew ;;
	[Ss]*) run_without_brew; break ;;
	*) echo "Invalid. Enter y, n, or s." ;;
	esac
done
