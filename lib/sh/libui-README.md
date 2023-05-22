# User Interface Support Library for Z Shell and Bash Scripts

## Description

The libui.sh library provides a script execution environment that simplifies
development of robust scripts with a standardized user interface.  The library
supports several capabilities ipso facto including script usage, several
"standard" options that help with debugging, options for alternate execution
flows (confirmation, no action, verbose, etc.), and color terminal highlighting.

## Synopsis

To create a libui script, use the following shebang:

```
#!/usr/bin/env libui
```

Alternatively, to source libui.sh in a zsh or bash script, include the line:

```
LIBUI="${SHLIBPATH:+${SHLIBPATH%/}/}libui.sh"; source "${LIBUI}" "${0}" "${@}"
```

Every libui script (or libui mod) should contain the following command:

```
Version [-m] [-r <minimum_version>] <version>
```

Where <version> is the version of the script and <minimum_version>, if provided,
ensures the libui.sh library is at least that version. The -m (mod) flag is used
to indicate that the file is a libui.sh mod.

Every libui script must initialize the library after configuration and before
starting the main script by using the following command:

```
Initialize
```

Every libui script should exit using the following:

```
Exit [return_value]
```

Where return_value is the value to be returned by the main script.

## Man Pages

Unix mandoc man pages are included with the User Interface Library and provide
more complete documentation on the services and capabilities provided.

Information on the use of the library is available as a man page: man 3 libui.sh

## Installation

The recommended installation of the User Interface Library is provided by the
libui script. The easiest installation is to use git to pull down the repository
and then execute:

```
make install
```

This will execute the libui script with the -i (Install) option. If the
`<COMMONROOT>` environment variable has not been configured with the library
installation path, a prompt will appear asking for the COMMONROOT directory.

The `<COMMONROOT>` parameter should be the absolute path for installing the
libui.sh library files. It is worth noting that the installation will create
several subdirectories under the provided path including: `lib/sh`, `bin`,
`share/man/man1`, and `share/man/man3`.

Alternatively, the libui script may be called directly from within the repo:

```
lib/sh/libui -i <COMMONROOT>
```

## Post Installation

Once installed, access to the library must be established:

* Add "/private/tmp/tl/lib/sh" to your PATH to access libui and libui.sh.
* Add "/private/tmp/tl/bin" to your PATH to access the example scripts.
* Add "/private/tmp/tl/share/man" to your MANPATH to access the man pages.

Once added, you can use "man 3 libui.sh" or "libui -m" to view the man page.

## Notes

The provided `<COMMONROOT>` path must be writable by the user performing the
installation.

## Vim Note

When using the "#!/usr/bin/env libui" shebang, add the following to your
~/.vim/scripts.vim file to improve syntax highlighting:

```
if getline(1) =~ '^#!/usr/bin/env libui'
  setfiletype zsh " or 'bash'
endif
```
