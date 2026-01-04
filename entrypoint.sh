#!/bin/bash

# GITHUB_USERNAME="girts521"
DOTFILES_REPO="git@github.com:$GITHUB_USERNAME/dotfiles.git"
TARGET_DIR="$HOME/.dotfiles"

echo "🔑 Fetching public keys..."

#Make sure the ssh dir exists
mkdir -p ~/.ssh

# Get the keys from github
KEYS=$(curl -sL "https://github.com/$GITHUB_USERNAME.keys")
echo $KEYS >~/.ssh/authorized_keys

chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

echo "⚙️  Setting up Dotfiles..."
ssh-keyscan github.com >>~/.ssh/known_hosts
if [ ! -d "$TARGET_DIR" ]; then
  echo "Cloning a fresh setup"
  git clone "$DOTFILES_REPO" "$TARGET_DIR"
  ln -sf "$TARGET_DIR/.zshrc" ~/.zshrc
  mkdir -p ~/.config
  ln -sf "$TARGET_DIR/.config/nvim" ~/.config/nvim
else
  echo "Updating existing dotfiles"
  git -C "$TARGET_DIR" pull
fi

echo "Starting the shell environment"

sudo mkdir -p /var/run/tailscale /var/lib/tailscale
sudo tailscaled --tun=userspace-networking \
  --socks5-server=localhost:1055 \
  --socket=/var/run/tailscale/tailscaled.sock \
  --state=/var/lib/tailscale/tailscaled.state >/dev/null 2>&1 &
sleep 2
# sudo tailscale set --operator=$USER
sudo tailscale up --hostname=temp-docker-$(date +%s) --accept-dns=true --accept-routes

cleanup() {
  echo "\nCleaning up Tailscale session..."
  sudo tailscale logout >/dev/null 2>&1
  sudo pkill tailscaled
}
trap cleanup EXIT

if [ "$1" = "remote" ]; then
  echo "Starting the ssh server..."
  sudo ssh-keygen -A
  sudo /usr/sbin/sshd -D -e
else
  echo "Starting ZSH"
  zsh
fi
