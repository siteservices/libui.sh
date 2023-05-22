#!/bin/zsh
#####
#
#	Libui Date Mod - Date Format Conversion
#
#	F Harvell - Mon Apr 20 12:44:50 EDT 2020
#
#####
#
# Provides date utility commands.
#
# Man page available for this module: man 3 libuiDate.sh
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

Version -r 1.822 -m 1.5

# defaults

# Convert one date format to another
#
# Syntax: ConvertDate [-i <input_format>] [-o <output_format>] <var_name> <date>
#
# Example: ConvertDate -i '%a %b %d %T %Z %Y' -o '%Y-%m-%d' today 'Tue Dec 28 18:26:37 EST 2021'
#
# Result: the variable "today" is assignd '2021-12-28'
#
UICMD+=( 'ConvertDate' )
ConvertDate () {
  ${_S} && ((_cConvertDate++))
  ${_M} && _Trace 'ConvertDate [%s]' "${*}"

  local _Date_ifmt='%a %b %d %T %Z %Y'
  local _Date_ofmt='%Y-%m-%d'

  local opt
  local OPTIND
  local OPTARG
  while getopts ':i:o:' opt
  do
    case ${opt} in
      i)
        ${_M} && _Trace 'Input format. (%s)' "${OPTARG}"
        _Date_ifmt="${OPTARG}"
        ;;

      o)
        ${_M} && _Trace 'Output format. (%s)' "${OPTARG}"
        _Date_ofmt="${OPTARG}"
        ;;

      *)
        Error -L '(ConvertDate) Unknnown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  local _Date_var=${1}
  ((2 == ${#})) || Error -L -e '(ConvertDate) Called without a variable name and source date.'
  shift

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'ConvertDate error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    ${_M} && _Trace 'Converting date. (%s -> %s)' "${_Date_ifmt}" "${_Date_ofmt}"
    if [[ 'Darwin' == "${OS}" || 'FreeBSD' == "${OS}" ]]
    then
      # BSD / macOS
      eval "${_Date_var}=\$(date -j -f '${_Date_ifmt}' '${*}' '+${_Date_ofmt}')"
    else
      # Linux / SysV
      eval "${_Date_var}=\$(date -d '${*}' +'${_Date_ofmt}')"
    fi

    return 0
  fi
}

return 0
