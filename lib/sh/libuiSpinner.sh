#!/bin/zsh
#####
#
#	Libui Spinner Mod - Spinner Progress Meter Utility
#
#	F Harvell - Fri Feb 11 17:41:27 EST 2022
#
#####
#
# Provides spinner / progress meter utility commands.
#
# Man page available for this mod: man 3 libuiSpinner.sh
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

Version -r 2.000 -m 1.17

# defaults

# Display spinner in the background
#
# Syntax: StartSpinner
#
# Example: StartSpinner; list=$(find .); StopSpinner
#
# Result: A spinner is started in the background, the find is executed, and the
# spinner is stopped.
#
# Note: Care should be taken to never start more than one spinner.
#
UICMD+=( 'StartSpinner' )
StartSpinner () { # [<info_message>]
  ${_S} && ((_cStartSpinner++))
  ${_M} && _Trace 'StartSpinner [%s]' "${*}"

  ${_M} && _Trace 'Check for quiet. (%s)' "${_quiet}"
  if ! ${_quiet}
  then
    ${_M} && _Trace 'Check for existing spinner. (%s)' "${_spinner}"
    if ((0 == ${_spinner:-0}))
    then
      ${_M} && _Trace 'Check for terminal.'
      if ${TERMINAL} && ! Error
      then
        ${_M} && _Trace 'Display message. (%s)' "${*}"
        local _s
        ${ZSH} && local _w='.' || local _w='?'
        if [[ "${1}" =~ (^|[^%])%([^%]|$) ]]
        then
          _s="${1}"
          shift
        elif [[ "${1}" =~ \\\\${_w} ]]
        then
          _s="${1}%s"
          shift
        else
          _s='%s'
        fi
        [[ -n "${@}" ]] && printf "${DJBL}${DSpinner}${_s}${D} ${DCEL}" "${@}" >&4 # duplicate stderr

        ${_M} && _Trace 'Starting spinner.'
        local _Spinner_i
        (
          ${ZSH} && jobs -Z 'Spinner' || BASH_ARGV0='Spinner'
          while true
          do
            for _Spinner_i in '|' '/' '-' '\'
            do
              printf " ${DSpinner}%s${D}${DCEL}\b\b" ${_Spinner_i} >&4 # duplicate stderr
              sleep 0.1
            done
          done
        ) &
        _spinner=$!
        ${_M} && _Trace 'Spinner running. (%s)' "${_spinner}"
      fi
    fi
  fi

  ${_M} && _Trace 'StartSpinner return. (%s)' 0
  return 0
}

# Pause a spinner running in the background
#
# Syntax: PauseSpinner
#
# Example: StartSpinner; list=$(find .); PauseSpinner; Verify "Continue?"; ResumeSpinner; StopSpinner
#
# Result: A spinner is started in the background, the find is executed, the
# spinner is paused, a question is asked, the spinner is resumed, and the
# spinner is stopped.
#
# Note: Care should be taken to never start more than one spinner.
#
UICMD+=( 'PauseSpinner' )
PauseSpinner () {
  ${_S} && ((_cPauseSpinner++))
  ${_M} && _Trace 'PauseSpinner [%s]' "${*}"

  ${_M} && _Trace 'Check for terminal.'
  if ${TERMINAL}
  then
    ${_M} && _Trace 'Pausing spinner. (%s)' "${_spinner}"
    ((0 < ${_spinner:-0})) && kill -TSTP ${_spinner} &> /dev/null
    ${_quiet} || printf "${DCEL:-  \b\b}${DJBL}${DCEL}" >&4 # duplicate stderr
  fi
  local _Spinner_rv=${?}

  ${_M} && _Trace 'PauseSpinner return. (%s)' "${_Spinner_rv}"
  return ${_Spinner_rv}
}

# Resume a spinner running in the background
#
# Syntax: ResumeSpinner
#
# Example: StartSpinner; list=$(find .); PauseSpinner; Verify "Continue?"; ResumeSpinner; StopSpinner
#
# Result: A spinner is started in the background, the find is executed, the
# spinner is paused, a question is asked, the spinner is resumed, and the
# spinner is stopped.
#
# Note: Care should be taken to never start more than one spinner.
#
UICMD+=( 'ResumeSpinner' )
ResumeSpinner () {
  ${_S} && ((_cResumeSpinner++))
  ${_M} && _Trace 'ResumeSpinner [%s]' "${*}"

  ${_M} && _Trace 'Check for terminal.'
  if ${TERMINAL}
  then
    ${_M} && _Trace 'Resuming spinner. (%s)' "${_spinner}"
    ${_quiet} || printf "${DCEL:-  \b\b}${DJBL}${DCEL}" >&4 # duplicate stderr
    ((0 < ${_spinner:-0})) && kill -CONT ${_spinner} &> /dev/null
  fi
  local _Spinner_rv=${?}

  ${_M} && _Trace 'ResumeSpinner return. (%s)' "${_Spinner_rv}"
  return ${_Spinner_rv}
}

# Stop a spinner running in the background
#
# Syntax: StopSpinner
#
# Example: StartSpinner; list=$(find .); StopSpinner
#
# Result: A spinner is started in the background, the find is executed, and the
# spinner is stopped.
#
# Note: Care should be taken to never start more than one spinner.
#
UICMD+=( 'StopSpinner' )
StopSpinner () {
  ${_S} && ((_cStopSpinner++))
  ${_M} && _Trace 'StopSpinner [%s]' "${*}"

  ${_M} && _Trace 'Stopping spinner. (%s)' "${_spinner}"
  ((0 < ${_spinner:-0})) && kill -TERM ${_spinner} &> /dev/null && unset _spinner
  ${_quiet} || printf "${DCEL:-  \b\b}${DJBL}${DCEL}" >&4 # duplicate stderr
  local _Spinner_rv=${?}

  ${_M} && _Trace 'StopSpinner return. (%s)' "${_Spinner_rv}"
  return ${_Spinner_rv}
}

# Display spinner and wait until background process exits
#
# Syntax: WaitSpinner
#
# Example: list=( $(find .) ) & WaitSpinner
#
# Result: The find command is executed in the background and a spinner is
# displayed until the find completes.
#
UICMD+=( 'WaitSpinner' )
WaitSpinner () {
  ${_S} && ((_cWaitSpinner++))
  ${_M} && _Trace 'WaitSpinner [%s]' "${*}"

  local pid=$!

  ${_M} && _Trace 'Check for valid PID. (%s)' "${_Spinner_pid}"
  if ((0 < _Spinner_pid))
  then
    ${_M} && _Trace 'Check for quiet. (%s)' "${_quiet}"
    if ! ${_quiet}
    then
      ${_M} && _Trace 'Check for existing spinner. (%s)' "${_spinner}"
      if ((0 == ${_spinner:-0}))
      then
        ${_M} && _Trace 'Check for terminal.'
        if ${TERMINAL}
        then
          ${_M} && _Trace 'Starting spinner. (%s)' "${_Spinner_pid}"
          local _Spinner_i
          while kill -0 ${_Spinner_pid} &> /dev/null
          do
            for _Spinner_i in '|' '/' '-' '\'
            do
              printf " ${DSpinner}%s${D}${DCEL}\b\b" ${_Spinner_i} >&4 # duplicate stderr
              sleep 0.1
            done
          done
          printf "${DCEL:-  \b\b}${DJBL}${DCEL}" >&4 # duplicate stderr
        fi
      fi
    fi

    ${_M} && _Trace 'Waiting for PID exit. (%s)' "${_Spinner_pid}"
    wait ${_Spinner_pid}
    local _Spinner_rv=${?}

    ${_M} && _Trace 'WaitSpinner return. (%s)' "${_Spinner_rv}"
    return ${_Spinner_rv}
  else
    ${_M} && _Trace 'WaitSpinner error return. (%s)' "${ERRV}"
    return ${ERRV}
  fi
}

# Display countdown while waiting
#
# Syntax: Sleep [-i "<message>"] [-u <interval>] [<sleep>]
#
# Example: Sleep -u 10 60
#
# Result: Displays "Waiting 60..." and then counts down while updating the
# message every 10 seconds until 60 seconds have elapsed.
#
# Note: The <message> should include one "%s" to capture the countdown. If
# <sleep> is not provided, will sleep 1 second. If <interval> is not provided,
# it will default to 1 second.
#
UICMD+=( 'Sleep' )
Sleep () { # [-i "<message>"] [-u <interval>] [<sleep>]
  ${_S} && ((_cSleep++))
  ${_M} && _Trace 'Sleep [%s]' "${*}"

  ${_M} && _Trace 'Check for terminal.'
  if ${TERMINAL}
  then
    local _Spinner_u=1
    local _Spinner_i='Waiting %s...'

    local opt
    local OPTIND
    local OPTARG
    while getopts ':i:u:' opt
    do
      case ${opt} in
        i)
          ${_M} && _Trace 'Message. (%s)' "${OPTARG}"
          _Spinner_i="${OPTARG}"
          ;;

        u)
          ${_M} && _Trace 'Update interval. (%s)' "${OPTARG}"
          _Spinner_u="${OPTARG}"
          ;;

        *)
          Tell -E -f -L '(Sleep) Unknown option. (-%s)' "${OPTARG}"
          ;;

      esac
    done
    shift $((OPTIND - 1))
    local _Spinner_c=$((${1:0} + ${_Spinner_u}))

    ${_M} && _Trace 'Verbose sleep. (%s)' "${_Spinner_c}"
    while ((0 < (_Spinner_c-=${_Spinner_u})))
    do
      printf "${DJBL}${DInfo}${_Spinner_i}${D}${DCEL}" "${_Spinner_c}" >&4 # duplicate stderr
      sleep ${_Spinner_u}
    done
    printf "${DJBL}${DCEL}" >&4 # duplicate stderr
  else
    ${_M} && _Trace 'Quiet sleep. (%s)' "${1:-1}"
    sleep ${1:-1}
  fi

  ${_M} && _Trace 'Sleep return. (%s)' 0
  return 0
}

# module exit callback
_SpinnerExitCallback () {
  ${_M} && _Trace '_SpinnerExitCallback [%s]' "${*}"

  ${_M} && _Trace 'Stopping spinner. (%s)' "${_spinner}"
  ((0 < ${_spinner:-0})) && kill -TERM ${_spinner} &> /dev/null && unset _spinner
  ! ${_quiet} && ${TERMINAL} && printf "${DCEL:-  \b\b}${DJBL}${DCEL}" >&4 # duplicate stderr
}

# register exit callback
_exitcallback+=( '_SpinnerExitCallback' )

return 0
