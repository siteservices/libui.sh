# Dictionary of Libui Library Commands

## Libui Mods

Basic libui library functionality can be extended with the following mods:

* Date (libuiDate.sh) - Date Format Utilities
* File (libuiFile.sh) - File Support
* FileRecord (libuiFileRecord.sh) - CSV File Records Support
* Info (libuiInfo.sh) - Libui Information Utilities
* Multiuser (libuiMultiuser.sh) - Libui Multiuser Support
* Package (libuiPackage.sh) - Package Utilities
* Profile (libuiProfile.sh) - Profile Configuration File Support
* Root (libuiRoot.sh) - Libui Root Account Support
* SSH (libuiSSH.sh) - Secure Shell Utilities
* Sort (libuiSort.sh) - Sort Utilities
* Spinner (libuiSpinner.sh) - Libui Progress Spinner Support
* Syslog (libuiSyslog.sh) - System Log Support
* Timer (libuiTimer.sh) - Libui Timer Support
* User (libuiUser.sh) - Libui User Support
* Utility (libuiUtility.sh) - Libui Support Utilities
* Workspace (libuiWorkspace.sh) - Workspace Support

Man pages are available for the above: man 3 libui{Mod}.sh

Use the following to load a mod prior to use:

```
LoadMod <mod_name>
```

## Libui Commands

### Action (libui.sh) - Perform tasks using the libui library.

Primary function for performing tasks while using the libui library. The Action
command should be used for any task that might make persistent changes. It
provides support for tracing, confirmation, debugging, etc.

```
Action [-1..-9|-a|-c|-C|-e|-F|-R|-s|-t|-W] [-i <info_message>] [-f <failure_message>] [-l <file_path>] [-p <pipe_element>] [-q <question>] [-r <retries>] [-w <retry_wait>] <command_string_to_evaluate>
```

### AddOption (libui.sh) - Add command line option flags for the script.

Defines option flags for the script. The AddOption command defines the option
flag, any associated option arguments, the name of the variable associated with
the option, and the keyword and description for the usage information.

```
AddOption [-a|-f|-m|-r|-t] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_variable>] [-k <keyword>] [-n <variable_name>] [-p <provided_value>] [-P <path>] [-s <selection_values>] [-S <selection_variable>] [-v <callback>] <option>[:]
```

### AddParameter (libui.sh) - Add command line parameters for the script.

Defines parameters for the script. The AddParameter command defines the
parameters for the script, i.e., the values following the command and any option
flags, including the name of the variable associated with the parameter(s), and
the keyword and description for the usage information.

```
AddParameter [-a|-m|-r] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_variable>] [-k <keyword>] [-n <variable_name>] [-P <path>] [-s <selection_values>] [-S <selection_variable>] [-v <callback>] [<variable_name>]
```

### Alert (libui.sh) - Display a highlighted alert message for the user.

Sends a highlighted text message to STDOUT. By default this message is displayed
in green text. The message can also be logged to a log file.

```
Alert [-1..-9|-a|-c] [-l <file_path>] <message_text>
```

### AllowRoot (libuiRoot.sh) - Allow the root user to execute the script.

By default, the libui library prevents the root user from executing the script.
When called prior to calling the Initialize command, this command allows the
root user to execute the script. When called after Initialize, Returns 0 if the
root user is allowed, otherwise it returns 1.

```
AllowRoot
```

### AnswerMatches (libui.sh) - Checks a provided answer against a match string.

When the Ask command is used to request a response from the user, this command
can be used to validate the response. The answer match string can be either an
absolute match string or, with the -r option flag, a regular expression.

```
AnswerMatches [-r] <answer_match_string>
```

### Ask (libui.sh) - Displays a question to the user and obtains an answer.

The Ask command displays a highlighted question to the user and waits to collect
a response. The Ask command supports answer validation, multiple-choice
questions, default answers, and more. The answer is available in the ANSWER
variable and can optionally be assigned to a named variable.

```
Ask [-b|-C|-N|-Y|-z] [-d <default>] [-n <variable_name>] [-P <path>] [-r <required_regex>] [-s <selection_value>] [-S <selection_variable>] <question_text>
```

### Capture (libui.sh) - Special function to capture the output of a command.

Captures STDOUT, STDERR, and the return value from the executed command string.

```
Capture <stdout_variable> <stderr_variable> <rv_variable> <command_string>
```

### Close (libuiFile.sh) - Closes a file descriptor opened with the Open command.

Closes a file descriptor that was previously opened using the Open command. The
library will automatically close any open file descriptors when the Exit command
is used to exit the script. The library uses shorthand flags -1 through -9 when
accessing the file descriptors in a libui library command. Please note that the
-0 file descriptor flag is a reserved flag for library use only. It is also
possible to close using the file path.

```
Close [-1..-9] [<file_path>]
```

### Confirm (libui.sh) - Check if the "-C" (Confirm) option flag was used.

Returns 0 if the "-C" (Confirm) option flag was provided on the command line,
otherwise it returns 1.

```
Confirm
```

### ConfirmVar (libui.sh) - Confirms the value contained within a variable.

Performs some tests on a variable to ensure that the value contained within the
variable meets some limited criteria. Optionally, if the value does not meet the
criteria, a question can be asked and a response collected for the variable. The
tests currently available include:

* If the variable is an associative array (-A)
* If the value is a directory (-d)
* If the value is a valid path (-e)
* If the value is a valid file path (-f)
* If the value is not empty (-n) (This is the default.)

Note: The ConfirmVar command uses the Ask command when asking the question
provided with the -q (Optional Question) or -Q (Always Question) option flags.

```
ConfirmVar [-A|-d|-e|-f|-n|-z] [-D <default>] [-P <path>] [-q|-Q <question>] [-s <selection_value>] [-S <selection_variable>] <variable_name> ...
```

### Contains (libui.sh) - Utility function to check if an array contains a value.

The Contains command if a value is contained within the array with the provided
array variable name.

```
Contains <array_variable> <value>
```

### ConvertDate (libuiDate.sh) - Converts a date string between formats.

This command provides an interface to the "date" command to convert data strings
from one format to another. The default input format is "%a %b %d %T %Z %Y"
(which is the default date command output format) and the default output format
is "%Y-%m-%d".

```
ConvertDate [-i <input_format>] [-o <output_format>] <var_name> <date>
```

### CreatePackage (libuiPackage.sh) - Creates a self-extracting package.

The library supports the creation of self-extracting .tarp (tar package) and
.sharp (shar package) packages. This command creates the package file.
The environment specification is a variable name that contains an environment
string prepended when executing the provided installer command. It is expected
that the installer is a libui script.

```
CreatePackage [-a -l -S -T] [-c <compression>] [-d <description>] [-e <environment_spec>] [-f <filelist_array_variable_name>] [-h <header_command>] [-i <installer>] [-n <encoding>] [-s <source_directory>] [-x <exclude_array_variable_name>] <package_filename>
```
### Error (libui.sh) - Display a highlighted error message for the user.

Sends a highlighted text message to STDERR. By default this message is displayed
in yellow text on a red background. The message can also be logged to a log
file. A return value can provided with the -r (Return Value) option flag.
Normally the Error command will exit the script (using the Exit command). This
can be disabled with the -E (Disable Exit) option flag.

```
Error [-1..-9|-a|-c|-e|-E|-L] [-l <file_path>] [-r <return_value>] <error_message>
```

### ExitCallback (libui-template) - Optional function in main script.

If an ExitCallback function is defined in the script, it will be called when the
script is exited using the Exit command.

```
ExitCallback () {
  Trace 'In user exit callback.'
}
```

### Exit (libui.sh) - Exits the main script.

The Exit command cleans up script resources, calls any exit callbacks, and
terminates the script. It returns the provided return value when provided or the
return value from the last executed command.

```
Exit [<return_value>]
```

### Force (libui.sh) - Check if the "-F" (Force) option flag was used.

Returns 0 if the "-F" (Force) option flag was provided on the command line,
otherwise it returns 1.

```
Force
```

### FormatElapsed (libuiTimer.sh) - Reformats ELAPSED in human readable format.

Converts the number of seconds in ELAPSED to a human readable format of "D days,
HH:MM:SS.SSS" where "D days" is only displayed if the elapsed time is greater
than 24 hours. See the StartTimer and GetElapsed commands for more information.

```
FormatElapsed [-d]
```

### GetElapsed (libuiTimer.sh) - Get the elapsed time from a timer.

Captures the time elapsed in seconds since the timer identified by the variable
name was started using the StartTimer command.

```
GetElapsed [<variable_name>]
```

### GetFileList (libuiFile.sh) - Get a list of file into an array.

Collects the file paths associated with the provided file specification and
loads them into an array variable with the provided variable name. The
collection of paths can optionally be recursive. The file specification can be
further refined with the option flags to limit the array results to:

* directories only (-d)
* files only (-f)
* filenames only (-n)
* directory paths only (-p)

```
GetFileList [-d|-e|-f|-n|-p|-r|-w] <variable_name> <file_specification> ...
```

### GetRealPath (libuiFile.sh) - Get the real, absolute path for a file.

Gets the absolute path for provided path specification, bypassing any symbolic
links. With the -P (Path) option flag, GetRealPath will only test the directory
portion of the path (to support the creation of new files).

```
GetRealPath [-P] <variable_name> [<path_specification>]
```

### GetTmp (libuiFile.sh) - Get a temporary directory, subdirectory or file.

Creates a temporary directory, subdirectory, or file and returns the path in the
provided variable name. The temporary files will be created in the path defined
by TMPDIR, if set, or "/tmp". Only one temporary directory will be created and
it, along with any contents, will automatically be removed when the Exit command
is called. Multiple subdirectories and files may be created, but all of them
will exist within the one temporary directory.

```
GetTmp [-d|-f|-s] <variable_name>
```

### InfoCallback (libui-template) - Optional function in main script.

If an InfoCallback function is defined in the script, it will be called when the
script displays usage information using the UsageInfo command.

```
InfoCallback () {
  Trace 'In user info callback.'
}
```

### InitCallback (libui-template) - Optional function in main script.

If an InitCallback function is defined in the script, it will be called when the
script is initialized using the Initialize command.

```
InitCallback () {
  Trace 'In user init callback.'
}
```

### Initialize (libui.sh) - Initializes the libui library after configuration.

Sets up the libui library to support main script operation. The Initialize
command must be called after all configuration commands have been executed and
before the first Actions are taken. Any command line option flags and parameters
are captured and checked for errors during initialization. Any defined
initialization callbacks are also called.

```
Initialize
```

### IsTarget (libuiSSH.sh) - Performs basic checks to confirm target is remote.

Performs some basic checks on the provided remote target name to ensure it is
a valid host and not the localhost.

```
IsTarget <target>
```

### LibuiConfig (libuiUtility.sh) - Creates a libui configuration file.

Note: The libuiUtility mod is designed to support the libui utility application.

This command creates a libui configuration file in the ".libui" directory inside
the user's home directory. It is called by the libui utility application.

```
LibuiConfig
```

### LibuiDemo (libuiUtility.sh) - Provides a simple libui capabilities demo.

Note: The libuiUtility mod is designed to support the libui utility application.

This command displays a simple libui demonstration that highlights some of the
defined variables and display capabilities. It is called by the libui utility
application.

```
LibuiDemo
```

### LibuiInstall (libuiUtility.sh) - Installs libui in another directory.

Note: The libuiUtility mod is designed to support the libui utility application.

This command copies the libui library components to another directory. It is
called by the libui utility application.

```
LibuiInstall
```

### LibuiPackage (libuiUtility.sh) - Creates a libui package for distribution.

Note: The libuiUtility mod is designed to support the libui utility application.

This command creates a libui package containing the library components for
distribution to another system. It is called by the libui utility application.

```
LibuiPackage
```

### LibuiPackageList (libuiUtility.sh) - Lists the libui components in a package.

Note: The libuiUtility mod is designed to support the libui utility application.

This command lists the library components that would be included in a libui
package for distribution to another system. It is called by the libui utility
application.

```
LibuiPackageList
```

### LibuiResetCaches (libuiUtility.sh) - Reset libui cache files.

Note: The libuiUtility mod is designed to support the libui utility application.

This command deletes and/or recreates the libui cache files that are stored in
the ".libui" directory inside the user's home directory. It is called by the
libui utility application.

```
LibuiResetCaches
```

### LibuiStats (libuiUtility.sh) - Display libui usage statistics.

Note: The libuiUtility mod is designed to support the libui utility application.

This command reads and displays libui statistics files that are stored in the
".libui" directory inside the user's home directory. It is called by the libui
utility application.

```
LibuiStats
```

### LibuiUnity (libuiUtility.sh) - Unifies the current libui with another.

Note: The libuiUtility mod is designed to support the libui utility application.

This command compares, updates, or unifies the libui library components in the
current libui library installation to an installation in another directory. It
is called by the libui utility application.

```
LibuiUnity [-u|-U|-v]
```

### LibuiUnlock (libuiUtility.sh) - Removes stale libui lock files.

Note: The libuiUtility mod is designed to support the libui utility application.

This command removes any existing libui lock files. It is only needed on systems
that do not support the flock command. It is called by the libui utility
application.

```
LibuiUnlock
```

### LibuiUpdateMan (libuiUtility.sh) - Updates the date in libui man pages.

Note: The libuiUtility mod is designed to support the libui utility application.

This command updates the date within the libui man pages when the timestamp
changes on a libui component script. It is called by the libui utility
application.

```
LibuiUpdateMan
```

### ListPackage (libuiPackage.sh) - List the contents of a package.
```
ListPackage
```

Generates a listing of files contained in a package.

### LoadMod (libui.sh) - Loads a libui mod.

The libui library supports mods that add new and/or change existing
functionality. This command loads a mod for use. It normally loads from the
SHLIBPATH but another path can be provided using the -P (Path) option flag.

```
LoadMod [-P <path>] <libui_mod_name>
```

### LoadProfile (libuiProfile.sh) - Manually load a profile.

The libui library supports runtime profiles. This command will manually load a
profile.

```
LoadProfile <file_path>
```

### Multiuser (libuiMultiuser.sh) - Check if multiuser mode is enabled.

Returns 0 if multiuser mode has been enabled (by loading the Multiuser mod),
otherwise it returns 1.

```
Multiuser
```

### NoAction (libui.sh) - Check if the "-N" (No Action) option flag was used.

Returns 0 if the "-N" (No Action) option flag was provided on the command line,
otherwise it returns 1.

```
NoAction
```

### Open (libuiFile.sh) - Open a file descriptor for use within the script.

The libui library supports file locking, enables file access shorthand, and can
automatically back up files through the Open command. The file descriptor to use
should be passed to the Open command and are restricted between 1 and 9. Please
note that the -0 file descriptor flag is a reserved flag for library use only.
Open file descriptors should be closed using the Close command.

```
Open [-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
```

### PathMatches (libuiFile.sh) - Compares two provided filesystem paths.

Compares the absolute path for provided path specifications, bypassing any
symbolic links. With the -P (Path) option flag, PathMatches will only test the
directory portion of the paths.

```
PathMatches [-P] <path_specification_1> <path_specification_2>
```

### PauseSpinner (libuiSpinner.sh) - Pause a running progress spinner.

Pauses a running progress spinner. It can be restarted by using the
ResumeSpinner command. This is primarily used when asking for user input in the
middle of a task.

```
PauseSpinner
```

### Quiet (libui.sh) - Check if the "-Q" (Quiet) option flag was used.

Returns 0 if the "-Q" (Quiet) option flag was provided on the command line,
otherwise it returns 1.

```
Quiet
```

### RecordClose (libuiFileRecord.sh) - Close a descriptor opened by RecordOpen.

Closes a file descriptor that was previously opened using the RecordOpen
command. The library will automatically close any open file descriptors when the
Exit command is used to exit the script. The library uses shorthand flags -1
through -9 when accessing the file descriptors in a libui library command.
Please note that the -0 file descriptor flag is a reserved flag for library use
only. It is also possible to close using the file path. Note: Uses the same
parameters as the Close command.

```
RecordClose [-1..-9] [<file_path>]
```

### RecordEntry (libuiFileRecord.sh) - Create an entry in a Record File.

Creates a comma separated values (CSV) record in an open record file. If the
data associative array or the column array is not provided, RecordEntry will use
the array variables "RecordData" and "RecordColumns", respectively. The data
associative array should use the same names as are included in the column array.

```
RecordEntry <fileid> [<data_assoc_array>] [<column_array>]
```

### RecordOpen (libuiFileRecord.sh) - Open a record-based file descriptor.

The libui library supports file locking, enables file access shorthand, and can
automatically back up files through the Open command. The file descriptor to use
should be passed to the Open command and are restricted between 1 and 9. Please
note that the -0 file descriptor flag is a reserved flag for library use only.
Open file descriptors should be closed using the Close command. Note: Uses the
same parameters as the Open command.

```
RecordOpen [-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
```

### RemoveFileList (libuiFile.sh) - Removes files in the provided array.

Removes the file paths contained in the array with the provided variable name.
RemoveFileList will attempt to quietly force the removal when the -f (Force)
option is provided.

```
RemoveFileList [-f] <name_of_array_variable> ...
```

### RequireRoot (libuiRoot.sh) - Require the root user to execute the script.

By default, the libui library prevents the root user from executing the script.
When called prior to calling the Initialize command, this command requires the
root user to execute the script. When called after Initialize, Returns 0 if the
root user is required, otherwise it returns 1.

```
RequireRoot
```

### ResumeSpinner (libuiSpinner.sh) - Resumes a progress spinner.

Resumes a running progress spinner that was paused by the PauseSpinner command.

```
ResumeSpinner
```

### Sleep (libuiSpinner.sh) - Sleeps a script with an optional countdown.

Pauses execution and optionally provides a countdown. The countdown is updated
at the interval provided by the -u (Update) option flag. The countdown message
displayed is provided by the -m (Message) option flag should include a "%s" for
the remaining seconds and defaults to:

```
Waiting %s...
```

```
Sleep [-m "<message>"] [-u <interval>] [<sleep>]
```

### Sort (libuiSort.sh) - Sorts an array.

Sorts the array variable with the provided name. Depending upon the provided
option flag, the sort can be forward or reverse, ASCII, lexical, numeric, path,
or custom.

```
Sort [-a|-A|-l|-L|-n|-N|-p] [-c <compare_function>] <array_variable_name> ...
```

### SSHExec (libuiSSH.sh) - Execute a command on a remote server via ssh.

Sends a command to a remote server (using -t) or a list of remote servers (using
-T) and collects the response into SSH_OUT (STDOUT), SSH_ERR (STDERR), and
SSH_RV (return value) variables.

```
SSHExec [-q|-v] [-p <password>] [-P <port>] [-t <target>] [-T <target_array_variable>] [-u <user>] <command> ...
```

### SSHSend (libuiSSH.sh) - Sends files to a remote server via scp.

Sends files to a remote server (using -t) or a list of remote servers (using
-T), placing the file into the provided destination, and collects the response
into SSH_OUT (STDOUT), SSH_ERR (STDERR), and SSH_RV (return value) variables.

```
SSHSend [-q|-v] -d <destination> [-p <password>] [-P <port>] [-t <target>] [-T <target_variable>] [-u <user>] <file> ...
```

### StartSpinner (libuiSpinner.sh) - Start a progress spinner.

Starts a progress spinner that is displayed a space after the current cursor
position. The spinner should be stopped with the StopSpinner command. An
informational message can be optionally displayed. Note: the spinner should also
stop when the program ends with the Exit command. (Under certain error
conditions, it is possible for the Spinner to persist beyond the script and
would need to be killed manually.)

```
StartSpinner [<info_message>]
```

### StartTimer (libuiTimer.sh) - Start a timer.

Starts a timer. There is a default timer or, a variable name can be provided to
support multiple timers.

```
StartTimer [<variable_name>]
```

### StopSpinner (libuiSpinner.sh) - Stop a progress spinner.

Stops a progress spinner that was started by the StartSpinner command. Note: the
spinner should also stop when the program ends with the Exit command. (Under
certain error conditions, it is possible for the Spinner to persist beyond the
script and would need to be killed manually.)

```
StopSpinner
```

### Syslog (libuiSyslog.sh) - Send a message to the system log.

Sends a message with the provided priority to the system log. The default
priority is "user.notice".

```
Syslog [-p <priority>] [<message>]
```

### Tell (libui.sh) - Display a highlighted message for the user.

Sends a highlighted text message to STDOUT. By default this message is displayed
in bold white text. The message can also be logged to a log file. Normally Tell
adds a newline after printing the message. This can be disabled with the -n (No
Newline) option.

```
Tell [-1..-9|-a|-c|-i|-n|-N] [-l <file_path>] <message_text>
```

### \_Trace (libui.sh) - Internal libui trace command.

The \_Trace command is an internal libui trace command. It is included here
because this form should be used in libui mods with the following form:

```
${_M} && _Trace 'Trace message. (%s)' "${var}"
```

### Trace (libui.sh) - Runtime trace command.

Trace provides debug messages when debugging is enabled with the -X (Xdebug)
command line option. For this to be effective, it is recommended that the Trace
command be used in place of comments within the code. That way when debugging is
enabled, it will be easy to trace the operation of the script to determine where
the error exists. Trace should be used with the following form:

```
Trace 'Trace message. (%s)' "${var}"
```

### UsageInfo (libuiInfo.sh) - Display usage information (i.e. help) to the user.

Displays usage information, i.e. help information, to the user. This function is
automatically provided by the libui library with the -H or -h (Help) command
line option flags. The usage information is built from the AddOption and
AddParameter commands. The UsageInfo command will also call a provided
InfoCallback function if one is available.

```
UsageInfo
```

### ValidateWorkspace (libuiWorkspace.sh) - Validates and load workspace info.

A workspace is considered to be the directory that contains one or more (git)
repositories. This functions loads configuration information and sets
environment variables that are used by other libui supported commands.

```
ValidateWorkspace [-W]
```

### Verbose (libui.sh) - Check if the "-V" (Verbose) option flag was used.

Returns 0 if the "-V" (Verbose) option flag was provided on the command line,
otherwise it returns 1.

```
Verbose
```

### Verify (libui.sh) - Asks a yes / no question and returns 0 for yes, 1 for no.

Uses Ask to ask the user a question and waits for a yes / no response. Returns 0
on a "yes" response and 1 on a "no" response. If a "q" is provided, the main
script will exit. Note that other Ask command options are also available.

```
Verify [-C|-N|-Y] [-d <default>] [-n <variable_name>] [-r <required_regex>] <question_text>
```

### Version (libui.sh) - Version information.

When a version number is provided, captures the version information for the
script. If the -r (Required) option flag is provided, confirms that the libui.sh
library version being used is at least that version. When used with no
parameters, displays the captured version information. This function is included
with the usage information provided by the libui library with the -H or -h
(Help) command line option flags.

```
Version [-m] [-r <required_libui_version>] <script_version>
```

### WaitSpinner (libuiSpinner.sh) - Start a spinner and wait for background task.

Starts a spinner and waits for the last executed background task to complete.

```
WaitSpinner
```

### Warn (libui.sh) - Display a highlighted warning message for the user.

Sends a highlighted text message to STDERR. By default this message is displayed
in black text on a yellow background. The message can also be logged to a log
file. A return value can provided with the -r (Return Value) option flag.

```
Warn [-1..-9|-a|-c] [-l <file_path>] [-r <return_value>] <warning_message>
```

### Write (libuiFile.sh) - Write text to a file.

Writes the provided data to a file identified by the provided file ID
(previously opened with the Open command) or the -f (File) option flag. The
Write command defaults to a printf format of "%s" and new-line as a record
marker. These can be changed with the -p (Printf) and -r (Record Marker) option
flags.

```
Write [-0|-1..-9|-a|-c] [-f <file_path>] [-p <format>] [-r <record_marker>] <data>
```

### Yes (libui.sh) - Check if the "-Y" (Yes) option flag was used.

Returns 0 if the "-Y" (Yes) option flag was provided on the command line,
otherwise it returns 1. The -e (Enable) and the -E (Disable) option flags can be
used to enable and disable the Yes feature within the script.

```
Yes [-e|-E]
```

## Vim Note

When using the "#!/usr/bin/env libui" shebang, add the following to your
~/.vim/scripts.vim file to improve syntax highlighting:

```
if getline(1) =~ '^#!/usr/bin/env libui'
  setfiletype zsh " or 'bash'
endif
```
