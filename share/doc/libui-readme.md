# libui - A User Interface Support Library for Z Shell and Bash Scripts

## Description

The libui user interface library provides a script execution environment that
simplifies development of robust scripts with a consistent user interface. The
library inherently provides several capabilities including several "standard"
option flags that help with debugging, options for alternate execution flows
(confirmation, no action, verbose, etc.), automatic script usage information,
and color terminal highlighting.

The easiest way to start a new script is to use the `libui -n <script_path>`
command. Use `man libui` for more details.

## Synopsis

To create a libui script, use the following shebang in the first line:

```
#!/usr/bin/env libui
```

Alternatively, to source libui.sh in a zsh or bash script, include the line:

```
source "${LIBUI:-libui.sh}" "${0}" "${@}"
```

Every libui script (or libui mod) should contain the following command:

```
Version [-m] [-r <minimum_version>] <version>
```

Where `<version>` is the version of the script and `<minimum_version>`, if
provided, ensures the libui.sh library is at least that version. The `-m` (mod)
flag is used to indicate that the file is a libui.sh mod.

Every libui script **must initialize the library** after configuration and
before starting the main script by using the following command:

```
Initialize
```

Every libui script should exit using the following:

```
Exit [<return_value>]
```

Where `<return_value>`, if provided, is the value to be returned by the script.

## Documentation

Documentation for the libui library is provided in the `share/doc` directory.

The markdown (.md) documentation can be accessed in a terminal using the `mless`
command.

## Man Pages

Unix mandoc man pages are included with the User Interface Library and provide
more comprehensive documentation on the commands and capabilities provided.

Information on the core library is available with `man 3 libui.sh`.

## Installation

The recommended installation of the User Interface Library is provided by the
libui script. The easiest installation is to use git to pull down the repository
and then execute:

```
make install
```

This will execute the libui script with the `-i` (Install) option. If the
`${COMMONROOT}` environment variable has not been configured with the library
installation path, a prompt will appear asking for the COMMONROOT directory.

The COMMONROOT value should be the absolute path for installing the libui.sh
library files. It is worth noting that the installation will create several
subdirectories under the provided path including: `lib/sh`, `bin`, `share/doc`,
`share/man/man1`, and `share/man/man3`.

Alternatively, the libui library can be installed by executing the libui script
directly from within the repo:

```
lib/sh/libui -i <COMMONROOT>
```

Notes: To include all of the regression tests, use `libui -I` (Install With
Tests) instead of `libui -i` (Install). Also, the provided \<COMMONROOT\> path
must be writable by the user performing the installation.

## Post Installation

Once installed, access to the library must be established:

* Add `</path/to/>lib/sh` to your `${PATH}` to access libui and libui.sh.
* Add `</path/to/>bin` to your `${PATH}` to access the example scripts.
* Add `</path/to/>share/man` to your `${MANPATH}` to access the man pages.

Please note that the above information will be displayed following an install.

Once the `${MANPATH}` environment variable has been updated, you can use `man 3
libui.sh` or `libui -m` to view the core library man page.

Also, the `mless` command can be used to view the markdown documents provided
in the `</path/to/>share/doc` directory.

## Creating a Script

The easiest way to create a new script is to use the `libui -n <script_path>`
command. This command copies the `libui-template` file from the `share/doc`
directory, asks a few questions, and creates a new, template-based script in the
location identified by the "\<script_path\>" parameter. (Note: Experienced users
may want to use the `libui -N <script_path>` form to create the new script
without the extra demo content.)

## Next Steps

It is recommended that every user reads through the `libui-dictionary.md`
document to get a high-level overview of the currently available commands.
Additional details on each of the commands and option flags can be found in the
associated man pages. This can be accessed using `mless libui-dictionary`.

The scripts available in the `bin` directory provide several real-world examples
of libui scripts. Reviewing those scripts to build knowledge is highly
recommended.

## Contact and Contributions

The libui user interface library is intended to be a community project. As such,
if you have a question, find an issue, identify a need, and/or wish to
contribute, please submit a patch or reach out to fharvell@siteservices.net or
via github.

## Notes

* The Z shell (zsh) is the preferred shell for libui script development and will
be selected by default. If zsh is not available, 'libui -i' will modify the
installed `libui/sh/libui` support script to use bash.

## Vim Note

When using the ```#!/usr/bin/env libui``` shebang, syntax highlighting and
formatting can be improved by creating a ```~/.vim/ftdetect/libui.vim``` file
and adding the following to set the filetype to zsh (or bash):

```
autocmd BufRead *
            \ if getline(1) =~ '^#!/usr/bin/env libui' |
            \   set filetype=zsh |
            \ endif
```

If you prefer Bash syntax highlighting, change ```set filetype=zsh``` in the
file to ```set filetype=bash```.

## Copyright and License

Copyright 2018-2025 siteservices.net, Inc. and made available in the public
domain. Permission is unconditionally granted to anyone with an interest, the
rights to use, modify, publish, distribute, sublicense, and/or sell this content
and associated files.

All content is provided "as is", without warranty of any kind, expressed or
implied, including but not limited to merchantability, fitness for a particular
purpose, and noninfringement. In no event shall the authors or copyright holders
be liable for any claim, damages, or other liability, whether in an action of
contract, tort, or otherwise, arising from, out of, or in connection with this
content or use of the associated files.
