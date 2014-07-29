This example demonstrates packaging a kivy application on Ubuntu 12.04 using PyInstaller.

The commands to install python, kivy, and pyinstaller are in `bootstrap.sh`. A Vagrantfile
is provided to make it easy to package a demo kivy app into a single-file linux executable.

Instructions:

- Install [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com)
- `git clone https://github.com/rajbot/kivy_pyinstaller_linux_example.git`
- `cd kivy_pyinstaller_linux_example`
- `vagrant up` (this will take a while)
- After the provisioning script is finished, type `vagrant reload` to boot into the desktop environment you just installed
- In the VirtualBox GUI window, log in as user "vagrant", pw "vagrant"
- Open a terminal and run `/home/vagrant/pong/dist/pong`


The setup script will install Kivy and PyInstaller in a virtualenv. We need to install
Kivy in a virtualenv instead of using the PPA because we need the `kivy.tools`
package in order to use the PyInstaller helper functions supplied by Kivy. The PPA does
not install the `kivy.tools` package.

In our PyInstaller .spec file, we install hooks using this code:
```python
from kivy.tools.packaging.pyinstaller_hooks import install_hooks
install_hooks(globals())
```
