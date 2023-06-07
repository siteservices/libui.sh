# Change Log

## v1.829

### New Features

* Added Caution - send a "caution" message to the user (wrapper around Warn -C).
* Added Drop - drop value from an array.
* Added Info - send an "info" message to the user (wrapper around Tell -i).
* Added Tell -i (Info) to send an info message to the user.
* Added Warn -C (Caution) to send a caution message to the user.
* Changed ValidateWorkspace warning message to a caution message.
* Fix tests and add new tests to support new features.
* Documentation updates.

### Incompatibilities

* Removed the short lived ValidateWorkspace -W (No Warning) option flag.
* Changed Tell -i (In Place) flag to -I (in Place) to support new Info flag.
* Removed the ${DNoAction} format. (Replaced with ${DCaution}.)

### Bug Fixes

* Minor changes to stats tracking file format.
* Minor update to profile handling.
* Update mless to support escapes outside of code blocks.

## v1.828

### New Features

* Add -E (No Echo) option to Ask and ConfirmVar.
* Add -d (Display) and -i \<message\> (Info) options to SSHExec.
* Add -W (Disable Warning) option to ValidateWorkspace.
* Allow GetFileList to work with file spec contained within variable value.
* Documentation updates.

### Bug Fixes

* Fix parameter capture. (Add quotes to prevent multi-word split in bash.)
* Fix -P \<path\> (Path) handling in AddOption, ConfirmVar, and Ask.
* Change duplicate STDERR file descriptor from 3 to 5. (Capture uses 3 and 4.)
* Change Spinner output from STDERR to duplicate STDERR file descriptor (5).
* Redirect Action -i \<message\> (Info) message to duplicate STDERR fd (5).
* Simplify and fix Action -t (Tee) in bash.
* Change \_fip to \_File\_ip in FileRecord mod.
* Fix LoadMod to prevent reloading mod.
* Fix Error location in zsh (using funcfiletrace[2]).
* Update mless to support \\\<, \\\>, and \\\_.
* Fix LibuiUpdateMan (change man= to \_Util\_mp).
* Update libui and libui-tests.sh to improve testing.
* Fix some tests in libui-test.sh.
* Also simplified ((0 == ${?})) constructs to just ((${?}))
