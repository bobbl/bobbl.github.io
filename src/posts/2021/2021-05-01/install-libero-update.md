---
layout: post
title:  "Install Microsemi Libero 2021.1 on Ubuntu 20.04"
date:   2021-05-01 00:00:00 +0200
categories: FPGA microsemi
---


This is how I installed Libero SoC v2021.1 on Ubuntu 20.04 LTS (Focal Fossa).
It is an update of [my previous post]({% post_url 2019-09-23-install-libero %}).


Get License
-----------

Create a directory for the license server (here I use ``~/.local/share/microsemi/license``)

    mkdir --p /home/USERNAME/.local/share/microsemi/license

Download the "Linux Daemon" from 
<https://www.microsemi.com/product-directory/design-resources/1711-licensing#downloads>
to the license directory and extract it with

    tar xf Linux_Licensing_Daemon.tar.Z

Create an account on <https://www.microsemi.com> and request a 
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
    DAEMON actlmgrd /home/USERNAME/.local/share/microsemi/license/Linux_Licensing_Daemon/actlmgrd
    DAEMON mgcld /home/USERNAME/.local/share/microsemi/license/Linux_Licensing_Daemon/mgcld
    VENDOR snpslmd /home/USERNAME/.local/share/microsemi/license/Linux_Licensing_Daemon/snpslmd

The license manager requires that `/usr/tmp` exists (otherwise you get
"FlexNet Licensing error:-25,234")

    sudo ln -s /tmp /usr/tmp

Install the depedencies

    sudo apt install lsb

And start the license server with

    Linux_Licensing_Daemon/lmgrd -c License.dat -log /tmp/lmgrd.log

If you get a "file not found" error, install lsb.

On my system I have the problem that the license works only for a few minutes.
I don't know why, but when I start Libero a second time after a few minutes,
it doesn't recognise the license. Stopping and restarting the license server
helps:

    Linux_Licensing_Daemon/lmdown -c License.dat -q
    Linux_Licensing_Daemon/lmgrd -c License.dat -log /tmp/lmgrd.log



Install Libero
--------------

Download "Libero SoC v2021.1 for Linux" from
<https://www.microsemi.com/product-directory/design-resources/1750-libero-soc#downloads>.

The downloaded binary is a self-extracting archive built with InstallAnywhere.
Before executing it, set its execute bit must be set and some dependencies have
to be installed:

    sudo apt install libxtst6:i386 libxrender1:i386 apt-file
    chmod +x Libero_SoC_v2021.1_lin.bin
    ./Libero_SoC_v2021.1_lin.bin

Now the graphical installer should be launched. If not, there are still some
library dependencies unresolved. From my experience, the console mode
installation does not work at all. Quit it by typing ``quit`` and try to
install additional X or Qt libraries until the graphical installer is started.

Within the graphical installer, I recommend to change the install path to
``/home/USERNAME/.local/share/microsemi/Libero_SoC-v12.1`` and the common directory
to ``/home/USERNAME/.local/share/microsemi/common``. Otherwise you need root
permissions whenever Libero updates the IP cores.

The graphical installer checks for dependencies and suggests a command line to
install them. Copy this line to a terminal and prepend it with `sudo`. When I
tired it, it was

    sudo apt-get install -y xfonts-intl-asian xfonts-intl-chinese \
        xfonts-intl-chinese-big xfonts-intl-japanese xfonts-intl-japanese-big \
        ksh libxft2:i386 libgtk2.0-0:i386 libcanberra-gtk-module:i386 \
        packagekit-gtk3-module:i386

If `apt-get` complains that a package is not available, simply remove it and try
again (I had to remove `packagekit-gtk3-module:i386`).

Before actually starting Libero, some environment variables have to be set:

    export LM_LICENSE_FILE=1702@localhost
    export SNPSLMD_LICENSE_FILE=1702@localhost
    export LD_LIBRARY_PATH=/usr/lib/i386-linux-gnu/:/usr/lib/x86_64-linux-gnu/:/usr/lib
    /home/USERNAME/.local/share/microsemi/Libero/bin/libero
