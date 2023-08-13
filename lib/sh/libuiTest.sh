#!/bin/zsh
# also works with bash but, zsh improves profiling
#!/bin/bash
#####
#
#	Libui Test - Libui Test Mod
#
#	F Harvell - Sat Jun 10 10:42:34 EDT 2023
#
#####
#
# Provides libui test commands.
#
# Man page available for this module: man 3 libuiTest.sh
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

Version -r 1.832 -m 1.2

##### configuration

# load mods

# defaults
_Test_debug=false


#####
#
# test functions
#
#####

UICMD+=( 'LibuiPerformTest' )
LibuiPerformTest () {
  ${_S} && ((_cLibuiPerformTest++))
  ${_M} && _Trace 'LibuiPerformTest [%s]' "${*}"

  local _Test_rv

  # ${_M} && _Trace 'Perform %s.' "${*}" --> don't use, generates output when testing Trace
  Tell '\nPerform: %s (Logfile: %s)\nResults:\n-----\n' "${*}" "${TESTDIR}/test.out"
  if ${ZSH}
  then
    eval "( ${@} )" 5> /dev/null 2>&1 | tee "${TESTDIR}/test.out"
    _Test_rv=${pipestatus[${AO}]}
  else
    eval "( ${@} )" 5> /dev/null 2>&1 | tee "${TESTDIR}/test.out"
    _Test_rv=${PIPESTATUS[${AO}]}
  fi

  ${_M} && _Trace 'LibuiPerformTest return. (%s)' "${_Test_rv}"
  Tell '\n-----\nReturn value: %s\n' "${_Test_rv}"
  return ${_Test_rv}
}

UICMD+=( 'LibuiValidateTest' )
LibuiValidateTest () {
  ${_S} && ((_cLibuiValidateTest++))
  ${_M} && _Trace 'LibuiValidateTest [%s]' "${*}"

  local _Test_input; [[ -f "${TESTDIR}/test.out" ]] && _Test_input="$(< "${TESTDIR}/test.out")"
  local _Test_initial=false
  local _Test_regex=false
  local _Test_rv=0

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
        _Test_initial=true
        ;;

      r)
        ${_M} && _Trace 'Make parameter regex.'
        _Test_regex=true
        ;;

      *)
        Tell -E '(validate) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  # get values
  local _Test_tv="${1}" # test value
  local vr="${2}" # valid return
  shift 2

  # validate
  ${_M} && _Trace 'Validate (initial:%s) (regex:%s): (valid:%s) %s=(test:%s) %s' "${_Test_initial}" "${_Test_regex}" "${vr}" "${*}" "${_Test_tv}" "${_Test_input}"
  if ${_Test_regex}
  then
    Tell "\nValidate (regex):\n${D}result |%d|%s|\n valid |%d|%s|\n" "${_Test_tv}" "${_Test_input}" "${vr}" "${*}"
    [[ "${_Test_tv}" -eq "${vr}" && "${_Test_input}" =~ ${*} ]] || _Test_rv=1 # regex needs to be unquoted
  elif ${_Test_initial}
  then
    Tell "\nValidate (initial):\n${D}result |%d|%s|\n valid |%d|%s|\n" "${_Test_tv}" "${_Test_input}" "${vr}" "${*}"
    ((_Test_tv == vr)) && [[ "${_Test_input}" == "${*}"* ]] || _Test_rv=1
  else
    Tell "\nValidate (exact):\n${D}result |%d|%s|\n valid |%d|%s|\n" "${_Test_tv}" "${_Test_input}" "${vr}" "${*}"
    ((_Test_tv == vr)) && [[ "${_Test_input}" == "${*}" ]] || _Test_rv=1
  fi

  ${_Test_debug} && _Terminal
  if ((_Test_rv))
  then
    Tell -W -r 2 '>>> Validation failed. (%s)' "${_Test_rv}"
    ${_Test_debug} && if ! Verify 'Continue?'
    then
      ${_M} && _Trace 'Quit %s. (%s)' "${CMD}" 0
      Exit 2
    fi
  else
    Tell -A 'Validation passed.'
  fi

  ${_M} && _Trace 'LibuiValidateTest return. (%s)' "${_Test_rv}"
  return ${_Test_rv}
}

UICMD+=( 'LibuiTest' )
LibuiTest () {
  ${_S} && ((_cLibuiTest++))
  ${_M} && _Trace 'LibuiTest [%s]' "${*}"

  local _Test_failedids; _Test_failedids=( )
  local _Test_rv=0
  local _Test_success=true
  local _Test_testdir

  # get options
  ${_M} && _Trace 'Check for LibuiTest options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':dt:' opt
  do
    case "${opt}" in
      d)
        ${_M} && _Trace 'Debug.'
        _Test_debug=true
        ;;

      t)
        ${_M} && _Trace 'Test directory. (%s)' "${OPTARG}"
        _Test_testdir="${OPTARG}"
        ;;

      *)
        Tell -E '(LibuiTest) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  local _Test_cond
  local _Test_count=1
  local _Test_env
  local _Test_errout
  local _Test_failedtests; _Test_failedtests=( )
  local _Test_opt
  local _Test_param
  local _Test_pass
  local _Test_result
  local _Test_run
  local _Test_shell
  local _Test_test
  local _Test_tests; _Test_tests=( )
  local _Test_warn

  ${_M} && _Trace 'Check for single test. (%s)' "${singletest}"
  if ${singletest}
  then
    ${_M} && _Trace 'Load test. (%s)' "${1}"
    source "${_Test_testdir}/${1}"

    ${_M} && _Trace 'Check for test. (%s)' "${1}"
    if declare -f ${1} > /dev/null
    then
      ${_M} && _Trace 'Start test. (%s)' "${1}"
      Tell '=====\nStarted "%s"%s in %s with: %s' "${1}" "${COUNT:+ (${COUNT})}" "${SHELL}" "${CMDLINE[*]}"

      ${_M} && _Trace 'Execute %s test. (%s)' "${SHELL}" "${1}"
      ${1}
      _Test_rv=${?}

      ${_M} && _Trace 'Finish test. (%s)' "${1}"
      Tell '\nCompleted "%s"%s in %s with: %s\n=====' "${1}" "${COUNT:+ (${COUNT})}" "${SHELL}" "${CMDLINE[*]}"
    else
      _Terminal
      Tell -E -f 'Test not available: %s.' "${1}"
      _Test_rv=1
    fi
  else
    ${_M} && _Trace 'Define test log. (%s)' "${TESTDIR}/test.log"
    _Test_log=">> \"${TESTDIR}/test.log\" 2>&1; _Test_result=\${?}"
    if ${ZSH}
    then
      ${debug} && _Test_log="2>&1 | tee -a \"${TESTDIR}/test.log\"; _Test_result=\"\${pipestatus[1]}\""
    else
      ${debug} && _Test_log="2>&1 | tee -a \"${TESTDIR}/test.log\"; _Test_result=\"\${PIPESTATUS[0]}\""
    fi

    ${_M} && _Trace 'Find tests. (%s)' "${_Test_testdir}"
    [[ -z "${@}" ]] && GetFileList -f -n _Test_tests "${_Test_testdir}"/test_* || _Test_tests=( "${@}" )

    ${_M} && _Trace 'Start session log.'
    Tell 'Test environment:'
    Version
    Tell 'Begin libui %s with %s tests on %s. (%s)' "${LIBUI_VERSION}" "${#_Test_tests[@]}" "$(date)" "${TESTDIR}"
    StartTimer _Test_logtimer

    ${_M} && _Trace 'Execute tests. (%s)' "${#_Test_tests[@]}"
    for _Test_test in "${_Test_tests[@]}"
    do
      Tell -I -N 'Preparing test %s: (%s)...' "${_Test_count}" "${_Test_test}"

      ${_M} && _Trace 'Prepare for test %s: (%s)' "${_Test_count}" "${_Test_test}"
      _Test_env="LIBUI_TRACE=false COUNT=${_Test_count} "
      _Test_opt='-T '
      ${_Test_debug} && _Test_opt+='-x d '
      ((0 < _xdb)) && _Test_opt+="-X ${_xdb} "
      _Test_param=' '
      _Test_errout=false

      ${_M} && _Trace 'Load test. (%s)' "${_Test_test}"
      source "${_Test_testdir}/${_Test_test}"

      ${_M} && _Trace 'Check for error out test. (%s)' "${_Test_errout}"
      if ${_Test_errout}
      then
        _Test_warn='-W'
        _Test_cond='-lt'
        _Test_pass=false
      else
        _Test_warn=
        _Test_cond='-eq'
        _Test_pass=true
      fi

      ${_M} && _Trace 'Execute test: %s %s%s%s.' "${CMD}" "${_Test_opt}" "${_Test_test}" "${_Test_param}"
      ${_Test_debug} && Tell 'Execute test: %s %s%s%s.' "${CMD}" "${_Test_opt}" "${_Test_test}" "${_Test_param}"
      _Test_run=0
      _Test_result=99
      StartTimer _Test_testtimer
      for _Test_shell in "${shells[@]}"
      do
        Tell -I -N 'Running test %s: (%s)...' "${_Test_count}" "${_Test_test}"

        ${_M} && _Trace 'Test command: %s' "${_Test_shell} ${CMDPATH} ${_Test_opt}${_Test_test}${_Test_param}"
        ${_Test_debug} && Tell 'Test command: %s' "${_Test_shell} ${CMDPATH} ${_Test_opt}${_Test_test}${_Test_param}"
        eval "Action -W -s ${_Test_warn} \"${_Test_env}${_Test_shell} ${CMDPATH} ${_Test_opt}${_Test_test}${_Test_param}\" ${_Test_log}"


        ${_M} && _Trace 'Check return value. (%s)' "${_Test_result}"
        case "${_Test_result}" in
          0)
            #${_Test_debug} && ${_Test_pass} && Tell -A 'Test passed in %s. (%s)' "${_Test_shell}" "${_Test_test}"
            ;;

          33)
            Tell "${DFy}Associative arrays are not available in this version of %s. (%s)${D}" "${_Test_shell}" "${_Test_test}"
            _Test_result=0
            ;;

          *)
            ${_Test_pass} && Tell "${DFr}Test failed in %s with %s. (%s)${D}" "${_Test_shell}" "${_Test_result}" "${_Test_test}"
            ;;

        esac

        ((_Test_run+=_Test_result))
      done
      GetElapsed _Test_testtimer
      ${_Test_debug} && Tell 'Finished test %s in %.4f seconds.' "${_Test_test}" "${ELAPSED}"

      ${_M} && _Trace 'Check results. (0 %s %s)' "${_Test_cond}" "${_Test_run}"
      if [ 0 ${_Test_cond} ${_Test_run} ]
      then
        Tell -A 'Test %03d passed in %.4f seconds. (%s)' "${_Test_count}" "${ELAPSED}" "${_Test_test}"
      else
        _Test_success=false
        _Test_failedids+=( ${_Test_count} )
        _Test_failedtests+=( ${_Test_test} )
        Tell -W 'Test %03d failed. (%s)' "${_Test_count}" "${_Test_test}"
        ${_Test_debug} && if ! Verify 'Continue?'
        then
          ${_M} && _Trace 'Quit %s. (%s)' "${CMD}" 0
          Exit 2
        fi
      fi

      ((_Test_count++))
    done

    ${_M} && _Trace 'End session log.'
    GetElapsed _Test_logtimer
    Tell 'Completed %d tests in %.4f seconds on %s.' "${#_Test_tests[@]}" "${ELAPSED}" "$(date)"

    ${_M} && _Trace 'Test suite results. (%s)' "${_Test_success}"
    ${_M} && _Trace 'Report. (%s)' "${_Test_success}"
    if ${_Test_success}
    then
      Tell -A 'Test suite successful. Passed %s tests.' "${#_Test_tests[@]}"
    else
      Tell -E -F 'Test suite not successful.'
      Tell 'Failed %s out of %s tests:' "${#_Test_failedtests[@]}" "${#_Test_tests[@]}"
      for ((i = AO; i < $((${#_Test_failedtests[@]} + AO)); i++))
      do
        Tell '  %s %s' "${_Test_failedids[${i}]}" "${_Test_failedtests[${i}]}"
      done
      Ask -z 'Press return to exit. (%s)' "${TESTDIR}"
    fi
  fi

  ${_M} && _Trace 'Return to prior directory.'
  popd > /dev/null

  ${_M} && _Trace 'LibuiTest return. (%s)' "${_Test_rv}"
  return ${_Test_rv}
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
  Tbr="$(tput setab 1)" # red
  Tbg="$(tput setab 2)" # green
  Tby="$(tput setab 3)" # yellow
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
  TAnswer="${Tfy}"
  TCaution="${TFm}"
  TConfirm="${Tb}${TFy}"
  TError="${Tbr}${Tb}${TFy}"
  TInfo="${TFc}"
  TOptions="${Tb}"
  TQuestion="${TFc}${Tsu}"
  TSpinner="${Tb}${TFc}"
  TTell="${Tb}"
  TTrace="${Td}"
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

