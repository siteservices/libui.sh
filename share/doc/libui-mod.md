# Libui Libui Mod Commands

Note: The libuiLibui mod is designed to support the libui application and is not intended for general use.

## Libui Mod

The libui utility mod provides support functions specifically created for the libui utility application. The functions described here may have limited application for other uses.

* Libui (man libuiLibui.sh) - Libui Support Utilities

Man page is available for the above: man 3 libuiLibui.sh

Use the following to load the mod prior to use:

```sh
LoadMod Libui
```

## Libui Libui Mod Commands

### LibuiConfig (man libuiLibui.sh) - Creates a libui configuration file.

This command creates a libui configuration file in the ".libui" directory inside the user's home directory. It is called by the libui utility application.

```sh
LibuiConfig
```

### LibuiDefer (man libuiLibui.sh) - Defers the current libui to another.

This command compares, updates, or defers the libui library components in the current libui library installation to an installation in another directory. It is called by the libui utility application.

* -u - update library in commonroot
* -U - unify library with commonroot
* -v - verify library against commonroot

```sh
LibuiDefer [-u|-U|-v]
```

### LibuiDemo (man libuiLibui.sh) - Provides a simple libui capabilities demo.

This command displays a simple libui demonstration that highlights some of the defined variables and display capabilities. It is called by the libui utility application.

```sh
LibuiDemo
```

### LibuiInstall (man libuiLibui.sh) - Installs libui in another directory.

This command copies the libui library components to another directory. It is called by the libui utility application.

```sh
LibuiInstall
```

### LibuiManpage (man libuiLibui.sh) - Generates a MANPATH command.

This command generates a command line that can be used to add the libui man page directory to the the MANPATH environment variable.

```sh
LibuiManpage
```

### LibuiPackage (man libuiLibui.sh) - Creates a libui package file.

This command creates a libui package containing the library components for distribution to another system. It is called by the libui utility application.

```sh
LibuiPackage
```

### LibuiPackageList (man libuiLibui.sh) - Lists components in a package file.

This command lists the library components that would be included in a libui package for distribution to another system. It is called by the libui utility application.

```sh
LibuiPackageList
```

### LibuiResetCache (man libuiLibui.sh) - Reset libui cache files.

This command deletes the libui cache files that are stored in the ".cache/libui" directory inside the user's home directory. It is called by the libui utility application.

```sh
LibuiResetCache
```

### LibuiResetState (man libuiLibui.sh) - Reset libui state files.

This command deletes the libui state files that are stored in the ".local/state/libui" directory inside the user's home directory. It is called by the libui utility application.

```sh
LibuiResetState
```

### LibuiStats (man libuiLibui.sh) - Display libui usage statistics.

This command reads and displays libui statistics files that are stored in the ".libui" directory inside the user's home directory. It is called by the libui utility application.

```sh
LibuiStats
```

### LibuiTimestamp (man libuiLibui.sh) - Updates the libui.sh timestamp.

This command updates the timestamp within the libui.sh file. It is called by the libui utility application.

```sh
LibuiTimestamp
```

### LibuiUnlock (man libuiLibui.sh) - Removes stale libui lock files.

This command removes any existing libui lock files. It is only needed on systems that do not support the flock command. It is called by the libui utility application.

```sh
LibuiUnlock
```

### LibuiUpdateMan (man libuiLibui.sh) - Updates the date in libui man pages.

This command updates the date within the libui man pages when the timestamp changes on a libui component script. It is called by the libui utility application.

```sh
LibuiUpdateMan
```

## License

This content and associated files as published by siteservices.net, Inc. are marked CCO 1.0. Permission is unconditionally granted to anyone with the interest, full rights to use, modify, publish, distribute, sublicense, and/or sell this content and all associated files. To view a copy of CCO 1.0, visit https://creativecommons.org/publicdomain/zero/1.0/.

All content is provided "as is", without warranty of any kind, expressed or implied, including but not limited to merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors or publishers be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the use of this content or any of the associated files.