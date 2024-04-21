#!/bin/bash

# Remove any existing Vim or related software
sudo apt-get remove -y vim vim-runtime gvim vim-tiny vim-common vim-gui-common vim-nox

# Install build dependencies
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  libncurses5-dev \
  libgtk2.0-dev \
  libatk1.0-dev \
  libcairo2-dev \
  libx11-dev \
  libxpm-dev \
  libxt-dev \
  python3-dev \
  ruby-dev \
  lua5.2 \
  liblua5.2-dev \
  libperl-dev \
  git

# check if vim folder exists, if it does then delete it

if [ -d "vim" ]; then
  # Control will enter here if $DIRECTORY exists.
  echo "vim folder exists, deleting it"
  rm -rf vim
fi

# Clone the Vim repository
git clone https://github.com/vim/vim.git

# Change to the Vim directory
cd vim

# Update the Vim repository
#git pull

# Get the latest version number
latest_version=$(git tag | sort -V | tail -n 1)

# Checkout the latest version
git checkout $latest_version

# Configure the build with clipboard support
#./configure --with-features=huge --enable-gui=auto --enable-cscope --prefix=/usr/local --enable-python3interp --with-python3-config-dir=$(python3-config --configdir) --enable-fontset --enable-multibyte --enable-xim --with-x --enable-gui=gtk2 --with-compiledby="Your Name" --with-clipboard
#./configure --with-features=huge --enable-gui=auto --enable-cscope --prefix=/usr/local --enable-python3interp --with-python3-config-dir=$(python3-config --configdir) --enable-fontset --enable-multibyte --enable-xim --with-x --enable-gui=gtk2 --with-compiledby="me!"
./configure --with-features=huge --prefix=/usr/local --enable-fontset --with-x --enable-gui=gtk2 --with-compiledby="me!"

# Compile and install Vim
make -j8
sudo make install

# Display success message
#echo "Vim and xterm with clipboard support have been installed successfully."
echo "Vim with clipboard support has been installed successfully."

exit 0
