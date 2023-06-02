# Quickstart for the Libui User Interface Library

## Main User Interface Commands

There are a few key commands provided by the libui library that almost every
libui script will utilize:

* Action
> This command supports the execution of commands that will generate persistent
> changes. It supports debugging, logging, command-line control, and user
> interaction for tasks that the user or programmer would like to control during
> script execution.

* AddOption
> This command adds an option flag to the command line and captures the use of
> the flag into a named variable. The data provided is also used to generate the
> usage information for the user.

* AddParameter
> Similar to the AddOption command, this command adds support for parameters to
> be supplied on the command line. Again the data provided is also used to
> generate usage information for the user.

* Alert / Error / Tell / Warn
> The Alert, Error, Tell, and Warn commands all generate messages to the script
> user. Essentially, they provide the information with various highlighting to
> properly alert the user to positive and negative content.

* Ask / AnswerMatches / Verify
> The Ask command prompts the user and waits for a response. The AnswerMatches
> command can be used to ensure that a provided response matches provided
> criteria. The Verify command essentially combines the two to ask yes/no
> questions and returns 0 for yes and 1 for no.

* ConfirmVar
> The ConfirmVar command is a powerful command for validating variables. It is
> most often used in the script-provided InitCallback function to confirm values
> prior to the execution of the main script.

* Initialize
> Each libui script must execute the Intialize command after using commands like
> the AddOption and AddParameter commands to configure the user interface and
> before the execution of the main script and any operational commands like
> Action, Ask, Verify, etc.

* Trace
> The Trace command is a very valuable debugging tool. It is recommended that
> the script writer use Trace anywhere that a comment would normally be
> provided. Then, when debugging is enabled, the trace messages will be
> displayed providing the user / debugger the opportunity to see exactly where
> the script is failing. It is also highly recommended that the trace messages
> include the variable of interest so that those values may be seen during
> debugging.

* Version
> Each libui script should include a Version command to define the version of
> the script and to identify the minimum libui.sh version required for proper
> operation. (When using `libui -n` to create a new script, the current library
> version is automatically used.)

* Exit
> Each libui script should include an Exit command to properly exit the script.
> When the Exit command is used, files are closed and unlocked, resources are
> cleaned up, statistics are collected, and the script-provied ExitCallback is
> called.

There are a large number of additional commands available. A read through the
libui-dictionary.md document to get a high-level overview of the currently
available commands is recommended.

## Creating a New Script

The easiest way to create a new script is to use the `libui -n {script}`
command. This command copies the `libui-template` file from the `share/doc`
directory, asks a few questions, and creates a new, templated script in the
location identified by the "{script}" parameter.

## Next Steps

It is recommended that every user reads through the libui-dictionary.md document
to get a high-level overview of the currently available commands. Additional
details on each of the commands and option flags can be found in the associated
man pages.

The scripts available in the `bin` directory provide several real-world examples
of libui scripts. Reviewing those scripts is highly recommended.

## Contact and Contributions

The libui user interface library is intended to be a community project. As such,
if you have a question, find an issue, identify a need, and/or wish to
contribute, please submit a patch or reach out to fharvell@siteservices.net or
via github.
