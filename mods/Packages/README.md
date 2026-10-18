# Packages directory

Originally meant to be used by the `D` op code, but later expanded to the `T` op code.

The `D` op code is used to install a standard Debian package of the same name as the module, examples exist here.

The `T` op code is used to extract a tarball directly into the `live-build` config tree as is, which can then be shared between multiple `live-build` configurations with little hassle.  Some of these current packages could be done using a combination of other newly added op codes.  However, they haven't been migrated to use that updated method of configuration yet.  However, in some cases, there might be value in keeping everything such as `steam` and `docker` all consolidated into a single tarball, rather than in a separate `.list` file, and other op codes.
