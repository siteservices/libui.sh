#!/usr/bin/env libui
#####
#
#	Libui Convert Mod - Conversion Utilities
#
#	F Harvell - Sat Nov 11 08:01:38 EST 2023
#
#####
#
# Provides conversion utility commands.
#
# Man page available for this mod: man 3 libuiConvert.sh
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

Version -r 2.005 -m 2.2

# defaults

# Convert one date format to another
#
# Syntax: ConvertDate [-i <input_format>] [-o <output_format>] <var_name> <date>
#
# Example: ConvertDate -i '%a %b %d %T %Z %Y' -o '%Y-%m-%d' today 'Tue Dec 28 18:26:37 EST 2021'
#
# Result: The variable "today" is assignd '2021-12-28'
#
UICMD+=( 'ConvertDate' )
ConvertDate () { # [-i <input_format>] [-o <output_format>] <var_name> [<date>]
  ${_S} && ((_cConvertDate++))
  ${_M} && _Trace 'ConvertDate [%s]' "${*}"

  local _Convert_ifmt='%a %b %d %T %Z %Y'
  local _Convert_ofmt='%Y-%m-%d'

  local opt
  local OPTIND
  local OPTARG
  while getopts ':i:o:' opt
  do
    case ${opt} in
      i)
        ${_M} && _Trace 'Input format. (%s)' "${OPTARG}"
        _Convert_ifmt="${OPTARG}"
        ;;

      o)
        ${_M} && _Trace 'Output format. (%s)' "${OPTARG}"
        _Convert_ofmt="${OPTARG}"
        ;;

      *)
        Tell -E -f -L '(ConvertDate) Unknnown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  ${_M} && _Trace 'Capture var and spec. (%s)' "${*}"
  local _Convert_var="${1}"
  local _Convert_date
  shift
  if ((${#}))
  then
    ${_M} && _Trace 'Get spec from args. (%s)' "${*}"
    _Convert_date=( "${@}" )
  else
    ${_M} && _Trace 'Get spec from var. (%s)' "${_Convert_var}"
    ${ZSH} && _Convert_date=( ${(P)_Convert_var[@]} ) || eval "_Convert_date=( \"\${${_Convert_var}[@]}\" )"
  fi
  ((${#_Convert_date[@]})) || Tell -E '(ConvertDate) Called without a soure date.'

  ${_M} && _Trace 'Converting date. (%s -> %s)' "${_Convert_ifmt}" "${_Convert_ofmt}"
  case "${UNIX}" in
    BSD) # BSD / macOS
      eval "${_Convert_var}=\"\$(date -j -f '${_Convert_ifmt}' \"${_Convert_date[@]}\" '+${_Convert_ofmt}')\""
      ;;

    *) # Linux / GNU
      [[ '%s' == "${_Convert_ifmt}" ]] && eval "${_Convert_var}=\"\$(date -d \"@${_Convert_date[@]}\" '+${_Convert_ofmt}')\"" || \
          eval "${_Convert_var}=\"\$(date -d \"${_Convert_date[@]}\" '+${_Convert_ofmt}')\""
      ;;

  esac

  ${M} && Trace 'ConvertDate return. (%s)' 0
  return 0
}

# Convert octal permissions to permissions string
#
# Syntax: OctalToPerms <variable> [<octal_perms>]
#
# Example: OctalToPerms perms 750
#
# Result: the variable "perms" is assignd 'rwxr-x---'
#
UICMD+=( 'OctalToPerms' )
OctalToPerms () { # <variable> [<octal_perms>]
  ${_S} && ((_cOctalToPerms++))
  ${_M} && _Trace 'OctalToPerms [%s]' "${*}"

  ${_M} && _Trace 'Capture var and perms. (%s)' "${*}"
  local _Convert_var="${1}"
  local _Convert_octal
  shift
  if ((${#}))
  then
    ${_M} && _Trace 'Get perms from argument. (%s)' "${1}"
    _Convert_octal="${1}"
  else
    ${_M} && _Trace 'Get perms from var. (%s)' "${_Convert_var}"
    ${ZSH} && _Convert_octal="${(P)_Convert_var}" || eval "_Convert_octal=\"\${${_Convert_var}}\""
  fi
  [[ -z "${_Convert_octal}" ]] && Tell -E '(OctalToPerms) Called without a value.'

  ${_M} && _Trace 'Convert perms. (%s)' "${_Convert_octal}"
  local _Convert_perms
  local _Convert_i
  local _Convert_p
  local _Convert_s=0
  local _Convert_x
  [[ 3 < ${#_Convert_octal} ]] && _Convert_s="${_Convert_octal:0:1}" && _Convert_octal="${_Convert_octal:1:3}"
  for _Convert_i in 0 1 2
  do
    _Convert_p=${_Convert_octal:${_Convert_i}:1}
    _Convert_x='x'
    ((4 <= _Convert_p)) && _Convert_p=$((_Convert_p - 4)) && _Convert_perms+='r' || _Convert_perms+='-'
    ((2 <= _Convert_p)) && _Convert_p=$((_Convert_p - 2)) && _Convert_perms+='w' || _Convert_perms+='-'
    ((0 == _Convert_i && 4 <= _Convert_s)) && _Convert_s=$((_Convert_s - 4)) && _Convert_x='s'
    ((1 == _Convert_i && 2 <= _Convert_s)) && _Convert_s=$((_Convert_s - 2)) && _Convert_x='s'
    ((2 == _Convert_i && 1 <= _Convert_s)) && _Convert_x='t'
    ((1 <= _Convert_p)) && _Convert_perms+="${_Convert_x}" || _Convert_perms+='-'
  done

  ${_M} && _Trace 'Perms string. (%s)' "${_Convert_perms}"
  eval "${_Convert_var}=\"\${_Convert_perms}\""

  ${M} && Trace 'OctalToPerms return. (%s)' 0
  return 0
}

# Convert permissions string to octal permissions
#
# Syntax: PermsToOctal <variable> [<perms_string>]
#
# Example: PermsToOctal perms 'rwxr-x---'
#
# Result: the variable "perms" is assignd '750'
#
UICMD+=( 'PermsToOctal' )
PermsToOctal () { # <variable> [<perms_string>]
  ${_S} && ((_cPermsToOctal++))
  ${_M} && _Trace 'PermsToOctal [%s]' "${*}"

  ${_M} && _Trace 'Capture var and perms. (%s)' "${*}"
  local _Convert_var="${1}"
  local _Convert_perms
  shift
  if ((${#}))
  then
    ${_M} && _Trace 'Get perms from argument. (%s)' "${1}"
    _Convert_perms="${1}"
  else
    ${_M} && _Trace 'Get perms from var. (%s)' "${_Convert_var}"
    ${ZSH} && _Convert_perms="${(P)_Convert_var}" || eval "_Convert_perms=\"\${${_Convert_var}}\""
  fi
  [[ -z "${_Convert_perms}" ]] && Tell -E '(PermsToOctal) Called without a value.'

  ${_M} && _Trace 'Convert perms. (%s)' "${_Convert_perms}"
  local _Convert_octal;
  local _Convert_i
  local _Convert_s=0;
  local _Convert_x=0;
  for _Convert_i in {0..8}
  do
    case "${_Convert_perms:${_Convert_i}:1}" in
      r)
        ((_Convert_x+=4))
        ;;

      w)
        ((_Convert_x+=2))
        ;;

      x)
        ((_Convert_x+=1))
        ;;

      s|S)
        ((_Convert_s+=(8 - _Convert_i) / 3 * 2))
        ((_Convert_x+=1))
        ;;

      t|T)
        ((_Convert_s+=1))
        ((_Convert_x+=1))
        ;;

      *)
        ;;

    esac
    ((0 == ++_Convert_i % 3)) && _Convert_octal+="${_Convert_x}" && _Convert_x=0
  done
  ((_Convert_s)) || _Convert_s=

  ${_M} && _Trace 'Octal perms. (%s)' "${_Convert_octal}"
  eval "${_Convert_var}=\"\${_Convert_s}\${_Convert_octal}\""

  ${M} && Trace 'PermsToOctal return. (%s)' 0
  return 0
}

return 0
