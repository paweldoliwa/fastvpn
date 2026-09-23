# fastvpn

Command-line control for Namecheap FastVPN on Linux via NetworkManager +
OpenVPN. Built for a terminal/tiling-WM workflow (no GUI network applet
needed) — search or fuzzy-pick any of the ~150 FastVPN server locations,
connect/disconnect with one command, password stored via `pass` behind a
PIN instead of in plain text.

## Install

```sh
git clone <this-repo-url> ~/fastvpn-cli
cd ~/fastvpn-cli
./install.sh
```

This installs `network-manager-openvpn`, `openvpn`, `gnupg`, `pass`, `fzf`
via `apt`, downloads the FastVPN OpenVPN server config bundle into
`/etc/openvpn/client/{udp,tcp}`, and symlinks `fastvpn` into
`~/.local/bin/fastvpn`. Safe to re-run; add `--refresh-configs` to force a
fresh download of the server list.

Because `fastvpn` is symlinked (not copied) into `~/.local/bin`, a later
`git pull` in this directory takes effect immediately — no need to re-run
the installer just to pick up script changes.

### One-time setup (per machine)

```sh
fastvpn set-username <your-fastvpn-username>   # from the FastVPN dashboard,
                                                # not your Namecheap login
fastvpn set-pin                                # choose a PIN, typed twice
fastvpn set-password                           # your FastVPN password
```

The PIN protects a dedicated GPG key that `pass` encrypts your FastVPN
password to. Nothing sensitive is stored in this repo or committed to git —
`set-username`/`set-pin`/`set-password` write only to `~/.config/fastvpn/`
and `~/.password-store/`, both outside the repo.

## Usage

```sh
fastvpn up la             # connect to Los Angeles (saved alias)
fastvpn up germany         # free-text search across the whole catalog
fastvpn pick                # interactive fuzzy picker (fzf)
fastvpn down
fastvpn toggle               # connect/disconnect; default with no args
fastvpn status
fastvpn list                  # configured aliases
fastvpn help                   # full command reference
```

The first time you connect to a given location it's lazily imported into
NetworkManager and you're prompted for your PIN; reconnecting to an
already-configured location never prompts again.

## Updating on another machine

```sh
cd ~/fastvpn-cli && git pull
```
