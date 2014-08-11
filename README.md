Setting up a development environment for development and packaging of Linux desktop
applications using Kivy is not straightforward.

This example demonstrates creating a debian package of a kivy application on Ubuntu 12.04.
The Vagrantfile provisions an Ubuntu instance using the included `bookstrap.sh`.

`bootstrap.sh` does the following:
- Sets up the Ubuntu Desktop
- Installs `python`, `kivy`, and `pyinstaller`
- Packages a kivy demo application as a single-file binary
- Creates a `.deb` contains the kivy app and an Unity Launcher (.desktop file)
- Installs the .deb package using `dpkg`
- Creates a shortcut on the Desktop that the user can double-click to launch the app


Instructions:

- Install [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com)
- `git clone https://github.com/rajbot/kivy_pyinstaller_linux_example.git`
- `cd kivy_pyinstaller_linux_example`
- `vagrant up` (this will take a while)
- After the provisioning script is finished, type `vagrant reload` to boot into the desktop environment you just installed
- In the VirtualBox GUI window, log in as user "vagrant", pw "vagrant"
- Double-click on the `Kivy Pong` icon on the Desktop to launch the app


The setup script will install Kivy and PyInstaller in a virtualenv. We need to install
Kivy in a virtualenv instead of using the PPA because we need the `kivy.tools`
package in order to use the PyInstaller helper functions supplied by Kivy. The PPA does
not install the `kivy.tools` package.

In our PyInstaller .spec file, we install hooks using this code:
```python
from kivy.tools.packaging.pyinstaller_hooks import install_hooks
install_hooks(globals())
```
