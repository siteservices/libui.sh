# libui - A User Interface Library for Z Shell and Bash Scripts

## Description

The libui user interface library provides a "pure-script" execution environment that simplifies development of robust scripts with a consistent user interface. The library inherently provides several high-level capabilities along with several "standard" option flags that help with debugging, options for alternate execution flows (confirmation, no action, verbose, etc.), automatic script usage information, and color terminal highlighting.

While identified as "pure-script" it does utilize several basic Unix / Linux commands such as awk, bc, date, grep, sed, sort, stat, tr, etc. to deliver the functionality provided. Efforts have been made to minimize external dependencies and provide portability across Unix-like operating systems.
## Synopsis

The easiest way to create a new script is to use the following command.

```
libui -n <script_path>
```

Use `libui -m` or `man libui` for a man page with details on the libui command. Information on the libui.sh shell library can be found using `man libui.sh`.

## Scripting

To create a libui script, use the following shebang in the first line of the script.

```
#!/usr/bin/env libui
```

Alternatively, to source libui.sh in a zsh or bash script, include the following line near the beginning of the script.

```
source "${LIBUI:-$(libui -\?)}" "${0}" "${@}"
```

Every libui script (or libui mod) should contain the following command line, again near the beginning of the script.

```
Version [-m] [-r <minimum_version>] <version>
```

Where `<version>` is the version of the script itself and `<minimum_version>`, if provided, ensures the libui.sh library is at least that version. (Use the `libui -v` command to find the current version of the libui.sh library.) The `-m` (mod) flag is used to indicate that the file is a libui.sh mod. See the libui.sh man page (`man libui.sh`) for details

Every libui script _**must initialize the library**_ after configuration and before starting the main script by using the following command. If no configuration is required, the `Initialize` command can follow the `Version` command.

```
Initialize
```

Every libui script should exit using the following command. This command will perform any required cleanup.

```
Exit [<return_value>]
```

The `<return_value>`, if provided, is the value to be returned by the script.

## Documentation

Documentation for the libui library is provided in the `share/doc` directory.

The libui markdown (.md) documentation can be accessed within a terminal using the provided `mless <document>` command.

## Man Pages

Unix mandoc man pages are included with the User Interface Library and provide more comprehensive documentation on the commands and capabilities provided.

Information on the core library is available with `man 3 libui.sh`.

## Installation

The recommended installation of the User Interface Library is provided by the libui script. The easiest installation is to use git to pull down the repository and then execute the following command.

```
make install
```

This will execute the libui script with the `-I` (Install) option. If the `${COMMONROOT}` environment variable has not been configured with the library installation path, a prompt will appear asking for the COMMONROOT directory. The default location for COMMONROOT is `~/.local/libui`.

The COMMONROOT environment variable should contain the absolute path for the libui.sh library files. The libui.sh library includes several subdirectories that are installed under the COMMONROOT path including: `bin`, `lib/sh`, `lib/test`, `share/doc`, `share/man/man1`, and `share/man/man3`.

Note: The provided \<COMMONROOT\> path must be writable by the user performing the installation.

Alternatively, the libui library can be installed by executing the libui script directly from within the repo using the following command.

```
bin/libui -I <COMMONROOT>
```

To include all the libui regression tests, use `libui -i <COMMONROOT>`, i.e., using the `-i` (Install With Tests) option flag instead of the `-I` (Install Without Tests) option flag.

## Post Installation

Once installed, access to the library must be established. This is best accomplished by adding the following to your .zshrc / .bashrc file.

```
export COMMONROOT=<path/to/commonroot>
[[ "${PATH}" =~ (.*:|^)"${COMMONROOT}/bin"($|:.*) ]] ||
    PATH="${COMMONROOT}/bin${PATH:+:${PATH}}"
eval "$(libui -M)"
```

The above (when you change <path/to/commonroot> to the libui install path):

* Creates the COMMONROOT environment variable.
* Adds `<COMMONROOT>/bin` to your `${PATH}` (if it's not already there) to gain access to the libui command and example scripts.
* Uses `eval $(libui -M)` to add `<COMMONROOT>/share/man` to your `${MANPATH}` for access to the libui man pages.

Once the `${PATH}` and `${MANPATH}` environment variables have been updated, you can use `man 3 libui.sh` or `libui -m` to view the core library man page.

Also, the `mless <document>` command can be used to view the markdown documents available in the `<COMMONROOT>/share/doc` directory. (The full path does not need to
be included, just the document name.)

## Creating a Script

The easiest way to create a new script is to use the `libui -n <script_path>` command. This command copies the `libui-template` file from the `share/doc` directory, asks a few questions, and creates a new, template-based script in the location identified by the "\<script_path\>" parameter. (Note: Experienced users may want to use the `libui -N <script_path>` form to create the new script without the extra demo content.)

## Next Steps

It is recommended that every user reads through the `libui-dictionary.md` document to get a high-level overview of the available commands. This can be accessed using `mless libui-dictionary`. Additional details on each of the commands and option flags can be found in the associated man pages.

The example scripts available in the `bin` directory provide several real-world examples of libui scripts. Reviewing those scripts to build knowledge is highly recommended.

## Contact and Contributions

The libui user interface library is intended to be a community project. As such, if you have a question, find an issue, identify a need, want a new command or mod, and/or wish to contribute, please submit a patch via github or reach out via email to fharvell@siteservices.net.

## Notes

* The Z shell (zsh) is the preferred shell for libui script development and will be selected by default. If zsh is not available, 'libui -i' will modify the installed `libui/sh/libui` support script to use bash.

## Editors
### Neovim

When using the `#!/usr/bin/env libui` shebang, syntax highlighting and formatting can be improved by creating a `~/.config/nvim/filetype.lua` file and adding the following to set the filetype to zsh (or bash):

```
vim.filetype.add({
  pattern = {
    [".*"] = {
      function(path, bufnr)
        local shebang = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
        if shebang:match('^#!.*[/ ]libui$') then return 'zsh' end
      end, { priority = -math.huge },
    },
  },
})
```

If you prefer bash syntax highlighting, change `return 'zsh'` in the file to `return 'bash'`.

### Vim

When using the `#!/usr/bin/env libui` shebang, syntax highlighting and formatting can be improved by creating a `~/.vim/ftdetect/libui.vim` file and adding the following to set the filetype to zsh (or bash):

```
autocmd BufRead *
	\ if getline(1) =~ '^#!/usr/bin/env libui' |
	\   set filetype=zsh |
	\ endif
```

If you prefer bash syntax highlighting, change `set filetype=zsh` in the file to `set filetype=bash`.

## License

This content and associated files as published by siteservices.net, Inc. are marked CCO 1.0. Permission is unconditionally granted to anyone with the interest, full rights to use, modify, publish, distribute, sublicense, and/or sell this content and all associated files. To view a copy of CCO 1.0, visit https://creativecommons.org/publicdomain/zero/1.0/.

All content is provided "as is", without warranty of any kind, expressed or implied, including but not limited to merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors or publishers be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the use of this content or any of the associated files.