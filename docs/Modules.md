# How do Modules Work?

Each `.mod` file is just a standard text file with special instructions for the custom engine to use, each of these custom instructions is called an **operation code**, and I will explain each of the codes you can use here.  There is no concept of comments, or line terminations.  You can place the entire module onto a single line, or seperate them out onto different lines.

## Operation Codes

All parameters are terminated by the tilde character, `~`.  If no *example* is provided, op code does not support any parameters.

 * `T`: Extract Tarball with same name as module into `config/` tree.
 * `C`: Copy file from `Files/` into file system root specified.
   - Eg: C/etc/myconf.rc~
 * `D`: Install `.deb` package file of same name as module from `Packages/`.
 * `L`: Add List to `config/package-lists/` from `Lists/` with same name as module.
 * `A`: Add the specified package name without using a list.
   - Eg: Aemacs~
 * `V`: Set the ISO Volume name for the generated `.iso` file.
   - Eg: VMy Debian Live~
 * `U`: Set the main live user's fully qualified name.
   - Eg: UKevin Veroneau~
 * `u`: Set the actual username for the live user.
   - Eg: ukveroneau~
 * `a`: Disable the auto-login facility in the live image.
 * `G`: Add a group to the default live user.
   - Eg: Gdocker~
 * `H`: Add a new single command to the build hook, this is run during the build process.
   - Eg: Hdepmod -a~
 * `B`: Add a new single command to the rc.local which will be executed during boot each time.
   - Eg: Bespeak "I am alive!"~
 * `S`: Set the theme for plymouth.
   - Eg: Scybernetic~
 * `%`: Add additional kernel boot operations for the `.iso` generation.
   - Eg: %persistence~

## Basic Examples

If you want to just include a new `.list` from `Lists/` then here is the most simpliest module:

`LX`

Other examples might be written here later, but the included modules in this repo should provide ample examples for people eager to get started on writting their own.
