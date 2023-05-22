#!/bin/zsh
#####
#
#	Libui Multiuser Mod - Multiuser Support
#
#	F Harvell - Tue Feb 28 19:34:25 EST 2023
#
#####
#
# Provides multiuser utility commands.
#
# Man page available for this module: man 3 libuiMultiuser.sh
#
#####
#
# Copyright 2018-2023 siteservices.net, Inc. and made available in the public
# domain. Permission is unconditionally granted to anyone with an interest, the
# rights to use, modify, publish, distribute, sublicense, and/or sell this
# content and associated files.
#
# All content is provided "as is", without warranty of any kind, expressed or
# implied, including but not limited to merchantability, fitness for a
# particular purpose, and noninfringement. In no event shall the authors or
# copyright holders be liable for any claim, damages, or other liability,
# whether in an action of contract, tort, or otherwise, arising from, out of,
# or in connection with this content or use of the associated files.
#
#####

Version -r 1.822 -m 1.1

# defaults
_multiuser=true

# file mod required
LoadMod File

# Get Multiuser Mode
#
# Syntax: Multiuser
#
# Example: Multiuser
#
# Result: Returns true if multiuser mode is enabled, otherwise returns false.
#
UICMD+=( 'Multiuser' )
Multiuser () {
  ${_S} && ((_cMultiuser++))
  ${_M} && _Trace 'Multiuser [%s]' "${*}"

  ${_M} && _Trace 'Return multiuser state. (%s)' "${_multiuser}"
  return $(${_multiuser}) # return multiuser state
}

return 0
