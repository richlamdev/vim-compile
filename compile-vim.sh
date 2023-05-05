#!/bin/bash

# Remove any existing Vim or related software
sudo apt-get remove -y vim vim-runtime gvim vim-tiny vim-common vim-gui-common vim-nox

# Remove any existing xterm packages that conflict with clipboard support
#sudo apt-get remove -y xterm xtermset

# Install build dependencies
sudo apt-get update
sudo apt-get install -y build-essential libncurses5-dev libgtk2.0-dev libatk1.0-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git

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
./configure --with-features=huge --enable-gui=auto --enable-cscope --prefix=/usr/local --enable-python3interp --with-python3-config-dir=$(python3-config --configdir) --enable-fontset --enable-multibyte --enable-xim --with-x --enable-gui=gtk2 --with-compiledby="me!"

# Compile and install Vim
make -j4
sudo make install

# Download the xterm_clipboard patch
#wget https://invisible-mirror.net/archives/xterm/xterm-xxx.x.x.x.x.x.clipboard.patch.gz

# Extract the patch
#gzip -d xterm-xxx.x.x.x.x.x.clipboard.patch.gz

# Download the latest xterm source code
#wget https://invisible-mirror.net/archives/xterm/xterm-xxx.x.x.x.tar.gz

# Extract the xterm source code
#tar -xzvf xterm-xxx.x.x.x.tar.gz

# Change to the xterm directory
#cd xterm-xxx.x.x.x

# Apply the patch
#patch -p1 < ../xterm-xxx.x.x.x.x.x.clipboard.patch

# Configure and install xterm with clipboard support
#./configure --prefix=/usr/local --enable-256-color --enable-unicode3 --enable-wide-chars --enable-backward-compatibility --enable-xterm-new-erase --enable-luit --enable-toolkit-scroll-bars --enable-freetype --with-gtk --with-x --with-xterm-new-erase --enable-xterm-clipboard
#make
sudo make install

# Cleanup
#cd ..
#rm -rf vim xterm-xxx.x.x.x.tar.gz xterm-xxx.x.x.x xterm-xxx.x.x.x.x.x.clipboard.patch

# Display success message
#echo "Vim and xterm with clipboard support have been installed successfully."
echo "Vim with clipboard support have been installed successfully."


