#!/usr/bin/env bash
# Installs the `fastvpn` command and its dependencies on a Debian/Ubuntu
# machine with NetworkManager. Safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
OVPN_BASE="/etc/openvpn/client"
CONFIG_ZIP_URL="https://vpn.ncapi.io/groupedServerList.zip"
REFRESH_CONFIGS="${1:-}"

echo "==> Installing dependencies (apt)"
sudo apt-get update
sudo apt-get install -y \
  network-manager-openvpn \
  openvpn \
  gnupg \
  pass \
  fzf \
  wget \
  unzip \
  curl

echo "==> Linking fastvpn into $BIN_DIR"
mkdir -p "$BIN_DIR"
chmod +x "$REPO_DIR/fastvpn"
ln -sf "$REPO_DIR/fastvpn" "$BIN_DIR/fastvpn"

if ! printf '%s' "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
  echo "    NOTE: $BIN_DIR isn't on PATH in this shell yet."
  echo "          Debian's default ~/.profile adds it automatically on next login."
  echo "          For this session: source ~/.profile"
fi

echo "==> FastVPN OpenVPN server configs ($OVPN_BASE)"
if [[ -d "$OVPN_BASE/udp" && -n "$(ls -A "$OVPN_BASE/udp" 2>/dev/null)" && "$REFRESH_CONFIGS" != "--refresh-configs" ]]; then
  echo "    Already present — skipping (run with --refresh-configs to force a re-download)."
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  wget -q -O "$tmp/configs.zip" "$CONFIG_ZIP_URL"
  unzip -q "$tmp/configs.zip" -d "$tmp"
  sudo mkdir -p "$OVPN_BASE"
  sudo cp -r "$tmp/tcp" "$tmp/udp" "$OVPN_BASE/"
  echo "    Installed $(ls "$tmp/udp" | wc -l) UDP + $(ls "$tmp/tcp" | wc -l) TCP server configs."
fi

cat <<'EOF'

==> Done. One-time setup (run these yourself — they need your input):
    fastvpn set-username <your-fastvpn-username>
    fastvpn set-pin
    fastvpn set-password

Then try:
    fastvpn up la
    fastvpn help
EOF
