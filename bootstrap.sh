#!/bin/bash
set -euo pipefail

echo "Provisioning ubuntu desktop"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-desktop

echo "Setting up kivy"

#from http://kivy.org/docs/installation/installation-linux.html#ubuntu-12-04-with-python-2-7
# Install necessary system packages
sudo apt-get install -y build-essential mercurial git python2.7 \
python-setuptools python-dev ffmpeg libsdl-image1.2-dev \
libsdl-mixer1.2-dev libsdl-ttf2.0-dev libsmpeg-dev libsdl1.2-dev \
libportmidi-dev libswscale-dev libavformat-dev libavcodec-dev zlib1g-dev

# Bootstrap a current Python environment
sudo apt-get remove --purge -y python-virtualenv python-pip
sudo easy_install-2.7 -U pip
sudo pip2.7 install -U virtualenv

# Install current version of Cython
sudo apt-get remove --purge -y cython
sudo pip2.7 install -U cython

# Install other PyGame dependencies
sudo apt-get remove --purge -y python-numpy
sudo pip2.7 install -U numpy

# Install PyGame
sudo apt-get remove --purge python-pygame
hg clone https://bitbucket.org/pygame/pygame
cd pygame
python2.7 setup.py build
sudo python2.7 setup.py install
cd ..
sudo rm -rf pygame



# Create a vitualenv
# Create a vitualenv
rm -rf venv
sudo -u vagrant virtualenv -p python2.7 --system-site-packages venv

# Install stable version of Kivy into the virtualenv
sudo -u vagrant venv/bin/pip install kivy
# For the development version of Kivy, use the following command instead
# venv/bin/pip install git+https://github.com/kivy/kivy.git@master

# Install development version of buildozer into the virtualenv
# venv/bin/pip install git+https://github.com/kivy/buildozer.git@master

# Install development version of plyer into the virtualenv
# venv/bin/pip install git+https://github.com/kivy/plyer.git@master

# Install a couple of dependencies for KivyCatalog
sudo -u vagrant venv/bin/pip install -U pygments docutils


echo "Setting up pyinstaller"
sudo -u vagrant venv/bin/pip install pyinstaller


echo "Setting up demo pong app"
sudo -u vagrant cp -r venv/share/kivy-examples/tutorials/pong .

spec="# -*- mode: python -*-
from kivy.tools.packaging.pyinstaller_hooks import install_hooks
install_hooks(globals())

a = Analysis(['main.py'],
             pathex=['/home/scribe/pong'],
             hiddenimports=[],
            )
pyz = PYZ(a.pure)
exe = EXE(pyz,
          [('pong.kv', 'pong.kv', 'DATA')],
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='pong',
          debug=False,
          strip=None,
          upx=True,
          console=False )
"

sudo -u vagrant echo "$spec" > pong/pong.spec

cd pong
sudo -u vagrant HOME=/home/vagrant /home/vagrant/venv/bin/pyinstaller pong.spec --clean


echo "You will now need to run 'vagrant reload' to start with the Ubuntu Desktop and run the /home/vagrant/pong/dist/pong the single-file executable"
