#!/bin/bash
set -euo pipefail

VIM_SRC="$HOME/src/vim"
PREFIX="/usr/local"

# Install build dependencies
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  libncurses5-dev \
  libx11-dev \
  libxt-dev \
  libxpm-dev \
  python3-dev \
  git

# Clone or fetch
if [ -d "$VIM_SRC/.git" ]; then
  echo "Existing repo found, fetching updates..."
  cd "$VIM_SRC"
  git fetch --tags --prune
else
  echo "Cloning Vim repository..."
  mkdir -p "$(dirname "$VIM_SRC")"
  git clone https://github.com/vim/vim.git "$VIM_SRC"
  cd "$VIM_SRC"
fi

# Determine latest tag
latest_version=$(git tag | sort -V | tail -n 1)
current_version=$(git describe --tags --exact-match 2>/dev/null || echo "none")

if [ "$current_version" = "$latest_version" ] && command -v vim &>/dev/null; then
  installed_version=$(vim --version | head -1)
  echo "Already on latest tag ($latest_version)."
  echo "Installed: $installed_version"
  read -rp "Rebuild anyway? [y/N] " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Nothing to do."
    exit 0
  fi
fi

echo "Building Vim $latest_version..."

# Clean previous build artifacts
git checkout "$latest_version"
git clean -fdx
make distclean 2>/dev/null || true

# Optional: CPU optimizations for speed
export CFLAGS="-O2 -march=native"
export LDFLAGS="-Wl,-O1"

./configure \
  --with-features=huge \
  --prefix="$PREFIX" \
  --enable-python3interp \
  --with-python3-config-dir="$(python3-config --configdir)" \
  --with-x \
  --with-compiledby="$(whoami) $(date '+%Y-%m-%d %H:%M:%S')"

make -j"$(nproc)"
sudo make install

# Verify
echo ""
echo "=== Build complete ==="
echo "Installed to: $(which vim)"
vim --version | head -1
vim --version | grep -oE '(\+|-)(clipboard|xterm_clipboard|python3)' | sort

# Warn if system vim would shadow our build
if [ "$(which vim)" != "$PREFIX/bin/vim" ]; then
  echo ""
  echo "WARNING: $(which vim) is taking precedence over $PREFIX/bin/vim"
  echo "Ensure $PREFIX/bin is early in your \$PATH"
fi
