#!/usr/bin/env libui
#####
#
#	Libui Term Mod - Terminal Support
#
#	F Harvell - Sat Dec 30 01:37:13 EST 2023
#
#####
#
# Provides terminal utility commands.
#
# Man page available for this mod: man 3 libuiTerm.sh
#
#####
#
# Copyright 2018-2024 siteservices.net, Inc. and made available in the public
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

Version -r 2.004 -m 1.1

# At Position Execute Command
#
# Syntax: At <row> <col> <command>
#
# Example: At 10 20 Tell -i 'Hello.'
#
# Result: Moves to row 10, column 20, and displays "Hello.".
#
UICMD+=( 'At' )
At () {
  ${_S} && ((_c_At++))
  ${_T} && _Trace 'At [%s]' "${*}"

  printf "${DSC}"
  tput cup ${1} ${2}
  shift 2
  "${@}"
  local _TERM_rv=${?}
  printf "${DRC}"

  ${_T} && _Trace 'At return. (%s)' "${_TERM_rv}"
  return ${_TERM_rv}
}

# Get Cursor Position
#
# Syntax: GetCursor
#
# Example: GetCursor
#
# Result: Updates ROW and COL ot the current cursor row and column.
#
UICMD+=( 'GetCursor' )
GetCursor () {
  ${_S} && ((_c_GetCursor++))
  ${_T} && _Trace 'GetCursor [%s]' "${*}"

  if [[ -n "${DCP}" ]]
  then
    local _x
    if ${ZSH}
    then
      printf "${DCP}" && IFS='[;' read -sd R _x ROW COL
    else
      IFS='[;' read -p ${DCP} -rsd R _x ROW COL
    fi
    local _TERM_rv=${?}
    ((ROW--))
    ((COL--))
  else
    ROW=
    COL=
  fi

  ${_T} && _Trace 'GetCursor return. (%s)' "${_TERM_rv}"
  return ${_TERM_rv}
}

# Set Cursor Position
#
# Syntax: SetCursor <row> <col>
#
# Example: SetCursor 10 20
#
# Result: Moves the cursor to row 10 column 20.
#
UICMD+=( 'SetCursor' )
SetCursor () {
  ${_S} && ((_c_SetCursor++))
  ${_T} && _Trace 'SetCursor [%s]' "${*}"

  tput cup ${1} ${2}
  local _TERM_rv=${?}

  ${_T} && _Trace 'SetCursor return. (%s)' "${_TERM_rv}"
  return ${_TERM_rv}
}

# Save Cursor Position
#
# Syntax: SaveCursor
#
# Example: SaveCursor
#
# Result: Tells the terminal to save the current cursor position.
#
UICMD+=( 'SaveCursor' )
SaveCursor () {
  ${_S} && ((_c_SaveCursor++))
  ${_T} && _Trace 'SaveCursor [%s]' "${*}"

  printf "${DSC}"

  ${_T} && _Trace 'SaveCursor return. (%s)' 0
  return 0
}

# Restore Cursor Position
#
# Syntax: RestoreCursor
#
# Example: RestoreCursor
#
# Result: Tells the terminal to restore the last saved cursor position.
#
UICMD+=( 'RestoreCursor' )
RestoreCursor () {
  ${_S} && ((_c_RestoreCursor++))
  ${_T} && _Trace 'RestoreCursor [%s]' "${*}"

  printf "${DRC}"

  ${_T} && _Trace 'RestoreCursor return. (%s)' 0
  return 0
}

return 0
