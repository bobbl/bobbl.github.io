---
layout: post
title:  "Install Microsemi Libero 12.1 on Ubuntu 18.04"
date:   2019-09-23 22:16:00 +0200
categories: FPGA microsemi
---


This is how I installed Libero SoC v12.1 on Ubuntu 18.04 LTS (Bionic Beaver).



Get License
-----------

Create a directory for the license server (here I use ``~/.local/microsemi/license``)

    mkdir --p /home/USERNAME/.local/microsemi/license

Download the "Linux Licensing Daemon" from 
<https://www.microsemi.com/product-directory/design-resources/1711-licensing#downloads>
to the license directory and extract it with

    tar xf Linux_Licensing_Daemon.tar.gz

Create an account on <www.microsemi.com> and request a 
"Libero Silver 1Yr Floating License for Windows/Linux Server".
You have to enter your MAC address (12 hexadecimal digits without
colons), which you can get by typing

    ip link | grep ether

The license file is sent via email. Store the license file ``License.dat`` in
the license directory. 

Now the first four lines of the license file must be edited, but *not the rest
of the file*. In the first line, replace ``<put.hostname.here>`` by 
``localhost``. In lines 2 to 4 replace ``PATH`` by the absolute path to the
license daemon directory. The first 4 lines schould then look like that:

    SERVER localhost 112233445566 1702
    DAEMON actlmgrd /home/USERNAME/microsemi/license/Linux_Licensing_Daemon/actlmgrd
    DAEMON mgcld /home/USERNAME/microsemi/license/Linux_Licensing_Daemon/mgcld
    VENDOR snpslmd /home/USERNAME/microsemi/license/Linux_Licensing_Daemon/snpslmd

Install the depedencies

    sudo apt install lsb

And start the license server with

    Linux_Licensing_Daemon/lmgrd -c License.dat -log /tmp/lmgrd.log



Install Libero
--------------

Download "Libero SoC v12.1 for Linux" from
<https://www.microsemi.com/product-directory/design-resources/1750-libero-soc#downloads>.

The downloaded binary is a self-extracting archive built with InstallAnywhere.
Before executing it, set its execute bit must be set and some dependencies have
to be installed:

    sudo apt install libxtst6:i386 libqtgui4:i386 libxrender1:i386 apt-file
    chmod +x Libero_SoC_v12.1_lin.bin
    ./Libero_SoC_v12.1_lin.bin

Now the graphical installer should be launched. If not, there are still some
library dependencies unresolved. From my experience, the console mode
installation does not work at all. Quit it by typing ``quit`` and try to
install additional X or Qt libraries until the graphical installer is started.

Within the graphical installer, I recommend to change the install path to
``/home/USERNAME/.local/microsemi/Libero_SoC-v12.1`` and the common directory
to ``/home/USERNAME/.local/microsemi/common``. Otherwise you need root
permissions whenever Libero updates the IP cores.

libz must be removed:

    rm /home/USERNAME/.local/microsemi/Libero:SoC-v12.1/Libero/lib/libz.so.1

Install dependencies:

    sudo apt install libmotif-dev libglib2.0-0:i386 libfreetype6:i386 \
        libsm6:i386 libfontconfig1:i386 libpulse0:i386 libqt5gui5:i386

libpng12-0 must be install manually (source: <https://www.linuxuprising.com/2018/05/fix-libpng12-0-missing-in-ubuntu-1804.html>).
Both the 32 bit version (for Libero itself) and the 64 bit version (for the chip planner) are required.

    wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_i386.deb
    wget http://security.ubuntu.com/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb
    sudo apt install ./libpng12-0_1.2.54-1ubuntu1.1_i386.deb
    sudo apt install ./libpng12-0_1.2.54-1ubuntu1.1_amd64.deb

The Libero scripts have the shebang ``#!/bin/sh`` although bash syntax is used.
Therefore dash must be disabled by

    sudo dpkg-reconfigure dash

and choosing "No".

Before actually starting Libero, some environment variables have to be set:

    export LM_LICENSE_FILE=1702@localhost
    export SNPSLMD_LICENSE_FILE=1702@localhost
    export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu/:/usr/lib
    /home/USERNAME/.local/microsemi/Libero/bin/libero



Install SoftConsole 6.0
-----------------------

Dpendencies:

    sudo apt-get install build-essential libstdc++6:i386

Download the Installer and make it executable:

    chmod +x Microsemi-SoftConsole-v6.0.0.116-Linux-x86_64-Installer
    ./Microsemi-SoftConsole-v6.0.0.116-Linux-x86_64-Installer

Accept the license and set the destination location to 
``/home/USERNAME/.local/microsemi/SoftConsole_v6.0``

Avoid root permission when accessing SoftConsole hardware:

    sudo cp ~/.local/microsemi/SoftConsole_v6.0/openocd/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d/

