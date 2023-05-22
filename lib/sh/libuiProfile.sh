#!/bin/zsh
#####
#
#	Libui Profile Mod - Use / Configuration Profile Support
#
#	F Harvell - Tue Feb 28 19:44:35 EST 2023
#
#####
#
# Provides use / configuration profile utility commands.
#
# Man page available for this module: man 3 libuiProfile.sh
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
_profile=true # for libui.sh

# Load Profile
#
# Syntax: LoadProfile <file_path>
#
# Example: LoadProfile "test.profile"
#
# Result: Sources the file named "test.profile" from the current directory.
#
UICMD+=( 'LoadProfile' )
LoadProfile () { # <file_path>
  ${_S} && ((_cLoadProfile++))
  ${_M} && _Trace 'LoadProfile [%s]' "${*}"

  ${_M} && _Trace 'Call _LoadProfile. (%s)' "${*}"
  _LoadProfile -P "${@}"
  local _rv=${?}

  ${_M} && _Trace 'LoadProfile return. (%s)' "${_rv}"
  return ${_rv}
}

# Load Profile Support
#
# Syntax: _LoadProfile -P <file_path>
#
# Example: _LoadProfile -P "test.profile"
#
# Result: Sources the file named "test.profile" from the current directory.
#
# Note: Any options / parameters provided beyond -P <file_path> are ignored.
# The function has been designed to work with the Initialize function to parse
# the -P <file_path> option from the command line.
#
UICMD+=( '_LoadProfile' )
_LoadProfile () { # -P <file_path>
  ${_S} && ((_c_LoadProfile++))
  ${_M} && _Trace '_LoadProfile [%s]' "${*}"

  local _Profile_f

  ${_M} && _Trace 'Process _LoadProfile options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':P:' _o
  do
    case ${_o} in
      P)
        ${_M} && _Trace 'Profile path. (%s)' "${OPTARG}"
        ${ZSH} && _Profile_f=${~OPTARG} || _Profile_f=${OPTARG}
        ;;

      *)
        ;;

    esac
  done
  shift $((OPTIND - 1))

  ${_M} && _Trace 'Load the profile. (%s)' "${_Profile_f}"
  [[ -f "${_Profile_f}" ]] && source "${_Profile_f}"
  local _rv=${?}

  ${_M} && _Trace '_LoadProfile return. (%s)' "${_rv}"
  return ${_rv}
}

return 0
