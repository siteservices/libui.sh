# Dictionary of Libui Library Commands

## Libui Mods

Basic libui library functionality can be extended with the following mods:

* Convert (man libuiConvert.sh) - Conversion Utilities
* File (man libuiFile.sh) - File Support
* FileRecord (man libuiFileRecord.sh) - CSV File Records Support
* Info (man libuiInfo.sh) - Libui Information Utilities
* Libui (man libuiLibui.sh) - Libui Support Mod (see addendum dictionary)
* Multiuser (man libuiMultiuser.sh) - Libui Multiuser Support
* Package (man libuiPackage.sh) - Package Utilities
* Profile (man libuiProfile.sh) - Profile Configuration File Support
* Root (man libuiRoot.sh) - Libui Root Account Support
* SSH (man libuiSSH.sh) - Secure Shell Utilities
* Sort (man libuiSort.sh) - Sort Utilities
* Spinner (man libuiSpinner.sh) - Libui Progress Spinner Support
* Syslog (man libuiSyslog.sh) - System Log Support
* Term (man libuiTerm.sh) - Libui Terminal Support
* Timer (man libuiTimer.sh) - Libui Timer Support
* User (man libuiUser.sh) - Libui User Support
* Utility (no man page) - Libui Utilities (libui internal use only)
* Workspace (man libuiWorkspace.sh) - Workspace Support

Man pages are available for the above: man 3 libui{Mod}.sh

Use the following to load a mod prior to use:

```
LoadMod <mod_name>
```

## Libui Commands

### Action (man libui.sh) - Perform tasks using the libui library.

Primary function for performing tasks while using the libui library. The Action
command should be used for any task that might make persistent changes. It
provides support for tracing, confirmation, debugging, etc. It will generate a
warning message on an action failure.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-C** - always confirm action
* **-e** - message to display on a non-zero (error) return value
* **-f** - generate error on failiure
* **-F** - skip action if prior failure
* **-i** - message to display while executing (use with **-s** or spinner)
* **-l** - log output to file
* **-p** - use provided pipeline action as return value
* **-q** - confirmation question to ask
* **-r** - retry action provided number of times before failing
* **-R** - reset any prior failures (see -F)
* **-s** - display progress spinner while executing
* **-t** - tee output to display and log file
* **-w** - wait time between retries (use with -r)
* **-W** - do not generate a warning on failure

```
Action [-1..-9|-a|-c|-C|-f|-F|-R|-s|-t|-W] [-i <info_message>] [-e <error_message>] [-l <file_path>] [-p <pipe_element>] [-q <question>] [-r <retries>] [-w <retry_wait>] <command_string_to_evaluate>
```

### At (man libuiTerm.sh) - Execute a command at a position on the terminal.

This support command saves the current cursor position, moves to the provided
position, executes the provided command, and restores the original cursor
position. Useful for displaying specific messages at a specific location on the
display. The command can be multiple words.

Note: Most of the libui.sh provided message commands jump to the beginning of
the current row before displaying the message. Most support the **-i** (In Place)
option flag allowing the message to be displayed "in place" at the current
cursor position.

```
At <row> <col> <command>
```

### AddOption (man libui.sh) - Add command line option flags for the script.

Defines option flags for the script. The AddOption command defines the option
flag, any associated option arguments, the name of the variable associated with
the option, and the keyword and description for the usage information.

* **-a** - automatically default if only one selection option
* **-c** - option callback called when processing option
* **-d** - option description
* **-f** - initial value "false", provided value "true"
* **-i** - initial value to use when option is not provided
* **-I** - get initial value from provided variable name
* **-k** - option keyword
* **-m** - allow option to be used multiple times (use array for option arguments)
* **-n** - option variable name
* **-p** - value to use when option is provided
* **-P** - path to prepend to provided value
* **-r** - option is required
* **-s** - selection of values that can be used
* **-S** - get selection of values from provided variable name
* **-t** - initial value "true", provided value "false"
* **-v** - validation callback called after all parameters have been processed

```
AddOption [-a|-f|-m|-r|-t] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_variable>] [-k <keyword>] [-n <variable_name>] [-p <provided_value>] [-P <path>] [-s <selection_values>] [-S <selection_variable>] [-v <callback>] <option>[:]
```

### AddParameter (man libui.sh) - Add command line parameters for the script.

Defines parameters for the script. The AddParameter command defines the
parameters for the script, i.e., the values following the command and any option
flags, including the name of the variable associated with the parameter(s), and
the keyword and description for the usage information.

* **-a** - automatically default if only one selection option
* **-c** - option callback called when processing option
* **-d** - option description
* **-i** - initial value to use when option is not provided
* **-I** - get initial value from provided variable name
* **-k** - option keyword
* **-m** - allow option to be used multiple times (use array for option arguments)
* **-n** - option variable name
* **-P** - path to prepend to provided value
* **-r** - option is required
* **-s** - selection of values that can be used
* **-S** - get selection of values from provided variable name
* **-v** - validation callback called after all parameters have been processed

```
AddParameter [-a|-m|-r] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_variable>] [-k <keyword>] [-n <variable_name>] [-P <path>] [-s <selection_values>] [-S <selection_variable>] [-v <callback>] [<variable_name>]
```

### Alert (man libui.sh) - Display a highlighted alert message for the user.

Sends a highlighted text message to STDOUT. By default this message is displayed
in green text. The message can also be logged to a log file.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-f** - force script to exit after displaying the message (see Error command)
* **-F** - Disable exit after displaying the message (see Error command)
* **-i** - display the message "in place", i.e., where the cursor currently is
* **-l** - log message to file
* **-L** - include the location of the message request (see Error command)
* **-n** - do not include a trailing newline
* **-N** - do not include a trailing linefeed
* **-r** - use provided return value

```
Alert [-1..-9|-a|-c|-f|-F|-i|-L|-n|-N] [-l <file_path>] [-r <return_value>] <message>
```

### AllowRoot (man libuiRoot.sh) - Allow the root user to execute the script.

By default, the libui library prevents the root user from executing the script.
When called prior to calling the Initialize command, this command allows the
root user to execute the script. When called after Initialize, Returns 0 if the
root user is allowed, otherwise it returns 1.

```
AllowRoot
```

### AnswerMatches (man libui.sh) - Checks an answer against a match string.

When the Ask command is used to request a response from the user, this command
can be used to validate the response. The answer match string can be either an
absolute match string or, with the **-r** option flag, a regular expression.

* **-r** - process answer match string as a regular expression

```
AnswerMatches [-r] <answer_match_string>
```

### Ask (man libui.sh) - Displays a question to the user and obtains an answer.

The Ask command displays a highlighted question to the user and waits to collect
a response. The Ask command supports answer validation, multiple-choice
questions, default answers, and more. The answer is available in the ANSWER
variable and can optionally be assigned to a named variable.

* **-b** - boolean, yes/no response
* **-C** - only ask when the **-C** (Confirm) command line option flag was used
* **-d** - default answer
* **-E** - disable echo on the terminal when asking a question
* **-n** - variable name to save the answer
* **-N** - default answer to "no"
* **-o** - output file descriptor
* **-P** - path fragment, i.e., directory, to prepend to answer
* **-r** - regular expression that the answer must match
* **-S** - get selection of values from provided variable name
* **-s** - selection of values that can be used
* **-Y** - default answer to "yes"
* **-z** - allow an empty answer (empty string)

```
Ask [-b|-C|-E|-N|-Y|-z] [-d <default>] [-n <variable_name>] [-P <path>] [-r <required_regex>] [-s <selection_value>] [-S <selection_variable>] <question_text>
```

### Capture (man libui.sh) - Special function to capture output from a command.

Captures STDOUT, STDERR, and the return value from the executed command string.

```
Capture <stdout_variable> <stderr_variable> <rv_variable> <command_string>
```

### Caution (man libui.sh) - Display a highlighted caution message for the user.

Sends a highlighted text message to STDERR. By default this message is displayed
in magenta text. The message can also be logged to a log file. A return value
can provided with the **-r** (Return Value) option flag.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-f** - force script to exit after displaying the message (see Error command)
* **-F** - Disable exit after displaying the message (see Error command)
* **-i** - display the message "in place", i.e., where the cursor currently is
* **-l** - log message to file
* **-L** - include the location of the message request (see Error command)
* **-n** - do not include a trailing newline
* **-N** - do not include a trailing linefeed
* **-r** - use provided return value

```
Caution [-1..-9|-a|-c|-f|-F|-i|-L|-n|-N] [-l <file_path>] [-r <return_value>] <message>
```

### Close (man libuiFile.sh) - Closes a file ID opened with the Open command.

Closes a file ID that was previously opened using the Open command. The library
will automatically close any open file ID when the Exit command is used to exit
the script. The library uses shorthand flags **-1** through **-9** when accessing
the file ID in a libui library command. Please note that the -0 file ID flag is
a reserved flag for library use only. It is also possible to close using the
file path.

* **-1..-9** - file id

```
Close [-1..-9] [<file_path>]
```

### Confirm (man libui.sh) - Check if in Confirm (-XC) mode.

Returns 0 if the "-XC" or "-Xc" (Confirm) option flag was provided on the
command line, otherwise it returns 1.

```
Confirm
```

### ConfirmVar (man libui.sh) - Confirms the value contained within a variable.

Performs some tests on a variable to ensure that the value contained within the
variable meets some limited criteria. Optionally, if the value does not meet the
criteria, a question can be asked and a response collected for the variable. The
tests currently available include:

* **-A** - check if the variable is an associative array
* **-d** - check if the value is a directory
* **-D** - default answer (provided to Ask when asking question, **-q** | -Q)
* **-e** - check if the value is a valid path
* **-E** - disable echo on the terminal when asking a question
* **-f** - check if the value is a valid file path
* **-n** - check if the value is not empty (This is the default.)
* **-P** - path to prepend before checking
* **-q** - question to ask if the variable is empty
* **-Q** - Always ask provided question
* **-S** - get selection of values from provided variable name
* **-s** - selection of values that can be used

Note: The ConfirmVar command uses the Ask command when asking the question
provided with the **-q** (Optional Question) or **-Q** (Always Question) option flags.

```
ConfirmVar [-A|-d|-e|-E|-f|-n|-z] [-D <default>] [-P <path>] [-q|-Q <question>] [-s <selection_value>] [-S <selection_variable>] <variable_name> ...
```

### Contains (man libui.sh) - Utility function to check an array for a value.

The Contains command returns 0 if a value is contained within the array with the
provided array variable name otherwise it returns 1.

```
Contains <array_variable> <value>
```

### ConvertDate (man libuiConvert.sh) - Converts a date string between formats.

This command provides an interface to the "date" command to convert data strings
from one format to another. The default input format is "%a %b %d %T %Z %Y"
(which is the default date command output format) and the default output format
is "%Y-%m-%d". If \<date\> is not provided, the date will be obtained from the
\<var\_name\> variable.

* **-i** - input format (man 1 date for details)
* **-o** - output format (man 1 date for details)

```
ConvertDate [-i <input_format>] [-o <output_format>] <var_name> [<date>]
```

### CreatePackage (man libuiPackage.sh) - Creates a self-extracting package.

The library supports the creation of self-extracting .tarp (tar package) and
.sharp (shar package) packages. This command creates the package file. The
environment specification is a variable name that contains an environment string
prepended when executing the provided installer command. It is expected that the
installer is a libui script.

* **-c** - tar compression option flag to use
* **-d** - description to use in package header
* **-f** - array variable name containing file list to include in package
* **-h** - function to call to generate the package header
* **-i** - installer command (included in self-extracting package header)
* **-I** - installer preparation commands (to set up environment, etc.)
* **-l** - generate package contents list instead of creating package
* **-n** - encoding to use (man 1 shar for details)
* **-N** - do not create a package, only create a tar archive
* **-P** - create a 'simple text archive' package (.starp)
* **-s** - source directory
* **-S** - create a shar package (.sharp)
* **-T** - create a tar package (.tarp)
* **-x** - array variable name containing file list to exclude from package
* **-X** - do not extract the archive before running the installer

```
CreatePackage [-l|-N|-P|-S|-T|-X] [-c <compression>] [-d <description>] [-f <filelist_array_variable_name>] [-h <header_command>] [-i <installer>] [-I <installer_prep>] [-n <encoding>] [-s <source_directory>] [-x <exclude_array_variable_name>] <package_filename>
```

### Drop (man libui.sh) - Utility function to drop a value from an array.

The Drop command removes the provided values from the array with the provided
array variable name. If the value contains a colon (:) at the end, both the
provided value and the following value will be removed. This is useful for
removing option values from an argument list like CMDARGS.

* **-r** - treat the provided value / value: is a regular expression pattern

```
Drop <array_variable> <value>|<value>: ...
```

### Error (man libui.sh) - Display a highlighted error message for the user.

Sends a highlighted text message to STDERR. By default this message is displayed
in yellow text on a red background. The message can also be logged to a log
file. A return value can provided with the **-r** (Return Value) option flag.
Normally the Error command will exit the script (using the Exit command). This
can be disabled with the **-E** (Disable Exit) option flag.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-f** - force script to exit after displaying the message (see Error command)
* **-F** - Disable exit after displaying the message (see Error command)
* **-i** - display the message "in place", i.e., where the cursor currently is
* **-l** - log message to file
* **-L** - include the location of the message request (see Error command)
* **-n** - do not include a trailing newline
* **-N** - do not include a trailing linefeed
* **-r** - use provided return value

```
Error [-1..-9|-a|-c|-f|-F|-i|-L|-n|-N] [-l <file_path>] [-r <return_value>] <message>
```

### ExitCallback (man libui-template) - Optional function in main script.

If an ExitCallback function is defined in the script, it will be called when the
script is exited using the Exit command.

```
ExitCallback () {
  Trace 'In user exit callback.'
}
```

### Exit (man libui.sh) - Exits the main script.

The Exit command cleans up script resources, calls any exit callbacks, and
terminates the script. It returns the provided return value when provided or the
return value from the last executed command.

```
Exit [<return_value>]
```

### Flush (man libuiFile.sh) - Flushes a file ID opened with the Open command.

Flushes a file ID that was previously opened using the Open command. This is
accomplished by closing and re-opening the associated file ID. The library uses
shorthand flags **-1** through **-9** when accessing the file ID in a libui library
command. Please note that the -0 file ID flag is a reserved flag for library use
only. It is also possible to flush using the file path.

* **-1..-9** - file id

```
Close [-1..-9] [<file_path>]
```

### Force (man libui.sh) - Check if in Force (-XF) mode.

Returns 0 if the "-XF" or "-Xf" (Force) option flag was provided on the command
line, otherwise it returns 1.

```
Force
```

### FormatElapsed (man libuiTimer.sh) - Formats ELAPSED to be human readable.

Converts the number of seconds in ELAPSED to a human readable format of
"HH:MM:SS.SSS". See the StartTimer and GetElapsed commands for more information.

* **-d** - also display "D days" for the elapsed time is greater than 24 hours

```
FormatElapsed [-d]
```

### GetCursor (man libuiTerm.sh) - Get the current cursor position.

Gets the current cursor position which is then available in the variables "ROW"
and "COL".

```
GetCursor
```

### GetElapsed (man libuiTimer.sh) - Get the elapsed time from a timer.

Captures the time elapsed in seconds since the timer identified by the variable
name was started using the StartTimer command.

```
GetElapsed [<variable_name>]
```

### GetFileList (man libuiFile.sh) - Get a list of file into an array.

Collects the file paths associated with the provided file specification and
loads them into an array variable with the provided variable name. The
collection of paths can optionally be recursive. Recursive searches only search
non-hidden subdirectories unless the -h (Hidden Recursive Search) option flag is
used. The file specification can be further refined with the option flags to
limit the array results to:

* **-c** - cd to provided directory before capturing list
* **-d** - directories only
* **-e** - generate an error if the list collected is empty
* **-f** - files only
* **-h** - perform a recursive directory search including hidden directories
* **-n** - return filenames only
* **-p** - directory paths only
* **-r** - perform a recursive directory search
* **-w** - generate a warning if the list collected is empty

```
GetFileList [-d|-e|-f|-h|-n|-p|-r|-w] [-c <path>] <variable_name> <file_specification> ...
```

### GetRealPath (man libuiFile.sh) - Get the real, absolute path for a file.

Gets the absolute path for provided path specification, bypassing any symbolic
links. With the **-P** (Path) option flag, GetRealPath will only test the directory
portion of the path, excluding the filename (to support the creation of new
files). With the -v (Validate Specification), the variable is updated with a
valid path, changing an initial "~" to ${HOME} and an initial "." to ${IWD} (the
initial (starting) working directory).

* **-P** - only check the directory path portion of the provided specification
* **-v** - only validate path, changing "~" to ${HOME} and "." to ${IWD}

```
GetRealPath [-P] <variable_name> [<path_specification>]
```

### GetTmp (man libuiFile.sh) - Get a temporary directory, subdirectory or file.

Creates a temporary directory, subdirectory, or file and returns the path in the
provided variable name. The temporary files will be created in the path defined
by TMPDIR, if set, or "/tmp". Only one temporary directory will be created and
it, along with any contents, will automatically be removed when the Exit command
is called. Multiple subdirectories and files may be created, but all of them
will exist within the one temporary directory.

* **-d** - create a temporary directory (limited to 1 directory)
* **-f** - create a temporary file (inside the main temporary directory)
* **-s** - create a temporary subdirectory (inside the main temporary directory)

```
GetTmp [-d|-f|-s] <variable_name>
```

### Info (man libui.sh) - Display a highlighted info message for the user.

Sends a highlighted text message to STDOUT. By default this message is displayed
in cyan text and does not include a trailing newline. The message can also be
logged to a log file.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-f** - force script to exit after displaying the message (see Error command)
* **-F** - Disable exit after displaying the message (see Error command)
* **-i** - display the message "in place", i.e., where the cursor currently is
* **-l** - log message to file
* **-L** - include the location of the message request (see Error command)
* **-N** - do not include a trailing linefeed
* **-r** - use provided return value

```
Info [-1..-9|-a|-c|-f|-F|-i|-L|-N] [-l <file_path>] [-r <return_value>] <message>
```

### InfoCallback (man libui-template) - Optional function in main script.

If an InfoCallback function is defined in the script, it will be called when the
script displays usage information using the UsageInfo command.

```
InfoCallback () {
  Trace 'In user info callback.'
}
```

### InitCallback (man libui-template) - Optional function in main script.

If an InitCallback function is defined in the script, it will be called when the
script is initialized using the Initialize command.

```
InitCallback () {
  Trace 'In user init callback.'
}
```

### Initialize (man libui.sh) - Initializes the libui library after configuration.

Sets up the libui library to support main script operation. The Initialize
command must be called after all configuration commands have been executed and
before the first Actions are taken. Any command line option flags and parameters
are captured and checked for errors during initialization. Any defined
initialization callbacks are also called.

```
Initialize
```

### IsRemote (man libuiSSH.sh) - Performs checks to confirm target is remote.

Performs some basic checks on the provided host name to ensure it is a valid
remote host and not the localhost.

```
IsRemote <target>
```

### ListPackage (man libuiPackage.sh) - List the contents of a package.

Generates a listing of files contained in a package.

```
ListPackage <package>
```

### LoadMod (man libui.sh) - Loads a libui mod.

The libui library supports mods that add new and/or change existing
functionality. This command loads a mod for use. It normally searches PATH but
another path can be provided using the **-P** (Path) option flag.

* **-P** - load mod from the provided directory (otherwise use PATH)

```
LoadMod [-P <path>] <libui_mod_name>
```

### LoadProfile (man libuiProfile.sh) - Manually load a profile.

The libui library supports runtime profiles. This command will manually load a
profile.

```
LoadProfile <file_path>
```

### MkDir (man libuiFile.sh) - Create a directory path with special permissions.

Creates any necessary directories in the provided path and sets the permissions
according to the provided flags:

* **-g** - set the group ownership of the directories to the provided group
* **-m** - use the provided mask as the umask when creating the directories
* **-s** - set the setgid bit for the created directories
* **-W** - Do not generate a warning on failure

```
MkDir [-s|-W] [-g <group>] [-m <mask>] <path>
```

### Multiuser (man libuiMultiuser.sh) - Check if multiuser mode is enabled.

Returns 0 if multiuser mode has been enabled (by loading the Multiuser mod),
otherwise it returns 1.

```
Multiuser
```

### NoAction (man libui.sh) - Check if in No Action (-XN) mode.

Returns 0 if the "-XN" or "-Xn" (No Action) option flag was provided on the
command line, otherwise it returns 1.

```
NoAction
```

### OctalToPerms (man libuiConvert.sh) - Converts octal perms to perms string.

This command converts the provided octal permissions int a permissions string
similar to what "ls" presents. If \<octal\_perms\> is not provided, the octal
value will be obtained from the \<var\_name\> variable.

```
OctalToPerms <var_name> [<octal_perms>]
```

### Open (man libuiFile.sh) - Open a file ID for use within the script.

The libui library supports file locking, enables file access shorthand, and can
automatically back up files through the Open command. The file ID to use should
be passed to the Open command and are restricted between 1 and 9. Please note
that the **-0** file ID flag is a reserved flag for library use only. Open file IDs
should be closed using the Close command.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-b** - backup the file as the provided filename before opening
* **-B** - backup the file into the provided directory (10 copies are maintained)
* **-m** - file creation mask - the umask to use when creating a new file with **-c**
* **-t** - file lock timeout in seconds (default is 30 seconds)
* **-w** - file lock wait warning message timeout (default is 5 seconds)

```
Open [-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
```

### Overwrite (man libui.sh) - Check if in Overwrite (-XO) mode.

Returns 0 if the "-XO" or "-Xo" (overwrite) option flag was provided on the
command line, otherwise it returns 1. The **-e** (Enable) and the **-E** (Disable) option
flags can be used to enable and disable the Yes mode within the script.

* **-e** - enable "Yes" mode, i.e., auto answer questions with default or "yes"
* **-E** - disable "Yes" mode

```
Overwrite [-e|-E]
```

### PathMatches (man libuiFile.sh) - Compares two provided filesystem paths.

Compares the absolute path for provided path specifications, bypassing any
symbolic links. With the **-P** (Path) option flag, PathMatches will only test the
directory portion of the paths.

* **-P** - match paths only, ignoring filenames

```
PathMatches [-P] <path_specification_1> <path_specification_2>
```

### PauseSpinner (man libuiSpinner.sh) - Pause a running progress spinner.

Pauses a running progress spinner. It can be restarted by using the
ResumeSpinner command. This is primarily used when asking for user input in the
middle of a task.

```
PauseSpinner
```

### Quiet (man libui.sh) - Check if in Quiet (-XQ) mode.

Returns 0 if the "-XQ" or "-Xq" (Quiet) option flag was provided on the command
line, otherwise it returns 1.

```
Quiet
```

### RecordClose (man libuiFileRecord.sh) - Close file IDs opened by RecordOpen.

Closes a file ID that was previously opened using the RecordOpen command. The
library will automatically close any open file ID when the Exit command is used
to exit the script. The library uses shorthand flags -1 through **-9** when
accessing the file ID in a libui library command. Please note that the **-0** file
ID flag is a reserved flag for library use only. It is also possible to close
using the file path. Note: Uses the same parameters as the Close command.

* **-1..-9** - file id

```
RecordClose [-1..-9] [<file_path>]
```

### RecordEntry (man libuiFileRecord.sh) - Create an entry in a Record File.

Creates a comma separated values (CSV) record in an open record file. If the
data associative array or the column array is not provided, RecordEntry will use
the array variables "RecordData" and "RecordColumns", respectively. The data
associative array should use the same names as are included in the column array.

* **-1..-9** - file id

```
RecordEntry [-1..-9] [<data_assoc_array>] [<column_array>]
```

### RecordOpen (man libuiFileRecord.sh) - Open a record-based file ID.

The libui library supports file locking, enables file access shorthand, and can
automatically back up files through the Open command. The file ID to use should
be passed to the Open command and are restricted between 1 and 9. Please note
that the **-0** file ID flag is a reserved flag for library use only. Open file IDs
should be closed using the Close command. Note: Uses the same parameters as the
Open command.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-b** - backup the file as the provided filename before opening
* **-B** - backup the file into the provided directory (10 copies are maintained)
* **-t** - file lock timeout
* **-w** - file lock wait warning message interval (displayed when less than -t)

```
RecordOpen [-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
```

### RemoveFileList (man libuiFile.sh) - Removes files in the provided array.

Removes the file paths contained in the array with the provided variable name.
RemoveFileList will attempt to quietly force the removal when the **-f** (Force)
option is provided.

* **-f** - force removal (i.e., use "rm -f")

```
RemoveFileList [-f] <name_of_array_variable> ...
```

### RequireRoot (man libuiRoot.sh) - Require the root user to execute the script.

By default, the libui library prevents the root user from executing the script.
When called prior to calling the Initialize command, this command requires the
root user to execute the script. When called after Initialize, Returns 0 if the
root user is required, otherwise it returns 1.

```
RequireRoot
```

### RestoreCursor (man libuiTerm.sh) - Restores cursor to last saved position.

Tells the terminal to restore the cursor to the last saved position. The cursor
position needs to have been previously saved using the SaveCursor command.

```
RestoreCursor
```

### ResumeSpinner (man libuiSpinner.sh) - Resumes a progress spinner.

Resumes a running progress spinner that was paused by the PauseSpinner command.

```
ResumeSpinner
```

### SaveCursor (man libuiTerm.sh) - Saves the current cursor position.

Tells the terminal to save the current cursor position. The cursor can then be
restored to the last saved postion using the RestoreCursor command.

```
SaveCursor
```

### Sleep (man libuiSpinner.sh) - Sleeps a script with an optional countdown.

Pauses execution and optionally provides a countdown. The countdown is updated
at the interval provided by the **-u** (Update) option flag. The countdown message
displayed is provided by the **-m** (Message) option flag should include a "%s" for
the remaining seconds and defaults to:

```
Waiting %s...
```

* **-i** - the message to display in sleep (include "%s" for seconds remaining)
* **-u** - the number of seconds to sleep between updates to the message

```
Sleep [-m "<message>"] [-u <interval>] [<sleep>]
```

### SetCursor (man libuiTerm.sh) - Move the cursor to the provided position.

Sets (i.e., moves) the cursor to the provided position.

```
SetCursor <row> <col>
```

### Sort (man libuiSort.sh) - Sorts an array.

Sorts the array variable with the provided name. Depending upon the provided
option flag, the sort can be ascending or descending, ASCII, lexical, numeric,
path, or custom.

* **-a** - ASCII ascending
* **-A** - ASCII decending
* **-c** - order comparison function
* **-l** - lexical ascending
* **-L** - lexical decending
* **-n** - numeric ascending
* **-N** - numeric decending
* **-p** - filesystem path depth-first sort

```
Sort [-a|-A|-l|-L|-n|-N|-p] [-c <compare_function>] <array_variable_name> ...
```

### SSHExec (man libuiSSH.sh) - Execute a command on a remote server via ssh.

Sends a command to a remote server (using -t) or a list of remote servers (using
-T) and collects the response into SSH_OUT (STDOUT), SSH_ERR (STDERR), and
SSH_RV (return value) variables.

* **-d** - enable display output (i.e., open a tty)
* **-i** - info message to display while executing
* **-p** - target system password
* **-P** - target system TCP/IP port
* **-q** - quiet execution (only capture results, no output display)
* **-t** - target host
* **-T** - array variable name containing list of target hosts
* **-u** - target system username
* **-v** - verbose execution (capture results and display output in real time)

```
SSHExec [-q|-v] [-p <password>] [-P <port>] [-t <target>] [-T <target_array_variable>] [-u <user>] <command> ...
```

### SSHSend (man libuiSSH.sh) - Sends files to a remote server via scp.

Sends files to a remote server (using -t) or a list of remote servers (using
-T), placing the file into the provided destination, and collects the response
into SSH_OUT (STDOUT), SSH_ERR (STDERR), and SSH_RV (return value) variables.

* **-d** - target system target directory
* **-p** - target system password
* **-P** - target system TCP/IP port
* **-q** - quiet execution (only capture results, no output display)
* **-t** - target host
* **-T** - array variable name containing list of target hosts
* **-u** - target system username
* **-v** - verbose execution (capture results and display output in real time)

```
SSHSend [-q|-v] **-d** <destination> [-p <password>] [-P <port>] [-t <target>] [-T <target_variable>] [-u <user>] <file> ...
```

### StartSpinner (man libuiSpinner.sh) - Start a progress spinner.

Starts a progress spinner that is displayed a space after the current cursor
position. The spinner should be stopped with the StopSpinner command. An
informational message can be optionally displayed. Note: the spinner should also
stop when the program ends with the Exit command. (Under certain error
conditions, it is possible for the Spinner to persist beyond the script and
would need to be killed manually.)

```
StartSpinner [<info_message>]
```

### StartTimer (man libuiTimer.sh) - Start a timer.

Starts a timer. There is a default timer or, a variable name can be provided to
support multiple timers.

```
StartTimer [<variable_name>]
```

### StopSpinner (man libuiSpinner.sh) - Stop a progress spinner.

Stops a progress spinner that was started by the StartSpinner command. Note: the
spinner should also stop when the program ends with the Exit command. (Under
certain error conditions, it is possible for the Spinner to persist beyond the
script and would need to be killed manually.)

```
StopSpinner
```

### Syslog (man libuiSyslog.sh) - Send a message to the system log.

Sends a message with the provided priority to the system log. The default
priority is "user.notice".

* **-p** - unix syslog priority label (man 3 syslog)

```
Syslog [-p <priority>] [<message>]
```

### Tell (man libui.sh) - Display a highlighted message for the user.

Sends a highlighted text message to STDOUT. By default this message is displayed
in bold white text. The message can also be logged to a log file. Normally Tell
adds a newline after printing the message. This can be disabled with the **-n** (No
Newline) option.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-A** - display the message as an "alert" message (see also Alert)
* **-C** - display the message as a "caution" message (see also Caution)
* **-E** - display the message as an "Error" message (see also Error)
* **-f** - force script to exit after displaying the message (see Error command)
* **-F** - Disable exit after displaying the message (see Error command)
* **-i** - display the message "in place", i.e., where the cursor currently is
* **-I** - display the message as an "info" message (see also Info)
* **-l** - log message to file
* **-L** - include the location of the message request (see Error command)
* **-n** - do not include a trailing newline
* **-N** - do not include a trailing linefeed
* **-o** - output file descriptor
* **-r** - use provided return value
* **-W** - display the message as a "Warning" message (see also Warn)

```
Tell [-1..-9|-a|-A|-c|-C|-E|-f|-F|-i|-I|-L|-n|-N|-W] [-l <file_path>] [-r <return_value>] <message>
```

### \_Trace (man libui.sh) - Internal libui trace command.

The \_Trace command is an internal libui trace command. It is included here
because this form should be used in libui mods with the following form:

```
${_M} && _Trace 'Trace message. (%s)' "${var}"
```

### Trace (man libui.sh) - Runtime trace command.

Trace provides debug messages when debugging is enabled with the **-X** (Xdebug)
command line option. For this to be effective, it is recommended that the Trace
command be used in place of comments within the code. That way when debugging is
enabled, it will be easy to trace the operation of the script to determine where
the error exists. Trace should be used with the following form:

```
Trace 'Trace message. (%s)' "${var}"
```

### UsageInfo (man libuiInfo.sh) - Display usage information (i.e. help) to the user.

Displays usage information, i.e. help information, to the user. This function is
automatically provided by the libui library with the **-H** or **-h** (Help) command
line option flags. The usage information is built from the AddOption and
AddParameter commands. The UsageInfo command will also call a provided
InfoCallback function if one is available.

```
UsageInfo
```

### ValidateWorkspace (man libuiWorkspace.sh) - Validate and load workspace info.

A workspace is considered to be the directory that contains one or more (git)
repositories. This functions loads configuration information and sets
environment variables that are used by other libui supported commands.

* **-w** - remain in the workspace directory after validation

```
ValidateWorkspace [-w]
```

### Verbose (man libui.sh) - Check if in Verbose (-XV) mode.

Returns 0 if the "-XV" or "-Xv" (Verbose) option flag was provided on the
command line, otherwise it returns 1.

```
Verbose
```

### Verify (man libui.sh) - Ask a yes/no question and return 0 for yes, 1 for no.

Uses Ask to ask the user a question and waits for a yes / no response. Returns 0
on a "yes" response and 1 on a "no" response. If a "q" is provided, the main
script will exit. The default answer is "yes". Note that other Ask command
options are also available.

* **-C** - only ask when the **-C** (Confirm) command line option flag was used
* **-d** - set default answer to argument
* **-n** - variable name to save the answer
* **-N** - set default answer to "no"
* **-r** - regular expression that the answer must match
* **-Y** - set default answer to "yes"

```
Verify [-C|-N|-Y] [-d <default>] [-n <variable_name>] [-r <required_regex>] <question_text>
```

### Version (man libui.sh) - Version information.

When a version number is provided, registers the version for the script. If the
**-r** (Required) option flag is provided, confirms that the libui.sh library
version being used is at least that version. If the **-m** (Mod) option flag is
provided, the script file is defined as a mod. If the **-a** (All) option flag
is provided, version information for all script files is displayed. When used
with no parameters, displays the version of the requesting script file. The
version information is included with the usage information provided by the libui
library with the **-H** or -h (Help) command line option flags.

* **-a** - display all registered script file versions
* **-m** - the script file is a libui mod
* **-r** - libui.sh library version must be at least provided version

```
Version [-a|-m] [-r <required_libui_version>] <script_version>
```

### WaitSpinner (man libuiSpinner.sh) - Start a spinner and wait for task.

Starts a spinner and waits for the last executed background task to complete.

```
WaitSpinner
```

### Warn (man libui.sh) - Display a highlighted warning message for the user.

Sends a highlighted text message to STDERR. By default this message is displayed
in black text on a yellow background. The message can also be logged to a log
file. A return value can provided with the **-r** (Return Value) option flag.

* **-1..-9** - file id
* **-a** | **-c** - append to / create log
* **-f** - force script to exit after displaying the message (see Error command)
* **-F** - Disable exit after displaying the message (see Error command)
* **-i** - display the message "in place", i.e., where the cursor currently is
* **-l** - log message to file
* **-L** - include the location of the message request (see Error command)
* **-n** - do not include a trailing newline
* **-N** - do not include a trailing linefeed
* **-r** - use provided return value

```
Warn [-1..-9|-a|-c|-f|-F|-i|-L|-n|-N] [-l <file_path>] [-r <return_value>] <message>
```

### Write (man libuiFile.sh) - Write text to a file.

Writes the provided data to a file identified by the provided file ID
(previously opened with the Open command) or the **-f** (File) option flag. The
Write command defaults to a printf format of "%s" and newline as a record
marker. These can be changed with the **-p** (Printf) and **-r** (Record Marker) option
flags.

* **-1..-9** - file id
* **-a** | **-c** - append to / create file
* **-f** - file to write data
* **-p** - printf format string for writing data
* **-r** - record marker to write after data, defaults to newline

```
Write [-0|-1..-9|-a|-c] [-f <file_path>] [-p <format>] [-r <record_marker>] <data>
```

### Yes (man libui.sh) - Check if in Yes (-XY) mode.

Returns 0 if the "-XY" or "-Xy" (Yes) option flag was provided on the command
line, otherwise it returns 1. The **-e** (Enable) and the **-E** (Disable) option
flags can be used to enable and disable the Yes mode within the script.

* **-e** - enable "Yes" mode, i.e., auto answer questions with default or "yes"
* **-E** - disable "Yes" mode

```
Yes [-e|-E]
```

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
