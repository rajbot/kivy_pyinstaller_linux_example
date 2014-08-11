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

#from http://developer.ubuntu.com/2012/02/how-to-prepare-a-compiled-application-for-ubuntu-software-center/
# Install packages necessary for creating .debs
sudo apt-get install -y devscripts lintian dh-make


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
chown vagrant pong/pong.spec

cd pong
sudo -u vagrant HOME=/home/vagrant /home/vagrant/venv/bin/pyinstaller pong.spec --clean
cd ..

echo "Creating and Installing kivypong_1.0-1.deb"

#Create a .deb
sudo -u vagrant mkdir -p kivypong_1.0-1/usr/local/bin
sudo -u vagrant mkdir -p kivypong_1.0-1/usr/share/applications
sudo -u vagrant mkdir -p kivypong_1.0-1/DEBIAN

deb_control="Source: kivypong
Priority: extra
Maintainer: vagrant <vagrant@unknown>
Build-Depends: debhelper (>= 8.0.0)
Standards-Version: 3.9.2
Package: kivypong
Version: 1.0-1
Architecture: i386
Description: Kivy Pong example
 This is an example of creating a single-binary .deb with a kivy app
"

echo "$deb_control" > kivypong_1.0-1/DEBIAN/control
chown vagrant kivypong_1.0-1/DEBIAN/control

desktop="[Desktop Entry]
Version=1.0
Name=Kivy Pong
Comment=Kivy Pong Example
Exec=/usr/local/bin/kivypong
Icon=/usr/share/icons/Humanity/apps/32/application-community.svg
Type=Application
Categories=Games;
"

echo "$desktop" > kivypong_1.0-1/usr/share/applications/kivypong.desktop
chmod a+x kivypong_1.0-1/usr/share/applications/kivypong.desktop
chown vagrant kivypong_1.0-1/usr/share/applications/kivypong.desktop


sudo -u vagrant cp pong/dist/pong kivypong_1.0-1/usr/local/bin/kivypong

sudo -u vagrant dpkg-deb --build kivypong_1.0-1

#install .deb
dpkg -i kivypong_1.0-1.deb

#create link on desktop
sudo -u vagrant rm -f /home/vagrant/Desktop/kivypong.desktop
sudo -u vagrant ln -s /usr/share/applications/kivypong.desktop /home/vagrant/Desktop


echo "You will now need to run 'vagrant reload' to start with the Ubuntu Desktop. A shortcut to the Kivy Pong application has been placed on the Desktop, which you can now run."
