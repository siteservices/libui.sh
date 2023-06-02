# Change Log

## v1.828

### New Features

* Add -E (No Echo) option to Ask and ConfirmVar.
* Add -d (Display) and -i \<message\> (Info) options to SSHExec.
* Add -W (Disable Warning) option to ValidateWorkspace.

### Bug Fixes

* Fix -P \<path\> (Path) handling in AddOption, ConfirmVar, and Ask.
* Change duplicate stderr file descriptor from 3 to 4. (Capture uses 3.)
* Change Spinner output from stderr to duplicate stderr file descriptor (4).
* Redirect Action -i \<message\> (Info) message to duplicate stderr fd (4).
* Change \_fip to \_File\_ip in FileRecord mod.
* Fix LoadMod to prevent reloading mod.
* Update mless to support \\\<, \\\>, and \\\_.
* Update libui and libui-tests.sh to improve testing.
