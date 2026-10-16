#!/usr/bin/env bash
# Installer for the `chess` CLI.
#   ./install.sh            install to ~/.local/bin/chess
#   ./install.sh --system   install to /usr/local/bin/chess (uses sudo)
#   ./install.sh --uninstall [--system]
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/chess"
DEST_DIR="$HOME/.local/bin"
SUDO=""
UNINSTALL=0

for arg in "$@"; do
  case $arg in
    --system)    DEST_DIR=/usr/local/bin ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help)   sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

g=$'\e[32m' y=$'\e[33m' r=$'\e[31m' b=$'\e[1m' n=$'\e[0m'
[[ -t 1 ]] || { g='' y='' r='' b='' n=''; }

if [[ $DEST_DIR == /usr/local/bin && ! -w $DEST_DIR ]]; then SUDO=sudo; fi
DEST="$DEST_DIR/chess"

if ((UNINSTALL)); then
  $SUDO rm -f "$DEST" && echo "${g}✔${n} Removed $DEST"
  echo "  Config (~/.config/chess-cli) and cache (~/.cache/chess-cli) were left in place."
  exit 0
fi

echo "${b}♞ Installing chess${n}"

# bash version
if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3))); then
  echo "${r}✖${n} Bash 4.3+ is required (found $BASH_VERSION)."; exit 1
fi

# dependencies
missing=()
for c in curl jq fzf; do command -v "$c" >/dev/null 2>&1 || missing+=("$c"); done
want_sf=0
command -v stockfish >/dev/null 2>&1 || [[ -x /usr/games/stockfish ]] || want_sf=1

pkg_install() {
  local pkgs=("$@")
  if   command -v apt-get >/dev/null; then sudo apt-get install -y "${pkgs[@]}"
  elif command -v dnf     >/dev/null; then sudo dnf install -y "${pkgs[@]}"
  elif command -v pacman  >/dev/null; then sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  elif command -v zypper  >/dev/null; then sudo zypper install -y "${pkgs[@]}"
  elif command -v apk     >/dev/null; then sudo apk add "${pkgs[@]}"
  else return 1; fi
}

if ((${#missing[@]})); then
  echo "${y}!${n} Missing required: ${missing[*]}"
  read -rp "  Install them with your package manager? [Y/n] " ans
  if [[ ${ans,,} != n* ]]; then
    pkg_install "${missing[@]}" || { echo "${r}✖${n} Please install manually: ${missing[*]}"; exit 1; }
  else
    echo "  Install later: ${missing[*]}"
  fi
fi

if ((want_sf)); then
  echo "${y}!${n} Stockfish not found (optional — needed for Chess.com blunder/mistake analysis)."
  read -rp "  Install stockfish? [Y/n] " ans
  if [[ ${ans,,} != n* ]]; then pkg_install stockfish || echo "  Couldn't install automatically — get it from https://stockfishchess.org/download/"; fi
fi

$SUDO mkdir -p "$DEST_DIR"
$SUDO install -m 755 "$SRC" "$DEST"
echo "${g}✔${n} Installed ${b}$DEST${n}"

case ":$PATH:" in
  *":$DEST_DIR:"*) ;;
  *) echo "${y}!${n} $DEST_DIR is not on your PATH. Add this to ~/.bashrc (or ~/.zshrc):"
     echo "      export PATH=\"$DEST_DIR:\$PATH\"" ;;
esac

echo
echo "  Next:  ${b}chess -u${n}   set your Chess.com / Lichess account"
echo "         ${b}chess -a${n}   review your recent games"
