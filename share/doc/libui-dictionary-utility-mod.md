# Dictionary of Libui Utility Mod Commands

## Libui Mod

The libui utility mod provides libu library utility support functions and is not
intended for general use:

* Utility (man libuiUtility.sh) - Libui Support Utilities

Man page is available for the above: man 3 libuiUtility.sh

Use the following to load a mod prior to use:

```
LoadMod Utility
```

## Libui Utility Commands

### LibuiConfig (man libuiUtility.sh) - Creates a libui configuration file.

Note: The libuiUtility mod is designed to support the libui utility application.

This command creates a libui configuration file in the ".libui" directory inside
the user's home directory. It is called by the libui utility application.

```
LibuiConfig
```

### LibuiDemo (man libuiUtility.sh) - Provides a simple libui capabilities demo.

Note: The libuiUtility mod is designed to support the libui utility application.

This command displays a simple libui demonstration that highlights some of the
defined variables and display capabilities. It is called by the libui utility
application.

```
LibuiDemo
```

### LibuiInstall (man libuiUtility.sh) - Installs libui in another directory.

Note: The libuiUtility mod is designed to support the libui utility application.

This command copies the libui library components to another directory. It is
called by the libui utility application.

```
LibuiInstall
```

### LibuiPackage (man libuiUtility.sh) - Creates a libui package file.

Note: The libuiUtility mod is designed to support the libui utility application.

This command creates a libui package containing the library components for
distribution to another system. It is called by the libui utility application.

```
LibuiPackage
```

### LibuiPackageList (man libuiUtility.sh) - Lists components in a package file.

Note: The libuiUtility mod is designed to support the libui utility application.

This command lists the library components that would be included in a libui
package for distribution to another system. It is called by the libui utility
application.

```
LibuiPackageList
```

### LibuiResetCaches (man libuiUtility.sh) - Reset libui cache files.

Note: The libuiUtility mod is designed to support the libui utility application.

This command deletes and/or recreates the libui cache files that are stored in
the ".libui" directory inside the user's home directory. It is called by the
libui utility application.

```
LibuiResetCaches
```

### LibuiStats (man libuiUtility.sh) - Display libui usage statistics.

Note: The libuiUtility mod is designed to support the libui utility application.

This command reads and displays libui statistics files that are stored in the
".libui" directory inside the user's home directory. It is called by the libui
utility application.

```
LibuiStats
```

### LibuiUnity (man libuiUtility.sh) - Unifies the current libui with another.

Note: The libuiUtility mod is designed to support the libui utility application.

This command compares, updates, or unifies the libui library components in the
current libui library installation to an installation in another directory. It
is called by the libui utility application.

* -u - update library in commonroot
* -U - unify library with commonroot
* -v - verify library against commonroot

```
LibuiUnity [-u|-U|-v]
```

### LibuiUnlock (man libuiUtility.sh) - Removes stale libui lock files.

Note: The libuiUtility mod is designed to support the libui utility application.

This command removes any existing libui lock files. It is only needed on systems
that do not support the flock command. It is called by the libui utility
application.

```
LibuiUnlock
```

### LibuiUpdateMan (man libuiUtility.sh) - Updates the date in libui man pages.

Note: The libuiUtility mod is designed to support the libui utility application.

This command updates the date within the libui man pages when the timestamp
changes on a libui component script. It is called by the libui utility
application.

```
LibuiUpdateMan
```