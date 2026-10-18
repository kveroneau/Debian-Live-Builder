# Live Builder custom modules

These are some custom modules that I have built for personal immutable images, but am going to share them with the overall community as a way to allow people see how they are created in practice, and to also have a working set of modules which can be used out of the box to generate a working `live-build` config tree that is ready to building using `lb build`.  I will also explain the main **entry point** modules in this readme here as well.  In a future release, the entry point modules will be separated.

## Entrypoint Modules

Only use these modules during an actual `live-build` config tree generation:

  * **dvdsys**: Might need some updates as not all files are available and have been redacted.  This image can be used like Movix back in the day for example, where you can embed various media files, and even play DVDs.  The front-end is made in Lazarus, and isn't perfect.  It makes use of the keyboard over mouse for overall navigation and use.

  * **gameros**: An Immutable Debian that I personal use to get Steam running on my laptop, some files may not be present in the repo, but mostly everything is intact, namely the steam runtime installation module.

  * **lbsys**: This builds a very minimal live image which has `live-build` and `nfs-kernel-server`, ideal for building Live images and immutable `.squashfs` on a different machine on the network.

  * **plasma-live**: A minimal KDE Plasma image, can be customized of course to add additional software.

  * **rogsys**: Very customized persnal immutable Debian configuration module.  Cannot be used without creating your own version of a few `rogsys` files.  It is provided here as an example for how you could use this system to start creating your own fully custom immutable Debian image.

  * **rsys**: A test of sorts with `rdesktop`, and a very basic window manager, allows for basic remote access to a PC over a network, a thin client if you will.

## Special Modules to Consider

Here are some special modules and how they should be used.

  * **nvidia**: use this to avoid having the resulting immutable image having the kernel headers, compiler tools, and such.  However, it requires additional set-up to actually work, namely, you will need to first compile the nvidia drivers yourself, and if you don't know how to do this, then use `nvidia-build` instead.

  * **nvidia-build**: Includes everything you need to build the nvidia kernel module, however, you will still need to do some manual configuration at the moment, namely updating the `depmod -a` command to point to the kernel being used in the image.

  * **homewifi**: This one loads in a Wifi network for my personal home for use with a desktop NetworkManager client, meaning the WPA-PSK should be stored in your wallet, such as kwallet.  The related file is in `Files/homewifi` which will also need to be modified.  The easiest way to get this set-up with your own personal Wifi, is to just use NetworkManager itself.  Connect to the network as you normally would, then copy out the new configuration file from `/etc/NetworkManager/system-connections/` into `Files/homwifi`, and then the build should then include your own personal Wifi network.

  * **wifilink**: This is meant if you need to run a Kiosk system that won't have any root access, so no ability to tell Network Manager anything, including the WPA-PSK key.  The file in `Files/wifilink` is a system connection which can embed the key directly into the immutable image itself.  Currently there is no secure storage, so never commit this file and it's key to a repository.  In the file included here, I blanked out the key.  Replace all the related information in the connection with the Wifi network needed, and build.
