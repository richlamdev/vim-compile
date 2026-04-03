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

latest_version=$(git tag | sort -V | tail -n 1)

# Compare against installed Vim
if command -v vim &>/dev/null; then
  # Build version string from vim --version output
  # e.g., "9.2" from first line + "1234" from "Included patches: 1-1234"
  # Compare as integers to avoid zero-padding mismatch (tag: 0280, patches: 280)
  installed_patch=$(vim --version | grep -oP 'Included patches: 1-\K\d+' || echo "0")
  tag_patch=$(echo "$latest_version" | grep -oP '\d+\.\d+\.\K\d+')
  # Remove leading zeros for comparison
  installed_patch=$((10#$installed_patch))
  tag_patch=$((10#$tag_patch))

  if [ "$installed_patch" -eq "$tag_patch" ]; then
    echo "Installed Vim (patch $installed_patch) matches latest tag ($latest_version)."
    read -rp "Rebuild anyway? [y/N] " reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
      echo "Nothing to do."
      exit 0
    fi
  else
    echo "Installed patch: $installed_patch | Latest: $latest_version (patch $tag_patch)"
  fi
fi

echo "Building Vim $latest_version..."

# Clean previous build artifacts
git checkout "$latest_version"
git clean -fdx
make distclean 2>/dev/null || true

# Compiler optimizations
export CFLAGS="-O2 -march=native"
export LDFLAGS="-Wl,-O1"

./configure \
  --with-features=huge \
  --prefix="$PREFIX" \
  --enable-python3interp \
  --with-python3-config-dir="$(python3-config --configdir)" \
  --with-x \
  --with-compiledby="$(whoami)  $latest_version"

make -j"$(nproc)"
sudo make install

# Verify
echo ""
echo "=== Build complete ==="
echo ""
echo "Previous patch version: ${installed_patch}"
echo "New patch version: ${tag_patch}"
echo ""
echo "Installed to: $(which vim)"
vim --version | head -1
vim --version | grep -oE '(\+|-)(clipboard|xterm_clipboard|python3)' | sort

# Warn if system vim would shadow our build
if [ "$(which vim)" != "$PREFIX/bin/vim" ]; then
  echo ""
  echo "WARNING: $(which vim) is taking precedence over $PREFIX/bin/vim"
  echo "Ensure $PREFIX/bin is early in your \$PATH"
fi
