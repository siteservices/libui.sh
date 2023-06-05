#!/bin/zsh
#####
#
#	Libui Syslog Mod - Syslog Utility
#
#	F Harvell - Mon Sep 26 04:25:03 EDT 2022
#
#####
#
# Provides syslog utility commands.
#
# Man page available for this module: man 3 libuiSyslog.sh
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

Version -r 1.822 -m 1.2

# defaults
_Syslog_default_priority='user.notice'

# Log a syslog entry
#
# Syntax: Syslog [-p <priority>] [<message>]
#
# Example: Syslog 'Adding new entry.'
#
# Result: The syslog command is executed with the default priority, user.notice,
# to add the message, "Adding new entry." to the syslog.
#
UICMD+=( 'Syslog' )
Syslog () { # [-p <priority>] [<message>]
  ${_S} && ((_cSyslog++))
  ${_M} && _Trace 'Syslog [%s]' "${*}"

  local _Syslog_p="${LIBUI_SYSLOG_PRIORITY-${_Syslog_default_priority}}"

  ${_M} && _Trace 'Process Syslog options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':p:' _o
  do
    case ${_o} in
      p)
        ${_M} && _Trace 'Syslog priority. (%s)' "${OPTARG}"
        _Syslog_p="${OPTARG}"
        ;;

      *)
        Error -L '(Syslog) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'Syslog error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    local _Syslog_logger="$(command -v logger) -t \"\${CMD}\" -p \"\${_Syslog_p}\" \"\${USER}: \""
    if ((${#}))
    then
      ${_M} && _Trace 'Log message to syslog. (%s)' "${*}"
      NoAction && printf '%s %s\n' "${_Syslog_logger}" "${*}" || eval "${_Syslog_logger} '${*}'"
    else
      ${_M} && _Trace 'Log script command line to syslog. (%s %s)' "${CMD}" "${_clp[*]}"
      NoAction && printf '%s %s %s\n' "${_Syslog_logger}" "${CMD}" "${_clp[*]}" ||
          eval "${_Syslog_logger} ${CMD} '${_clp[*]}'"
    fi

    return 0
  fi
}

return 0
