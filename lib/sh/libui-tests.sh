#!/bin/zsh
#####
#
#	libui-tests.sh - Regression Tests for libui.sh
#
#	F Harvell - Fri May  5 12:21:34 EDT 2023
#
#####
#
# This file is sourced by the LibuiUtility.sh libui mod and should only contain
# regression test functions. It is not a libui script nor a libui mod.
#
# IMPORTANT: These tests do white box manipulation of many libui.sh internals
# and should not be used as a model for libui.sh development. Please use the
# libui-template file as a model for libui.sh script development.
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

# version
Version -r 1.825 1.825

# defaults
unset tests


#####
#
# test functions
#
#####

UICMD+=( 'LibuiPerformTest' )
LibuiPerformTest () {
  ${_S} && ((_cLibuiPerformTest++))
  ${_M} && _Trace 'LibuiPerformTest [%s]' "${*}"

  local rv

  # ${_M} && _Trace 'Perform %s.' "${*}" --> don't use, generates output when testing Trace
  Tell '\nPerform: %s (Logfile: %s)\nResults:\n-----\n' "${*}" "${TESTDIR}/test.out"
  if ${ZSH}
  then
    eval "( ${@} )" 2>&1 | tee "${TESTDIR}/test.out"
    rv=${pipestatus[${AO}]}
  else
    eval "( ${@} )" 2>&1 | tee "${TESTDIR}/test.out"
    rv=${PIPESTATUS[${AO}]}
  fi

  ${_M} && _Trace 'LibuiPerformTest return. (%s)' "${rv}"
  Tell '\n-----\nReturn value: %s\n' "${rv}"
  return ${rv}
}

UICMD+=( 'LibuiValidateTest' )
LibuiValidateTest () {
  ${_S} && ((_cLibuiValidateTest++))
  ${_M} && _Trace 'LibuiValidateTest [%s]' "${*}"

  local input; [[ -f "${TESTDIR}/test.out" ]] && input="$(< "${TESTDIR}/test.out")"
  local initial=false
  local regex=false
  local rv=0

  # get options
  ${_M} && _Trace 'Check for validate options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':ir' opt
  do
    case "${opt}" in
      i)
        ${_M} && _Trace 'Make parameter initial.'
        initial=true
        ;;

      r)
        ${_M} && _Trace 'Make parameter regex.'
        regex=true
        ;;

      *)
        Error '(validate) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  # get values
  local tv="${1}" # test value
  local vr="${2}" # valid return
  shift 2

  # validate
  ${_M} && _Trace 'Validate (initial:%s) (regex:%s): (valid:%s) %s=(test:%s) %s' "${initial}" "${regex}" "${vr}" "${*}" "${tv}" "${input}"
  if ${regex}
  then
    Tell '\nValidate (regex):\nresult |%d|%s|\n valid |%d|%s|\n' "${tv}" "${input}" "${vr}" "${*}"
    [[ "${tv}" -eq "${vr}" && "${input}" =~ ${*} ]] || rv=1 # regex needs to be unquoted
  elif ${initial}
  then
    Tell '\nValidate (initial):\nresult |%d|%s|\n valid |%d|%s|\n' "${tv}" "${input}" "${vr}" "${*}"
    ((tv == vr)) && [[ "${input}" == "${*}"* ]] || rv=1
  else
    Tell '\nValidate (exact):\nresult |%d|%s|\n valid |%d|%s|\n' "${tv}" "${input}" "${vr}" "${*}"
    ((tv == vr)) && [[ "${input}" == "${*}" ]] || rv=1
  fi

  ${_Util_debug} && _Terminal
  if ((0 != rv))
  then
    Warn '>>> Validation failed.'
    ${_Util_debug} && if ! Verify 'Continue?'
    then
      ${_M} && _Trace 'Quit %s. (%s)' "${CMD}" 0
      Exit 2
    fi
  else
    Alert 'Validation passed.'
  fi

  ${_M} && _Trace 'LibuiValidateTest return. (%s)' "${rv}"
  return ${rv}
}


#####
#
# test support functions
#
#####

UICMD+=( 'RetryCountdown' )
RetryCountdown () {
  ${_S} && ((_cRetry++))
  ${_M} && _Trace 'RetryCountdown [%s]' "${*}"

  ${_M} && _Trace 'RetryCountdown. (%s)' "${retries}"
  ((retries--))
  if ((0 < retries))
  then
    ${_M} && _Trace 'Return "Bad". (%s)' "${retries}"
    printf "Bad\n"
    return 1
  else
    ${_M} && _Trace 'Return "Good". (%s)' "${retries}"
    printf "Good\n"
    return 0
  fi
}

UICMD+=( 'LibuiGetDisplayTestValues' )
LibuiGetDisplayTestValues () {
  ${_S} && ((_cDisplayTestValues++))
  ${_M} && _Trace 'LibuiGetDisplayTestValues [%s]' "${*}"

  ${_M} && _Trace 'Define display values.'
  TCS="$(tput clear)" # clear screen (jump home)
  TCEL="$(tput el)" # clear end of line
  TCES="$(tput ed)" # clear end of screen
  TJBL="$(tput hpa 0)" # jump begin of line
  TJH="$(tput cup 0 0)" # jump home (0, 0)
  TRP="$(tput u7)" # read cursor position
  if ((16 <= $(tput colors)))
  then
    TB0="$(tput setab 8)" # bright black
    TBr="$(tput setab 9)" # bright red
    TBg="$(tput setab 10)" # bright green
    TBy="$(tput setab 11)" # bright yellow
    TBb="$(tput setab 12)" # bright blue
    TBm="$(tput setab 13)" # bright magenta
    TBc="$(tput setab 14)" # bright cyan
    TB7="$(tput setab 15)" # bright white
    TF0="$(tput setaf 8)" # bright black
    TFr="$(tput setaf 9)"; Tfr="${TFr}" # bright / red
    TFg="$(tput setaf 10)" # bright green
    TFy="$(tput setaf 11)"; Tfy="${TFy}" # bright / yellow
    TFb="$(tput setaf 12)"; Tfb="${TFb}" # bright / blue
    TFm="$(tput setaf 13)" # bright magenta
    TFc="$(tput setaf 14)" # bright cyan
    TF7="$(tput setaf 15)"; Tf7="${TF7}" # bright / white
  else
    Tfr="$(tput bold; tput setaf 1)" # red
    Tfy="$(tput bold; tput setaf 3)" # yellow
    Tfb="$(tput bold; tput setaf 4)" # blue
    Tf7="$(tput bold; tput setaf 7)" # white
  fi
  Tb0="$(tput setab 0)" # black
  Tbr="$(tput bold; tput setab 1)" # red
  Tbg="$(tput setab 2)" # green
  Tby="$(tput bold; tput setab 3)" # yellow
  Tbb="$(tput setab 4)" # blue
  Tbm="$(tput setab 5)" # magenta
  Tbc="$(tput setab 6)" # cyan
  Tb7="$(tput setab 7)" # white
  Tf0="$(tput setaf 0)" # black
  Tfg="$(tput setaf 2)" # green
  Tfm="$(tput setaf 5)" # magenta
  Tfc="$(tput setaf 6)" # cyan
  Tb="$(tput bold)" # bold
  [[ -n "$(tput dim)" ]] && Td="$(tput dim)" || Td="${TF0:-${Tf0}}" # dim
  Tsu="$(tput smul)" # start underline
  Teu="$(tput rmul)" # end underline
  Tr="$(tput rev)" # reverse
  Tss="$(tput smso)" # start standout
  Tes="$(tput rmso)" # exit standout
  T="$(tput sgr0)" # normal
  TAction="${Tfb}" # display formats
  TAlarm="${Td}${Tfr}"
  TAlert="${Tb}${TFg}"
  TAnswer="${Td}${Tfy}"
  TCaution="${Tb}${TFr}"
  TConfirm="${Tb}${TFy}"
  TError="${Tbr}${Tb}${TFy}"
  TInfo="${Tb}${TFm}"
  TNoAction="${Tfm}"
  TOptions="${Tb}"
  TQuestion="${Tb}${TFc}"
  TSpinner="${Tb}${TFc}"
  TTell="${Tb}"
  TTrace="${Tfc}"
  TWarn="${Tby}${TBy}${Tf0}"
  T0="${T}${Tb}${Tsu}" # display modes
  T1="${T}${Tb}${TFr}"
  T2="${T}${Tb}${TFg}"
  T3="${T}${Tb}${TFy}"
  T4="${T}${Tb}${TFb}"
  T5="${T}${Tb}${TFm}"
  T6="${T}${Tb}${TFc}"
  T7="${T}${Tb}"
  T8="${T}"
  T9="${T}${Td}"

  ${_M} && _Trace 'GetDisplayTestValues return. (%s)' 0
  return 0
}


#####
#
# test cases
#
#####

# info test
tests+=( 'test_Info' )
test_Info () {
  LibuiPerformTest 'libui -h'
  LibuiValidateTest -i ${?} 2 "${infotext}"
  return ${?}
}

# Predefined vars
tests+=( 'test_AA' )
test_AA () {
  local bv="${BASH_VERSION%.*}"; [[ -n "${bv}" ]] && bv="${bv//.}" || bv=0
  LibuiPerformTest 'Tell -- "${AA}"'
  local tv=${?}
  if ${ZSH} || ((40 <= bv))
  then
    LibuiValidateTest "${tv}" 0 'true'
  else
    LibuiValidateTest "${tv}" 0 'false'
  fi
  return ${?}
}
tests+=( 'test_AO' )
test_AO () {
  LibuiPerformTest 'Tell -- "${AO}"'
  local tv=${?}
  if ${ZSH}
  then
    LibuiValidateTest "${tv}" 0 1
  else
    LibuiValidateTest "${tv}" 0 0
  fi
  return ${?}
}
tests+=( 'test_IWD' )
test_IWD () {
  LibuiPerformTest 'Tell -- "${IWD}"'
  LibuiValidateTest ${?} 0 "${_Util_workdir}"
  return ${?}
}
tests+=( 'test_BV' )
test_BV () {
  local bv="${BASH_VERSION%.*}"; [[ -n "${bv}" ]] && bv="${bv//.}" || bv=0
  LibuiPerformTest 'Tell -- "${BV}"'
  LibuiValidateTest ${?} 0 "${bv}"
  return ${?}
}
tests+=( 'test_CMD' )
test_CMD () {
  LibuiPerformTest 'Tell -- "${CMD}"'
  LibuiValidateTest ${?} 0 "${script##*/}"
  return ${?}
}
tests+=( 'test_CMDARGS' )
test_CMDARGS () {
  LibuiPerformTest 'Tell -- "${CMDARGS[*]}"'
  LibuiValidateTest ${?} 0 "${arg[*]}"
  return ${?}
}
tests+=( 'test_CMDLINE' )
test_CMDLINE () {
  LibuiPerformTest 'Tell -- "${CMDLINE[*]}"'
  LibuiValidateTest ${?} 0 "${script} ${arg[*]}"
  return ${?}
}
tests+=( 'test_CMDPATH' )
test_CMDPATH () {
  LibuiPerformTest 'Tell -- "${CMDPATH}"'
  LibuiValidateTest ${?} 0 "${script}"
  return ${?}
}
tests+=( 'test_DOMAIN' )
test_DOMAIN () {
  local h="$(/bin/hostname -f 2> /dev/null)"
  local d; ${ZSH} && d="${(L)h#*\.}" || d="$(printf '%s\n' "${h#*\.}" | tr '[:upper:]' '[:lower:]')"
  [[ 'local' == "${d}" ]] && d=
  d="${d:-$(/usr/bin/grep '^search ' /etc/resolv.conf 2> /dev/null | /usr/bin/cut -d ' ' -f 2)}"
  LibuiPerformTest 'Tell -- "${DOMAIN}"'
  LibuiValidateTest ${?} 0 "${d}"
  return ${?}
}
tests+=( 'test_FMFLAGS' )
test_FMFLAGS () {
  LibuiPerformTest 'Tell -- "${FMFLAGS}"'
  LibuiValidateTest ${?} 0 ''
  return ${?}
}
tests+=( '-C test_FMFLAGS_C' )
test_FMFLAGS_C () {
  LibuiPerformTest 'Tell -- "${FMFLAGS}"'
  LibuiValidateTest ${?} 0 '-i'
  return ${?}
}
tests+=( '-F test_FMFLAGS_F' )
test_FMFLAGS_F () {
  LibuiPerformTest 'Tell -- "${FMFLAGS}"'
  LibuiValidateTest ${?} 0 '-f'
  return ${?}
}
tests+=( '-Y test_CHFLAGS_Y' )
test_CHFLAGS_Y () {
  local tflags
  [[ "${arg[*]}" =~ .*-X.* ]] && tflags+='-X [0-9] '
  [[ "${arg[*]}" =~ .*-Y.* ]] && tflags+='-Y '
  LibuiPerformTest 'Tell -- "${CHFLAGS}"'
  LibuiValidateTest -r ${?} 0 ".*${tflags}.*"
  return ${?}
}
tests+=( 'test_HOST' )
test_HOST () {
  local f="$(/bin/hostname -f 2> /dev/null)"
  local host; ${ZSH} && host="${(L)f%%\.*}" || host="$(printf '%s\n' "${f%%\.*}" | tr '[:upper:]' '[:lower:]')"
  host="${host:-$(hostname -s 2> /dev/null)}"
  host="${host:-$(uname -n 2> /dev/null)}"
  LibuiPerformTest 'Tell -- "${HOST}"'
  LibuiValidateTest ${?} 0 "${host}"
  return ${?}
}
tests+=( 'test_LIBUI' )
test_LIBUI () {
  LibuiPerformTest 'Tell -- "${LIBUI}"'
  LibuiValidateTest ${?} 0 "${SHLIBPATH%/}/libui.sh" # FIXME! needs better validation value
  return ${?}
}
tests+=( 'test_MAXINT' )
test_MAXINT () {
  local maxint=9223372036854775807; ((2147483647 > maxint)) && maxint=2147483647
  LibuiPerformTest 'Tell -- "${MAXINT}"'
  LibuiValidateTest ${?} 0 "${maxint}"
  return ${?}
}
tests+=( 'test_N' )
test_N () {
  local n=$'\n'
  LibuiPerformTest 'Tell "|${N}|"'
  LibuiValidateTest ${?} 0 "|${n}|"
  return ${?}
}
tests+=( 'test_NROPT' )
test_NROPT () {
  ${_Util_debug} && local p=2 || local p=1
  LibuiPerformTest 'Tell -- "${NROPT}"'
  LibuiValidateTest ${?} 0 "${p}"
  return ${?}
}
tests+=( 'test_NRPARAM' )
test_NRPARAM () {
  LibuiPerformTest 'Tell -- "${NRPARAM}"'
  LibuiValidateTest ${?} 0 "1" # assumes normal parameters
  return ${?}
}
tests+=( 'test_OS' )
test_OS () {
  local tos="$(uname -s)"
  [[ "${tos}" =~ .*CYGWIN.* ]] && tos="(${tos}|Windows_NT)"
  LibuiPerformTest 'Tell -- "${OS}"'
  LibuiValidateTest -r ${?} 0 "${tos}"
  return ${?}
}
tests+=( 'test_PV' )
test_PV () {
  local pv=true
  local zv="${ZSH_VERSION%.*}"; [[ -n "${zv}" ]] && zv="${zv//.}" || zv=0; ${ZSH} && ((53 > zv)) && pv=false
  LibuiPerformTest 'Tell -- "${PV}"'
  LibuiValidateTest ${?} 0 "${pv}"
  return ${?}
}
tests+=( 'test_SHELL' )
test_SHELL () {
  ${ZSH} && local sh="${ZSH_NAME:t}" || local sh="$([[ -n "${BASH_VERSION}" ]] && printf 'bash' || printf 'sh')"
  LibuiPerformTest 'Tell -- "${SHELL}"'
  LibuiValidateTest ${?} 0 "${sh}"
  return ${?}
}
tests+=( 'test_SHLIBPATH' )
test_SHLIBPATH () {
  local lpath="${BASH_SOURCE:-${(%):-%x}}"
  LibuiPerformTest 'Tell -- "${SHLIBPATH}"'
  LibuiValidateTest ${?} 0 "${lpath%/*}"
  return ${?}
}
tests+=( 'test_TERMINAL' )
test_TERMINAL () {
  [[ -t 1 ]] && local pass="${TERMINAL:-true}" || local pass="${TERMINAL:-false}"
  LibuiPerformTest 'Tell -- "${TERMINAL}"'
  LibuiValidateTest ${?} 0 "${pass}"
  return ${?}
}
tests+=( 'test_UIVERSION' )
test_UIVERSION () {
  #LoadMod Timer # note: loaded by main
  LibuiPerformTest 'Tell -- "${UIVERSION[*]}"'
  LibuiValidateTest -r ${?} 0 ".*libui\.sh.*"
  return ${?}
}
tests+=( 'test_UIMOD' )
test_UIMOD () {
  #LoadMod Timer # note: loaded by main
  LibuiPerformTest 'Tell -- "${UIMOD[*]}"'
  LibuiValidateTest -r ${?} 0 ".*Timer.*"
  return ${?}
}
tests+=( 'test_UICMD' )
test_UICMD () {
  #LoadMod Timer # note: loaded by main
  LibuiPerformTest 'Tell -- "${UICMD[*]}"'
  LibuiValidateTest -r ${?} 0 ".*StartTimer GetElapsed FormatElapsed.*"
  return ${?}
}
tests+=( 'test_ZSH' )
test_ZSH () {
  LibuiPerformTest 'Tell -- "${ZSH}"'
  local tv=${?}
  if ${ZSH}
  then
    LibuiValidateTest "${tv}" 0 'true'
  else
    LibuiValidateTest "${tv}" 0 'false'
  fi
  return ${?}
}
tests+=( 'test_ZV' )
test_ZV () {
  local zv="${ZSH_VERSION%.*}"; [[ -n "${zv}" ]] && zv="${zv//.}" || zv=0
  LibuiPerformTest 'Tell -- "${ZV}"'
  LibuiValidateTest ${?} 0 "${zv}"
  return ${?}
}

# Display
tests+=( 'test_Display' )
test_Display () {
  LibuiGetDisplayTestValues
  local t="${TERMINAL}"
  TERMINAL=true
  _Terminal
  TERMINAL="${t}"
  LibuiPerformTest "printf 'Terminal: ${Db0},${Dbr},${Dbg},${Dby},${Dbb},${Dbm},${Dbc},${Db7},${DB0},${DBr},${DBg},${DBy},${DBb},${DBm},${DBc},${DB7},${Df0},${Dfr},${Dfg},${Dfy},${Dfb},${Dfm},${Dfc},${Df7},${DF0},${DFr},${DFg},${DFy},${DFb},${DFm},${DFc},${DF7},${Db},${Dd},${Dsu},${Deu},${Dr},${Dss},${Des},${D},${D0},${D1},${D2},${D3},${D4},${D5},${D6},${D7},${D8},${D9},${DAction},${DAlarm},${DAlert},${DAnswer},${DCaution},${DConfirm},${DError},${DInfo},${DNoAction},${DOptions},${DQuestion},${DSpinner},${DTell},${DTrace},${DWarn},${D}.'"
  LibuiValidateTest ${?} 0 "Terminal: ${Tb0},${Tbr},${Tbg},${Tby},${Tbb},${Tbm},${Tbc},${Tb7},${TB0},${TBr},${TBg},${TBy},${TBb},${TBm},${TBc},${TB7},${Tf0},${Tfr},${Tfg},${Tfy},${Tfb},${Tfm},${Tfc},${Tf7},${TF0},${TFr},${TFg},${TFy},${TFb},${TFm},${TFc},${TF7},${Tb},${Td},${Tsu},${Teu},${Tr},${Tss},${Tes},${T},${T0},${T1},${T2},${T3},${T4},${T5},${T6},${T7},${T8},${T9},${TAction},${TAlarm},${TAlert},${TAnswer},${TCaution},${TConfirm},${TError},${TInfo},${TNoAction},${TOptions},${TQuestion},${TSpinner},${TTell},${TTrace},${TWarn},${T}."
  return ${?}
}

# Contains <array_var> <value>
tests+=( 'test_Contains_True' )
test_Contains_True () {
  local testarray; testarray=( a b c xxx yyy zzz )
  LibuiPerformTest 'Contains testarray "b" && printf "Exists." || printf "Does not exist."'
  LibuiValidateTest ${?} 0 'Exists.'
  return ${?}
}
tests+=( 'test_Contains_False' )
test_Contains_False () {
  local testarray; testarray=( a b c xxx yyy zzz )
  LibuiPerformTest 'Contains testarray "x" && printf "Exists." || printf "Does not exist."'
  LibuiValidateTest ${?} 0 'Does not exist.'
  return ${?}
}

# Capture <stdout_var> <stderr_var> <rv_var> <command_string>
tests+=( 'test_Capture_Failure' )
test_Capture_Failure () {
  TestFunction () { printf 'Out\n'; printf 'Err\n' > /dev/stderr; return 5; }
  Action 'Capture so se sr TestFunction'
  LibuiPerformTest "Tell 'rv: %s, OUT: %s, ERR: %s, RV: %s.' '${?}' '${so}' '${se}' '${sr}'"
  LibuiValidateTest ${?} 0 'rv: 5, OUT: Out, ERR: Err, RV: 5.'
  return ${?}
}
tests+=( 'test_Capture_Success' )
test_Capture_Success () {
  TestFunction () { printf 'Out\n'; return 0; }
  Action 'Capture so se sr TestFunction'
  LibuiPerformTest "Tell 'rv: %s, OUT: %s, ERR: %s, RV: %s.' '${?}' '${so}' '${se}' '${sr}'"
  LibuiValidateTest ${?} 0 'rv: 0, OUT: Out, ERR: , RV: 0.'
  return ${?}
}

# LoadProfile <file_path>
tests+=( 'test_LoadProfile' )
test_LoadProfile () {
  printf '%s\n' "profile_data='Profile data loaded.'" > "${TESTDIR}/test.profile"
  LoadMod Profile
  LoadProfile "${TESTDIR}/test.profile"
  LibuiPerformTest 'Tell -- "${profile_data}"'
  LibuiValidateTest ${?} 0 'Profile data loaded.'
  return ${?}
}
tests+=( "-P '${TESTDIR}/test.profile' test_LoadProfile_cmdline" ) # note: will only work if follows test_LoadProfile
test_LoadProfile_cmdline () {
  LibuiPerformTest 'Tell -- "${profile_data}"'
  LibuiValidateTest ${?} 0 'Profile data loaded.'
  return ${?}
}

# Action [-1..-9|-a|-c|-C|-e|-F|-R|-s|-t|-W] [-i <info_message>] [-l <file_path>] [-p <pipe_element>] [-q <question>] [-r <retries>] [-w <retry_wait>] <command_string_to_evaluate>
tests+=( 'test_Action' )
test_Action () {
  LibuiPerformTest 'Action "ls -d /tmp"'
  LibuiValidateTest ${?} 0 '/tmp'
  return ${?}
}
tests+=( 'test_Action-r_Good' )
test_Action-r_Good () {
  retries=3
  LibuiPerformTest 'Action -r 3 "RetryCountdown"'
  LibuiValidateTest ${?} 0 "Bad${N}Bad${N}Good"
  return ${?}
}
tests+=( 'test_Action-r_Bad_Warning' )
test_Action-r_Bad_Warning () {
  retries=4
  LibuiPerformTest 'Action -r 3 "RetryCountdown"'
  LibuiValidateTest ${?} 1 "Bad${N}Bad${N}Bad${N}WARNING: (Action) Failure while evaluating command."
  return ${?}
}
tests+=( 'test_Action-r_Bad_Error' )
test_Action-r_Bad_Error () {
  retries=4
  LibuiPerformTest 'Action -e -r 3 "RetryCountdown"'
  LibuiValidateTest ${?} 1 "Bad${N}Bad${N}Bad${N}ERROR: (Action) Failure while evaluating command."
  return ${?}
}
tests+=( 'test_Action-r_Verbose_Bad_Warning' )
test_Action-r_Verbose_Bad_Warning () {
  _vdb=true
  retries=4
  LibuiPerformTest 'Action -r 3 "RetryCountdown"'
  LibuiValidateTest ${?} 1 "(Action) RetryCountdown (PWD: ${TESTDIR})${N}Bad${N}Bad${N}Bad${N}WARNING: (Action) Failure while evaluating command. (RetryCountdown, PWD: ${TESTDIR})"
  return ${?}
}
tests+=( 'test_Action-r_Verbose_Bad_Error' )
test_Action-r_Verbose_Bad_Error () {
  _vdb=true
  retries=4
  LibuiPerformTest 'Action -e -r 3 "RetryCountdown"'
  LibuiValidateTest ${?} 1 "(Action) RetryCountdown (PWD: ${TESTDIR})${N}Bad${N}Bad${N}Bad${N}ERROR: (Action) Failure while evaluating command. (RetryCountdown, PWD: ${TESTDIR})"
  return ${?}
}
tests+=( 'test_Action-rs' )
test_Action-rs () {
  #LoadMod Timer # note: loaded by main
  retries=2
  local timer
  StartTimer timer
  Action -r 2 -w 1 "RetryCountdown"
  GetElapsed timer
  LibuiPerformTest 'Tell "RetryCountdown: %s" "${ELAPSED}"'
  LibuiValidateTest -r ${?} 0 'RetryCountdown: (1|2).*'
  return ${?}
}
tests+=( 'test_Action-W' )
test_Action-W () {
  LibuiPerformTest 'Action -W "false"'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Action_Warning' )
test_Action_Warning () {
  LibuiPerformTest 'Action "false"'
  LibuiValidateTest ${?} 1 "WARNING: (Action) Failure while evaluating command."
  return ${?}
}
tests+=( 'test_Action-e' )
test_Action-e () {
  LibuiPerformTest 'Action -e "false"'
  LibuiValidateTest ${?} 1 "ERROR: (Action) Failure while evaluating command."
  return ${?}
}
tests+=( 'test_Action-f' )
test_Action-f () {
  LibuiPerformTest 'Action -f "Test failure." "false"'
  LibuiValidateTest ${?} 1 "WARNING: (Action) Test failure."
  return ${?}
}
tests+=( 'test_Action_Verbose_Warning' )
test_Action_Verbose_Warning () {
  _vdb=true
  LibuiPerformTest 'Action "false"'
  LibuiValidateTest ${?} 1 "(Action) false (PWD: ${TESTDIR})${N}WARNING: (Action) Failure while evaluating command. (false, PWD: ${TESTDIR})"
  return ${?}
}
tests+=( 'test_Action-e_Verbose' )
test_Action-e_Verbose () {
  _vdb=true
  LibuiPerformTest 'Action -e "false"'
  LibuiValidateTest ${?} 1 "(Action) false (PWD: ${TESTDIR})${N}ERROR: (Action) Failure while evaluating command. (false, PWD: ${TESTDIR})"
  return ${?}
}
tests+=( 'test_Action-f_Verbose' )
test_Action-f_Verbose () {
  _vdb=true
  LibuiPerformTest 'Action -f "Test failure." "false"'
  LibuiValidateTest ${?} 1 "(Action) false (PWD: ${TESTDIR})${N}WARNING: (Action) Test failure. (false, PWD: ${TESTDIR})"
  return ${?}
}
tests+=( 'test_Action-i' )
test_Action-i () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Action -i "Test info." "ls -d /tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 "${TJBL}${TAction}Test info.${T}${TCEL} /tmp"
  return ${?}
}
tests+=( 'test_Action-s-i' )
test_Action-s-i () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Action -s -i "Test info." "ls -d /tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest -r "${tv}" 0 '/tmp...*'
  return ${?}
}
tests+=( 'test_Action-q' )
test_Action-q () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Action -q "Test question?" "ls -d /tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 '/tmp'
  return ${?}
}
tests+=( 'test_No_Term_Action-q' )
test_No_Term_Action-q () {
  LibuiPerformTest 'Action -q "Test question?" "ls -d /tmp"'
  LibuiValidateTest ${?} 0 '/tmp'
  return ${?}
}
tests+=( 'test_Action-Cq' )
test_Action-Cq () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Action -C -q "Verify question?" "ls -d /tmp" <<< "yes"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 '(Confirm) Verify question? (y/n) [yes] /tmp'
  return ${?}
}
tests+=( '-X 2 test_Action_Verbose' )
test_Action_Verbose () {
  LibuiPerformTest 'Action "ls -d /tmp"'
  LibuiValidateTest -r ${?} 0 "\(Action\) ls -d /tmp \(PWD: .*\)${N}/tmp"
  return ${?}
}
tests+=( '-X 2 test_Action_Verbose-q' )
test_Action_Verbose-q () {
  LibuiPerformTest 'Action -q "Test question 2." "ls -d /tmp"'
  LibuiValidateTest -r ${?} 0 "\(Action\) ls -d /tmp \(PWD: .*\)${N}/tmp"
  return ${?}
}
tests+=( 'test_Action_Pipe_True' )
test_Action_Pipe_True () {
  LibuiPerformTest 'Action -W "true | wc -w"'
  LibuiValidateTest -r ${?} 0 '\s*0'
  return ${?}
}
tests+=( 'test_Action_Pipe_False' )
test_Action_Pipe_False () {
  LibuiPerformTest 'Action -W "false | wc -w"'
  LibuiValidateTest -r ${?} 1 '\s*0'
  return ${?}
}
tests+=( 'test_Action_Pipe_End' )
test_Action_Pipe_End () {
  LibuiPerformTest 'Action -W -p -1 "false | wc -w"'
  LibuiValidateTest -r ${?} 0 '\s*0'
  return ${?}
}
tests+=( 'test_Action_Pipe_Error' )
test_Action_Pipe_Error () {
  LibuiPerformTest "Action -W -p ${AO} 'false | wc -w'"
  LibuiValidateTest -r ${?} 1 '\s*0'
  return ${?}
}
tests+=( 'test_Action_Open_Log' )
test_Action_Open_Log () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  Action -1 "ls -d /tmp"
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest -r ${?} 0 "ACTION .*: ls -d /tmp${N}/tmp"
  return ${?}
}
tests+=( 'test_Action_Log-a' )
test_Action_Log-a () {
  local lfile; GetTmp -f lfile
  Action -l "${lfile}" "ls -d /tmp"
  Action -l "${lfile}" "ls -d /tmp"
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest -r ${?} 0 "ACTION .*: ls -d /tmp${N}/tmp${N}ACTION .*: ls -d /tmp${N}/tmp"
  return ${?}
}
tests+=( 'test_Action_Log-c' )
test_Action_Log-c () {
  local lfile; GetTmp -f lfile
  Action -l "${lfile}" "ls -d /tmp"
  Action -c -l "${lfile}" "ls -d /tmp"
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest -r ${?} 0 "ACTION .*: ls -d /tmp${N}/tmp"
  return ${?}
}
tests+=( 'test_Action_Log-t' )
test_Action_Log-t () {
  local lfile; GetTmp -f lfile
  Action -t -l "${lfile}" 'ls -d /tmp'
  LibuiPerformTest "Action -t -l '${lfile}' 'ls -d /tmp'; cat '${lfile}'"
  LibuiValidateTest -r ${?} 0 "/tmp${N}ACTION .*: ls -d /tmp${N}/tmp${N}ACTION .*: ls -d /tmp${N}/tmp"
  return ${?}
}
tests+=( 'test_Action_Log-t-c' )
test_Action_Log-t-c () {
  local lfile; GetTmp -f lfile
  Action -c -t -l "${lfile}" 'ls -d /tmp'
  LibuiPerformTest "Action -c -t -l '${lfile}' 'ls -d /tmp'; cat '${lfile}'"
  LibuiValidateTest -r ${?} 0 "/tmp${N}ACTION .*: ls -d /tmp${N}/tmp"
  return ${?}
}
tests+=( 'test_Action_Open_Log-t' )
test_Action_Open_Log-t () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  Action -t -1 'ls -d /tmp'
  LibuiPerformTest "Action -t -1 'ls -d /tmp'; cat '${lfile}'"
  LibuiValidateTest -r ${?} 0 "/tmp${N}ACTION .*: ls -d /tmp${N}/tmp${N}ACTION .*: ls -d /tmp${N}/tmp"
  Close -1
  return ${?}
}
tests+=( 'test_Action-1' )
test_Action-1 () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  Action -1 "ls -d /tmp"
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest -r ${?} 0 "ACTION .*: ls -d /tmp${N}/tmp"
  return ${?}
}
tests+=( 'test_Action_False' )
test_Action_False () {
  _action=false # set action
  LibuiPerformTest 'Action'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Action_True' )
test_Action_True () {
  _action=true # set action
  LibuiPerformTest 'Action'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_Action_Success' )
test_Action_Success () {
  Action "ls -d /tmp"
  LibuiPerformTest 'Action'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_Action-F_Success' )
test_Action-F_Success () {
  Action "ls -d /tmp"
  LibuiPerformTest 'Action -F "ls -d /tmp"'
  LibuiValidateTest ${?} 0 '/tmp'
  return ${?}
}
tests+=( 'test_Action_Failure' )
test_Action_Failure () {
  Action "ls -d /badpath"
  LibuiPerformTest 'Action'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Action-F_Failure' )
test_Action-F_Failure () {
  Action "ls -d /badpath"
  LibuiPerformTest 'Action -F "ls -d /tmp"'
  LibuiValidateTest -r ${?} 2 'WARNING: \(Action\) Skipping due to previous failure: .*'
  return ${?}
}
tests+=( 'test_Action-R-F_Failure' )
test_Action-R-F_Failure () {
  Action "ls -d /badpath"
  LibuiPerformTest 'Action -R -F "ls -d /tmp"'
  LibuiValidateTest ${?} 0 '/tmp'
  return ${?}
}
tests+=( 'test_Action_Reset-F_Failure' )
test_Action_Reset-F_Failure () {
  Action "ls -d /badpath"
  Action -R
  LibuiPerformTest 'Action -F "ls -d /tmp"'
  LibuiValidateTest ${?} 0 '/tmp'
  return ${?}
}

# AddOption [-a|-f|-m|-r|-t] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_var>] [-k <keyword>] [-n <var>] [-p <provided_value>] [-P <path>] [-s <selection_values>] [-S <selection_var>] [-v <callback>] <option>[:]
tests+=( 'test_AddOption-s' )
test_AddOption-s () {
  LibuiPerformTest 'libui -x oA -h'
  LibuiValidateTest -r ${?} 2 '.*-Z *Test A *- Test option A\. \(_Util_optA: \).*'
  return ${?}
}
tests+=( 'test_AddOption-s-a' )
test_AddOption-s-a () {
  LibuiPerformTest 'libui -x oa -h'
  LibuiValidateTest -r ${?} 2 '.*-Z *Test a *- Test option a\. \(_Util_opta: a\).*'
  return ${?}
}
tests+=( 'test_AddOption-s_Bad' )
test_AddOption-s_Bad () {
  LibuiPerformTest 'libui -x os -Z x'
  LibuiValidateTest -r ${?} 2 '.*ERROR: The value provided for -Z \(Test s\) is not an available option value\. \(x\).*'
  return ${?}
}
tests+=( 'test_AddOption-S_Bad' )
test_AddOption-S_Bad () {
  LibuiPerformTest 'libui -x oS -Z a'
  LibuiValidateTest -r ${?} 2 '.*ERROR: The value provided for -Z \(Test S\) is not an available option value\. \(a\).*'
  return ${?}
}
tests+=( 'test_AddOption_Validation' )
test_AddOption_Validation () {
  LibuiPerformTest 'libui -x ov -Z v'
  LibuiValidateTest -r ${?} 0 '.*Validation test\. \(v == v\).*'
  return ${?}
}
tests+=( '-x aot test_AddOption_aot' )
test_AddOption_aot () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*Option test\. \(o: 0, aot\).*'
  return ${?}
}
tests+=( '-x one -x two -x three -x four -x five test_AddOption_Multiple' )
test_AddOption_Multiple () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*Option test\. \(o: 0, one two three four five\).*'
  return ${?}
}
tests+=( 'test_AddOption_default' )
test_AddOption_default () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*Option test\. \(o: 0, X\).*'
  return ${?}
}
tests+=( '-x o test_AddOption-o' )
test_AddOption-o () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*Option test\. \(o: 1, o\).*'
  return ${?}
}
tests+=( 'test_AddOption_No_Debug' )
test_AddOption_No_Debug () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*-X *XDebug *- *Set debug level to specified level\. \(level: 0\).*'
  return ${?}
}
tests+=( '-X 2 test_AddOption_Debug' )
test_AddOption_Debug () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*-X *XDebug *- *Set debug level to specified level\. \(level: 2\).*'
  return ${?}
}
tests+=( '-x b test_AddOption_Binary_false' )
test_AddOption_Binary_false () {
  LibuiPerformTest 'Tell -- "${binaryft}"'
  LibuiValidateTest ${?} 0 'false'
  return ${?}
}
tests+=( '-x b -b test_AddOption-b_Binary_true' )
test_AddOption-b_Binary_true () {
  LibuiPerformTest 'Tell -- "${binaryft}"'
  LibuiValidateTest ${?} 0 'true'
  return ${?}
}
tests+=( '-x B test_AddOption_Binary_true' )
test_AddOption_Binary_true () {
  LibuiPerformTest 'Tell -- "${binarytf}"'
  LibuiValidateTest ${?} 0 'true'
  return ${?}
}
tests+=( '-x B -B test_AddOption-B_Binary_false' )
test_AddOption-B_Binary_false () {
  LibuiPerformTest 'Tell -- "${binarytf}"'
  LibuiValidateTest ${?} 0 'false'
  return ${?}
}

# AddParameter [-a|-m|-r] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_var>] [-k <keyword>] [-n <var>] [-P <path>] [-s <selection_values>] [-S <selection_var>] [-v <callback>] [<var>]
tests+=( 'test_AddParameter' )
test_AddParameter () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*<_Util_param> *- Parameter: Name of the test to perform, package filename, or COMMONROOT directory\. \(_Util_param: test_AddParameter\).*'
  return ${?}
}
tests+=( 'test_AddParameter-s' )
test_AddParameter-s () {
  LibuiPerformTest 'libui -x pA -h'
  LibuiValidateTest -r ${?} 2 '.*<_Util_testparam> *- Test Param: Test parameter A\. \(_Util_testparam: \).*'
  return ${?}
}
tests+=( 'test_AddParameter-s-a' )
test_AddParameter-s-a () {
  LibuiPerformTest 'libui -x pa -h'
  LibuiValidateTest -r ${?} 2 '.*<_Util_testparam> *- Test Param: Test parameter a\. \(_Util_testparam: a\).*'
  return ${?}
}
tests+=( 'test_AddParameter-s_Bad' )
test_AddParameter-s_Bad () {
  LibuiPerformTest 'libui -x ps x'
  LibuiValidateTest -r ${?} 2 '.*ERROR: The value provided for _Util_testparam \(Test Param\) is not an available parameter value\. \(x\).*'
  return ${?}
}
tests+=( 'test_AddParameter-S_Bad' )
test_AddParameter-S_Bad () {
  LibuiPerformTest 'libui -x pS a'
  LibuiValidateTest -r ${?} 2 '.*ERROR: The value provided for _Util_testparam \(Test Param\) is not an available parameter value\. \(a\).*'
  return ${?}
}
tests+=( 'test_AddParameter_Validation' )
test_AddParameter_Validation () {
  LibuiPerformTest 'libui -x pv v'
  LibuiValidateTest -r ${?} 0 '.*Validation test\. \(v == v\).*'
  return ${?}
}
tests+=( 'test_AddParameter_Missing' )
test_AddParameter_Missing () {
  LibuiPerformTest 'libui -p'
  LibuiValidateTest -r ${?} 2 '.*ERROR: Missing parameter\. \(.*\).*'
  return ${?}
}
tests+=( 'errout_AddParameter_Too_Many too many' )
errout_AddParameter_Too_Many () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 1 '.*ERROR in .*: \(AddParameter\) Too many parameters provided\. \(too many\).*'
  return ${?}
}
tests+=( '-x p test_AddParameter_Multiple two three' )
test_AddParameter_Multiple () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*<_Util_param> *- Parameter: Name of the test to perform, package filename, or COMMONROOT directory\. \(_Util_param: test_AddParameter_Multiple.* two.* three\).*'
  return ${?}
}

# Alert [-1..-9|-a|-c] [-l <file_path>] <message_text>
tests+=( 'test_Alert' )
test_Alert () {
  LibuiPerformTest 'Alert "Test Alert command."'
  LibuiValidateTest ${?} 0 'Test Alert command.'
  return ${?}
}
tests+=( 'test_Alert_Log-a' )
test_Alert_Log-a () {
  local lfile; GetTmp -f lfile
  Alert -l "${lfile}" "Alert test 1."
  Alert -l "${lfile}" "Alert test 2."
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "ALERT: Alert test 1.${N}ALERT: Alert test 2."
  return ${?}
}
tests+=( 'test_Alert_Log-c' )
test_Alert_Log-c () {
  local lfile; GetTmp -f lfile
  Alert -c -l "${lfile}" "Alert test 1."
  Alert -c -l "${lfile}" "Alert test 2."
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "ALERT: Alert test 2."
  return ${?}
}
tests+=( 'test_Alert-1' )
test_Alert-1 () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  Alert -1 "Test Alert log file."
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "ALERT: Test Alert log file."
  return ${?}
}

# AnswerMatches <string>
tests+=( 'test_AnswerMatches_Auto_Yes' )
test_AnswerMatches_Auto_Yes () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  Ask 'Test AnswerMatches yes command?'
  Yes -E
  TERMINAL="${t}"
  LibuiPerformTest 'AnswerMatches y'
  LibuiValidateTest ${?} 0 ''
  return ${?}
}
tests+=( 'test_AnswerMatches_Auto_X' )
test_AnswerMatches_Auto_X () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  Ask 'Test AnswerMatches X command?'
  Yes -E
  TERMINAL="${t}"
  LibuiPerformTest 'AnswerMatches X'
  LibuiValidateTest ${?} 1 ''
  return ${?}
}
tests+=( 'test_AnswerMatches_Match' )
test_AnswerMatches_Match () {
  ANSWER='yes'
  LibuiPerformTest 'AnswerMatches y'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_AnswerMatches_Nomatch' )
test_AnswerMatches_Nomatch () {
  ANSWER='no'
  LibuiPerformTest 'AnswerMatches y'
  LibuiValidateTest ${?} 1
  return ${?}
}

# Verify [-C|-N|-Y] [-d <default>] [-n <varname>] [-r <required>] <question_text>
tests+=( 'test_Verify' )
test_Verify () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify "Test verify?" <<< "yes"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] '
  return ${?}
}
tests+=( 'test_Verify_no' )
test_Verify_no () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify "Test verify?" <<< "no"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 1 'Test verify? (y/n) [yes] '
  return ${?}
}
tests+=( 'test_Verify-C' )
test_Verify-C () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify -C "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-C test_C_Verify-C' )
test_C_Verify-C () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify -C "Test verify?" <<< "yes"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] '
  return ${?}
}
tests+=( '-C test_C_No_Term_Verify-C' )
test_C_No_Term_Verify-C () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Verify -C "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] yes'
  return ${?}
}
tests+=( '-Y test_Y_Verify' )
test_Y_Verify () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] yes'
  return ${?}
}
tests+=( '-Y test_Y_No_Term_Verify' )
test_Y_No_Term_Verify () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Verify "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] yes'
  return ${?}
}
tests+=( 'test_No_Term_Verify' )
test_No_Term_Verify () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Verify "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] yes'
  return ${?}
}
tests+=( 'test_No_Term_Verify-N' )
test_No_Term_Verify-N () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Verify -N "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 1 'Test verify? (y/n) [no] no'
  return ${?}
}
tests+=( 'test_No_Term_Verify-d_no' )
test_No_Term_Verify-d_no () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Verify -d "no" "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 1 'Test verify? (y/n) [no] no'
  return ${?}
}
tests+=( 'test_Verify_False' )
test_Verify_False () {
  LibuiPerformTest 'Verify'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Verify_True' )
test_Verify_True () {
  _verify=true # set verify
  LibuiPerformTest 'Verify'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_Verify_Success' )
test_Verify_Success () {
  local t="${TERMINAL}"
  TERMINAL=true
  Verify "Test verify?" <<< "yes"
  TERMINAL="${t}"
  LibuiPerformTest 'Verify'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_Verify_Failure' )
test_Verify_Failure () {
  local t="${TERMINAL}"
  TERMINAL=true
  Verify "Test verify?" <<< "no"
  TERMINAL="${t}"
  LibuiPerformTest 'Verify'
  LibuiValidateTest ${?} 1
  return ${?}
}

# Ask [-b|-C|-z] [-d <default>] [-n <varname>] [-P <path>] [-r <required>] [-s <selection_value>] [-S <selection_var>] <question_text>
tests+=( 'test_Ask' )
test_Ask () {
  local t="${TERMINAL}"
  TERMINAL=true
  Ask 'Test question?' <<< 'answer'
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  LibuiValidateTest ${?} 0 'The answer is: answer'
  return ${?}
}
tests+=( 'test_Ask-b' )
test_Ask-b () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Ask -b "Test boolean?" <<< "yes"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test boolean? (y/n) [] '
  return ${?}
}
tests+=( 'test_Ask_Select_Value_Text' )
test_Ask_Select_Value_Text () {
  local t="${TERMINAL}"
  TERMINAL=true
  Ask -s one -s two -s three 'Test question?' <<< 'two'
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  LibuiValidateTest ${?} 0 'The answer is: two'
  return ${?}
}
tests+=( 'test_Ask_Select_Value_Number' )
test_Ask_Select_Value_Number () {
  local t="${TERMINAL}"
  TERMINAL=true
  Ask -s one -s two -s three 'Test question?' <<< '3'
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  LibuiValidateTest ${?} 0 'The answer is: three'
  return ${?}
}
tests+=( 'test_Ask_Select_Var_Text' )
test_Ask_Select_Var_Text () {
  local select; select=( one two three )
  local t="${TERMINAL}"
  TERMINAL=true
  Ask -S select 'Test question?' <<< 'two'
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  LibuiValidateTest ${?} 0 'The answer is: two'
  return ${?}
}
tests+=( 'test_Ask_Select_Var_Number' )
test_Ask_Select_Var_Number () {
  local select; select=( one two three )
  local t="${TERMINAL}"
  TERMINAL=true
  Ask -S select 'Test question?' <<< '3'
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  LibuiValidateTest ${?} 0 'The answer is: three'
  return ${?}
}
tests+=( 'test_Ask_Yes' )
test_Ask_Yes () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  LibuiPerformTest 'Ask "Test Ask command?"'
  Yes -E
  TERMINAL="${t}"
  LibuiValidateTest ${?} 0 'Test Ask command? [yes] yes'
  return ${?}
}
tests+=( '-C test_Ask_Confirm_True' )
test_Ask_Confirm_True () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  LibuiPerformTest 'Ask -C "Test Ask -C with Confirm true?"'
  Yes -E
  TERMINAL="${t}"
  LibuiValidateTest ${?} 0 'Test Ask -C with Confirm true? [yes] yes'
  return ${?}
}
tests+=( 'test_Ask_Confirm_False' )
test_Ask_Confirm_False () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  LibuiPerformTest 'Ask -C "Test Ask -C with Confirm false?"'
  Yes -E
  TERMINAL="${t}"
  LibuiValidateTest ${?} 0 ''
  return ${?}
}
tests+=( 'test_Ask_Default' )
test_Ask_Default () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  LibuiPerformTest 'Ask -d "default" "Test Ask with default?"'
  Yes -E
  TERMINAL="${t}"
  LibuiValidateTest ${?} 0 'Test Ask with default? [default] default'
  return ${?}
}
tests+=( 'test_Ask_ANSWER' )
test_Ask_ANSWER () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  Ask -d 'default answer' -n testvar 'Test Ask with testvar?'
  Yes -E
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "Test variable: ${ANSWER}."'
  LibuiValidateTest ${?} 0 'Test variable: default answer.'
  return ${?}
}
tests+=( 'test_Ask_Variable' )
test_Ask_Variable () {
  local t="${TERMINAL}"
  TERMINAL=true
  Yes -e
  Ask -d 'default variable' -n testvar 'Test Ask with testvar?'
  Yes -E
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "Test variable: ${testvar}."'
  LibuiValidateTest ${?} 0 'Test variable: default variable.'
  return ${?}
}
tests+=( 'test_Ask-z' )
test_Ask-z () {
  Ask -z 'Test question?' <<< ''
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  LibuiValidateTest ${?} 0 'The answer is: '
  return ${?}
}
tests+=( 'test_Ask-z_Answer' )
test_Ask-z_Answer () {
  Ask -z 'Test question?' <<< 'answer'
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  LibuiValidateTest ${?} 0 'The answer is: '
  return ${?}
}
tests+=( 'test_No_Term_Ask' )
test_No_Term_Ask () {
  local t="${TERMINAL}"
  TERMINAL=false
  _exitcleanup=false
  LibuiPerformTest 'Ask "Test Ask command?"'
  local tv=${?}
  _exitcleanup=true
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 1 "ERROR: (Ask) Question asked without a terminal, no default, and a response required."
  return ${?}
}
tests+=( '-C test_C_No_Term_Ask_Confirm_True' )
test_C_No_Term_Ask_Confirm_True () {
  local t="${TERMINAL}"
  TERMINAL=false
  Yes -e
  LibuiPerformTest 'Ask -C "Test No Term Ask -C with Confirm true?"'
  local tv=${?}
  Yes -E
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test No Term Ask -C with Confirm true? [yes] yes'
  return ${?}
}
tests+=( 'test_No_Term_Ask_Confirm_False' )
test_No_Term_Ask_Confirm_False () {
  local t="${TERMINAL}"
  TERMINAL=false
  Yes -e
  LibuiPerformTest 'Ask -C "Test No Term Ask -C with Confirm false?"'
  local tv=${?}
  Yes -E
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 ''
  return ${?}
}
tests+=( 'test_No_Term_Ask_Default' )
test_No_Term_Ask_Default () {
  local t="${TERMINAL}"
  TERMINAL=false
  Yes -e
  LibuiPerformTest 'Ask -d "default" "Test Ask with default?"'
  local tv=${?}
  Yes -E
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test Ask with default? [default] default'
  return ${?}
}
tests+=( 'test_No_Term_Ask-z' )
test_No_Term_Ask-z () {
  local t="${TERMINAL}"
  TERMINAL=false
  Ask -z 'Test question?' <<< ''
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'The answer is: '
  return ${?}
}
tests+=( 'test_No_Term_Ask-z_Answer' )
test_No_Term_Ask-z_Answer () {
  local t="${TERMINAL}"
  TERMINAL=false
  Ask -z 'Test question?' <<< 'answer'
  LibuiPerformTest 'Tell "The answer is: %s" "${ANSWER}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'The answer is: '
  return ${?}
}

# Confirm
tests+=( 'test_Confirm_False' )
test_Confirm_False () {
  LibuiPerformTest 'Confirm'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Confirm_True' )
test_Confirm_True () {
  _confirm=true # set confirm
  LibuiPerformTest 'Confirm'
  local tv=${?}
  _confirm=false # reset confirm
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-C test_Confirm-C' )
test_Confirm-C () {
  LibuiPerformTest 'Confirm'
  local tv=${?}
  _confirm=false # reset confirm
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-C test_C_Confirm_Action-q' )
test_C_Confirm_Action-q () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Action -q "Confirm question?" "ls -d /tmp" <<< "yes"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 '(Confirm) Confirm question? (y/n) [yes] /tmp'
  return ${?}
}
tests+=( '-C test_C_Confirm_Verify' )
test_C_Confirm_Verify () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify "Test verify?" <<< "yes"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] '
  return ${?}
}
tests+=( '-C test_C_Confirm_Verify-C' )
test_C_Confirm_Verify-C () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify -C "Test verify?" <<< "yes"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] '
  return ${?}
}
tests+=( '-C test_C_Confirm_No_Term_Verify-C' )
test_C_Confirm_No_Term_Verify-C () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Verify -C "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] yes'
  return ${?}
}
tests+=( 'test_Confirm_FMFLAG' )
test_Confirm_FMFLAG () {
  LibuiPerformTest 'Tell "Test confirm FMFLAGS: %s." "${FMFLAGS}"'
  LibuiValidateTest ${?} 0 'Test confirm FMFLAGS: .'
  return ${?}
}
tests+=( '-C test_Confirm_FMFLAG-C' )
test_Confirm_FMFLAG-C () {
  LibuiPerformTest 'Tell "Test confirm -C FMFLAGS: %s." "${FMFLAGS}"'
  LibuiValidateTest ${?} 0 'Test confirm -C FMFLAGS: -i.'
  return ${?}
}

# ConfirmVar [-A|-d|-e|-f|-n|-z] [-D <default>] [-P <path>] [-q|-Q <question>] [-s <selection_value>] [-S <selection_var>] <variable> ...
tests+=( 'test_ConfirmVar-n_Question' )
test_ConfirmVar-n_Question () {
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  ConfirmVar -q 'Test question?' -n response <<< '/tmp'
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "The value is: %s" "${response}"'
  LibuiValidateTest ${?} 0 'The value is: /tmp'
  return ${?}
}
tests+=( 'test_ConfirmVar-nz_Question' )
test_ConfirmVar-nz_Question () {
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  ConfirmVar -q 'Test question?' -z -n response <<< ''
  TERMINAL="${t}"
  LibuiPerformTest 'Tell "The value is: %s" "${response}"'
  LibuiValidateTest ${?} 0 'The value is: '
  return ${?}
}
tests+=( 'test_ConfirmVar-n_Empty_Question' )
test_ConfirmVar-n_Empty_Question () {
  unset response
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'ConfirmVar -q "Empty question?" -n response <<< "/tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Empty question? [] '
  return ${?}
}
tests+=( 'test_ConfirmVar-n_Empty_Question-Q' )
test_ConfirmVar-n_Empty_Question-Q () {
  unset response
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'ConfirmVar -Q "Empty question?" -n response <<< "/tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Empty question? [] '
  return ${?}
}
tests+=( 'test_ConfirmVar-n_Full_Question' )
test_ConfirmVar-n_Full_Question () {
  response='/tmp'
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'ConfirmVar -q "Full question?" -n response'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 ''
  return ${?}
}
tests+=( 'test_ConfirmVar-n_Full_Question-Q' )
test_ConfirmVar-n_Full_Question-Q () {
  response='/tmp'
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'ConfirmVar -Q "Full question?" -n response <<< "/tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Full question? [/tmp] '
  return ${?}
}
tests+=( 'test_ConfirmVar-d_Question' )
test_ConfirmVar-d_Question () {
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  LibuiPerformTest "ConfirmVar -q 'Directory question?' -d response <<< '/tmp'"
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Directory question? [] '
  return ${?}
}
tests+=( 'test_ConfirmVar_Select_Var_Number' )
test_ConfirmVar_Select_Var_Number () {
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  testlist=( 'one' 'two' 'three' )
  LibuiPerformTest 'ConfirmVar -S testlist -q "Test question?" response <<< "2"; printf "%s\n" "${response}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest ${tv} 0 "${N}The possible responses are:${N}   1. one${N}   2. two${N}   3. three${N}${N}Test question? [] two"
  return ${?}
}
tests+=( 'test_ConfirmVar_Select_Value_Text' )
test_ConfirmVar_Select_Value_Text () {
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  LibuiPerformTest 'ConfirmVar -s one -s two -s three -q "Test question?" response <<< "two"; printf "%s\n" "${response}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest ${tv} 0 "${N}The possible responses are:${N}   1. one${N}   2. two${N}   3. three${N}${N}Test question? [] two"
  return ${?}
}
tests+=( 'test_ConfirmVar_Default_Select_Var' )
test_ConfirmVar_Default_Select_Var () {
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  testlist=( 'one' 'two' 'three' )
  LibuiPerformTest 'ConfirmVar -S testlist -q "Test question?" -D "three" response <<< ""; printf "%s\n" "${response}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest ${tv} 0 "${N}The possible responses are:${N}   1. one${N}   2. two${N}   3. three${N}${N}Test question? [three] three"
  return ${?}
}
tests+=( 'test_ConfirmVar_Single_Select_Value' )
test_ConfirmVar_Single_Select_Value () {
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  LibuiPerformTest 'ConfirmVar -s one -q "Test question?" response <<< ""; printf "%s\n" "${response}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest ${tv} 0 "${N}The possible responses are:${N}   1. one${N}${N}Test question? [one] one"
  return ${?}
}
tests+=( 'test_ConfirmVar_File_Select_Value_Text' )
test_ConfirmVar_File_Select_Value_Text () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  LibuiPerformTest 'ConfirmVar -f -s "${TESTDIR}/listfile-1" -s "${TESTDIR}/listfile 2" -q "Test question?" -P "${TESTDIR}" response <<< "listfile 2"; printf "%s\n" "${response}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest ${tv} 0 "${N}The possible responses are:${N}   1. listfile-1${N}   2. listfile 2${N}${N}Test question? [] ${TESTDIR}/listfile 2"
  return ${?}
}
tests+=( 'test_ConfirmVar_Dir_Select_Var_Number' )
test_ConfirmVar_Dir_Select_Var_Number () {
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  GetFileList -d testlist "${TESTDIR}/list*"
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  LibuiPerformTest 'ConfirmVar -d -S testlist -q "Test question?" -P "${TESTDIR}" response <<< "2"; printf "%s\n" "${response}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest ${tv} 0 "${N}The possible responses are:${N}   1. listdir 2${N}   2. listdir-1${N}${N}Test question? [] ${TESTDIR}/listdir-1"
  return ${?}
}
tests+=( 'test_ConfirmVar_File_Select_Alt' )
test_ConfirmVar_File_Select_Alt () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "touch ${TESTDIR}/listdir-1/testfile\ 1"
  GetFileList -f testlist "${TESTDIR}/list*"
  local t="${TERMINAL}"
  TERMINAL=true
  unset response
  LibuiPerformTest 'ConfirmVar -f -S testlist -q "Test question?" -P "${TESTDIR}" response <<< "${TESTDIR}/listdir-1/testfile 1"; printf "%s\n" "${response}"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest ${tv} 0 "${N}The possible responses are:${N}   1. listfile 2${N}   2. listfile-1${N}${N}Test question? [] ${TESTDIR}/listdir-1/testfile 1"
  return ${?}
}
tests+=( 'test_ConfirmVar_Undef' )
test_ConfirmVar_Undef () {
  unset response
  _exitcleanup=false
  LibuiPerformTest 'ConfirmVar response'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 'ERROR: The variable "response" is required but not defined.'
  return ${?}
}
tests+=( 'test_No_Term_ConfirmVar_Undef' )
test_No_Term_ConfirmVar_Undef () {
  local t="${TERMINAL}"
  TERMINAL=false
  unset noterm
  LibuiPerformTest 'ConfirmVar noterm'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 1 'ERROR: The variable "noterm" is required but not defined.'
  return ${?}
}
tests+=( 'test_ConfirmVar_Undef_Debug' )
test_ConfirmVar_Undef_Debug () {
  unset response
  local x=%{_xdb}
  _xdb=1
  LibuiPerformTest 'ConfirmVar response'
  local tv=${?}
  _xdb="${x}"
  LibuiValidateTest -r "${tv}" 1 'ERROR in .*: The variable "response" is required but not defined.'
  return ${?}
}
tests+=( 'test_No_Term_ConfirmVar_Undef_Debug' )
test_No_Term_ConfirmVar_Undef_Debug () {
  local t="${TERMINAL}"
  TERMINAL=false
  unset noterm
  local x=%{_xdb}
  _xdb=1
  LibuiPerformTest 'ConfirmVar noterm'
  local tv=${?}
  _xdb="${x}"
  TERMINAL="${t}"
  LibuiValidateTest -r "${tv}" 1 'ERROR in .*: The variable "noterm" is required but not defined.'
  return ${?}
}
tests+=( 'test_ConfirmVar_HOME' )
test_ConfirmVar_HOME () {
  LibuiPerformTest 'ConfirmVar HOME'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_ConfirmVar-n_HOME' )
test_ConfirmVar-n_HOME () {
  LibuiPerformTest 'ConfirmVar -n HOME'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_ConfirmVar-A_AA' )
test_ConfirmVar-A_AA () {
  if ${AA}
  then
    typeset -A testvar
    testvar['array']='test'
    LibuiPerformTest 'ConfirmVar -A testvar'
    LibuiValidateTest ${?} 0
  else
    Warn -r 33 'Associative arrays are not supported in %s. (%s)' "${SHELL}" "${BASH_VERSION}"
  fi
  return ${?}
}
tests+=( 'test_ConfirmVar-A_Array' )
test_ConfirmVar-A_Array () {
  testvar=( 'test' )
  _exitcleanup=false
  LibuiPerformTest 'ConfirmVar -A testvar'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 'ERROR: The variable "testvar" is not an associative array.'
  return ${?}
}
tests+=( 'test_ConfirmVar-A_String' )
test_ConfirmVar-A_String () {
  testvar='test'
  _exitcleanup=false
  LibuiPerformTest 'ConfirmVar -A testvar'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 'ERROR: The variable "testvar" is not an associative array.'
  return ${?}
}
tests+=( 'test_ConfirmVar-d_tmp' )
test_ConfirmVar-d_tmp () {
  testvar='/tmp'
  LibuiPerformTest 'ConfirmVar -d testvar'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_ConfirmVar-d_tmp2' )
test_ConfirmVar-d_tmp2 () {
  testvar='/tmp2'
  _exitcleanup=false
  LibuiPerformTest 'ConfirmVar -d testvar'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 'ERROR: The directory "/tmp2" does not exist. (testvar)'
  return ${?}
}
tests+=( 'test_ConfirmVar-e_cvfile' )
test_ConfirmVar-e_cvfile () {
  Action -W "touch ${TESTDIR}/cvfile"
  testvar="${TESTDIR}/cvfile"
  LibuiPerformTest 'ConfirmVar -e testvar'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_ConfirmVar-e_Empty' )
test_ConfirmVar-e_Empty () {
  testvar="${TESTDIR}/invalid-cvfile"
  _exitcleanup=false
  LibuiPerformTest 'ConfirmVar -e testvar'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 "ERROR: The path \"${TESTDIR}/invalid-cvfile\" does not exist. (testvar)"
  return ${?}
}
tests+=( 'test_ConfirmVar-f_cvfile' )
test_ConfirmVar-f_cvfile () {
  Action -W "touch ${TESTDIR}/cvfile"
  testvar="${TESTDIR}/cvfile"
  LibuiPerformTest 'ConfirmVar -f testvar'
  LibuiValidateTest ${?} 0 ''
  return ${?}
}
tests+=( 'test_ConfirmVar-f_Empty' )
test_ConfirmVar-f_Empty () {
  testvar="${TESTDIR}/invalid-cvfile"
  _exitcleanup=false
  LibuiPerformTest 'ConfirmVar -f testvar'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 "ERROR: The file \"${TESTDIR}/invalid-cvfile\" does not exist. (testvar)"
  return ${?}
}

# Error [-1..-9|-a|-c|-e|-E|-L] [-l <file_path>] [-r <retval>] <error_message>
tests+=( 'test_Error' )
test_Error () {
  _exitcleanup=false
  LibuiPerformTest 'Error "Test Error command."'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 "ERROR: Test Error command."
  return ${?}
}
tests+=( 'test_Error-E' )
test_Error-E () {
  LibuiPerformTest 'Error -E -r 5 "Test Error -E -r 5 command."'
  LibuiValidateTest ${?} 5 "ERROR: Test Error -E -r 5 command."
  return ${?}
}
tests+=( 'test_Error-e' )
test_Error-e () {
  LibuiPerformTest 'Error -e "Test Error -e command."'
  LibuiValidateTest ${?} 1 "ERROR: Test Error -e command."
  return ${?}
}
tests+=( 'test_Error-r' )
test_Error-r () {
  _exitcleanup=false
  LibuiPerformTest 'Error -r 5 "Test Error -r 5 command."'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 5 "ERROR: Test Error -r 5 command."
  return ${?}
}
tests+=( 'test_Error_Log-a' )
test_Error_Log-a () {
  local lfile; GetTmp -f lfile
  _exitcleanup=false
  _init=true
  Error -l "${lfile}" "Error test 1."
  Error -l "${lfile}" "Error test 2."
  _init=false
  _exitcleanup=true
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "ERROR: Error test 1.${N}ERROR: Error test 2."
  return ${?}
}
tests+=( 'test_Error_Log-c' )
test_Error_Log-c () {
  local lfile; GetTmp -f lfile
  _exitcleanup=false
  _init=true
  Error -c -l "${lfile}" "Error test 1."
  Error -c -l "${lfile}" "Error test 2."
  _init=false
  _exitcleanup=true
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "ERROR: Error test 2."
  return ${?}
}
tests+=( 'test_Error-1' )
test_Error-1 () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  _exitcleanup=false
  _init=true
  Error -1 "Test Error log file."
  _init=false
  _exitcleanup=true
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "ERROR: Test Error log file."
  return ${?}
}

# Force
tests+=( 'test_Force_False' )
test_Force_False () {
  LibuiPerformTest 'Force'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Force_True' )
test_Force_True () {
  _force=true # set force
  LibuiPerformTest 'Force'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_Force_FMFLAG' )
test_Force_FMFLAG () {
  LibuiPerformTest 'Tell "Test force FMFLAGS: %s." "${FMFLAGS}"'
  LibuiValidateTest ${?} 0 'Test force FMFLAGS: .'
  return ${?}
}
tests+=( '-F test_Force-F' )
test_Force-F () {
  LibuiPerformTest 'Force'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( '-F test_Force_FMFLAG-F' )
test_Force_FMFLAG-F () {
  LibuiPerformTest 'Tell "Test force -F FMFLAGS: %s." "${FMFLAGS}"'
  LibuiValidateTest ${?} 0 'Test force -F FMFLAGS: -f.'
  return ${?}
}

# GetFileList [-d|-e|-f|-n|-p|-r|-w] <name_of_array_variable> <file_specification> ...
tests+=( 'test_GetFileList_Error' )
test_GetFileList_Error () {
  local rp
  _exitcleanup=false
  LibuiPerformTest 'GetFileList rp'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(GetFileList\) Called without a variable name and file specification\."
  return ${?}
}
tests+=( 'test_GetFileList' )
test_GetFileList () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  LibuiPerformTest "GetFileList testlist '${TESTDIR}/list*'"
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_GetFileList_Show' )
test_GetFileList_Show () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  LibuiPerformTest "GetFileList -f testlist '${TESTDIR}/list*'; Tell -- '%s' \"\${testlist[*]}\""
  LibuiValidateTest ${?} 0 "${TESTDIR}/listfile 2 ${TESTDIR}/listfile-1"
  return ${?}
}
tests+=( 'test_GetFileList_Multiple' )
test_GetFileList_Multiple () {
  Action -W "touch ${TESTDIR}/.listfile-0"
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "touch ${TESTDIR}/.listfile-3"
  LibuiPerformTest "GetFileList -f testlist '${TESTDIR}/.??*' '${TESTDIR}/list*'"
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_GetFileList_Multiple_Show' )
test_GetFileList_Multiple_Show () {
  Action -W "touch ${TESTDIR}/.listfile-0"
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "touch ${TESTDIR}/.listfile-3"
  LibuiPerformTest "GetFileList -f testlist '${TESTDIR}/.??*' '${TESTDIR}/list*'; Tell -- '%s' \"\${testlist[*]}\""
  LibuiValidateTest ${?} 0 "${TESTDIR}/.listfile-0 ${TESTDIR}/.listfile-3 ${TESTDIR}/listfile 2 ${TESTDIR}/listfile-1"
  return ${?}
}
tests+=( 'test_GetFileList-f' )
test_GetFileList-f () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  LibuiPerformTest "GetFileList -f testlist '${TESTDIR}/list*'; Tell -- '%s' \"\${testlist[*]}\""
  LibuiValidateTest ${?} 0 "${TESTDIR}/listfile 2 ${TESTDIR}/listfile-1"
  return ${?}
}
tests+=( 'test_GetFileList-f-n' )
test_GetFileList-f-n () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  LibuiPerformTest "GetFileList -f -n testlist '${TESTDIR}/list*'; Tell -- '%s' \"\${testlist[*]}\""
  LibuiValidateTest ${?} 0 "listfile 2 listfile-1"
  return ${?}
}
tests+=( 'test_GetFileList-d' )
test_GetFileList-d () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  LibuiPerformTest "GetFileList -d testlist '${TESTDIR}/list*'; Tell -- '%s' \"\${testlist[*]}\""
  LibuiValidateTest ${?} 0 "${TESTDIR}/listdir 2 ${TESTDIR}/listdir-1"
  return ${?}
}
tests+=( 'test_GetFileList-d-p' )
test_GetFileList-d-p () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  LibuiPerformTest "GetFileList -d -p testlist '${TESTDIR}/list*'; Tell -- '%s' \"\${testlist[*]}\""
  LibuiValidateTest ${?} 0 "${TESTDIR}"
  return ${?}
}
tests+=( 'test_GetFileList-r' )
test_GetFileList-r () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  Action -W "touch ${TESTDIR}/listdir-1/dirfile-1"
  Action -W "touch ${TESTDIR}/listdir-1/dirfile\ 2"
  LibuiPerformTest "GetFileList -r testlist '${TESTDIR}/list*'"
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_GetFileList-r_Show' )
test_GetFileList-r_Show () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  Action -W "touch ${TESTDIR}/listdir-1/dirfile-1"
  Action -W "touch ${TESTDIR}/listdir-1/dirfile\ 2"
  Action -W "touch ${TESTDIR}/listdir-1/testfile\ 1"
  LibuiPerformTest "GetFileList -r testlist '${TESTDIR}/list*'; Tell -- '%s' \"\${testlist[*]}\""
  LibuiValidateTest ${?} 0 "${TESTDIR}/listdir 2 ${TESTDIR}/listdir-1 ${TESTDIR}/listfile 2 ${TESTDIR}/listfile-1 ${TESTDIR}/listdir-1/dirfile 2 ${TESTDIR}/listdir-1/dirfile-1 ${TESTDIR}/listdir-1/testfile 1"
  return ${?}
}
tests+=( 'test_GetFileList_Empty_Warn' )
test_GetFileList_Empty_Warn () {
  _exitcleanup=false
  LibuiPerformTest "GetFileList -w testlist '${TESTDIR}/invalid*'"
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 2 "WARNING: \(GetFileList\) No file found\. \(.*\)"
  return ${?}
}
tests+=( 'test_GetFileList_Empty_Error' )
test_GetFileList_Empty_Error () {
  _exitcleanup=false
  LibuiPerformTest "GetFileList -e testlist '${TESTDIR}/invalid*'"
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 2 "ERROR: \(GetFileList\) No file found\. \(.*\)"
  return ${?}
}
tests+=( 'test_GetFileList_Empty' )
test_GetFileList_Empty () {
  LibuiPerformTest "GetFileList testlist '${TESTDIR}/invalid*'"
  LibuiValidateTest ${?} 2
  return ${?}
}
tests+=( 'test_GetFileList_Empty_Show' )
test_GetFileList_Empty_Show () {
  LibuiPerformTest "GetFileList testlist '${TESTDIR}/invalid*'; Tell -- '%s' \"\${testlist}\""
  LibuiValidateTest ${?} 0
  return ${?}
}

# GetRealPath [-d] <name_of_variable_to_save_path_into> <path_specification>
tests+=( 'test_GetRealPath_Error' )
test_GetRealPath_Error () {
  local rp
  _exitcleanup=false
  LibuiPerformTest 'GetRealPath rp /usr /bin'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(GetRealPath\) Invalid parameter count\."
  return ${?}
}
tests+=( 'test_GetRealPath_d' )
test_GetRealPath_d () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp=file
  local td
  GetTmp td
  cd ${td}
  GetRealPath -d rp
  cd -
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}/file"
  return ${?}
}
tests+=( 'test_GetRealPath' )
test_GetRealPath () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp=file
  local td
  GetTmp td
  Action -W "touch ${td}/file"
  cd ${td}
  GetRealPath rp
  cd -
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}/file"
  return ${?}
}
tests+=( 'test_GetRealPath_Empty' )
test_GetRealPath_Empty () {
  local rp
  local td
  GetTmp td
  cd ${td}
  _exitcleanup=false
  LibuiPerformTest 'GetRealPath rp'
  local tv=${?}
  _exitcleanup=true
  cd -
  LibuiValidateTest "${tv}" 1 "ERROR: (GetRealPath) No path provided. (rp)"
  return ${?}
}
tests+=( 'test_GetRealPath_d_Bad' )
test_GetRealPath_d_Bad () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp
  local td
  GetTmp td
  cd ${td}
  _exitcleanup=false
  LibuiPerformTest 'GetRealPath -d rp badpath/file'
  local tv=${?}
  _exitcleanup=true
  cd -
  LibuiValidateTest "${tv}" 1 "ERROR: (GetRealPath) Invalid path provided. (badpath)"
  return ${?}
}
tests+=( 'test_GetRealPath_Bad' )
test_GetRealPath_Bad () {
  local rp
  _exitcleanup=false
  LibuiPerformTest 'GetRealPath rp /badpath'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest "${tv}" 1 "ERROR: (GetRealPath) Invalid path provided. (/badpath)"
  return ${?}
}
tests+=( 'test_GetRealPath_Dir' )
test_GetRealPath_Dir () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp
  local td
  GetTmp td
  GetRealPath rp ${td}
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}"
  return ${?}
}
tests+=( 'test_GetRealPath_.' )
test_GetRealPath_. () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp
  local td
  GetTmp td
  cd ${td}
  GetRealPath rp .
  cd -
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}"
  return ${?}
}
tests+=( 'test_GetRealPath_File' )
test_GetRealPath_File () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp
  local td
  GetTmp td
  Action -W "touch ${td}/filepath"
  GetRealPath rp ${td}/filepath
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}/filepath"
  return ${?}
}
tests+=( 'test_GetRealPath_Symlink_DirFile' )
test_GetRealPath_Symlink_DirFile () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp
  local td
  GetTmp td
  Action -W "mkdir ${td}/pathdir"
  Action -W "touch ${td}/pathdir/filepath2"
  Action -W "ln -s ${td}/pathdir ${td}/dirlink"
  GetRealPath rp ${td}/dirlink/filepath2
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}/pathdir/filepath2"
  return ${?}
}
tests+=( 'test_GetRealPath_Symlink_EndDir' )
test_GetRealPath_Symlink_EndDir () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp
  local td
  GetTmp td
  Action -W "mkdir ${td}/pathdir2"
  Action -W "mkdir ${td}/pathdir2/enddir"
  Action -W "ln -s ${td}/pathdir2/enddir ${td}/dirlink2"
  GetRealPath rp ${td}/dirlink2
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}/pathdir2/enddir"
  return ${?}
}
tests+=( 'test_GetRealPath_Symlink_EndFile' )
test_GetRealPath_Symlink_EndFile () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local rp
  local td
  GetTmp td
  Action -W "mkdir ${td}/pathdir3"
  Action -W "touch ${td}/pathdir3/filepath3"
  Action -W "ln -s ${td}/pathdir3/filepath3 ${td}/filelink3"
  GetRealPath rp ${td}/filelink3
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}${td}/pathdir3/filepath3"
  return ${?}
}
tests+=( 'test_GetRealPath_HomeDir' )
test_GetRealPath_HomeDir () {
  local mp="${HOME}/.libui"
  local rp='~/.libui'
  GetRealPath rp
  LibuiPerformTest 'Tell -- "${rp}"'
  LibuiValidateTest ${?} 0 "${mp}"
  return ${?}
}

# GetTmp [-f|-s] <var_name>
tests+=( 'test_GetTmp_Error' )
test_GetTmp_Error () {
  _exitcleanup=false
  LibuiPerformTest 'GetTmp'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(GetTmp\) Called without a variable name\."
  return ${?}
}
tests+=( 'test_GetTmp' )
test_GetTmp () {
  local td
  GetTmp td
  LibuiPerformTest "ls -d '${td}'"
  LibuiValidateTest ${?} 0 "${td}"
  return ${?}
}
tests+=( 'test_GetTmp-f_Error' )
test_GetTmp-f_Error () {
  _exitcleanup=false
  LibuiPerformTest 'GetTmp -f'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(GetTmp\) Called without a variable name\."
  return ${?}
}
tests+=( 'test_GetTmp-f' )
test_GetTmp-f () {
  local tf
  _udb=true
  GetTmp -f tf
  _udb=false
  LibuiPerformTest "ls '${tf}'"
  LibuiValidateTest ${?} 0 "${tf}"
  return ${?}
}
tests+=( 'test_GetTmp-s_Error' )
test_GetTmp-s_Error () {
  _exitcleanup=false
  LibuiPerformTest 'GetTmp -s'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(GetTmp\) Called without a variable name\."
  return ${?}
}
tests+=( 'test_GetTmp-s' )
test_GetTmp-s () {
  local ts
  GetTmp -s ts
  LibuiPerformTest "ls -a '${ts}'"
  LibuiValidateTest ${?} 0 ".${N}.."
  return ${?}
}

# Help
tests+=( '-H errout_help-H' )
errout_help-H () {
  LibuiPerformTest 'Tell "Test -H help."'
  LibuiValidateTest ${?} 2
  return ${?}
}
tests+=( '-h errout_help-h' )
errout_help-h () {
  LibuiPerformTest 'Tell "Test -h help."'
  LibuiValidateTest ${?} 2
  return ${?}
}

# NoAction
tests+=( 'test_NoAction' )
test_NoAction () {
  _noaction=true # set no action
  LibuiPerformTest 'NoAction'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_NoAction_False' )
test_NoAction_False () {
  LibuiPerformTest 'NoAction'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_NoAction_True' )
test_NoAction_True () {
  _noaction=true # set no action
  LibuiPerformTest 'Action "ls -lad /tmp"'
  LibuiValidateTest ${?} 0 '(No Action) ls -lad /tmp'
  return ${?}
}
tests+=( '-N test_NoAction-N' )
test_NoAction-N () {
  LibuiPerformTest 'Action "ls -lad /tmp"'
  LibuiValidateTest ${?} 0 '(No Action) ls -lad /tmp'
  return ${?}
}
tests+=( '-X 2 -N test_NoAction_Verbose' )
test_NoAction_Verbose () {
  LibuiPerformTest 'Action "ls /tmp.tst"'
  LibuiValidateTest -r ${?} 0 '\(No Action\) ls /tmp.tst \(PWD: .*\)'
  return ${?}
}
tests+=( '-X 2 -N test_NoAction_Verbose-q' )
test_NoAction_Verbose-q () {
  LibuiPerformTest 'Action -q "Test question." "ls /tmp.question"'
  LibuiValidateTest -r ${?} 0 '\(No Action\) ls /tmp.question \(PWD: .*\)'
  return ${?}
}

# PathMatches <path_specification_1> <path_specification_2>
tests+=( 'test_PathMatches_Error' )
test_PathMatches_Error () {
  _exitcleanup=false
  LibuiPerformTest 'PathMatches .'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(PathMatches\) Invalid parameter count\."
  return ${?}
}
tests+=( 'test_PathMatches_No_Match' )
test_PathMatches_No_Match () {
  local td
  GetTmp td
  cd ${td}
  LibuiPerformTest 'PathMatches / .'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_PathMatches_Dir' )
test_PathMatches_Dir () {
  local td
  GetTmp td
  cd ${td}
  LibuiPerformTest "PathMatches . ${td}"
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_PathMatches_File' )
test_PathMatches_File () {
  local td
  GetTmp td
  Action -W "touch ${td}/filepath"
  cd ${td}
  LibuiPerformTest "PathMatches filepath ${td}/filepath"
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_PathMatches_Symlink_DirFile' )
test_PathMatches_Symlink_DirFile () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local td
  GetTmp td
  Action -W "mkdir ${td}/pathdir"
  Action -W "touch ${td}/pathdir/filepath2"
  Action -W "ln -s ${td}/pathdir ${td}/dirlink"
  LibuiPerformTest "PathMatches ${mp}${td}/pathdir/filepath2 ${td}/dirlink/filepath2"
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_PathMatches_Symlink_EndDir' )
test_PathMatches_Symlink_EndDir () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local td
  GetTmp td
  Action -W "mkdir ${td}/pathdir2"
  Action -W "mkdir ${td}/pathdir2/enddir"
  Action -W "ln -s ${td}/pathdir2/enddir ${td}/dirlink2"
  LibuiPerformTest "PathMatches ${mp}${td}/pathdir2/enddir ${td}/dirlink2"
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_PathMatches_Symlink_EndFile' )
test_PathMatches_Symlink_EndFile () {
  local mp="$(readlink /var 2> /dev/null)"; [[ -n "${mp}" ]] && mp="/${mp%/*}"
  local td
  GetTmp td
  Action -W "mkdir ${td}/pathdir3"
  Action -W "touch ${td}/pathdir3/filepath3"
  Action -W "ln -s ${td}/pathdir3/filepath3 ${td}/filelink3"
  LibuiPerformTest "PathMatches ${mp}${td}/pathdir3/filepath3 ${td}/filelink3"
  LibuiValidateTest ${?} 0
  return ${?}
}

# Quiet
tests+=( 'test_Quiet_False' )
test_Quiet_False () {
  LibuiPerformTest 'Quiet'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Quiet_True' )
test_Quiet_True () {
  _quiet=true # set quiet
  LibuiPerformTest 'Quiet'
  local tv=${?}
  _quiet=false # reset quiet
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-Q test_Quiet-Q' )
test_Quiet-Q () {
  LibuiPerformTest 'Quiet'
  local tv=${?}
  _quiet=false # reset quiet
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( 'test_Quiet_False_Show' )
test_Quiet_False_Show () {
  LibuiPerformTest 'Tell "Test Quiet Show."'
  LibuiValidateTest ${?} 0 'Test Quiet Show.'
  return ${?}
}
tests+=( 'test_Quiet_True_Show' )
test_Quiet_True_Show () {
  _quiet=true # set quiet
  LibuiPerformTest 'Tell "Test Quiet No Show."'
  local tv=${?}
  _quiet=false # reset quiet
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-Q test_Quiet-Q_Show' )
test_Quiet-Q_Show () {
  LibuiPerformTest 'Tell "Test Quiet -Q No Show."'
  local tv=${?}
  _quiet=false # reset quiet
  LibuiValidateTest "${tv}" 0
  return ${?}
}

# Verbose
tests+=( 'test_Verbose_False' )
test_Verbose_False () {
  LibuiPerformTest 'Verbose'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Verbose_True' )
test_Verbose_True () {
  _vdb=true # set verbose debug
  LibuiPerformTest 'Verbose'
  local tv=${?}
  _vdb=false # reset verbose debug
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-Y -X 2 test_Verbose-X2' )
test_Verbose-X2 () {
  LibuiPerformTest 'Verbose'
  local tv=${?}
  _vdb=false # reset verbose debug
  LibuiValidateTest "${tv}" 0
  return ${?}
}

# Yes [-e|-E]
tests+=( 'test_Yes_False' )
test_Yes_False () {
  LibuiPerformTest 'Yes'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( 'test_Yes_True' )
test_Yes_True () {
  Yes -e
  LibuiPerformTest 'Yes'
  local tv=${?}
  Yes -E
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-Y test_Y_Yes' )
test_Y_Yes () {
  LibuiPerformTest 'Yes'
  local tv=${?}
  Yes -E
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-Y test_Y_Yes_Action-Cq' )
test_Y_Yes_Action-Cq () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Action -C -q "Yes question?" "ls -d /tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 "(Confirm) Yes question? (y/n) [yes] yes${N}/tmp"
  return ${?}
}
tests+=( '-Y test_Y_Yes_No_Term_Action-Cq' )
test_Y_Yes_No_Term_Action-Cq () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Action -C -q "Yes question?" "ls -d /tmp"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 "(Confirm) Yes question? (y/n) [yes] yes${N}/tmp"
  return ${?}
}
tests+=( '-Y test_Y_Yes_Verify' )
test_Y_Yes_Verify () {
  local t="${TERMINAL}"
  TERMINAL=true
  LibuiPerformTest 'Verify "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] yes'
  return ${?}
}
tests+=( '-Y -C test_Y_C_Yes_No_Term_Verify-C' )
test_Y_C_Yes_No_Term_Verify-C () {
  local t="${TERMINAL}"
  TERMINAL=false
  LibuiPerformTest 'Verify -C "Test verify?"'
  local tv=${?}
  TERMINAL="${t}"
  LibuiValidateTest "${tv}" 0 'Test verify? (y/n) [yes] yes'
  return ${?}
}
tests+=( 'test_Yes-e' )
test_Yes-e () {
  Yes -e
  LibuiPerformTest 'Yes'
  local tv=${?}
  Yes -E
  LibuiValidateTest "${tv}" 0
  return ${?}
}
tests+=( '-Y test_Y_Yes-E' )
test_Y_Yes-E () {
  Yes -E
  LibuiPerformTest 'Yes'
  local tv=${?}
  LibuiValidateTest "${tv}" 1
  return ${?}
}

# RemoveFileList [-f (force)] <name_of_array_variable> ...
tests+=( 'test_RemoveFileList_Error' )
test_RemoveFileList_Error () {
  _exitcleanup=false
  LibuiPerformTest 'RemoveFileList'
  local tv=${?}
  _exitcleanup=true
  LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(RemoveFileList\) Called without a variable name\."
  return ${?}
}
tests+=( 'test_RemoveFileList_Recursive' )
test_RemoveFileList_Recursive () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  Action -W "mkdir -p ${TESTDIR}/listdir-1"
  Action -W "mkdir -p ${TESTDIR}/listdir\ 2"
  Action -W "touch ${TESTDIR}/listdir-1/dirfile-1"
  Action -W "touch ${TESTDIR}/listdir-1/dirfile\ 2"
  GetFileList -r testlist "${TESTDIR}/list*"
  LibuiPerformTest 'RemoveFileList testlist'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_RemoveFileList' )
test_RemoveFileList () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  GetFileList testlist "${TESTDIR}/list*"
  LibuiPerformTest 'RemoveFileList testlist'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_RemoveFileList-f' )
test_RemoveFileList-f () {
  Action -W "touch ${TESTDIR}/listfile-1"
  Action -W "touch ${TESTDIR}/listfile\ 2"
  GetFileList testlist "${TESTDIR}/list*"
  LibuiPerformTest 'RemoveFileList -f testlist'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_RemoveFileList_Empty' )
test_RemoveFileList_Empty () {
  GetFileList testlist "${TESTDIR}/invalid-list*"
  LibuiPerformTest 'RemoveFileList testlist'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_RemoveFileList-f_Empty' )
test_RemoveFileList-f_Empty () {
  GetFileList testlist "${TESTDIR}/invalid-list*"
  LibuiPerformTest 'RemoveFileList -f testlist'
  LibuiValidateTest ${?} 0
  return ${?}
}

# Root Allowed
tests+=( '-x r test_AllowRoot_True' )
test_AllowRoot_True () {
  LibuiPerformTest 'AllowRoot'
  LibuiValidateTest ${?} 0
  return ${?}
}
tests+=( 'test_AllowRoot_False' )
test_AllowRoot_False () {
  LoadMod Root
  LibuiPerformTest 'AllowRoot'
  LibuiValidateTest ${?} 1
  return ${?}
}

# Root Required
tests+=( 'test_RequireRoot_False' )
test_RequireRoot_False () {
  LoadMod Root
  LibuiPerformTest 'RequireRoot'
  LibuiValidateTest ${?} 1
  return ${?}
}
tests+=( '-x R errout_RequireRoot' )
errout_RequireRoot () {
  LibuiPerformTest 'Tell "Test require root."'
  LibuiValidateTest ${?} 1 "ERROR: You must be root to execute ${CMD}."
  return ${?}
}

# Sort () { # parameters: [-a|-d|-p] [-c <compare_function> ]  <name_of_variable_with_list_to_sort>
tests+=( 'test_Sort' )
test_Sort () {
  LoadMod Sort
  testlist=( GF C0 k2 Sj yF xu 0W 6V Eb Ti Ju s1 Do Bm 1d Cm wn go wb lp zQ aG Uf Sy Xn lU Kr sw pe T bX id xZ Eb xO BL Wp pg sw Yr )
  LibuiPerformTest 'Sort testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 '0W 1d 6V aG BL Bm bX C0 Cm Do Eb Eb GF go id Ju k2 Kr lp lU pe pg s1 Sj sw sw Sy T Ti Uf wb wn Wp Xn xO xu xZ yF Yr zQ'
  return ${?}
}
tests+=( 'test_Sort-A' )
test_Sort-A () {
  LoadMod Sort
  testlist=( Dd IJ KX Lm yM Ua lp tk Wf QO 7D OR iE m6 ev Lb Dy 4z b8 4l LJ a2 rJ zj 4z EY EY gQ j0 p EQ Ov zh dI UK 5q ji Uw zV E1 )
  LibuiPerformTest 'Sort -A testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 'zj zh zV yM tk rJ p m6 lp ji j0 iE gQ ev dI b8 a2 Wf Uw Ua UK QO Ov OR Lm Lb LJ KX IJ EY EY EQ E1 Dy Dd 7D 5q 4z 4z 4l'
  return ${?}
}
tests+=( 'test_Sort-a' )
test_Sort-a () {
  LoadMod Sort
  testlist=( Vn ih Mj sn Ee rc dH JD 3e s1 WD N 6o ze Vm SR pY Kw XM xx Hz uM 17 vn Da ga mr EN 7S o0 58 b6 vS wg hn qL RO jg gU ua )
  LibuiPerformTest 'Sort -a testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 '17 3e 58 6o 7S Da EN Ee Hz JD Kw Mj N RO SR Vm Vn WD XM b6 dH gU ga hn ih jg mr o0 pY qL rc s1 sn uM ua vS vn wg xx ze'
  return ${?}
}
tests+=( 'test_Sort-c' )
test_Sort-c () {
  LoadMod Sort
  testlist=( OB vF Da h1 9x Ls Eu fx pQ KG Vw lC Tf p6 p9 ha 5V rH Ji AO 6 ZA No dq Vz 7H dP KB rM sx Cp dA ye PE Q8 cr Q9 2A 9T 4n )
  ${ZSH} || test_cmp () { [ "${2}" \< "${1}" ]; }
  ${ZSH} && test_cmp () { [[ "${2}" < "${1}" ]]; }
  LibuiPerformTest 'Sort -c test_cmp testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 'ye vF sx rM rH pQ p9 p6 lC ha h1 fx dq dP dA cr ZA Vz Vw Tf Q9 Q8 PE OB No Ls KG KB Ji Eu Da Cp AO 9x 9T 7H 6 5V 4n 2A'
  return ${?}
}
tests+=( 'test_Sort-L' )
test_Sort-L () {
  LoadMod Sort
  testlist=( Dd IJ KX Lm yM Ua lp tk Wf QO 7D OR iE m6 ev Lb Dy 4z b8 4l LJ a2 rJ zj 4z EY EY gQ j0 p EQ Ov zh dI UK 5q ji Uw zV E1 )
  LibuiPerformTest 'Sort -L testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 'zV zj zh yM Wf Uw UK Ua tk rJ QO p Ov OR m6 lp Lm LJ Lb KX ji j0 IJ iE gQ EY EY ev EQ E1 Dy dI Dd b8 a2 7D 5q 4z 4z 4l'
  return ${?}
}
tests+=( 'test_Sort-l' )
test_Sort-l () {
  LoadMod Sort
  testlist=( Vn ih Mj sn Ee rc dH JD 3e s1 WD N 6o ze Vm SR pY Kw XM xx Hz uM 17 vx Da ga mr EN 7S o0 58 b6 vS wg hn qL RO jg gU ua )
  LibuiPerformTest 'Sort -l testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 '17 3e 58 6o 7S b6 Da dH Ee EN ga gU hn Hz ih JD jg Kw Mj mr N o0 pY qL rc RO s1 sn SR ua uM Vm Vn vS vx WD wg XM xx ze'
  return ${?}
}
tests+=( 'test_Sort-N' )
test_Sort-N () {
  LoadMod Sort
  testlist=( 88 19 46 46 15 89 54 84 12 16 38 82 98 44 94 76 80 80 70 41 21 46 24 93 11 42 24 55 10 09 98 88 17 73 58 20 30 7 35 60 )
  LibuiPerformTest 'Sort -N testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 '98 98 94 93 89 88 88 84 82 80 80 76 73 70 60 58 55 54 46 46 46 44 42 41 38 35 30 24 24 21 20 19 17 16 15 12 11 10 09 7'
  return ${?}
}
tests+=( 'test_Sort-n' )
test_Sort-n () {
  LoadMod Sort
  testlist=( 37 08 50 25 89 02 83 06 50 37 61 89 38 20 30 92 23 82 70 06 11 51 47 72 45 22 42 87 43 76 76 78 15 10 46 5 91 72 73 64 )
  LibuiPerformTest 'Sort -n testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 '02 5 06 06 08 10 11 15 20 22 23 25 30 37 37 38 42 43 45 46 47 50 50 51 61 64 70 72 72 73 76 76 78 82 83 87 89 89 91 92'
  return ${?}
}
tests+=( 'test_Sort-p' )
test_Sort-p () {
  LoadMod Sort
  testlist=( "/d 1" "/d 2" "/d 1/d 2" "/d 1/d 2/d 3" "/d 3" "/d 1/d 2/d 3" "/d 1/d 2/d 3/d 4" "/d 4" "/d 1/d 2/d 3/d 4" "/d 1/d 2/d 3/d 4/d 5" "/d 5" "/d 1/d 2/d 3/d 4/d 5" )
  LibuiPerformTest 'Sort -p testlist; printf "%s\n" "${testlist[*]}"'
  LibuiValidateTest ${?} 0 '/d 1/d 2/d 3/d 4/d 5 /d 1/d 2/d 3/d 4/d 5 /d 1/d 2/d 3/d 4 /d 1/d 2/d 3/d 4 /d 1/d 2/d 3 /d 1/d 2/d 3 /d 1/d 2 /d 1 /d 2 /d 3 /d 4 /d 5'
  return ${?}
}

# Syslog [-p <priority>] [<message>]
tests+=( 'test_Syslog' )
test_Syslog () {
  LoadMod Syslog
  LibuiPerformTest 'Syslog'
  LibuiValidateTest ${?} 0 ''
  return ${?}
}
tests+=( 'test_Syslog_Message' )
test_Syslog_Message () {
  LoadMod Syslog
  LibuiPerformTest 'Syslog "Libui user test message."'
  LibuiValidateTest ${?} 0 ''
  return ${?}
}
tests+=( 'test_Syslog_Message-p' )
test_Syslog_Message-p () {
  LoadMod Syslog
  LibuiPerformTest 'Syslog -p user.info "Libui user.info test message."'
  LibuiValidateTest ${?} 0 ''
  return ${?}
}

# Tell [-1..-9|-a|-c|-n|-N] [-l <file_path>] <message_text>
tests+=( 'test_Tell' )
test_Tell () {
  LibuiPerformTest 'Tell "Test 1."; Tell "Test 2."'
  LibuiValidateTest ${?} 0 "Test 1.${N}Test 2."
  return ${?}
}
tests+=( 'test_Tell-n' )
test_Tell-n () {
  LibuiPerformTest 'Tell -n "Test 1."; Tell -n "Test 2."'
  LibuiValidateTest ${?} 0 'Test 1.Test 2.'
  return ${?}
}
tests+=( 'test_Tell-N' )
test_Tell-N () {
  LibuiGetDisplayTestValues
  local t="${TERMINAL}"
  TERMINAL=true
  _Terminal
  TERMINAL="${t}"
  LibuiPerformTest 'Tell -N "Test 1."; Tell -N "Test 2."'
  LibuiValidateTest ${?} 0 "${TJBL}${Tb}Test 1.${T}${TCEL}${TJBL}${TJBL}${Tb}Test 2.${T}${TCEL}${TJBL}"
  return ${?}
}
tests+=( 'test_Tell-i' )
test_Tell-i () {
  LibuiGetDisplayTestValues
  local t="${TERMINAL}"
  TERMINAL=true
  _Terminal
  TERMINAL="${t}"
  LibuiPerformTest 'Tell -n "Test 1. "; Tell -i "Test 2."'
  LibuiValidateTest ${?} 0 "${TJBL}${Tb}Test 1. ${T}${TCEL}${Tb}Test 2.${T}${TCEL}"
  return ${?}
}
tests+=( 'test_Tell_Log-a' )
test_Tell_Log-a () {
  local lfile; GetTmp -f lfile
  Tell -l "${lfile}" "Tell test 1."
  Tell -l "${lfile}" "Tell test 2."
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "Tell test 1.${N}Tell test 2."
  return ${?}
}
tests+=( 'test_Tell_Log-c' )
test_Tell_Log-c () {
  local lfile; GetTmp -f lfile
  Tell -c -l "${lfile}" "Tell test 1."
  Tell -c -l "${lfile}" "Tell test 2."
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "Tell test 2."
  return ${?}
}
tests+=( 'test_Tell-1' )
test_Tell-1 () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  Tell -1 "Test Tell log file."
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "Test Tell log file."
  return ${?}
}

# Trace <debug_message>
tests+=( 'test_Trace' )
test_Trace () {
  _hdb=true # set host debug output
  LibuiPerformTest 'Trace "Test Trace command."'
  local tv=${?}
  _hdb=false # reset host debug output
  LibuiValidateTest -r "${tv}" 0 '.*Test Trace command.'
  return ${?}
}
tests+=( 'test_Trace_Profile' )
test_Trace_Profile () {
  _hdb=true # set host debug output
  _pdb=true # set profile output
  LibuiPerformTest 'Trace "Test Trace Profile."'
  local tv=${?}
  _pdb=false # reset profile output
  _hdb=false # reset host debug output
  if ${ZSH}
  then
    LibuiValidateTest -r "${tv}" 0 '\+[0-9]+\.[0-9]+:.*TRACE: Test Trace Profile\.'
    tv=${?}
  else
    LibuiValidateTest -r "${tv}" 0 '\+[0-9]+:.*TRACE: Test Trace Profile\.'
    tv=${?}
  fi
  return "${tv}"
}

# open / write / close file
tests+=( 'test_Open-c_Write' )
test_Open-c_Write () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  Write -1 'Test_Open-c_Write'
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 'Test_Open-c_Write'
  return ${?}
}
tests+=( 'test_Open-a_Write' )
test_Open-a_Write () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -a "${lfile}"
  Write -1 'Test_Open-a_Write'
  Write -1 'Test_Open-a_Write'
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "Test_Open-a_Write${N}Test_Open-a_Write"
  return ${?}
}
tests+=( 'test_Open-a-b_Write' )
test_Open-a-b_Write () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -a -b "${lfile}"
  Write -1 'Test_Open-a-b_Write 1'
  Close -1
  Open -2 -a -b "${lfile}"
  Write -2 'Test_Open-a-b_Write 2'
  Close -2
  LibuiPerformTest "ls '${lfile}'*"
  LibuiValidateTest ${?} 0 "${lfile}${N}${lfile}.0.bz2"
  return ${?}
}
tests+=( 'test_Open-a-B_File_Write' )
test_Open-a-B_File_Write () {
  local lfile; GetTmp -f lfile
  local ldir; GetTmp -s ldir
  LoadMod File
  Open -1 -a -B "${ldir}/backup" "${lfile}"
  Write -1 'Test_Open-a-B_File_Write 1'
  Close -1
  Open -2 -a -B "${ldir}/backup" "${lfile}"
  Write -2 'Test_Open-a-B_File_Write 2'
  Close -2
  LibuiPerformTest "ls '${lfile}'*; ls '${ldir}'/*"
  LibuiValidateTest ${?} 0 "${lfile}${N}${ldir}/backup.0.bz2"
  return ${?}
}
tests+=( 'test_Open-a-B_Dir_Write' )
test_Open-a-B_Dir_Write () {
  local lfile; GetTmp -f lfile
  local ldir; GetTmp -s ldir
  LoadMod File
  Open -1 -a -B "${ldir}" "${lfile}"
  Write -1 'Test_Open-a-B_Dir_Write 1'
  Close -1
  Open -2 -a -B "${ldir}" "${lfile}"
  Write -2 'Test_Open-a-B_Dir_Write 2'
  Close -2
  LibuiPerformTest "ls '${lfile}'*; ls '${ldir}'/*"
  LibuiValidateTest ${?} 0 "${lfile}${N}${ldir}/${lfile##*/}.0.bz2${N}${ldir}/${lfile##*/}.1.bz2"
  return ${?}
}
tests+=( 'test_Write-cf' )
test_Write-cf () {
  local lfile; GetTmp -f lfile
  Write -c -f "${lfile}" 'Test_Write-cf'
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 'Test_Write-cf'
  return ${?}
}
tests+=( 'test_Write-cfr' )
test_Write-cfr () {
  local lfile; GetTmp -f lfile
  Write -c -f "${lfile}" -r ' - ' 1 2 3
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 '1 - 2 - 3 - '
  return ${?}
}
tests+=( 'test_Write-cfp' )
test_Write-cfp () {
  local lfile; GetTmp -f lfile
  Write -c -f "${lfile}" -p 'Test %s.\n' '123'
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 'Test 123.'
  return ${?}
}
tests+=( 'test_Write-af' )
test_Write-af () {
  local lfile; GetTmp -f lfile
  Write -a -f "${lfile}" 'Test_Write-af 1'
  Write -f "${lfile}" 'Test_Write-af 2'
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "Test_Write-af 1${N}Test_Write-af 2"
  return ${?}
}
tests+=( 'test_Write-afrp' )
test_Write-afrp () {
  local lfile; GetTmp -f lfile
  Write -f "${lfile}" -r ' - ' 'Test_Write-afrp 1'
  Write -a -f "${lfile}" -p 'Test %s.\n' 'Write-afrp 2'
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 'Test_Write-afrp 1 - Test Write-afrp 2.'
  return ${?}
}

# ledger file
tests+=( 'test_Ledger_File' )
test_Ledger_File () {
  local lfile; GetTmp -f lfile
  (LIBUI_LEDGER=true LIBUI_LEDGERFILE="${lfile}" libui -x w)
  LibuiPerformTest "wc -l '${lfile}'"
  LibuiValidateTest -r ${?} 0 " *1 *${lfile}"
  return ${?}
}
tests+=( 'test_Multiuser_Ledger_File' )
test_Multiuser_Ledger_File () {
  local lfile; GetTmp -f lfile
  (LIBUI_LEDGER=true LIBUI_LEDGERFILE="${lfile}" libui -x m -x w)
  LibuiPerformTest "wc -l '${lfile}'"
  LibuiValidateTest -r ${?} 0 " *1 *${lfile}"
  return ${?}
}
tests+=( '-x n test_No_Ledger_File' )
test_No_Ledger_File () {
  local ldb="${LIBUI_LEDGER:-true}"
  LibuiPerformTest 'Tell "Test no ledger file. (%s)" "${_ldb}"'
  LibuiValidateTest ${?} 0 "Test no ledger file. (${ldb})"
  return ${?}
}

# trace file
tests+=( 'test_Trace_File' )
test_Trace_File () {
  local lfile; GetTmp -f lfile
  (LIBUI_TRACE=true LIBUI_TRACEFILE="${lfile}" libui -x w)
  LibuiPerformTest "grep 'Executed \"/.*/libui -x w\" on ' '${lfile}'"
  LibuiValidateTest -r ${?} 0 "Executed \"${script} -x w\" on .*"
  return ${?}
}
tests+=( '-x n test_No_Trace_File' )
test_No_Trace_File () {
  local tdb="${LIBUI_TRACE:-true}"
  LibuiPerformTest 'Tell "Test no trace file. (%s)" "${_tdb}"'
  LibuiValidateTest ${?} 0 "Test no trace file. (${tdb})"
  return ${?}
}

# stats file
tests+=( 'test_Stats_File' )
test_Stats_File () {
  local lfile; GetTmp -f lfile
  (LIBUI_STATS=true LIBUI_STATSFILE="${lfile}" libui -x w)
  LibuiPerformTest "grep '# libui stats on ' '${lfile}'"
  LibuiValidateTest -r ${?} 0 '# libui stats on .*'
  return ${?}
}
tests+=( 'test_Multiuser_Stats_File' )
test_Multiuser_Stats_File () {
  local lfile; GetTmp -f lfile
  (LIBUI_STATS=true LIBUI_STATSFILE="${lfile}" libui -x m -x w)
  LibuiPerformTest "grep '# libui stats on ' '${lfile}'"
  LibuiValidateTest -r ${?} 0 '# libui stats on .*'
  return ${?}
}
tests+=( '-x n test_No_Stats_File' )
test_No_Stats_File () {
  local sdb="${LIBUI_STATS:-true}"
  LibuiPerformTest 'Tell "Test no stats file. (%s)" "${_sdb}"'
  LibuiValidateTest ${?} 0 "Test no stats file. (${sdb})"
  return ${?}
}

# hooks
tests+=( 'test_Hookdir' )
test_Hookdir () {
  local ldir; GetTmp -s ldir
  Write -c -f "${ldir}/libui-init" 'printf "Test hookdir init.\\n"'
  Write -c -f "${ldir}/libui-exit" 'printf "Test hookdir exit.\\n"'
  LibuiPerformTest "LIBUI_HOOKDIR=\"${ldir}\" libui -x w"
  LibuiValidateTest ${?} 0 "Test hookdir init.${N}Hello World.${N}Test hookdir exit."
  return ${?}
}
tests+=( 'test_Local_Hook' )
test_Local_Hook () {
  local ldir; GetTmp -s ldir
  Write -c -f "${ldir}/.libui-init" 'printf "Test local init hook.\\n"'
  Write -c -f "${ldir}/.libui-exit" 'printf "Test local exit hook.\\n"'
  cd "${ldir}"
  LibuiPerformTest "libui -x w"
  LibuiValidateTest ${?} 0 "Test local init hook.${N}Hello World.${N}Test local exit hook."
  return ${?}
}

# Warn [-1..-9|-a|-c] [-l <file_path>] [-r <retval>] <warning_message>
tests+=( 'test_Warn' )
test_Warn () {
  LibuiPerformTest 'Warn "Test Warn command."'
  LibuiValidateTest ${?} 1 'WARNING: Test Warn command.'
  return ${?}
}
tests+=( 'test_Warn_Log-a' )
test_Warn_Log-a () {
  local lfile; GetTmp -f lfile
  Warn -l "${lfile}" "Warn test 1."
  Warn -l "${lfile}" "Warn test 2."
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "WARNING: Warn test 1.${N}WARNING: Warn test 2."
  return ${?}
}
tests+=( 'test_Warn_Log-c' )
test_Warn_Log-c () {
  local lfile; GetTmp -f lfile
  Warn -c -l "${lfile}" "Warn test 1."
  Warn -c -l "${lfile}" "Warn test 2."
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "WARNING: Warn test 2."
  return ${?}
}
tests+=( 'test_Warn-1' )
test_Warn-1 () {
  local lfile; GetTmp -f lfile
  LoadMod File
  Open -1 -c "${lfile}"
  Warn -1 "Test Warn log file."
  Close -1
  LibuiPerformTest "cat '${lfile}'"
  LibuiValidateTest ${?} 0 "WARNING: Test Warn log file."
  return ${?}
}
tests+=( 'test_Warn-r' )
test_Warn-r () {
  LibuiPerformTest 'Warn -r 5 "Test Warn -r 5 command."'
  LibuiValidateTest ${?} 5 'WARNING: Test Warn -r 5 command.'
  return ${?}
}

# error processing
tests+=( 'test_Preinit' )
test_Preinit () {
  LibuiPerformTest 'AddOption B'
  LibuiValidateTest -r ${?} 1 'ERROR .* \(AddOption\) Must be called before Initialize\.'
  return ${?}
}

# logfile log
#tests+=( 'test_Logfile' )
test_Logfile () {
  [[ -f "${LIBUI_LOGFILE}" ]] && printf '' > "${LIBUI_LOGFILE}"
  Action "ls -d /tmp"
  LibuiPerformTest "cat '${LIBUI_LOGFILE}'"
  LibuiValidateTest -r ${?} 0 "ACTION .*: ls -d /tmp${N}/tmp"
  return ${?}
}

# mods
tests+=( 'test_ConvertDate' )
test_ConvertDate () {
  LoadMod Date
  local short
  local td="$(date '+%Y-%m-%d')"
  ConvertDate short "$(date)"
  LibuiPerformTest 'Tell "Date: %s" "${short}"'
  LibuiValidateTest ${?} 0 "Date: ${td}"
  return ${?}
}
tests+=( 'test_Record' )
test_Record () {
  if ${AA}
  then
    LoadMod FileRecord
    local lfile; GetTmp -f lfile
    RecordColumns=( one two three four five )
    RecordData[one]="Test 1"
    RecordData[two]="Second"
    RecordData[three]="\$3,333.33"
    RecordData[four]="\"Test four.\""
    RecordData[five]="I said, \"five!\""
    RecordOpen -1 "${lfile}"
    RecordEntry -1
    RecordClose -1
    LibuiPerformTest "cat '${lfile}'"
    LibuiValidateTest ${?} 0 'Test 1,Second,"$3,333.33","""Test four.""","I said, ""five!"""'
  else
    _exitcleanup=false
    LibuiPerformTest 'LoadMod FileRecord'
    local tv=${?}
    _exitcleanup=true
    LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(libuiRecord\) Requires associative arrays that .* does not provide\."
    ((0 == ${?})) && Warn -r 33 'Associative arrays are not supported in %s. (%s)' "${SHELL}" "${BASH_VERSION}"
  fi
  return ${?}
}
tests+=( 'test_Record_1_Param' )
test_Record_1_Param () {
  if ${AA}
  then
    LoadMod FileRecord
    local lfile; GetTmp -f lfile
    declare -A da
    RecordColumns=( one two three four five )
    da[one]="Test 1"
    da[two]="Second"
    da[three]="\$3,333.33"
    da[four]="\"Test four.\""
    da[five]="He said, \"five!\""
    RecordOpen -1 "${lfile}"
    RecordEntry -1 da
    RecordClose -1
    LibuiPerformTest "cat '${lfile}'"
    LibuiValidateTest ${?} 0 'Test 1,Second,"$3,333.33","""Test four.""","He said, ""five!"""'
  else
    _exitcleanup=false
    LibuiPerformTest 'LoadMod FileRecord'
    local tv=${?}
    _exitcleanup=true
    LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(libuiRecord\) Requires associative arrays that .* does not provide\."
    ((0 == ${?})) && Warn -r 33 'Associative arrays are not supported in %s. (%s)' "${SHELL}" "${BASH_VERSION}"
  fi
  return ${?}
}
tests+=( 'test_Record_2_Param' )
test_Record_2_Param () {
  if ${AA}
  then
    LoadMod FileRecord
    local lfile; GetTmp -f lfile
    local ca; ca=( one two three four five )
    declare -A da
    da[one]="Test 1"
    da[two]="Second"
    da[three]="\$3,333.33"
    da[four]="\"Test four.\""
    da[five]="She said, \"five!\""
    RecordOpen -1 "${lfile}"
    RecordEntry -1 da ca
    RecordClose -1
    LibuiPerformTest "cat '${lfile}'"
    LibuiValidateTest ${?} 0 'Test 1,Second,"$3,333.33","""Test four.""","She said, ""five!"""'
  else
    _exitcleanup=false
    LibuiPerformTest 'LoadMod FileRecord'
    local tv=${?}
    _exitcleanup=true
    LibuiValidateTest -r "${tv}" 1 "ERROR in .*: \(libuiRecord\) Requires associative arrays that .* does not provide\."
    ((0 == ${?})) && Warn -r 33 'Associative arrays are not supported in %s. (%s)' "${SHELL}" "${BASH_VERSION}"
  fi
  return ${?}
}
tests+=( 'test_Timer' )
test_Timer () {
  #LoadMod Timer # note: loaded by main
  local timer
  StartTimer timer
  sleep 1
  GetElapsed timer
  LibuiPerformTest 'Tell "Timed: %s" "${ELAPSED}"'
  LibuiValidateTest -r ${?} 0 'Timed: (1|2).*'
  return ${?}
}
tests+=( 'test_InfoCallback' )
test_InfoCallback () {
  LoadMod Info
  LibuiPerformTest 'UsageInfo'
  LibuiValidateTest -r ${?} 2 '.*Hello World test\..*'
  return ${?}
}

return 0
