#!/bin/zsh
#####
#
#	Libui Root Mod - Root User Support
#
#	F Harvell - Tue Feb 28 21:14:02 EST 2023
#
#####
#
# Provides root user account access utility commands.
#
# Man page available for this mod: man 3 libuiRoot.sh
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

Version -r 2.000 -m 1.1

# defaults
_allowroot=false
_requireroot=false

# Allow Root
#
# Syntax: AllowRoot
#
# Example: AllowRoot
#
# Result: Prior to calling Initialize, root execution will be allowed. After
# Initialize, will return true if root execution is allowed, otherwise false.
#
UICMD+=( 'AllowRoot' )
AllowRoot () {
  ${_S} && ((_cAllowRoot++))
  ${_M} && _Trace 'AllowRoot [%s]' "${*}"

  ${_init} || return $(${_allowroot}) # return allowroot state

  ${_M} && _Trace 'Allow execution by root.'
  _allowroot=true

  ${_M} && _Trace 'AllowRoot return. (%s)' 0
  return 0
}

# Require Root
#
# Syntax: RequireRoot
#
# Example: RequireRoot
#
# Result: Prior to calling Initialize, root execution will be required. After
# Initialize, will return true if root execution is required, otherwise false.
#
UICMD+=( 'RequireRoot' )
RequireRoot () {
  ${_S} && ((_cRequireRoot++))
  ${_M} && _Trace 'RequireRoot [%s]' "${*}"

  ${_init} || return $(${_requireroot}) # return requireroot state

  ${_M} && _Trace 'Require execution by root.'
  _requireroot=true

  ${_M} && _Trace 'RequireRoot return. (%s)' 0
  return 0
}

return 0
