#!/bin/zsh
#####
#
#	Libui Timer Mod - Timer Utilities
#
#	F Harvell - Tue Jan 11 06:52:52 EST 2022
#
#####
#
# Provides timer utility commands.
#
# Man page available for this module: man 3 libuiTimer.sh
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

Version -r 1.822 -m 1.7

# defaults
command -v bc &> /dev/null && __BC='bc' || __BC='awk "{print $1 - $3}"'
__timer=0
ELAPSED=0

# Start a timer
#
# Syntax: StartTimer [<variable_name>]
#
# Example: StartTimer task
#
# Result: Current ${SECONDS} is captured
#
UICMD+=( 'StartTimer' )
StartTimer () { # [<variable_name>]
  ${_S} && ((_cStartTimer++))
  ${_M} && _Trace 'StartTimer [%s]' "${*}"

  local _Timer_now=${SECONDS}

  if [[ -z "${1}" ]]
  then
    ${_M} && _Trace 'Start timer. (%s)' "${_Timer_now}"
    __timer=${_Timer_now}
  else
    ${_M} && _Trace 'Start timer %s. (%s)' "${1}" "${_Timer_now}"
    eval "${1}=${_Timer_now}"
  fi

  return 0
}

# Get timer elapsed time
#
# Syntax: GetElapsed [<variable_name>]
#
# Example: GetElapsed task
#
# Result: Timer elapsed time in seconds is captured in ${ELAPSED}
#
UICMD+=( 'GetElapsed' )
GetElapsed () { # [<variable>]
  ${_S} && ((_cGetElapsed++))
  ${_M} && _Trace 'GetElapsed [%s]' "${*}"

  if [[ -z "${1}" ]]
  then
    ${ZSH} && ((ELAPSED = SECONDS - __timer)) || ELAPSED=$(${__BC} <<< "${SECONDS} - ${__timer}")
    ${_M} && _Trace 'Timer %s elapsed. (%s)' "${__timer}" "${ELAPSED}"
  else
    ${ZSH} && eval "((ELAPSED = SECONDS - ${1}))" || eval "ELAPSED=\$(${__BC} <<< \"${SECONDS} - \${${1}}\")"
    ${_M} && _Trace 'Timer %s elapsed. (%s)' "${1}" "${ELAPSED}"
  fi

  return 0
}

# Format elapsed time
#
# Syntax: FormatElapsed [-d]
#
# Example: FormatElapsed
#
# Result: Format ${ELAPSED} as [# days] HH:MM:SS.ssss
#
# format elapsed time
UICMD+=( 'FormatElapsed' )
FormatElapsed () { # [-d]
  ${_S} && ((_cFormatElapsed++))
  ${_M} && _Trace 'FormatElapsed [%s]' "${*}"

  local _Timer_days=false

  ${_M} && _Trace 'Process FormatElapsed options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':d' opt
  do
    case ${opt} in
      d)
        ${_M} && _Trace 'Report days.'
        _Timer_days=true
        ;;

      *)
        Error '(FormatElapsed) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'FormatElapsed error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    ${_M} && _Trace 'Calculate elapsed time components. (%s)' "${ELAPSED}"
    local _Timer_d=0
    local _Timer_f=0
    local _Timer_h=0
    local _Timer_m=0
    ${ZSH} && integer _Timer_s=${ELAPSED} && ((_Timer_f = ELAPSED - _Timer_s)) || local _Timer_s=${ELAPSED}
    ((_Timer_m = _Timer_s / 60))
    ((_Timer_s = _Timer_s % 60))
    ((_Timer_h = _Timer_m / 60))
    ((_Timer_m = _Timer_m % 60))
    ((_Timer_d = _Timer_h / 24))
    unset ELAPSED
    if ${_Timer_days}
    then
      ((_Timer_h = _Timer_h % 24))
      ELAPSED="${_Timer_d} day"
      ((1 == _Timer_d)) && ELAPSED+=" " || ELAPSED+="s "
    fi
    ${ZSH} && float ss=$((_Timer_s + _Timer_f)) && ELAPSED+=$(printf '%02d:%02d:%07.04f' "${_Timer_h}" "${_Timer_m}" "${ss}") || \
        ELAPSED+=$(printf '%02d:%02d:%02d' "${_Timer_h}" "${_Timer_m}" "${_Timer_s}")
    ${_M} && _Trace 'ELAPSED formatted time. (%s)' "${ELAPSED}"

    return 0
  fi
}

# module initialization callback
_TimerInitCallback () {
  ${_M} && _Trace '_TimerInitCallback [%s]' "${*}"
  StartTimer
}

# register init callback
_initcallback+=( '_TimerInitCallback' )

return 0
