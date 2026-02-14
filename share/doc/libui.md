# Quickstart for the Libui User Interface Library for Z Shell and Bash

The libui user interface library provides a "pure-script" execution environment that simplifies development of robust scripts with a consistent user interface. The library inherently provides several high-level capabilities along with several "standard" option flags that help with debugging, options for alternate execution flows (confirmation, no action, verbose, etc.), automatic script usage information, and color terminal highlighting.

This document provides a quick overview of the libui user interface library. More information can be found in the `libui-readme.md` and `libui-dictionary.md` files. Once the library has been installed, these documents are available in the `share/doc` subdirectory and can be read in a terminal using the `mless` command, e.g., `mless libui-dictionary.md`.

## Installation

The libui library is available at https://github.com/siteservices/libui.sh. Once downloaded, it should be installed using `make install` and providing an installation directory. Once installed, the `bin` subdirectory under the installation directory needs to be added to the user's PATH. To access the available man pages, the installation `share/man` subdirectory should also be added to the user's MANPATH.

## The `libui` Command

The entry point for libui scripts is the libui command. This command, when installed becomes the main interface for working with the libui library. A simple introduction to its capabilities can be found by simply executing the command using `libui`. This will display a help page that helps explain the available option flags and operation.

Use `libui -m` or `man libui` for a man page with details on the libui command. Information on the libui.sh shell library can be found using `man libui.sh`.

The easiest way to create a new script is to use the `libui -n <script>` command.

The easiest way to create a new script is to use the following command.

```sh
libui -n <script_path>
```

This command copies the `libui-template` file from the `share/doc` subdirectory, asks a few questions, and creates a new, templated script in the location identified by the "\<script_path\>" parameter. If the script will be created from scratch, the recommended shebang is:

```sh
#!/usr/bin/env libui
```

This shebang automatically loads the libui.sh library for use. See the libui.sh man page for more details.

## Main User Interface Commands

While the libui library provides a large number of commands, there are a few key commands that almost every libui script will utilize. The following paragraphs provide an overview of these key commands.

* Action
> This command supports the execution of commands that will generate persistent changes. It supports debugging, logging, command-line control, and user interaction for tasks that the user or programmer would like to control during script execution.

* AddOption
> This command adds an option flag to the command line and captures the use of the flag into a named variable. The data provided is also used to generate the usage information for the user.

* AddParameter
> Similar to the AddOption command, this command adds support for parameters to be supplied on the command line. Again the data provided is also used to generate usage information for the user.

* Alert / Error / Tell / Warn
> The Alert, Error, Tell, and Warn commands all generate messages to the script user. Essentially, they provide the information with various highlighting to properly alert the user to positive and negative content.

* Ask / AnswerMatches / Verify
> The Ask command prompts the user and waits for a response. The AnswerMatches command can be used to ensure that a provided response matches provided criteria. The Verify command essentially combines the two to ask yes/no questions and returns 0 for yes and 1 for no.

* ConfirmVar
> The ConfirmVar command is a powerful command for validating variables. It is most often used in the script-provided InitCallback function to confirm values prior to the execution of the main script.

* Initialize
> Each libui script must execute the Intialize command after using commands like the AddOption and AddParameter commands to configure the user interface and before the execution of the main script and any operational commands like Action, Ask, Verify, etc.

* Trace
> The Trace command is a very valuable debugging tool. It is recommended that the script writer use Trace anywhere that a comment would normally be provided. Then, when debugging is enabled, the trace messages will be displayed providing the user / debugger the opportunity to see exactly where the script is failing. It is also highly recommended that the trace messages include the variable of interest so that those values may be seen during debugging.

* Version \<version\>
> Each libui script should include a Version command to define the version of the script and to identify the minimum libui.sh version required for proper operation. (When using `libui -n` to create a new script, the current library version is automatically used.) Version should be "major.minor, i.e., #.#".

* Exit
> Each libui script should include an Exit command to properly exit the script. When the Exit command is used, files are closed and unlocked, resources are cleaned up, statistics are collected, and the script-provided ExitCallback is called.

While this covers the common commands, reviewing the libui-dictionary.md document provides a high-level overview of each available command. The available man pages provide a more thorough description of each command, capability, and available option flag.

## Next Steps

It is recommended that every user reads through the `libui.md` and `libui-dictionary.md` documents to get a high-level overview of the available commands. These files can be accessed using `mless libui-dictionary` and `mless libui-dictionary` commands. Complete details on each of the libui provided commands and option flags can be found in the associated man pages, e.g., by executing the `man libui.sh` command.

Example scripts are also available in the `bin` directory and provide several real-world examples of libui scripts. Reviewing those scripts to build knowledge is highly recommended.
## Contact and Contributions

The libui user interface library is intended to be a community project. As such, if you have a question, find an issue, identify a need, want a new command or mod, and/or wish to contribute, please submit a patch via github or reach out via email to fharvell@siteservices.net.

## License

This content and associated files as published by siteservices.net, Inc. are marked CCO 1.0. Permission is unconditionally granted to anyone with the interest, full rights to use, modify, publish, distribute, sublicense, and/or sell this content and all associated files. To view a copy of CCO 1.0, visit https://creativecommons.org/publicdomain/zero/1.0/.

All content is provided "as is", without warranty of any kind, expressed or implied, including but not limited to merchantability, fitness for a particular purpose, and noninfringement. In no event shall the authors or publishers be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the use of this content or any of the associated files.