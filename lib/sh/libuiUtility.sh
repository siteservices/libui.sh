#!/bin/zsh
# also works with bash but, zsh improves profiling
#!/bin/bash
#####
#
#	Libui Utilities - Multifunction Libui Utility Mod
#
#	F Harvell - Fri May  5 12:20:41 EDT 2023
#
#####
#
# Provides libui utility commands.
#
# Man page available for this module: man 3 libuiUtility.sh
#
#####
#
# IMPORTANT: This module does a lot of white box manipulation of the libui.sh
# internals and should not be used as a model for libui.sh Mod development.
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

Version -r 1.825 -m 1.2

##### configuration

# load mods
LoadMod File
LoadMod Info
LoadMod Sort
LoadMod Spinner
LoadMod Timer
LoadMod User

# defaults
export LC_ALL=POSIX
${ZSH} || shopt -s expand_aliases
GetRealPath _Util_libuiroot "${LIBUI%/*}/../../"
_Util_installenv='SHLIBPATH="${d}/lib/sh"'
_Util_installer='${d}/lib/sh/libui'
_Util_groupmode='g+w'
_Util_lockdir="${LIBUI_LOCKDIR:-${LIBUI_DOTFILE}/lock}"
_Util_configfile="${LIBUI_DOTFILE}/libui.conf"
_Util_dcprefix="${LIBUI_DOTFILE}/display-"
_Util_statsfile="${LIBUI_DOTFILE}/stats"
_Util_failedtests=( )
_Util_addoptft=false
_Util_addopttf=false
_Util_allowroot=false
_Util_debug=false
_Util_helloworld=false
_Util_multiuser=false
_Util_nolog=false
_Util_optcnt=0
_Util_parray=false
_Util_requireroot=false
_Util_verify=false
_Util_workdir="${PWD}"
GetTmp _Util_tmpdir

# info compare text
infotext="
USAGE: libui [-c|-d|-i|-l|-L|-m|-M|-p|-R|-s|-t|-T|-u|-U|-v ...|-C|-F|-H|-h|-N|-Q|-V|-Y] [-e <_Util_shells>] ... [-x <_Util_testopt>] ... [-X <level>] [<_Util_param>]

  -c  Config           - Create default configuration file \"${HOME}/.libui/libui.conf\". (_Util_config: false)
  -d  Demo             - Provide capabilities demonstration. (_Util_demo: false)
  -e  Execution        - Specify shell for regression testing (otherwise both bash and zsh). (_Util_shells: zsh, bash)
  -i  Install          - Install libui into provided directory (or COMMONROOT). (_Util_install: false)
  -l  List             - List files that would be included in a libui package. (_Util_list: false)
  -L  Lockfiles        - Remove leftover lockfiles. (_Util_unlock: false)
  -m  Man Page         - Display man page.
  -M  Update Man Pages - Update man page timestamps to match respective script timestamp. (_Util_updatemp: false)
  -p  Package          - Create a libui.sh package with the provided filename. (_Util_package: false)
  -R  Reset Caches     - Reset display and user information caches. (_Util_cachereset: false)
  -s  Stats            - Display stats. (_Util_stats: false)
  -t  Test             - Perform libui regression testing. (_Util_testing: false)
  -T  (Single) Test    - Perform single test. (_Util_singletest: false)
  -u  Update           - Update libui in COMMONROOT (or provided directory). (_Util_update: false)
  -U  Unify            - Unify environment by removing files already in COMMONROOT (or provided directory). (_Util_unify: false)
  -v  Verify           - Verify libui in COMMONROOT (or provided directory). (_Util_vlevel: )
  -x  Test Option      - (Only for test.) Set test mode. (_Util_testopt: X)
  -C  Confirm          - Confirm operations before performing them. (confirm: false)
  -F  Force            - Force file operations. (force: false)
  -H  Help             - Display usage message. (help: true)
  -N  No Action        - Show operations without performing them. (noaction: false)
  -Q  Quiet            - Execute quietly. (quiet: false)
  -V  Version          - Display version information. (version: false)
  -X  XDebug           - Set debug level to specified level. (level: 0)
  -Y  Yes              - Provide \"y\" or default answer to asked questions. (yes: false)

  <_Util_param>        - Parameter: Name of the test to perform, package filename, or COMMONROOT directory. (_Util_param: )

  Available option values:
    For -e (Execution): zsh, bash
    For -x (Test Option): b, B, d, m, n, o, oa, oA, os, oS, ov, p, pa, pA, ps, pS, pv, r, R, w, X, aot, one, two, three, four, five

This script provides support functionality for the libui library including
regression testing, capabilities demonstration, and usage statistics reports.

Current test mode options:
    AddOption F/T test. (b: false)
    AddOption T/F test. (B: false)
    Debug mode (d: false)
    Multiuser test. (m: false)
    No log test. (n: false)
    Option test. (o: 0, X)
    Parameter array test. (p: false)
    Root allowed test. (r: false)
    Root required test. (R: false)
    Hello World test. (w: false)

"

#####
#
# setup utility
#
#####

UICMD+=( 'LibuiUtilitySetup' )
LibuiUtilitySetup () {
  ${_S} && ((_cLibuiUtilitySetup++))
  ${_M} && _Trace 'LibuiUtilitySetup [%s]' "${*}"

  ${_M} && _Trace 'Parameter flags capture for tests.' "${arg[*]}}"
  [[ " ${arg[*]} " =~ .*\ -P\ .* ]] && LoadMod Profile
  [[ " ${arg[*]} " =~ .*\ -T\ .* ]] && TERMINAL=true
  [[ " ${arg[*]} " =~ .*\ -x\ *oa\ .* ]] && aopt=true || aopt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *oA\ .* ]] && Aopt=true || Aopt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *os\ .* ]] && sopt=true || sopt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *oS\ .* ]] && Sopt=true || Sopt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *ov\ .* ]] && vopt=true || vopt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *pa\ .* ]] && aparam=true || aparam=false
  [[ " ${arg[*]} " =~ .*\ -x\ *pA\ .* ]] && Aparam=true || Aparam=false
  [[ " ${arg[*]} " =~ .*\ -x\ *ps\ .* ]] && sparam=true || sparam=false
  [[ " ${arg[*]} " =~ .*\ -x\ *pS\ .* ]] && Sparam=true || Sparam=false
  [[ " ${arg[*]} " =~ .*\ -x\ *pv\ .* ]] && vparam=true || vparam=false
  [[ " ${arg[*]} " =~ .*\ -x\ *m\ .* ]] && LoadMod Multiuser && Multiuser
  [[ " ${arg[*]} " =~ .*\ -x\ *r\ .* ]] && LoadMod Root && AllowRoot
  [[ " ${arg[*]} " =~ .*\ -x\ *R\ .* ]] && LoadMod Root && RequireRoot
  [[ " ${arg[*]} " =~ .*\ -x\ *p\ .* ]] && popt='-m' # set AddParameter option for testing
  [[ " ${arg[*]} " =~ .*\ -p\ .* ]] && popt='-r' # set AddParameter option for package

  ${_M} && _Trace 'Set up utility options.'
  [[ " ${arg[*]} " =~ .*\ -x\ *b\ .* ]] && AddOption -n binaryft -f -k 'Binary F/T' -d '(Only for test.) For testing AddOption -f option.' b
  [[ " ${arg[*]} " =~ .*\ -x\ *B\ .* ]] && AddOption -n binarytf -t -k 'Binary T/F' -d '(Only for test.) For testing AddOption -t option.' B
  AddOption -n _Util_config -f -k 'Config' -d 'Create default configuration file "${_Util_configfile}".' c
  AddOption -n _Util_demo -f -k 'Demo' -d 'Provide capabilities demonstration.' d
  AddOption -n _Util_shells -m -s 'zsh' -s 'bash' -i 'zsh' -i 'bash' -k 'Execution' -d 'Specify shell for regression testing (otherwise both bash and zsh).' e:
  AddOption -n _Util_install -f -k 'Install' -d 'Install libui into provided directory (or COMMONROOT).' i
  AddOption -n _Util_list -f -k 'List' -d 'List files that would be included in a libui package.' l
  AddOption -n _Util_unlock -f -k 'Lockfiles' -d 'Remove leftover lockfiles.' L
  AddOption -c ManualCallback -k 'Man Page' -d 'Display man page.' m
  AddOption -n _Util_updatemp -f -k 'Update Man Pages' -d 'Update man page timestamps to match respective script timestamp.' M
  AddOption -n _Util_package -f -k 'Package' -d 'Create a libui.sh package with the provided filename.' p
  AddOption -n _Util_cachereset -f -k 'Reset Caches' -d 'Reset display and user information caches.' R
  AddOption -n _Util_stats -f -k 'Stats' -d 'Display stats.' s
  AddOption -n _Util_testing -f -k 'Test' -d 'Perform libui regression testing.' t
  AddOption -n _Util_singletest -c SingleTestCallback -f -k '(Single) Test' -d 'Perform single test.' T
  AddOption -n _Util_update -f -k 'Update' -d 'Update libui in COMMONROOT (or provided directory).' u
  AddOption -n _Util_unify -f -k 'Unify' -d 'Unify environment by removing files already in COMMONROOT (or provided directory).' U
  AddOption -n _Util_vlevel -c VerifyCallback -m -p true -k 'Verify' -d 'Verify libui in COMMONROOT (or provided directory).' v
  availopt=( b B d m n o oa oA os oS ov p pa pA ps pS pv r R w X aot one two three four five )
  _Util_testopt=( X )
  AddOption -n _Util_testopt -c TestModeCallback -m -S availopt -k 'Test Option' -d '(Only for test.) Set test mode.' x:
  testvalues=( x y z )
  ${aopt} && AddOption -n _Util_opta -s a -a -k 'Test a' -d 'Test option a.' Z:
  ${Aopt} && AddOption -n _Util_optA -s A -k 'Test A' -d 'Test option A.' Z:
  ${sopt} && AddOption -n _Util_opts -s a -s b -s c -k 'Test s' -d 'Test option s.' Z:
  ${Sopt} && AddOption -n _Util_optS -S testvalues -k 'Test S' -d 'Test option S.' Z:
  ${vopt} && AddOption -n _Util_optv -v ValidCallback -k 'Test v' -d 'Test option v.' Z:
  ${aparam} && AddParameter -s a -a -k 'Test Param' -d 'Test parameter a.' _Util_testparam
  ${Aparam} && AddParameter -s A -k 'Test Param' -d 'Test parameter A.' _Util_testparam
  ${sparam} && AddParameter -s a -s b -s c -k 'Test Param' -d 'Test parameter s.' _Util_testparam
  ${Sparam} && AddParameter -S testvalues -k 'Test Param' -d 'Test parameter S.' _Util_testparam
  ${vparam} && AddParameter -v ValidCallback -k 'Test Param' -d 'Test parameter v.' _Util_testparam
  AddParameter ${popt} -i '' -k 'Parameter' -d 'Name of the test to perform, package filename, or COMMONROOT directory.' _Util_param

  ##### callbacks

  # single test callback
  SingleTestCallback () {
    ${_M} && _Trace 'Set up for single test.'
    _Util_testing=true
  }

  # test mode callback
  TestModeCallback () {
    ${_M} && _Trace 'Set up test mode. (%s)' "${1}"
    case ${1} in
      b)
        ${_M} && _Trace 'Set up AddOption False / True test.'
        _Util_addoptft=true
        ;;

      B)
        ${_M} && _Trace 'Set up AddOption True / False test.'
        _Util_addopttf=true
        ;;

      d)
        ${_M} && _Trace 'Set up test debug.'
        _Util_debug=true
        ;;

      m)
        ${_M} && _Trace 'Set up for multiuser testing.'
        _Util_multiuser=true
        ;;

      n)
        ${_M} && _Trace 'Set up no log testing.'
        _Util_nolog=true
        ;;

      o)
        ${_M} && _Trace 'Increment option count.'
        ((_Util_optcnt++))
        ;;

      p)
        ${_M} && _Trace 'Set up parameter array test.'
        _Util_parray=true
        ;;

      r)
        ${_M} && _Trace 'Set up allow root test.'
        _Util_allowroot=true
        ;;

      R)
        ${_M} && _Trace 'Set up require root test.'
        _Util_requireroot=true
        ;;

      w)
        ${_M} && _Trace 'Set up hello world test.'
        _Util_helloworld=true
        ;;

      *)
        ${_M} && _Trace 'Received additional argument. (%s)' "${1}"
        ;;

    esac
  }

  # for -m - display manual callback
  ManualCallback () {
    ${_M} && _Trace 'Display manual.'
    man() {
      LESS_TERMCAP_mb="$(tput bold; tput setaf 5)" \
      LESS_TERMCAP_md="$(tput bold; tput setaf 6)" \
      LESS_TERMCAP_me="$(tput sgr0)" \
      LESS_TERMCAP_se="$(tput sgr0)" \
      LESS_TERMCAP_so="$(tput bold; tput setaf 1)" \
      LESS_TERMCAP_ue="$(tput rmul; tput sgr0)" \
      LESS_TERMCAP_us="$(tput smul; tput bold; tput setaf 3)" \
      command man "$@"
    }

    if man libui.sh &> /dev/null
    then
      man libui.sh
    elif man ${LIBUI%/*}/../../man/man3/libui.sh.3 &> /dev/null
    then
      man ${LIBUI%/*}/../../man/man3/libui.sh.3
    elif man ${LIBUI%/*}/libui.sh.3 &> /dev/null
    then
      man ${LIBUI%/*}/libui.sh.3
    fi

    Exit 0
  }

  # valid callback
  ValidCallback () {
    Tell 'Validation test. (v == %s)' "${_Util_optv}${_Util_testparam}"
    _Util_helloworld=true
  }

  # verify callback
  VerifyCallback () {
    ${_M} && _Trace 'Set up for verify.'
    _Util_verify=true
  }

  # info callback
  InfoCallback () {
    ${_M} && _Trace 'In user usage information callback.'
    cat << EOF
This script provides support functionality for the libui library including
regression testing, capabilities demonstration, and usage statistics reports.

Current test mode options:
    AddOption F/T test. (b: ${_Util_addoptft})
    AddOption T/F test. (B: ${_Util_addopttf})
    Debug mode (d: ${_Util_debug})
    Multiuser test. (m: ${_Util_multiuser})
    No log test. (n: ${_Util_nolog})
    Option test. (o: ${_Util_optcnt}, ${_Util_testopt[*]})
    Parameter array test. (p: ${_Util_parray})
    Root allowed test. (r: ${_Util_allowroot})
    Root required test. (R: ${_Util_requireroot})
    Hello World test. (w: ${_Util_helloworld})
EOF
  }

  ExitCallback () {
    ${_M} && _Trace 'In user exit callback.'

    ${_Util_debug} || [[ -n "${_Util_failedtests}" && -n "${_Util_tmpdir}" ]] && Verify 'Delete logs and exit? (%s)' "${_Util_tmpdir}"
  }

  InitCallback () {
    ${_M} && _Trace 'Program initialization.'

    ${_M} && _Trace 'Get test name. (%s)' "${_Util_parray}"
    if ${_Util_parray}
    then
      _Util_tname="${_Util_param[${AO}]}"
    else
      _Util_tname="${_Util_param}"
    fi

    if ${_Util_install} || ${_Util_verify} || ${_Util_update} || ${_Util_unify}
    then
      ${_M} && _Trace 'Obtaining commonroot info. (%s / %s)' "${COMMONROOT}" "${_Util_param}"
      [[ -n "${_Util_param}" ]] && COMMONROOT="${_Util_param}"
      ConfirmVar -q 'Please provide a COMMONROOT directory path:' -d COMMONROOT
      if PathMatches "${_Util_libuiroot}" "${COMMONROOT}"
      then
        Error 'The libui root is COMMONROOT. (%s)' "${COMMONROOT}"
      fi
    elif ${_Util_testing}
    then
      ${_M} && _Trace 'Set up test directory. (%s)' "${TESTDIR}"
      if [[ -z "${TESTDIR}" ]]
      then
        ${_M} && _Trace 'Initialize TESTDIR.'
        export TESTDIR="${_Util_tmpdir}"
        ${_Util_debug} && Tell 'Test directory is: %s' "${TESTDIR}"
      fi
      ConfirmVar -d TESTDIR
      pushd "${TESTDIR}" > /dev/null

      ${_M} && _Trace 'Define log. (%s)' "${TESTDIR}/test.log"
      log=">> \"${TESTDIR}/test.log\" 2>&1; rv=\${?}"
      if ${ZSH}
      then
        ${_Util_debug} && log="2>&1 | tee -a \"${TESTDIR}/test.log\"; rv=\"\${pipestatus[1]}\""
      else
        ${_Util_debug} && log="2>&1 | tee -a \"${TESTDIR}/test.log\"; rv=\"\${PIPESTATUS[0]}\""
      fi
    fi
  }
}


#####
#
# libui support functions
#
#####

UICMD+=( 'LibuiTest' )
LibuiTest () {
  ${_S} && ((_cLibuiTest++))
  ${_M} && _Trace 'LibuiTest [%s]' "${*}"

  local _Util_failedids; _Util_failedids=( )
  local _Util_rv=0
  local _Util_success=true
  local _Util_subopt='-t '

  LibuCheckResults () {
    ${_M} && _Trace 'LibuCheckResults [%s]' "${*}"

    local _Util_pass="${4}" # pass
    local _Util_rv="${3}" # return value
    local _Util_shell="${1}" # shell
    local _Util_test="${2}" # test

    ${_M} && _Trace 'Check %s.' "${*}"
    ${_Util_debug} && Tell 'Check return value. (%s)' "${_Util_rv}"
    case "${_Util_rv}" in
      0)
        #${_Util_debug} && ${_Util_pass} && Alert 'Test passed in %s. (%s)' "${_Util_shell}" "${_Util_test}"
        ;;

      33)
        Tell "${DFy}Associative arrays are not available in this version of %s. (%s)${D}" "${_Util_shell}" "${_Util_test}"
        _Util_rv=0
        ;;

      *)
        ${_Util_pass} && Tell "${DFr}Test failed in %s with %s. (%s)${D}" "${_Util_shell}" "${_Util_rv}" "${_Util_test}"
        ;;

    esac

    ${_M} && _Trace 'LibuCheckResults return. (%s)' "${_Util_rv}"
    return ${_Util_rv}
  }

  ${_M} && _Trace 'Load libui tests.'
  source "${SHLIBPATH}/libui-tests.sh"

  ${_M} && _Trace 'Start %s. (%s)' "${CMD}" "${CMDLINE}"
  [[ -n "${_Util_tname}" ]] && Tell '\n=====\nStarted "%s" (%s) in %s with: %s' "${_Util_tname}" "${COUNT}" "${SHELL}" "${CMDLINE[*]}"

  ${_M} && _Trace 'Check for test. (%s)' "${_Util_tname}"
  if [[ -z "${_Util_tname}" ]]
  then
    local _Util_ds="$(date)"
    local _Util_exec
    local _Util_test
    local _Util_tr

    ${_M} && _Trace 'Start log.'
    Tell 'Test environment:'
    Version
    Tell 'Begin libui %s with %s tests on %s. (%s)' "${LIBUI_VERSION}" "${#tests[@]}" "${_Util_ds}" "${_Util_tmpdir}"
    StartTimer _Util_logtimer

    ${_M} && _Trace 'Check for debug. (%s)' "${_Util_debug}"
    ${_Util_debug} && _Util_subopt+='-x '
    ((0 < _xdb)) && _Util_subopt+="-X ${_xdb} "

    ${_M} && _Trace 'Execute tests. (%s)' "${#tests[@]}"
    _Util_count=1
    local _Util_count=1
    for _Util_test in "${tests[@]}"
    do
      ${_M} && _Trace 'Prepare test command: %s %s%s.' "${CMD}" "${_Util_subopt}" "${_Util_test}"
      env="LIBUI_TRACE=false COUNT=${_Util_count}"
      [[ 'test_Logfile' == "${_Util_test}" ]] && env+=" LIBUI_LOGFILE='${_Util_tmpdir}/logfile.log'"
      case "${_Util_test}" in
        *test_*)
          warn=''
          cond='-eq'
          pass=true
          ;;

        *errout_*)
          warn='-W'
          cond='-lt'
          pass=false
          ;;

        *)
          Error 'Invalid test type. (%s)' "${_Util_test}"
          ;;

      esac

      ${_M} && _Trace 'Execute test. (%s)' "${_Util_test}"
      ${_Util_debug} && Tell 'Execute test. (%s)' "${_Util_test}"
      StartTimer _Util_testtimer
      _Util_tr=0
      for _Util_exec in "${_Util_shells[@]}"
      do
        ${_M} && _Trace 'Test command: %s' "${_Util_exec} ${CMDPATH} ${_Util_subopt}${_Util_test}"
        ${_Util_debug} && Tell 'Test command: %s' "${_Util_exec} ${CMDPATH} ${_Util_subopt}${_Util_test}"
        eval "Action ${warn} \"${env} ${_Util_exec} ${CMDPATH} ${_Util_subopt}${_Util_test}\" ${log}"
        LibuCheckResults "${_Util_exec}" "${_Util_test}" "${rv}" "${pass}"
        _Util_tr=$((_Util_tr + ${?}))
      done
      GetElapsed _Util_testtimer
      ${_Util_debug} && Tell 'Finished test %s in %.4f seconds.' "${_Util_test}" "${ELAPSED}"

      ${_M} && _Trace 'Check results. (0 %s %s)' "${cond}" "${_Util_tr}"
      if [ 0 ${cond} "${_Util_tr}" ]
      then
        Alert 'Test %03d passed in %.4f seconds. (%s)' "${_Util_count}" "${ELAPSED}" "${_Util_test}"
      else
        _Util_success=false
        _Util_failedids+=( ${_Util_count} )
        _Util_failedtests+=( ${_Util_test} )
        Warn 'Test %03d failed. (%s)' "${_Util_count}" "${_Util_test}"
        ${_Util_debug} && if ! Verify 'Continue?'
        then
          ${_M} && _Trace 'Quit %s. (%s)' "${CMD}" 0
          Exit 2
        fi
      fi

      ((_Util_count++))
    done

    ${_M} && _Trace 'End log.'
    GetElapsed _Util_logtimer
    _Util_ds="$(date)"
    Tell 'Completed %d tests in %.4f seconds on %s.' "${#tests[@]}" "${ELAPSED}" "${_Util_ds}"

    ${_M} && _Trace 'Check version equivalence. (%s)' "${Version[1]##* }"
    tv="${UIVERSION[-1]##* }"
    ${_M} && _Trace 'Check for test / UI version compatability. (test: %s, libui: %s)' "${tv}" "${LIBUI_VERSION}"
    ((${tv//.} == ${LIBUI_VERSION//.})) || Warn '%s: Test script and libui versions do not match. (test: %s, libui: %s)' "${CMD}" "${tv}" "${LIBUI_VERSION}"

    ${_M} && _Trace 'Test suite results. (%s)' "${_Util_success}"
    ${_M} && _Trace 'Report. (%s)' "${_Util_success}"
    if ${_Util_success}
    then
      Alert 'Test suite successful. Passed %s tests.' "${#tests[@]}"
    else
      Error -E 'Test suite not successful.'
      Tell 'Failed %s out of %s tests:' "${#_Util_failedtests[@]}" "${#tests[@]}"
      for ((i = AO; i < $((${#_Util_failedtests[@]} + AO)); i++))
      do
        Tell '  %s %s' "${_Util_failedids[${i}]}" "${_Util_failedtests[${i}]}"
      done
    fi
  else
    ${_M} && _Trace 'Check for test. (%s)' "${_Util_tname}"
    if declare -f ${_Util_tname} > /dev/null
    then
      ${_M} && _Trace 'Execute %s test. (%s)' "${SHELL}" "${_Util_tname}"
      ${_Util_tname}
      _Util_rv=${?}
    else
      _Terminal
      Error -e 'Test not available: %s.' "${_Util_tname}"
      _Util_rv=1
    fi
  fi

  ${_M} && _Trace 'Return to prior directory.'
  popd > /dev/null

  ${_M} && _Trace 'LibuiTest return. (%s)' "${_Util_rv}"
  return ${_Util_rv}
}

UICMD+=( 'LibuiConfig' )
LibuiConfig () {
  ${_S} && ((_cLibuiConfig++))
  ${_M} && _Trace 'LibuiConfig [%s]' "${*}"

  local _Util_rv=0

  if Force || [[ ! -f "${_Util_configfile}" ]] || Verify 'Really overwrite libui configuration file %s?' "${_Util_configfile}"
  then
    Tell 'Create default config file. (%s)' "${_Util_configfile}"
    LoadMod File
    Open -1 -c ${_Util_configfile}
    Write -1 "#####${N}#${N}# libui.conf - $(date)${N}#${N}######${N}"
    Write -1 "# use LIBUI_<VAR>=\"\${LIBUI_<VAR>:-<value>}\" to support temporary command line environment changes.${N}"
    Write -1 "$(grep 'LIBUI_' "${LIBUI}" | grep 'LIBUI_\S*:-' | sed 's/^.*\(LIBUI_.*:-.*\)}.*$/\1/' | sed 's/}[";].*$//' | sed -E 's/(LIBUI_.*):-(.*)$/\1="${\1:-\2}"/' | sed 's/^/#/' | sort -u)"
    Close -1
    Alert 'Config file has been created. (%s)' "${_Util_configfile}"
  fi
  _Util_rv=${?}

  ${_M} && _Trace 'LibuiConfig return. (%s)' "${_Util_rv}"
  return ${_Util_rv}
}

UICMD+=( 'LibuiDemo' )
LibuiDemo () {
  ${_S} && ((_cLibuiDemo++))
  ${_M} && _Trace 'LibuiDemo [%s]' "${*}"

  if ${TERMINAL}
  then
    Tell 'Available display codes:'
    _Terminal
    [[ -z "${DCS}" ]] && Warn 'Clear screen (DCS) not defined.' || printf '\t%s\n' 'Clear screen (DCS).'
    [[ -z "${DCEL}" ]] && Warn 'Clear to end of line (DCEL) not defined.' || printf '\t%s\n' 'Clear to end of line (DCEL).'
    [[ -z "${DCES}" ]] && Warn 'Clear to end of screen (DCES) not defined.' || printf '\t%s\n' 'Clear to end of screen (DCES).'
    [[ -z "${DJBL}" ]] && Warn 'Jump to beginning of line (DJBL) not defined.' || printf '\t%s\n' 'Jump to beginning of line (DJBL).'
    [[ -z "${DJH}" ]] && Warn 'Jump to home (DJH) not defined.' || printf '\t%s\n' 'Jump to home (DJH).'
    [[ -z "${DRP}" ]] && Warn 'Read cursor position (DRP) not defined.' || printf '\t%s\n' 'Read cursor position (DRP).'
    [[ -z "${Db0}" ]] && Warn 'Black background (Db0) not defined.' || printf "\t${Db0}%s${D}\n" 'Black background (Db0).'
    [[ -z "${Dbr}" ]] && Warn 'Red background (Dbr) not defined.' || printf "\t${Dbr}%s${D}\n" 'Red background (Dbr).'
    [[ -z "${Dbg}" ]] && Warn 'Green background(Dbg) not defined.' || printf "\t${Dbg}%s${D}\n" 'Green background(Dbg).'
    [[ -z "${Dby}" ]] && Warn 'Yellow background (Dby) not defined.' || printf "\t${Dby}%s${D}\n" 'Yellow background (Dby).'
    [[ -z "${Dbb}" ]] && Warn 'Blue background (Dbb) not defined.' || printf "\t${Dbb}%s${D}\n" 'Blue background (Dbb).'
    [[ -z "${Dbm}" ]] && Warn 'Magenta background (Dbm) not defined.' || printf "\t${Dbm}%s${D}\n" 'Magenta background (Dbm).'
    [[ -z "${Dbc}" ]] && Warn 'Cyan background (Dbc) not defined.' || printf "\t${Dbc}%s${D}\n" 'Cyan background (Dbc).'
    [[ -z "${Db7}" ]] && Warn 'White background (Db7) not defined.' || printf "\t${Db7}%s${D}\n" 'White background (Db7).'
    [[ -z "${DB0}" ]] && Warn 'Bright black background (DB0) not defined.' || printf "\t${DB0}%s${D}\n" 'Bright black background (DB0).'
    [[ -z "${DBr}" ]] && Warn 'Bright red background (DBr) not defined.' || printf "\t${DBr}%s${D}\n" 'Bright red background (DBr).'
    [[ -z "${DBg}" ]] && Warn 'Bright green background (DBg) not defined.' || printf "\t${DBg}%s${D}\n" 'Bright green background (DBg).'
    [[ -z "${DBy}" ]] && Warn 'Bright yellow background (DBy) not defined.' || printf "\t${DBy}%s${D}\n" 'Bright yellow background (DBy).'
    [[ -z "${DBb}" ]] && Warn 'Bright blue background (DBb) not defined.' || printf "\t${DBb}%s${D}\n" 'Bright blue background (DBb).'
    [[ -z "${DBm}" ]] && Warn 'Bright magenta background (DBm) not defined.' || printf "\t${DBm}%s${D}\n" 'Bright magenta background (DBm).'
    [[ -z "${DBc}" ]] && Warn 'Bright cyan background (DBc) not defined.' || printf "\t${DBc}%s${D}\n" 'Bright cyan background (DBc).'
    [[ -z "${DB7}" ]] && Warn 'Bright white background (DB7) not defined.' || printf "\t${DB7}%s${D}\n" 'Bright white background (DB7).'
    [[ -z "${Df0}" ]] && Warn 'Black foreground (Df0) not defined.' || printf "\t${Df0}%s${D}\n" 'Black foreground (Df0).'
    [[ -z "${Dfr}" ]] && Warn 'Red foreground (Dfr) not defined.' || printf "\t${Dfr}%s${D}\n" 'Red foreground (Dfr).'
    [[ -z "${Dfg}" ]] && Warn 'Green foreground (Dfg) not defined.' || printf "\t${Dfg}%s${D}\n" 'Green foreground (Dfg).'
    [[ -z "${Dfy}" ]] && Warn 'Yellow foreground (Dfy) not defined.' || printf "\t${Dfy}%s${D}\n" 'Yellow foreground (Dfy).'
    [[ -z "${Dfb}" ]] && Warn 'Blue foreground (Dfb) not defined.' || printf "\t${Dfb}%s${D}\n" 'Blue foreground (Dfb).'
    [[ -z "${Dfm}" ]] && Warn 'Magenta foreground (Dfm) not defined.' || printf "\t${Dfm}%s${D}\n" 'Magenta foreground (Dfm).'
    [[ -z "${Dfc}" ]] && Warn 'Cyan foreground (Dfc) not defined.' || printf "\t${Dfc}%s${D}\n" 'Cyan foreground (Dfc).'
    [[ -z "${Df7}" ]] && Warn 'White foreground (Df7) not defined.' || printf "\t${Df7}%s${D}\n" 'White foreground (Df7).'
    [[ -z "${DF0}" ]] && Warn 'Bright black foreground (DF0) not defined.' || printf "\t${DF0}%s${D}\n" 'Bright black foreground (DF0).'
    [[ -z "${DFr}" ]] && Warn 'Bright red foreground (DFr) not defined.' || printf "\t${DFr}%s${D}\n" 'Bright red foreground (DFr).'
    [[ -z "${DFg}" ]] && Warn 'Bright green foreground (DFg) not defined.' || printf "\t${DFg}%s${D}\n" 'Bright green foreground (DFg).'
    [[ -z "${DFy}" ]] && Warn 'Bright yellow foreground (DFy) not defined.' || printf "\t${DFy}%s${D}\n" 'Bright yellow foreground (DFy).'
    [[ -z "${DFb}" ]] && Warn 'Bright blue foreground (DFb) not defined.' || printf "\t${DFb}%s${D}\n" 'Bright blue foreground (DFb).'
    [[ -z "${DFm}" ]] && Warn 'Bright magenta foreground (DFm) not defined.' || printf "\t${DFm}%s${D}\n" 'Bright magenta foreground (DFm).'
    [[ -z "${DFc}" ]] && Warn 'Bright cyan foreground (DFc) not defined.' || printf "\t${DFc}%s${D}\n" 'Bright cyan foreground (DFc).'
    [[ -z "${DF7}" ]] && Warn 'Bright white foreground (DF7) not defined.' || printf "\t${DF7}%s${D}\n" 'Bright white foreground (DF7).'
    [[ -z "${Db}" ]] && Warn 'Bold text (Db) not defined.' || printf "\t${Db}%s${D}\n" 'Bold text (Db).'
    [[ -z "${Dd}" ]] && Warn 'Dim text (Dd) not defined.' || printf "\t${Dd}%s${D}\n" 'Dim text (Dd).'
    [[ -z "${Dsu}" ]] && Warn 'Start underline (Dsu) not defined.' || printf "\t${Dsu}%s${D}\n" 'Start underline (Dsu).'
    [[ -z "${Deu}" ]] && Warn 'End underline (Deu) not defined.' || printf "\t${Deu}%s${D}\n" 'End underline (Deu).'
    [[ -z "${Dr}" ]] && Warn 'Reverse display (Dr) not defined.' || printf "\t${Dr}%s${D}\n" 'Reverse display (Dr).'
    [[ -z "${Dss}" ]] && Warn 'Start standout text (Dss) not defined.' || printf "\t${Dss}%s${D}\n" 'Start standout text (Dss).'
    [[ -z "${Des}" ]] && Warn 'End standout text (Des) not defined.' || printf "\t${Des}%s${D}\n" 'End standout text (Des).'
    [[ -z "${D}" ]] && Warn 'Reset hightlighting (D) not defined.' || printf "\t${D}%s${D}\n" 'Reset hightlighting (D).'
  else
    Warn 'Terminal display codes are not available without a terminal.'
  fi

  Tell '\nDisplay formats:'
  Tell "\t${DAction}Action format."
  Tell "\t${DAlarm}Alarm format."
  Tell "\t${DAlert}Alert format."
  Tell "\t${DAnswer}Answer format."
  Tell "\t${DCaution}Caution format."
  Tell "\t${DConfirm}Confirm format."
  Tell "\t${DError}Error format."
  Tell "\t${DInfo}Info format."
  Tell "\t${DNoAction}No Action format."
  Tell "\t${DOptions}Options format."
  Tell "\t${DQuestion}Question format."
  Tell "\t${DSpinner}Spinner format."
  Tell "\t${DTell}Tell format."
  Tell "\t${DTrace}Trace format."
  Tell "\t${DWarn}Warning format."

  Tell '\nDisplay modes:'
  Tell "\t${D0}Display mode %d." 0
  Tell "\t${D1}Display mode %d." 1
  Tell "\t${D2}Display mode %d." 2
  Tell "\t${D3}Display mode %d." 3
  Tell "\t${D4}Display mode %d." 4
  Tell "\t${D5}Display mode %d." 5
  Tell "\t${D6}Display mode %d." 6
  Tell "\t${D7}Display mode %d." 7
  Tell "\t${D8}Display mode %d." 8
  Tell "\t${D9}Display mode %d." 9

  Tell '\nExecution environment:'
  Tell "\tAssociative array (AA):          ${DFc}%s${D}" "${AA}"
  Tell "\tArray offset (AO):               ${DFc}%s${D}" "${AO}"
  Tell "\tInitial working directory (IWD): ${DFc}%s${D}" "${IWD}"
  Tell "\tBash version (BV):               ${DFc}%s${D}" "${BV}"
  Tell "\tCommand line string (CMDLINE):   ${DFc}%s${D}" "${CMDLINE[*]}"
# Tell "\tCursor position (CROW, CCOL):    ${DFc}%s${D}" "${CROW}, ${CCOL}"
  Tell "\tDomain name (DOMAIN):            ${DFc}%s${D}" "${DOMAIN}"
  Tell "\tEffective UID (EUID):            ${DFc}%s${D} (note: consumed, not generated)" "${EUID}"
  Tell "\tHost name (HOST):                ${DFc}%s${D}" "${HOST}"
  Tell "\tPath of libui library (LIBUI):   ${DFc}%s${D}" "${LIBUI}"
  Tell "\tMax integer (MAXINT):            ${DFc}%s${D}" "${MAXINT}"
  Tell "\tNumber of options (NROPT):       ${DFc}%s${D}" "${NROPT}"
  Tell "\tNumber of parameters (NRPARAM):  ${DFc}%s${D}" "${NRPARAM}"
  Tell "\tOperating system (OS):           ${DFc}%s${D}" "${OS}"
  Tell "\tProgram name (CMD):              ${DFc}%s${D}" "${CMD}"
  Tell "\tSupports printf -v (PV):         ${DFc}%s${D}" "${PV}"
  Tell "\tScreen size (SROWS, SCOLS):      ${DFc}%s${D}" "${SROWS}, ${SCOLS}"
  Tell "\tShell (SHELL):                   ${DFc}%s${D}" "${SHELL}"
  Tell "\tShell library path (SHLIBPATH):  ${DFc}%s${D}" "${SHLIBPATH}"
  Tell "\tOutput to terminal (TERMINAL):   ${DFc}%s${D}" "${TERMINAL}"
  Tell "\tLoaded UI mods (UIMOD):          ${DFc}%s${D}" "${UIMOD[*]}"
# Tell "\tTracked UI functions (UICMD):    ${DFc}%s${D}" "${UICMD[*]}"
  Tell "\tUser name (USER):                ${DFc}%s${D} (note: consumed, not generated)" "${USER}"
  Tell "\tUsing Z shell (ZSH):             ${DFc}%s${D}" "${ZSH}"
  Tell "\tZ shell version (ZV):            ${DFc}%s${D}" "${ZV}"

  ${_M} && _Trace 'LibuiDemo return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiStats' )
LibuiStats () {
  ${_S} && ((_cLibuiStats++))
  ${_M} && _Trace 'LibuiStats [%s]' "${*}"

  ${_M} && _Trace 'Prepare to display stats. (%s)' "${_Util_statsfile}"
  ( # subshell
    source "${_Util_statsfile}"
    ${ZSH} && ((_cav = ${_ctime} / ${_crun})) || _cav="$(bc <<< "scale=6; ${_ctime} / ${_crun}")"
    Tell '%-17s %28s' 'Stats since:' "${_cstart}"
    values=(
      'Total Runs:' "${_crun}"
      'Total Run Time:' "${_ctime}"
      'Average Run Time:' "${_cav}"
      'Function Calls:' ''
    )
    Tell '%-30s %20s' "${values[@]}"
    Sort UICMD
    for stat in "${UICMD[@]}"
    do
      eval "Tell '%-30s %20s' '  ${stat}:' \"\${_c${stat}}\""
    done
  )

  ${_M} && _Trace 'LibuiStats return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiReset' )
LibuiReset () {
  ${_S} && ((_cLibuiReset++))
  ${_M} && _Trace 'LibuiReset [%s]' "${*}"

  ${_M} && _Trace 'Prepare to reset stats file %s.' "${_Util_statsfile}"
  if [[ -e "${_Util_statsfile}" ]]
  then
    if Verify 'Really reset stats file %s?' "${_Util_statsfile}"
    then
      ${_M} && _Trace 'Remove stats file %s.' "${_Util_statsfile}"
      Action "rm ${FMFLAGS} '${_Util_statsfile}'"
      Alert 'Stats file has been removed. (%s)' "${_Util_statsfile}"
    fi
  fi

  GetFileList cachefiles "${_Util_dcprefix}*"
  ${_M} && _Trace 'Prepare to remove cache files. (%s)' "${cachefiles[*]}"
  if [[ -n "${cachefiles}" ]]
  then
    if Verify 'Really remove cache files? (%s)' "${cachefiles[*]}"
    then
      local _Util_file
      for _Util_file in "${cachefiles[@]}"
      do
        if [[ -e "${_Util_file}" ]]
        then
          ${_M} && _Trace 'Remove cache %s.' "${_Util_file}"
          Action -q "Really remove ${_Util_file} cache?" "rm ${FMFLAGS} '${_Util_file}'"
        fi
      done
      Alert 'Cache files have been removed. (%s)' "${cachefiles[*]}"
    fi
  fi

  ${_M} && _Trace 'Reset user info.'
  Verify 'Really update user info?' && SetUserInfo -u

  ${_M} && _Trace 'LibuiReset return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiUnlock' )
LibuiUnlock () {
  ${_S} && ((_cLibuiUnlock++))
  ${_M} && _Trace 'LibuiUnlock [%s]' "${*}"

  local _Util_lockfiles
  local _Util_lockfile

  GetFileList _Util_lockfiles "${_Util_lockdir}/*"
  ${_M} && _Trace 'Prepare to remove lockfiles. (%s)' "${_Util_lockfiles[*]}"
  if Verify 'Really remove lockfiles?'
  then
    local _Util_file
    for _Util_file in "${_Util_lockfiles[@]}"
    do
      _Util_lockfile="$(<${_Util_file})"
      ${_M} && _Trace 'Remove lock file %s.' "${_Util_lockfile}"
      if [[ -e "${_Util_lockfile}" ]]
      then
        Action -q "Really remove ${_Util_lockfile} lockfile?" "rm ${FMFLAGS} '${_Util_lockfile}' '${_Util_file}'"
      else
        Action -q "Really remove ${_Util_file} lockfile?" "rm ${FMFLAGS} '${_Util_file}'"
      fi
    done
    Alert 'Lock file(s) have been removed. (%s)' "${_Util_lockfiles[*]}"
  fi

  ${_M} && _Trace 'LibuiUnlock return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiUpdateMan' )
LibuiUpdateMan () {
  ${_S} && ((_cLibuiUpdateMan++))
  ${_M} && _Trace 'LibuiUpdateMan [%s]' "${*}"

  pushd "${_Util_libuiroot}" > /dev/null

  ${_M} && _Trace 'Update man pages in %s.' "${_Util_libuiroot}"
  local _Util_file
  local _Util_fts
  local _Util_mp
  local _Util_mts
  local _Util_sedi; [[ 'Darwin' == "${OS}" ]] && _Util_sedi="-i ''" || _Util_sedi="-i"
  for _Util_file in $(find . -name 'man' -prune -o -name '.*.sw*' -prune -o -type f -print)
  do
    _Util_file="${_Util_file#./}"
    ${ZSH} && eval "man=( ${_Util_libuiroot}/share/man/man*/${_Util_file##*/}.*(N) )" || \
        _Util_mp=( ${_Util_libuiroot}/share/man/man*/${_Util_file##*/}.* )
    _Util_mp="${_Util_mp[${AO}]}"
    ${_M} && _Trace 'Check for %s man page. (%s)' "${_Util_file}" "${_Util_mp}"
    if [[ -f "${_Util_mp}" ]]
    then
      _Util_fts="$(date -r "${_Util_file}" '+%B %e, %Y' 2>/dev/null)"
      _Util_fts="${_Util_fts/  / }"
      _Util_mts=( $(grep '^\.Dd' ${_Util_mp}) ) #.Dd January 1, 2022
      _Util_mts="${_Util_mts#.* }"

      ${_M} && _Trace 'Check man %s (%s) against file %s (%s).' "${_Util_mp}" "${_Util_mts}" "${_Util_file}" "${_Util_fts}"
      if [[ "${_Util_fts}" != "${_Util_mts}" ]]
      then
        Tell 'File timestamps differ: %s (%s) vs. %s (%s).' "${_Util_mp##*/}" "${_Util_mts}" "${_Util_file##*/}" "${_Util_fts}"
        if Verify 'Update man page date?'
        then
          Tell 'Update %s man page timestamp to %s.' "${_Util_mp}" "${_Util_fts}"
          Action "sed ${_Util_sedi} -e 's/^\.Dd ${_Util_mts}/\.Dd ${_Util_fts}/' '${_Util_mp}'"
        fi
      fi
    fi
  done
  Alert 'Man page headers are up to date.'

  popd > /dev/null

  ${_M} && _Trace 'LibuiUpdateMan return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiPackageList' )
LibuiPackageList () {
  ${_S} && ((_cLibuiPackageList++))
  ${_M} && _Trace 'LibuiPackageList [%s]' "${*}"

  pushd "${_Util_libuiroot}" > /dev/null

  ${_M} && _Trace 'List libui package.'
  local _Util_files=( $(find . -name '.*.sw*' -prune -o -name 'libui*') )
  _Util_files+=( $(grep -rl '{libui tool}' . | grep -v '\.sw.$') )

  ${_M} && _Trace 'Files in libui package. (%s)' "${_Util_files[*]}"
  Tell 'Libui Files:'
  printf '  %s\n' "${_Util_files[@]}"

  popd > /dev/null

  ${_M} && _Trace 'LibuiPackageList return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiPackage' )
LibuiPackage () {
  ${_S} && ((_cLibuiPackage++))
  ${_M} && _Trace 'LibuiPackage [%s]' "${*}"

  GetRealPath -d _Util_param
  LoadMod Package

  pushd "${_Util_libuiroot}" > /dev/null

  ${_M} && _Trace 'Create libui package. (%s)' "${_Util_param}"
  local _Util_files=( $(find . -name '.*.sw*' -prune -o -name 'libui*') )
  _Util_files+=( $(grep -rl '{libui tool}' . | grep -v '\.sw.$') )
  ${_M} && _Trace 'Files to include in libui package. (%s)' "${_Util_files[*]}"
  if [[ ".sharp" == "${_Util_param: -6}" ]]
  then
    Action -q 'Create libui shar package archive?' "CreatePackage -S -f _Util_files -x excludes -e '${_Util_installenv}' -i '${_Util_installer}' -s '${_Util_libuiroot}' '${_Util_param}'"
  else
    [[ ".tarp" == "${_Util_param: -5}" ]] || _Util_param+='.tarp'
    Action -q 'Create libui tar package archive?' "CreatePackage -T -f _Util_files -x excludes -e '${_Util_installenv}' -i '${_Util_installer}' -s '${_Util_libuiroot}' '${_Util_param}'"
  fi
  Alert 'Creation of libui package complete. (%s)' "${_Util_param}"

  popd > /dev/null

  ${_M} && _Trace 'LibuiPackage return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiInstall' )
LibuiInstall () {
  ${_S} && ((_cLibuiInstall++))
  ${_M} && _Trace 'LibuiInstall [%s]' "${*}"

  StartSpinner

  ${_M} && _Trace 'Install libui into %s.' "${COMMONROOT}"
  _Util_files=( $(find "${_Util_libuiroot}" -name '.*.sw*' -prune -o -name 'libui*') )
  _Util_files+=( $(grep -rl '{libui tool}' "${_Util_libuiroot}" | grep -v '\.sw.$') )
  local _Util_file
  for _Util_file in "${_Util_files[@]#${_Util_libuiroot%/}/}"
  do
    [[ ! -d "${COMMONROOT}/${_Util_file%/*}" ]] && Action -W "mkdir -p '${COMMONROOT}/${_Util_file%/*}'" && \
        Action -W "chmod ${_Util_groupmode} '${COMMONROOT}/${_Util_file%/*}'"
    Action "cp ${FMFLAGS} "${_Util_libuiroot%/}/${_Util_file}" '${COMMONROOT}/${_Util_file}'"
    Action -W "chmod ${_Util_groupmode} '${COMMONROOT}/${_Util_file}'"
  done

  StopSpinner

  Alert 'Installation of libui into %s complete.' "${COMMONROOT}"
  GetRealPath COMMONROOT
  cat << EOF
To use the library, the following should be added to your environment:

  * Add "${COMMONROOT}/lib/sh" to your PATH to access libui and libui.sh.
  * Add "${COMMONROOT}/bin" to your PATH to access the example scripts.
  * Add "${COMMONROOT}/share/man" to your MANPATH to access the man pages.

Once added, you can use "man 3 libui.sh" or "libui -m" to view the man page.
EOF

  ${_M} && _Trace 'LibuiInstall return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiUnify' )
LibuiUnify () {
  ${_S} && ((_cX++))
  ${_M} && _Trace 'LibuiUnify [%s]' "${*}"

  local _Util_different=false
  local _Util_file

  pushd "${_Util_libuiroot}" > /dev/null

  ${_M} && _Trace 'Verify %s environment with %s.' "${COMMONROOT}" "${_Util_libuiroot}"
  for _Util_file in $(find . -name '.*.sw*' -prune -o -type f -print)
  do
    _Util_file="${_Util_file#./}"
    if [[ -f "${COMMONROOT}/${_Util_file}" ]]
    then
      ${_M} && _Trace 'Check %s against %s.' "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
      Action -W "cmp -s '${_Util_libuiroot}/${_Util_file}' '${COMMONROOT}/${_Util_file}'"
      if ((0 != ${?}))
      then
        Tell 'File differs: %s -> %s' "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
        _Util_different=true
        if [[ 'true' == "${_Util_vlevel[2]}" ]]
        then
          Tell "${Dfy}diff %s %s${D}" "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
          Action -W "diff '${_Util_libuiroot}/${_Util_file}' '${COMMONROOT}/${_Util_file}'"
        fi
      fi
    fi
  done

  ${_M} && _Trace 'Check for different files. (%s)' "${_Util_different}"
  if ${_Util_different}
  then
    ${_M} && _Trace 'Check for update or unify. (%s / %s)' "${_Util_update}" "${_Util_unify}"
    if ${_Util_update}
    then
      if Verify 'Are you sure you wish to update files in %s from your environment (%s)?' "${COMMONROOT}" "${_Util_libuiroot}"
      then
        ${_M} && _Trace 'Update %s environment with %s.' "${COMMONROOT}" "${_Util_libuiroot}"
        StartSpinner
        pushd "${_Util_libuiroot}" > /dev/null
        for _Util_file in $(find . -name '.*.sw*' -prune -o -type f -print)
        do
          _Util_file="${_Util_file#./}"
          if [[ -f "${COMMONROOT}/${_Util_file}" ]]
          then
            ${_M} && _Trace 'Copy %s to %s.' "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
            Action -q "Copy ${_Util_libuiroot}/${_Util_file} file to ${COMMONROOT}? (y/n)" "cp ${FMFLAGS} '${_Util_libuiroot}/${_Util_file}' '${COMMONROOT}/${_Util_file}'"
            Action "chmod ${_Util_groupmode} '${COMMONROOT}/${_Util_file}'"
          fi
        done
        popd > /dev/null
        StopSpinner
        Alert 'Update %s -> %s complete.' "${_Util_libuiroot}" "${COMMONROOT}"
      fi
    elif ${_Util_unify}
    then
      if Verify 'Are you sure you wish to remove files from %s that exist in %s?' "${_Util_libuiroot}" "${COMMONROOT}"
      then
        ${_M} && _Trace 'Unify user environment with %s. (%s)' "${COMMONROOT}" "${_Util_libuiroot}"
        StartSpinner
        pushd "${_Util_libuiroot}" > /dev/null
        for _Util_file in $(find . -name '.*.sw*' -prune -o -name '*version' -prune -o -type f -print)
        do
          _Util_file="${_Util_file#./}"
          if [[ -f "${COMMONROOT}/${_Util_file}" ]]
          then
            ${_M} && _Trace 'Remove %s.' "${_Util_libuiroot}/${_Util_file}"
            Action -q "The file ${COMMONROOT}/${_Util_file} exists, remove from ${_Util_libuiroot}? (y/n)" "rm ${FMFLAGS} '${_Util_libuiroot}/${_Util_file}'"
          fi
        done
        popd > /dev/null
        StopSpinner
        Alert 'Unification with %s environment complete.' "${COMMONROOT}"
      fi
    else
      Warn 'There are differences. (%s != %s)' "${COMMONROOT}" "${_Util_libuiroot}"
    fi
  else
    Alert 'Verify complete, no file differences. (%s == %s)' "${COMMONROOT}" "${_Util_libuiroot}"
  fi

  popd > /dev/null

  ${_M} && _Trace 'LibuiUnify return. (%s)' 0
  return 0
}

#####
#
# utility main
#
#####

UICMD+=( 'LibuiUtility' )
LibuiUtility () {
  ${_S} && ((_cLibuiUtility++))
  ${_M} && _Trace 'LibuiUtility [%s]' "${*}"

  ${_M} && _Trace 'Find operation.'
  if ${_Util_helloworld}
  then
    ${_M} && _Trace 'Display hello world.'
    printf 'Hello World.\n'
    Exit 0
  elif ${_Util_testing}
  then
    LibuiTest
  elif ${_Util_config}
  then
    LibuiConfig
  elif ${_Util_demo}
  then
    LibuiDemo
  elif ${_Util_stats}
  then
    LibuiStats
  elif ${_Util_cachereset}
  then
    LibuiReset
  elif ${_Util_unlock}
  then
    LibuiUnlock
  elif ${_Util_updatemp}
  then
    LibuiUpdateMan
  elif ${_Util_list}
  then
    LibuiPackageList
  elif ${_Util_package}
  then
    LibuiPackage
  elif ${_Util_install}
  then
    LibuiInstall
  elif ${_Util_verify} || ${_Util_update} || ${_Util_unify}
  then
    LibuiUnify
  else
    ${_M} && _Trace 'Display usage.'
    LoadMod Info
    UsageInfo
  fi
}

${_M} && _Trace 'Setup libui utility functions.'
LibuiUtilitySetup

return 0
