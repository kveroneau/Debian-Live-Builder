# How does this all work anyways?

Well, this document, and several others are here to explain the build process to you, before you invoke `lb build`.

Currently, the best way to start fresh is to of course create a standard `live-build` config tree, and this should be under `/srv/builder`, it is currently hardcoded into the program at this time.  This can be a mount point on *tmpfs*, or a really fast drive.  First use your standard `lb config` program to set-up the standard `live-build` config tree in this directory, and ensure that it's ready to go.  After, you can then run the compiled `LiveBuilder`, and have the `mods/` directory inside your `/home/user/mods`, as it is also currently hardcoded to use this location as well.

The only button you need to care about is the first one, just select one of the entry point modules from the list, and hit the first button.  A log will appear in the other window to show you all the progress, and then let you know when you can proceed with `lb build`.  The `LiveBuilder` can run as the standard user account, but as always `lb build` does need to run as the `root` user.

The program will first take the contents from `base.tgz`, which can also be customized to create the initial `config/` tree, then it will run through the module you selected, which can also include the `R` op code, which will can run additional modules.  See the other document on how modules are written.
