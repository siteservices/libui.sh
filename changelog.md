# Change Log

## v1.832

### New Features / Enhancements

* Add LIBUI_SSHTIMEOUT environment variable support to libui SSH mod.
* Add word wrapping to mless and improve ordered list processing.
* Change Action retry wait default from 0 to 1 second.
* Documentation updates.

### Bug Fixes

* Add mless no file found error message.

### Known Issues

* Word wrapping in mless does not ignore terminal effects.

## v1.831

### New Features / Enhancements

* Add -v (Validate Specification) to GetRealPath to support creating new paths.
* Add -m \<mask\> (Mask) to Open to change the default umask when creating a file.
* Add -N (No Package) tarball only support to libui Package mod.
* Improve information message handling in StartSpinner and Sleep.
* Adjustments to the display themes (Question, Answer, yellow, red).
* Move libui application tools from LibuiUtility mod to LibuiLibui mod.
* Move utility functions from libui.sh to libui Utility mod.
* Add MLESSPATH support to mless.
* Tweak UsageInfo help message in libui Info mod.
* Documentation updates.

### Incompatibilities

* Change Sleep -m (Message) to -i (Info Message).

### Bug Fixes

* Fix file path handling in AddOption, AddParameter, and ConfirmVar.
* Fix caution message handling in Open.
* Fix package listing in libui Package mod.
* Combine mkdir and chmod in libui Libui mod.
* Improved backtick (\`) and horizontal rule handling in mless.
* Fix command typo in libui SSH mod.

## v1.830

### New Features / Enhancements

* Split tests into individual test files in var/libui/test.
* Updated libui Utility mod and created Libui Test mod.
* Documentation updates.

### Bug Fixes

* Fix load mod handling in bash.
* Fix some tests.

## v1.829

### New Features / Enhancements

* Add Drop - drop a value from an array.
* Add Caution - send a "caution" message to the user (wrapper around Tell -C).
* Add Info - send an "info" message to the user (wrapper around Tell -I).
* Add to Tell: -A (Alert) -C (Caution) -E (Error) -I (Info) -W (Warn).
* Fix tests and add new tests to support new features.
* Documentation updates.

### Incompatibilities

* Change Action -e (Exit on Failure) to -f (Force Exit on Failure).
* Change Action -f (Failure Message) to -e (Error Message).
* Change Error -e (Force Exit) to -f (Force Exit).
* Change Error -E (Do not Exit) to -F (Cancel Exit).
* Remove the ${DNoAction} format. (No Action now displayed with ${DCaution}.)

### Bug Fixes

* Consolidate Alert, Caution, Error, Info, Warn into Tell (performance).
* Change ValidateWorkspace warning message to a caution message.
* Minor changes to stats tracking file format.
* Minor update to profile handling.
* Update mless to support escapes only outside of code blocks.

## v1.828

### New Features / Enhancements

* Add -E (No Echo) option to Ask and ConfirmVar.
* Add -d (Display) and -i \<message\> (Info) options to SSHExec.
* Allow GetFileList to work with a file spec contained within the variable value.
* Documentation updates.

### Bug Fixes

* Fix parameter capture. (Add quotes to prevent a multi-word split in bash.)
* Fix -P \<path\> (Path) handling in AddOption, ConfirmVar, and Ask.
* Change duplicate STDERR file descriptor from 3 to 5. (Capture uses 3 and 4.)
* Change Spinner output from STDERR to duplicate STDERR file descriptor (5).
* Redirect Action -i \<message\> (Info) message to duplicate STDERR fd (5).
* Simplify and fix Action -t (Tee) in bash.
* Change \_fip to \_File\_ip in libui FileRecord mod.
* Fix LoadMod to prevent reloading mod.
* Fix Error location in zsh (using funcfiletrace[2]).
* Update mless to support \\\<, \\\>, and \\\_.
* Fix LibuiUpdateMan (change man= to \_Util\_mp).
* Update libui and libui-tests.sh to improve testing.
* Fix some tests in libui-test.sh.
* Also simplified ((0 == ${?})) constructs to just ((${?}))
