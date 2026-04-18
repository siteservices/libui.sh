#!/usr/bin/env libui
#####
#
#	Libui Support - Multifunction Libui Support Mod
#
#	F Harvell - Fri May  5 12:20:41 EDT 2023
#
#####
#
# Provides libui utility commands.
#
# Man page available for this mod: man 3 libuiLibui.sh
#
#####
#
# IMPORTANT: This mod does a lot of white box manipulation of the libui.sh
# internals and should not be used as a model for libui.sh Mod development.
#
#####
#
# This content and associated files as published by siteservices.net, Inc. are
# marked CCO 1.0. Permission is unconditionally granted to anyone with the
# interest, full rights to use, modify, publish, distribute, sublicense, and/or
# sell this content and all associated files. To view a copy of CCO 1.0, visit
# https://creativecommons.org/publicdomain/zero/1.0/.
#
# All content is provided "as is", without warranty of any kind, expressed or
# implied, including but not limited to merchantability, fitness for a
# particular purpose, and noninfringement. In no event shall the authors or
# publishers be liable for any claim, damages, or other liability, whether in an
# action of contract, tort, or otherwise, arising from, out of, or in connection
# with the use of this content or any of the associated files.
#
#####

Version -r 2.014 -m 1.23

##### configuration

# load mods
LoadMod File
LoadMod Info
LoadMod Sort
LoadMod Spinner
LoadMod Timer
LoadMod User
LoadMod Term
LoadMod Test

# defaults
export LC_ALL=POSIX
${ZSH} || shopt -s expand_aliases
GetRealPath _Util_libuiroot "${LIBUI%/*}/../../"
_Util_template="${_Util_libuiroot}/share/doc/libui-template"
_Util_libuitest="${LIBUI_TEST:-${_Util_libuiroot}/lib/test/libui}"
_Util_installer="sh=\"\${ZSH_NAME:t}\"; sh=\${sh:-bash}${N}\${sh} \"\${d}/bin/libui\" \${@}"
_Util_groupmode='g+wX'
_Util_configfile="${LIBUI_CONFIG}/libui.conf"
_Util_dcprefix="${LIBUI_CACHE}/display-"
_Util_statsfile="${LIBUI_STATE}/stats"
_Util_lockdir="${LIBUI_LOCKDIR:-${LIBUI_STATE}/lock}"
_Util_workdir="${PWD}"
GetTmp _Util_tmpdir


#####
#
# setup utility
#
#####

UICMD+=( '_LibuiSetup' )
_LibuiSetup () {
  ${_S} && ((_c_LibuiSetup++))
  ${_M} && _Trace '_LibuiSetup [%s]' "${*}"

  # defaults
  debug=false
  helloworld=false
  multiparam=false
  verify=false

  # setup values
  _Util_addoptft=false
  _Util_addopttf=false
  _Util_allowroot=false
  _Util_multiuser=false
  _Util_nolog=false
  _Util_optcnt=0
  _Util_requireroot=false
  _Util_terminal=false

  # local variables
  local aopt
  local Aopt
  local copt
  local Copt
  local popt
  local sopt
  local Sopt
  local vopt
  local aparam
  local Aparam
  local sparam
  local Sparam
  local vparam

  ${_M} && _Trace 'Parameter flags capture for tests.' "${arg[*]}"
  [[ " ${arg[*]} " =~ .*\ -x\ *oa\ .* ]] && aopt=true || aopt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *oA\ .* ]] && Aopt=true || Aopt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *oc\ .* ]] && copt=true || copt=false
  [[ " ${arg[*]} " =~ .*\ -x\ *oC\ .* ]] && Copt=true || Copt=false
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
  [[ " ${arg[*]} " =~ .*\ -x\ *t\ .* ]] && TERMINAL=true
  [[ " ${arg[*]} " =~ .*\ -t\ .* || " ${arg[*]} " =~ .*\ -x\ *p\ .* ]] && popt='-m' # set AddParameter option for testing
  [[ " ${arg[*]} " =~ .*\ -p\ .* ]] && popt='-r' # set AddParameter option for package

  ${_M} && _Trace 'Set up utility options.'
  [[ " ${arg[*]} " =~ .*\ -x\ *b\ .* ]] && AddOption -n binaryft -f -k 'Binary F/T' -d '(Only for test.) For testing AddOption -f option.' b
  [[ " ${arg[*]} " =~ .*\ -x\ *B\ .* ]] && AddOption -n binarytf -t -k 'Binary T/F' -d '(Only for test.) For testing AddOption -t option.' B
  AddOption -n config -f -k 'Config' -d 'Create default configuration file "${_Util_configfile}".' c
  AddOption -n cachereset -f -k 'Cache Reset' -d 'Reset (clear) library caches.' C
  AddOption -n demo -f -k 'Demo' -d 'Provide capabilities demonstration.' d
  AddOption -n defer -f -k 'Defer' -d 'Defer user environment by preferring COMMONROOT (or provided directory).' D
  AddOption -n shells -m -s 'zsh' -s 'bash' -i 'zsh' -i 'bash' -k 'Execution' -d 'Specify shell for regression testing (otherwise both bash and zsh).' e:
  AddOption -n group -f -k 'Group' -d 'Make installed files / directories group writable.' g
  AddOption -n installtests -f -k 'Install Tests' -d 'Install libui and tests into provided directory (or COMMONROOT).' i
  AddOption -n install -f -k 'Install' -d 'Install libui into provided directory (or COMMONROOT).' I
  AddOption -n list -f -k 'List' -d 'List files that would be included in a libui package.' l
  AddOption -n unlock -f -k 'Lockfiles' -d 'Remove leftover lockfiles.' L
  AddOption -n mpage -f -k 'Man Page' -d 'Display man page.' m
  AddOption -n mpath -f -k 'Man Path' -d 'Return the libui manpath.' M
  AddOption -n new -f -k 'New Script' -d 'Create a new libui script with the provided filename.' n
  AddOption -n empty -f -k 'New Empty Script' -d 'Create a libui script with the provided filename without demo content.' N
  AddOption -n package -f -k 'Package' -d 'Create a libui.sh package with the provided filename.' p
  AddOption -n prepackage -f -k 'Pre-package' -d 'Update documentation / datestamps in preparation for packaging.' P
  AddOption -n stats -f -k 'Stats' -d 'Display stats.' s
  AddOption -n statereset -f -k 'State Reset' -d 'Reset (clear) state (i.e., stats, logs, and ledger).' S
  AddOption -n testing -f -k 'Test' -d 'Perform libui regression testing.' t
  AddOption -n singletest -c SingleTestCallback -f -k '(Single) Test' -d 'Perform single test.' T
  AddOption -n update -f -k 'Update' -d 'Update libui in COMMONROOT (or provided directory).' u
  AddOption -n userreset -f -k 'User Reset' -d 'Reset user information.' U
  AddOption -n version -f -k 'Version' -d 'Obtain version information. (Please use -Xv in applications.)' v
  AddOption -n vlevel -c VerifyCallback -m -p true -k 'Verify' -d 'Verify libui in COMMONROOT (or provided directory).' V
  availopt=( b B d m n o oa oA oc oC os oS ov p P pa pA ps pS pv r R t T w X aot one two three four five )
  testopt=( X )
  AddOption -n testopt -c TestModeCallback -m -S availopt -k 'Test Option' -d '(Only for test.) Set test mode.' x:
  testvalues=( x y z )
  ${aopt} && AddOption -n opta -s a -a -k 'Test a' -d 'Test option a.' Z:
  ${Aopt} && AddOption -n optA -s A -k 'Test A' -d 'Test option A.' Z:
  ${copt} && AddOption -n optc -C -k 'Test c' -d 'Test option c.' Z
  ${Copt} && AddOption -n optC -C -k 'Test C' -d 'Test option C.' Z:
  ${sopt} && AddOption -n opts -s a -s b -s c -k 'Test s' -d 'Test option s.' Z:
  ${Sopt} && AddOption -n optS -S testvalues -k 'Test S' -d 'Test option S.' Z:
  ${vopt} && AddOption -n optv -v ValidCallback -k 'Test v' -d 'Test option v.' Z:
  ${aparam} && AddParameter -s a -a -k 'Test Param' -d 'Test parameter a.' testparam
  ${Aparam} && AddParameter -s A -k 'Test Param' -d 'Test parameter A.' testparam
  ${sparam} && AddParameter -s a -s b -s c -k 'Test Param' -d 'Test parameter s.' testparam
  ${Sparam} && AddParameter -S testvalues -k 'Test Param' -d 'Test parameter S.' testparam
  ${vparam} && AddParameter -v ValidCallback -k 'Test Param' -d 'Test parameter v.' testparam
  AddParameter ${popt} -i '' -k 'Parameter' -d 'Name of the test to perform, package filename, or COMMONROOT directory.' param

  ##### callbacks

  # single test callback
  SingleTestCallback () {
    ${_M} && _Trace 'Set up for single test.'
    testing=true
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
        debug=true
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
        ${_M} && _Trace 'Set up multiple parameter test.'
        multiparam=true
        ;;
      r)
        ${_M} && _Trace 'Set up allow root test.'
        _Util_allowroot=true
        ;;
      R)
        ${_M} && _Trace 'Set up require root test.'
        _Util_requireroot=true
        ;;
      t)
        ${_M} && _Trace 'Set up terminal test.'
        _Util_terminal=true
        ;;
      w)
        ${_M} && _Trace 'Set up hello world test.'
        helloworld=true
        ;;
      *)
        ${_M} && _Trace 'Received additional argument. (%s)' "${1}"
        ;;
    esac
  }

  # valid callback
  ValidCallback () {
    Tell 'Validation test. (v == %s)' "${optv}${testparam}"
    helloworld=true
  }

  # verify callback
  VerifyCallback () {
    ${_M} && _Trace 'Set up for verify.'
    verify=true
  }

  # info callback
  InfoCallback () {
    ${_M} && _Trace 'In user usage information callback.'
    cat << EOF
This script provides support functionality for the libui library including
regression testing, capabilities demonstration, and usage statistics reports.

Hints: ${D0}Use the "-n" (New Script) option to generate a new liubi script.${D}
       Use the "-d" (Demo) option to see the display formats available.
       Use the "-v" (Verify) option more than once to increase verbosity.

Shell environment: ${SHENV}

Current test mode options:
    AddOption F/T test. (b: ${_Util_addoptft})
    AddOption T/F test. (B: ${_Util_addopttf})
    Debug mode (d: ${debug})
    Multiuser test. (m: ${_Util_multiuser})
    No log test. (n: ${_Util_nolog})
    Option test. (o: ${_Util_optcnt}, ${testopt[*]})
    Parameter array test. (p: ${multiparam})
    Root allowed test. (r: ${_Util_allowroot})
    Root required test. (R: ${_Util_requireroot})
    Terminal test. (R: ${_Util_terminal})
    Hello World test. (w: ${helloworld})
EOF
  }

  ExitCallback () {
    ${_M} && _Trace 'In user exit callback.'

    ${debug} && Verify -r '[yY].*' 'Delete logs and exit? (%s)' "${_Util_tmpdir}"
  }

  InitCallback () {
    ${_M} && _Trace 'Program initialization.'

    ${installtests} && install=true

    if ${install} || ${verify} || ${update} || ${defer}
    then
      ${_M} && _Trace 'Check for multiple actions error.'
      local _Util_x=0
      ${install} && ((_Util_x++))
      ${verify} && ((_Util_x++))
      ${update} && ((_Util_x++))
      ${defer} && ((_Util_x++))
      ((1 < _Util_x)) && Tell -E 'Only one COMMONROOT action can be performed at a time.'

      ${_M} && _Trace 'Obtaining commonroot info. (%s / %s)' "${COMMONROOT}" "${param}"
      [[ -n "${param}" ]] && COMMONROOT="${param}"
      ConfirmVar -q 'Please provide a COMMONROOT directory path:' -d COMMONROOT
      if PathMatches "${_Util_libuiroot}" "${COMMONROOT}"
      then
        Tell -E 'The libui root is COMMONROOT. (%s)' "${COMMONROOT}"
      fi
    elif ${testing}
    then
      ${_M} && _Trace 'Set up test directory. (%s)' "${TESTDIR}"
      if [[ -z "${TESTDIR}" ]]
      then
        ${_M} && _Trace 'Initialize TESTDIR.'
        export TESTDIR="${_Util_tmpdir}"
        ${debug} && Tell 'Test directory is: %s' "${TESTDIR}"
      fi
      ConfirmVar -d TESTDIR
      pushd "${TESTDIR}" > /dev/null
    elif ${new} || ${empty}
    then
      GetRealPath -v param
      [[ -d "${param%/*}" ]] || Error 'Parent directory does not exist. (%s)' "${param%/*}"
    fi
  }
}


#####
#
# libui support functions
#
#####

UICMD+=( 'LibuiConfig' )
LibuiConfig () {
  ${_S} && ((_cLibuiConfig++))
  ${_M} && _Trace 'LibuiConfig [%s]' "${*}"

  local _Util_rv=0

  Overwrite || [[ ! -f "${_Util_configfile}" ]] || Error 'The configuration file already exists, use -XO to overwrite.'
  if [[ ! -f "${_Util_configfile}" ]] || Verify 'Really overwrite existing libui configuration file %s?' "${_Util_configfile}"
  then
    ${_M} && _Trace 'Create default config file. (%s)' "${_Util_configfile}"
    LoadMod File
    Open -1 -c ${_Util_configfile}
    Write -1 "#####${N}#${N}# libui.conf - $(date)${N}#${N}######${N}"
    Write -1 "# use LIBUI_{VAR}=\"\${LIBUI_{VAR}:-<value>}\" to support temporary command line environment changes.${N}"
    Write -1 "$(grep 'LIBUI_' "${LIBUI}" | grep 'LIBUI_\S*:-' | sed 's/^.*\(LIBUI_[^:]*\):-\([^;]*\)}.*$/\1="${\1:-\2}"/' | sed 's/^/#/' | sort -u)"
    DOMAIN="${LIBUI_DOMAIN:-${DOMAIN:-$(/bin/hostname -f 2> /dev/null | cut -d . -f 2-)}}"
    Close -1

    Tell -A 'Config file has been created. (%s)' "${_Util_configfile}"
  fi
  _Util_rv=${?}

  ${_M} && _Trace 'LibuiConfig return. (%s)' "${_Util_rv}"
  return ${_Util_rv}
}

UICMD+=( 'LibuiDemo' )
LibuiDemo () {
  ${_S} && ((_cLibuiDemo++))
  ${_M} && _Trace 'LibuiDemo [%s]' "${*}"

  Tell 'Capabilities Demo'

  Tell '\nDisplay formats:'
  Tell "\t${DAlarm}Alarm format."
  Tell "\t${DAlert}Alert format."
  Tell "\t${DAnswer}Answer format."
  Tell "\t${DBrief}Brief format."
  Tell "\t${DCaution}Caution format."
  Tell "\t${DConfirm}Confirm format."
  Tell "\t${DError}Error format."
  Tell "\t${DInfo}Info format."
  Tell "\t${DOptions}Options format."
  Tell "\t${DQuestion}Question format."
  Tell "\t${DSpinner}Spinner format."
  Tell "\t${DTell}Tell format."
  Tell "\t${DTrace}Trace format."
  Tell "\t${DWarn}Warning format."

  Tell '\nDisplay modes:'
  Tell "\t${D0}D0 - Display mode %d." 0
  Tell "\t${D1}D1 - Display mode %d." 1
  Tell "\t${D2}D2 - Display mode %d." 2
  Tell "\t${D3}D3 - Display mode %d." 3
  Tell "\t${D4}D4 - Display mode %d." 4
  Tell "\t${D5}D5 - Display mode %d." 5
  Tell "\t${D6}D6 - Display mode %d." 6
  Tell "\t${D7}D7 - Display mode %d." 7
  Tell "\t${D8}D8 - Display mode %d." 8
  Tell "\t${D9}D9 - Display mode %d." 9

  if ${TERMINAL}
  then
    Tell '\nAvailable display codes:'
    [[ -z "${DCS}" ]] && Tell -W 'Clear screen (DCS) not defined.' || printf '\t%s\n' 'DCS - Clear screen.'
    [[ -z "${DCEL}" ]] && Tell -W 'Clear to end of line (DCEL) not defined.' || printf '\t%s\n' 'DCEL - Clear to end of line.'
    [[ -z "${DCES}" ]] && Tell -W 'Clear to end of screen (DCES) not defined.' || printf '\t%s\n' 'DCES - Clear to end of screen.'
    [[ -z "${DJBL}" ]] && Tell -W 'Jump to beginning of line (DJBL) not defined.' || printf '\t%s\n' 'DJBL - Jump to beginning of line.'
    [[ -z "${DJH}" ]] && Tell -W 'Jump to home (DJH) not defined.' || printf '\t%s\n' 'DJH - Jump to home.'
    [[ -z "${DCP}" ]] && Tell -W 'Read cursor position (DCP) not defined.' || printf '\t%s\n' 'DCP - Read cursor position.'
    [[ -z "${Db0}" ]] && Tell -W 'Black background (Db0) not defined.' || printf "\t${Db0}%s${D}\n" 'Db0 - Black background.'
    [[ -z "${Dbr}" ]] && Tell -W 'Red background (Dbr) not defined.' || printf "\t${Dbr}%s${D}\n" 'Dbr - Red background.'
    [[ -z "${Dbg}" ]] && Tell -W 'Green background(Dbg) not defined.' || printf "\t${Dbg}%s${D}\n" 'Dbg - Green backgroun.'
    [[ -z "${Dby}" ]] && Tell -W 'Yellow background (Dby) not defined.' || printf "\t${Dby}%s${D}\n" 'Dby - Yellow background.'
    [[ -z "${Dbb}" ]] && Tell -W 'Blue background (Dbb) not defined.' || printf "\t${Dbb}%s${D}\n" 'Dbb - Blue background.'
    [[ -z "${Dbm}" ]] && Tell -W 'Magenta background (Dbm) not defined.' || printf "\t${Dbm}%s${D}\n" 'Dbm - Magenta background.'
    [[ -z "${Dbc}" ]] && Tell -W 'Cyan background (Dbc) not defined.' || printf "\t${Dbc}%s${D}\n" 'Dbc - Cyan background.'
    [[ -z "${Db7}" ]] && Tell -W 'White background (Db7) not defined.' || printf "\t${Db7}%s${D}\n" 'Db7 - White background.'
    [[ -z "${DB0}" ]] && Tell -W 'Bright black background (DB0) not defined.' || printf "\t${DB0}%s${D}\n" 'DB0 - Bright black background.'
    [[ -z "${DBr}" ]] && Tell -W 'Bright red background (DBr) not defined.' || printf "\t${DBr}%s${D}\n" 'DBr - Bright red background.'
    [[ -z "${DBg}" ]] && Tell -W 'Bright green background (DBg) not defined.' || printf "\t${DBg}%s${D}\n" 'DBg - Bright green background.'
    [[ -z "${DBy}" ]] && Tell -W 'Bright yellow background (DBy) not defined.' || printf "\t${DBy}%s${D}\n" 'DBy - Bright yellow background.'
    [[ -z "${DBb}" ]] && Tell -W 'Bright blue background (DBb) not defined.' || printf "\t${DBb}%s${D}\n" 'DBb - Bright blue background.'
    [[ -z "${DBm}" ]] && Tell -W 'Bright magenta background (DBm) not defined.' || printf "\t${DBm}%s${D}\n" 'DBm - Bright magenta background.'
    [[ -z "${DBc}" ]] && Tell -W 'Bright cyan background (DBc) not defined.' || printf "\t${DBc}%s${D}\n" 'DBc - Bright cyan background.'
    [[ -z "${DB7}" ]] && Tell -W 'Bright white background (DB7) not defined.' || printf "\t${DB7}%s${D}\n" 'DB7 - Bright white background.'
    [[ -z "${Df0}" ]] && Tell -W 'Black foreground (Df0) not defined.' || printf "\t${Df0}%s${D}\n" 'Df0 - Black foreground.'
    [[ -z "${Dfr}" ]] && Tell -W 'Red foreground (Dfr) not defined.' || printf "\t${Dfr}%s${D}\n" 'Dfr - Red foreground.'
    [[ -z "${Dfg}" ]] && Tell -W 'Green foreground (Dfg) not defined.' || printf "\t${Dfg}%s${D}\n" 'Dfg - Green foreground.'
    [[ -z "${Dfy}" ]] && Tell -W 'Yellow foreground (Dfy) not defined.' || printf "\t${Dfy}%s${D}\n" 'Dfy - Yellow foreground.'
    [[ -z "${Dfb}" ]] && Tell -W 'Blue foreground (Dfb) not defined.' || printf "\t${Dfb}%s${D}\n" 'Dfb - Blue foreground.'
    [[ -z "${Dfm}" ]] && Tell -W 'Magenta foreground (Dfm) not defined.' || printf "\t${Dfm}%s${D}\n" 'Dfm - Magenta foreground.'
    [[ -z "${Dfc}" ]] && Tell -W 'Cyan foreground (Dfc) not defined.' || printf "\t${Dfc}%s${D}\n" 'Dfc - Cyan foreground.'
    [[ -z "${Df7}" ]] && Tell -W 'White foreground (Df7) not defined.' || printf "\t${Df7}%s${D}\n" 'Df7 - White foreground.'
    [[ -z "${DF0}" ]] && Tell -W 'Bright black foreground (DF0) not defined.' || printf "\t${DF0}%s${D}\n" 'DF0 - Bright black foreground.'
    [[ -z "${DFr}" ]] && Tell -W 'Bright red foreground (DFr) not defined.' || printf "\t${DFr}%s${D}\n" 'DFr - Bright red foreground.'
    [[ -z "${DFg}" ]] && Tell -W 'Bright green foreground (DFg) not defined.' || printf "\t${DFg}%s${D}\n" 'DFg - Bright green foreground.'
    [[ -z "${DFy}" ]] && Tell -W 'Bright yellow foreground (DFy) not defined.' || printf "\t${DFy}%s${D}\n" 'DFy - Bright yellow foreground.'
    [[ -z "${DFb}" ]] && Tell -W 'Bright blue foreground (DFb) not defined.' || printf "\t${DFb}%s${D}\n" 'DFb - Bright blue foreground.'
    [[ -z "${DFm}" ]] && Tell -W 'Bright magenta foreground (DFm) not defined.' || printf "\t${DFm}%s${D}\n" 'DFm - Bright magenta foreground.'
    [[ -z "${DFc}" ]] && Tell -W 'Bright cyan foreground (DFc) not defined.' || printf "\t${DFc}%s${D}\n" 'DFc - Bright cyan foreground.'
    [[ -z "${DF7}" ]] && Tell -W 'Bright white foreground (DF7) not defined.' || printf "\t${DF7}%s${D}\n" 'DF7 - Bright white foreground.'
    [[ -z "${Db}" ]] && Tell -W 'Bold text (Db) not defined.' || printf "\t${Db}%s${D}\n" 'Db - Bold text.'
    [[ -z "${Dd}" ]] && Tell -W 'Dim text (Dd) not defined.' || printf "\t${Dd}%s${D}\n" 'Dd - Dim text.'
    [[ -z "${Dsu}" ]] && Tell -W 'Start underline (Dsu) not defined.' || printf "\t${Dsu}%s${D}\n" 'Dsu - Start underline.'
    [[ -z "${Deu}" ]] && Tell -W 'End underline (Deu) not defined.' || printf "\t${Deu}%s${D}\n" 'Deu - End underline.'
    [[ -z "${Dr}" ]] && Tell -W 'Reverse display (Dr) not defined.' || printf "\t${Dr}%s${D}\n" 'Dr - Reverse display.'
    [[ -z "${Dss}" ]] && Tell -W 'Start standout text (Dss) not defined.' || printf "\t${Dss}%s${D}\n" 'Dss - Start standout text.'
    [[ -z "${Des}" ]] && Tell -W 'End standout text (Des) not defined.' || printf "\t${Des}%s${D}\n" 'Des - End standout text.'
    [[ -z "${D}" ]] && Tell -W 'Reset highlighting (D) not defined.' || printf "\t${D}%s${D}\n" 'D - Reset highlighting.'
  else
    Tell -W '\nTerminal display codes are not available without a terminal.'
  fi

  GetCursor

  Tell '\nTerminal Information:'
  Tell "\tHEIGHT${D} - Terminal Height:        ${DFc}%s${D}" "${HEIGHT}"
  Tell "\tWIDTH${D} - Terminal Width:          ${DFc}%s${D}" "${WIDTH}"
  Tell "\tMAXROW${D} - Max row:                ${DFc}%s${D}" "${MAXROW}"
  Tell "\tMAXCOL${D} - Max column:             ${DFc}%s${D}" "${MAXCOL}"
  Tell "\tROW, COL${D} - Cursor position:      ${DFc}%s${D}" "${ROW}, ${COL}"

  Tell '\nExecution environment:'
  Tell "\tAA${D} - Associative array:          ${DFc}%s${D}" "${AA}"
  Tell "\tANSWER${D} - Last answer provided:   ${DFc}%s${D}" "${ANSWER}"
  Tell "\tAO${D} - Array offset:               ${DFc}%s${D}" "${AO}"
  Tell "\tARCH${D} - System architecture:      ${DFc}%s${D}" "${ARCH}"
  Tell "\tBV${D} - Bash version:               ${DFc}%s${D}" "${BV}"
  Tell "\tBSDPATH${D} - Path to BSD versions:  ${DFc}%s${D} (note: only for Solaris)" "${BSDPATH}"
  Tell "\tCHFLAGS${D} - Chain flags:           ${DFc}%s${D}" "${CHFLAGS}"
  Tell "\tCMD${D} - Command name:              ${DFc}%s${D}" "${CMD}"
  Tell "\tCMDARGS${D} - Command arguments:     ${DFc}%s${D}" "${CMDARGS[*]}"
  Tell "\tCMDLINE${D} - Command line string:   ${DFc}%s${D}" "${CMDLINE[*]}"
  Tell "\tCMDPATH${D} - Command path:          ${DFc}%s${D}" "${CMDPATH}"
  Tell "\tDOMAIN${D} - Domain name:            ${DFc}%s${D}" "${DOMAIN}"
  Tell "\tEUID${D} - Effective UID:            ${DFc}%s${D} (note: consumed, not generated)" "${EUID}"
  Tell "\tEGID${D} - Effective UID:            ${DFc}%s${D} (note: consumed, not generated)" "${EGID}"
  Tell "\tFMFLAGS${D} - File Management flags: ${DFc}%s${D}" "${FMFLAGS}"
  Tell "\tGROUP${D} - Primary Group:           ${DFc}%s${D}" "${GROUP}"
  Tell "\tHOST${D} - Host name:                ${DFc}%s${D}" "${HOST}"
  Tell "\tIWD${D} - Initial working directory: ${DFc}%s${D}" "${IWD}"
  Tell "\tLIBUI${D} - Path to libui library:   ${DFc}%s${D}" "${LIBUI}"
  Tell "\tMAXINT${D} - Max integer:            ${DFc}%s${D}" "${MAXINT}"
  Tell "\tNROPT${D} - Number of options:       ${DFc}%s${D}" "${NROPT}"
  Tell "\tNRPARAM${D} - Number of parameters:  ${DFc}%s${D}" "${NRPARAM}"
  Tell "\tOS${D} - Operating system:           ${DFc}%s${D}" "${OS}"
  Tell "\tOS_DIST${D} - OS distribution:       ${DFc}%s${D}" "${OS_DIST}"
  Tell "\tPV${D} - Supports printf -v:         ${DFc}%s${D}" "${PV}"
  Tell "\tSHENV${D} - Shell environment:       ${DFc}%s${D}" "${SHENV}"
  Tell "\tTERMINAL${D} - Terminal available:   ${DFc}%s${D}" "${TERMINAL}"
  Tell "\tUICMD${D} - Tracked UI functions:    ${DFc}%s${D} (note: only displaying variable count.)" "${#UICMD[*]}"
  Tell "\tUIMOD${D} - Loaded UI mods:          ${DFc}%s${D}" "${UIMOD[*]}"
  Tell "\tUIVERSION${D} - Version information: ${DFc}%s${D}" "${UIVERSION[*]}"
  Tell "\tUNIX${D} - Unix system type:         ${DFc}%s${D}" "${UNIX}"
  Tell "\tUSER${D} - Username:                 ${DFc}%s${D} (note: consumed, not generated)" "${USER}"
  Tell "\tZSH${D} - Using Z shell:             ${DFc}%s${D}" "${ZSH}"
  Tell "\tZV${D} - Z shell version:            ${DFc}%s${D}" "${ZV}"

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

UICMD+=( 'LibuiResetCache' )
LibuiResetCache () {
  ${_S} && ((_cLibuiResetCache++))
  ${_M} && _Trace 'LibuiResetCache [%s]' "${*}"

  GetFileList cachefiles "${LIBUI_CACHE}/*"
  ${_M} && _Trace 'Prepare to remove cache files. (%s)' "${cachefiles[*]}"
  if [[ -n "${cachefiles}" ]]
  then
    if Verify 'Really remove cache files? (%s)' "${cachefiles[*]}"
    then
      local _Util_file
      for _Util_file in "${cachefiles[@]}"
      do
        if [[ -f "${_Util_file}" ]]
        then
          ${_M} && _Trace 'Remove cache %s.' "${_Util_file}"
          Action -q "Really remove ${_Util_file}?" "rm ${FMFLAGS} '${_Util_file}'"
        fi
      done
      Tell -A 'Cache files have been removed. (%s)' "${cachefiles[*]}"
    fi
  fi

  ${_M} && _Trace 'LibuiResetCache return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiResetState' )
LibuiResetState () {
  ${_S} && ((_cLibuiResetState++))
  ${_M} && _Trace 'LibuiResetState [%s]' "${*}"

  GetFileList statefiles "${LIBUI_STATE}/*"
  ${_M} && _Trace 'Prepare to remove state files. (%s)' "${statefiles[*]}"
  if [[ -n "${statefiles}" ]]
  then
    if Verify 'Really remove state files? (%s)' "${statefiles[*]}"
    then
      local _Util_file
      for _Util_file in "${statefiles[@]}"
      do
        if [[ -f "${_Util_file}" ]]
        then
          ${_M} && _Trace 'Remove state file %s.' "${_Util_file}"
          Action -q "Really remove ${_Util_file}?" "rm ${FMFLAGS} '${_Util_file}'"
        fi
      done
      Tell -A 'State files have been removed. (%s)' "${statefiles[*]}"
    fi
  fi

  ${_M} && _Trace 'LibuiResetState return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiUnlock' )
LibuiUnlock () {
  ${_S} && ((_cLibuiUnlock++))
  ${_M} && _Trace 'LibuiUnlock [%s]' "${*}"

  local _Util_lockfiles
  local _Util_lockfile

  ${_M} && _Trace 'Get lockfile list. (%s)' "${_Util_lockdir}"
  GetFileList _Util_lockfiles "${_Util_lockdir}/*"

  ${_M} && _Trace 'Check for lockfiles. (%s)' "${#_Util_lockfiles[@]}"
  ${debug} && Tell 'Lockfiles: %s' "${_Util_lockfiles[*]}"
  if [[ -n "${_Util_lockfiles}" ]]
  then
    ${_M} && _Trace 'Prepare to remove lockfiles. (%s)' "${_Util_lockfiles[*]}"
    if Verify 'Really remove %s lockfiles?' "${#_Util_lockfiles[@]}"
    then
      ${_M} && _Trace 'Remove lockfiles. (%s)' "${_Util_lockfiles[*]}"
      local _Util_file
      for _Util_file in "${_Util_lockfiles[@]}"
      do
        _Util_lockfile="$(<"${_Util_file}")"
        ${_M} && _Trace 'Remove lockfile %s.' "${_Util_lockfile}"
        if [[ -e "${_Util_lockfile}" ]]
        then
          Action -q "Really remove ${_Util_lockfile} lockfile?" "rm ${FMFLAGS} '${_Util_lockfile}' '${_Util_file}'"
        else
          Action -q "Really remove ${_Util_file} lockfile?" "rm ${FMFLAGS} '${_Util_file}'"
        fi
      done
      Tell -A 'Lockfiles have been removed.'
    fi
  else
    Tell -C 'No lockfiles were found.'
  fi

  ${_M} && _Trace 'LibuiUnlock return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiManpage' )
LibuiManpage () {
  ${_S} && ((_cLibuiManpage++))
  ${_M} && _Trace 'LibuiManpage [%s]' "${*}"

  ${_M} && _Trace 'Display man page.'
  man() {
    LESS_TERMCAP_mb="$(tput bold; tput setaf 5)" \
    LESS_TERMCAP_md="$(tput bold; tput setaf 6)" \
    LESS_TERMCAP_me="$(tput sgr0)" \
    LESS_TERMCAP_se="$(tput sgr0)" \
    LESS_TERMCAP_so="$(tput bold; tput setaf 1)" \
    LESS_TERMCAP_ue="$(tput rmul; tput sgr0)" \
    LESS_TERMCAP_us="$(tput smul; tput bold; tput setaf 3)" \
    command man -M "${LIBUI%/*/*/*}/share/man:${MANPAGE}" "${@}"
  }
  man "${1:-libui}"

  ${_M} && _Trace 'LibuiManpage return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiTimestamp' )
LibuiTimestamp () {
  ${_S} && ((_cLibuiTimestamp++))
  ${_M} && _Trace 'LibuiTimestamp [%s]' "${*}"

  ${_M} && _Trace 'Update %s timestamp.' "${LIBUI}"
  local _Util_now=$(date '+%a %b %e %T %Z %Y' | sed 's/  / /g')
  local _Util_sedi; [[ 'GNU' == "${UNIX}" ]] && _Util_sedi="-i" || _Util_sedi="-i ''"
  Action -q 'Update the libui.sh notation date?' "sed ${_Util_sedi} -e 's/ LIBUI_VERSION=\([0-9][0-9]*\.[0-9][0-9][0-9]\) # .* .* .* .*:.*:.* .* [0-9][0-9][0-9][0-9]$/ LIBUI_VERSION=\1 # ${_Util_now}/' '${LIBUI}'" && \
      Tell -A '%s timestamp updated.' "${LIBUI}"

  ${_M} && _Trace 'LibuiTimestamp return. (%s)' 0
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
  local _Util_sedi; [[ 'GNU' == "${UNIX}" ]] && _Util_sedi="-i" || _Util_sedi="-i ''"
  for _Util_file in $(find . -name 'man' -prune -o -name '.git' -prune -o -name '.*.sw*' -prune -o -type f -print)
  do
    _Util_file="${_Util_file#./}"
    ${ZSH} && eval "_Util_mp=( ${_Util_libuiroot}/share/man/man*/${_Util_file##*/}.*(N) )" || \
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
  Tell -A 'Man page headers are up to date.'

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
  local _Util_files; _Util_files=( $(find . -name '.git' -prune -o -name '.*.sw*' -prune -o -type f -name 'libui*' -print) )
  [[ -d "${_Util_libuitest}" ]] && _Util_files+=( $(find .${_Util_libuitest#${_Util_libuiroot}} -name '.git' -prune -o -name '.*.sw*' -prune -o -type f -print) )
  _Util_files+=( $(grep -rl '{libui tool}' . | grep -v '\.sw.$') )
  Sort -u _Util_files

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

  local _Util_installer

  ${_M} && _Trace 'Process LibuiPackage options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':i:' opt
  do
    case ${opt} in
      i)
        ${_M} && _Trace 'Installer. (%s)' "${OPTARG}"
        _Util_installer="${OPTARG}"
        ;;
      *)
        Tell -E -f -L '(LibuiPackage) Unknown option. (-%s)' "${OPTARG}"
        ;;
    esac
  done
  shift $((OPTIND - 1))
  local _Util_package="${1}"
  GetRealPath -P _Util_package
  LoadMod Package

  ${_M} && _Trace 'Change directory. (%s)' "${_Util_libuiroot}"
  pushd "${_Util_libuiroot}" > /dev/null

  ${_M} && _Trace 'Create libui package. (%s)' "${_Util_package}"
  local _Util_files; _Util_files=( $(find . -name '.git' -prune -o -name '.*.sw*' -prune -o -type f -name 'libui*' -print) )
  [[ -d "${_Util_libuitest}" ]] && _Util_files+=( $(find .${_Util_libuitest#${_Util_libuiroot}} -name '.git' -prune -o -name '.*.sw*' -prune -o -type f -print) )
  _Util_files+=( $(grep -rl '{libui tool}' . | grep -v '\.sw.$') )
  Sort -u _Util_files

  ${_M} && _Trace 'Files to include in libui package. (%s)' "${_Util_files[*]}"
  if [[ ".sharp" == "${_Util_package: -6}" ]]
  then
    Action -q 'Create libui shar package archive?' "CreatePackage -S -f _Util_files -x excludes -i '${_Util_installer}' -s '${_Util_libuiroot}' '${_Util_package}'"
  elif [[ ".starp" == "${_Util_package: -6}" ]]
  then
    Action -q 'Create libui star package archive?' "CreatePackage -P -f _Util_files -x excludes -i '${_Util_installer}' -s '${_Util_libuiroot}' '${_Util_package}'"
  else
    [[ ".tarp" == "${_Util_package: -5}" ]] || _Util_package+='.tarp'
    Action -q 'Create libui tar package archive?' "CreatePackage -T -f _Util_files -x excludes -i '${_Util_installer}' -s '${_Util_libuiroot}' '${_Util_package}'"
  fi
  Tell -A 'Creation of libui package complete. (%s)' "${_Util_package}"

  popd > /dev/null

  ${_M} && _Trace 'LibuiPackage return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiInstall' )
LibuiInstall () {
  ${_S} && ((_cLibuiInstall++))
  ${_M} && _Trace 'LibuiInstall [%s]' "${*}"

  StartSpinner 'Installing into commonroot "%s".' "${COMMONROOT}"

  if Force || Verify 'Really install libui from "%s" into "%s"?' "${_Util_libuiroot}" "${COMMONROOT}"
  then
    ${_M} && _Trace 'Install libui from "%s" into "%s".' "${_Util_libuiroot}" "${COMMONROOT}"
    _Util_files=( $(find "${_Util_libuiroot}" -name '.git' -prune -o -name '.*.sw*' -prune -o -type f -name 'libui*' -print) )
    ${installtests} && [[ -d "${_Util_libuitest}" ]] && \
        _Util_files+=( $(find "${_Util_libuitest}" -name '.git' -prune -o -name '.*.sw*' -prune -o -type f -print) )
    _Util_files+=( $(grep -rl '{libui tool}' "${_Util_libuiroot}" | grep -v '\.sw.$') )
    local _Util_file
    for _Util_file in "${_Util_files[@]#${_Util_libuiroot%/}/}"
    do
      [[ ! -d "${COMMONROOT}/${_Util_file%/*}" ]] && \
          Action -W "mkdir -p '${COMMONROOT}/${_Util_file%/*}'" && \
          ${group} && Action -F -W "chmod ${_Util_groupmode} '${COMMONROOT}/${_Util_file%/*}'"
      Action "cp ${FMFLAGS} "${_Util_libuiroot%/}/${_Util_file}" '${COMMONROOT}/${_Util_file}'" && \
          ${group} && Action -W "chmod ${_Util_groupmode} '${COMMONROOT}/${_Util_file}'"
    done

    StopSpinner

    Tell -A 'Installation of libui into %s complete.' "${COMMONROOT}"
    GetRealPath COMMONROOT
    Quiet || cat << EOF
To use the library, the following should be added to your environment:

  * Add "${COMMONROOT}/bin" to your PATH to access libui and example scripts.
  * Add "${COMMONROOT}/share/man" to your MANPATH to access the man pages.

Once added, you can use "man 3 libui.sh" or "libui -m" to view the man page.
EOF

    ${_M} && _Trace 'Check for zsh.'
    if ${ZSH} && ((${+commands[zsh]})) || command -v zsh &> /dev/null
    then
      Tell "${D}Using '#!/usr/bin/env libui' shebang will execute scripts using Z shell (zsh)."
    else
      Tell -W 'Z shell (zsh) is not available, modifying %s to use bash.' "${COMMONROOT}/bin/libui"
      local _Util_sedi; [[ 'GNU' == "${UNIX}" ]] && _Util_sedi="-i" || _Util_sedi="-i ''"
      Action -F "sed ${_Util_sedi} -e '1s|^#!/usr/bin/env zsh|#!/usr/bin/env bash|' '${COMMONROOT}/bin/libui'"
      Action -F "sed ${_Util_sedi} -e '3s|^#!/usr/bin/env bash|#!/usr/bin/env zsh|' '${COMMONROOT}/bin/libui'"
      Tell "${D}Using '#!/usr/bin/env libui' shebang will execute scripts using bash."
    fi
  fi

  ${_M} && _Trace 'LibuiInstall return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiDefer' )
LibuiDefer () { # [-d|-D|-u|-v]
  ${_S} && ((_cLibuiDefer++))
  ${_M} && _Trace 'LibuiDefer [%s]' "${*}"

  local _Util_diff=false
  local _Util_file
  local _Util_list; _Util_list=( )
  local _Util_defer=false
  local _Util_update=false
  local _Util_verify=true

  ${_M} && _Trace 'Process LibuiDefer options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':dDuv' opt
  do
    case ${opt} in
      d)
        ${_M} && _Trace 'Diff.'
        _Util_diff=true
        ;;
      u)
        ${_M} && _Trace 'Update.'
        _Util_update=true
        ;;
      D)
        ${_M} && _Trace 'Defer.'
        _Util_defer=true
        ;;
      v)
        ${_M} && _Trace 'Verify.'
        _Util_verify=true
        ;;
      *)
        Tell -E -f -L '(LibuiDefer) Unknown option. (-%s)' "${OPTARG}"
        ;;
    esac
  done
  shift $((OPTIND - 1))

  pushd "${_Util_libuiroot}" > /dev/null

  StartSpinner 'Comparing "%s" with commonroot "%s".' "${_Util_libuiroot}" "${COMMONROOT}"

  ${_M} && _Trace 'Verify %s environment with %s.' "${COMMONROOT}" "${_Util_libuiroot}"
  for _Util_file in $(find . -name 'Deferred' -prune -o -name '.git' -prune -o -name '.*.sw*' -o -name '.DS_Store*' -prune -o -type f -print)
  do
    _Util_file="${_Util_file#./}"
    if [[ -f "${COMMONROOT}/${_Util_file}" ]]
    then
      ${_M} && _Trace 'Check %s against %s.' "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
      if ! Action -W "cmp -s '${_Util_libuiroot}/${_Util_file}' '${COMMONROOT}/${_Util_file}'"
      then
        Tell 'File differs: %s -> %s' "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
        _Util_list+=( "${_Util_file}" )
        if ${_Util_diff}
        then
          Tell "${Dfy}diff %s %s${D}" "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
          Action -W "diff '${_Util_libuiroot}/${_Util_file}' '${COMMONROOT}/${_Util_file}'"
        fi
      fi
    fi
  done

  StopSpinner

  ${_M} && _Trace 'Check for different files. (%s)' "${#_Util_list[@]}"
  if [[ -n "${_Util_list}" ]]
  then
    ${_M} && _Trace 'Check for update. (%s)' "${_Util_update}"
    if ${_Util_update} && Verify 'Are you sure you wish to update files in %s from your environment (%s)?' "${COMMONROOT}" "${_Util_libuiroot}"
    then
      StartSpinner 'Updating commonroot "%s".' "${COMMONROOT}"

      ${_M} && _Trace 'Update %s environment with %s.' "${COMMONROOT}" "${_Util_libuiroot}"
      pushd "${_Util_libuiroot}" > /dev/null
      for _Util_file in "${_Util_list[@]}"
      do
        if [[ -f "${COMMONROOT}/${_Util_file}" ]]
        then
          ${_M} && _Trace 'Copy %s to %s.' "${_Util_libuiroot}/${_Util_file}" "${COMMONROOT}/${_Util_file}"
          Action -q "Copy ${_Util_libuiroot}/${_Util_file} file to ${COMMONROOT}? (y/n)" "cp ${FMFLAGS} '${_Util_libuiroot}/${_Util_file}' '${COMMONROOT}/${_Util_file}'" && \
              ${group} && Action "chmod ${_Util_groupmode} '${COMMONROOT}/${_Util_file}'"
        fi
      done
      popd > /dev/null

      StopSpinner

      Tell -A 'Update %s -> %s complete.' "${_Util_libuiroot}" "${COMMONROOT}"
    else
      Tell -C 'Local files and commonroot files are different. (%s != %s)' "${COMMONROOT}" "${_Util_libuiroot}"
    fi
  else
    Tell -A 'Verify complete, no file differences. (%s = %s)' "${COMMONROOT}" "${_Util_libuiroot}"
  fi

  ${_M} && _Trace 'Check for defer. (%s)' "${_Util_defer}"
  if ${_Util_defer} && Verify 'Are you sure you wish to defer files from %s that exist in %s?' "${_Util_libuiroot}" "${COMMONROOT}"
  then
    StartSpinner 'Deferring user environment to "%s".' "${COMMONROOT}"

    ${_M} && _Trace 'Defer user environment to %s. (%s)' "${COMMONROOT}" "${_Util_libuiroot}"
    pushd "${_Util_libuiroot}" > /dev/null
    MkDir "${_Util_libuiroot}/Deferred"
    for _Util_file in $(find . -name 'Deferred' -prune -o -name '.git' -prune -o -name '.*.sw*' -prune -o -name '*version' -prune -o -type f -print)
    do
      _Util_file="${_Util_file#./}"
      if [[ -f "${COMMONROOT}/${_Util_file}" ]]
      then
        ${_M} && _Trace 'Defer %s.' "${_Util_libuiroot}/${_Util_file}"
        Action -q "The file ${COMMONROOT}/${_Util_file} exists, defer in ${_Util_libuiroot}? (y/n)" "mv ${FMFLAGS} '${_Util_libuiroot}/${_Util_file}' '${_Util_libuiroot}/Deferred/${_Util_file}'"
      fi
    done
    popd > /dev/null

    StopSpinner

    Tell -A 'Deferral to %s environment complete.' "${COMMONROOT}"
  fi

  popd > /dev/null

  ${_M} && _Trace 'LibuiDefer return. (%s)' 0
  return 0
}

UICMD+=( 'LibuiNew' )
LibuiNew () { # [-e] =t <template_file>
  ${_S} && ((_cLibuiNew++))
  ${_M} && _Trace 'LibuiNew [%s]' "${*}"

  local _Util_empty=false
  local _Util_template
  local _Util_rv=0

  ${_M} && _Trace 'Process LibuiNew options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':et:' opt
  do
    case ${opt} in
      e)
        ${_M} && _Trace 'Empty.'
        _Util_empty=true
        ;;
      t)
        ${_M} && _Trace 'Template. (%s)' "${OPTARG}"
        _Util_template="${OPTARG}"
        ;;
      *)
        Tell -E -f -L '(LibuiNew) Unknown option. (-%s)' "${OPTARG}"
        ;;
    esac
  done
  shift $((OPTIND - 1))
  local _Util_target="${1}"
  [[ -f "${_Util_template}" ]] || Tell -E 'Template libui script file is not available. (%s)' "${_Util_template}"

  Overwrite || [[ ! -f "${_Util_target}" ]] || Error 'The script file already exists, use -XO to overwrite.'
  if [[ ! -f "${_Util_target}" ]] || Verify -N 'Really overwrite existing script file %s?' "${_Util_target}"
  then
    ${_M} && _Trace 'Remove existing script. (%s)' "${_Util_target}"
    [[ -f "${_Util_target}" ]] && Action "rm ${FMFLAGS} '${_Util_target}'"

    ${_M} && _Trace 'Create new libui script. (%s)' "${_Util_target}"
    local _Util_sedi; [[ 'GNU' == "${UNIX}" ]] && _Util_sedi="-i" || _Util_sedi="-i ''"
    ${_Util_empty} && Action -F "cat '${_Util_template}' | grep -v 'demo content' > '${_Util_target}'" || \
        Action -F "cat '${_Util_template}' | sed -e '/^\(#.*\)# demo content/s//\1  # demo content/' | sed -e '/^[^#].*# demo content/s/^/#/' > '${_Util_target}'"
    Ask -d '<TITLE HERE>' 'Provide a title for the script header:'
    Action -F "sed ${_Util_sedi} -e 's/<TITLE HERE>/${ANSWER}/g' '${_Util_target}'"
    Ask -d '<SHORT DESCRIPTION HERE>' 'Provide a short, one-line description for the script header:'
    Action -F "sed ${_Util_sedi} -e 's/<SHORT DESCRIPTION HERE>/${ANSWER}/g' '${_Util_target}'"
    Action -F "sed ${_Util_sedi} -e 's/<NAME HERE>/${NAME:-${USER}}/g' '${_Util_target}'"
    Action -F "sed ${_Util_sedi} -e 's/<TIMESTAMP HERE>/$(date)/g' '${_Util_target}'"
    Action -F "sed ${_Util_sedi} -e 's/<REQUIRED LIBUI HERE>/${LIBUI_VERSION}/g' '${_Util_target}'"
    Action -F "sed ${_Util_sedi} -e 's/<SCRIPT VERSION HERE>/1.0/g' '${_Util_target}'"
    Action -F "chmod +x '${_Util_target}'"

    Tell -A 'New file has been created. (%s)' "${_Util_target}"
    local _Util_here=$(tr '[:space:]' '\n' < "${param}" | grep -c 'HERE'); ((_Util_here)) || unset _Util_here
    Tell 'Search for "HERE" and replace%s with new script content.' "${_Util_here:+ all ${_Util_here}}"
    ${_Util_empty} || Tell 'The lines containing "demo content" should be deleted.'
  fi
  _Util_rv=${?}

  ${_M} && _Trace 'LibuiNew return. (%s)' "${_Util_rv}"
  return ${_Util_rv}
}


#####
#
# utility main
#
#####

UICMD+=( '_LibuiProcess' )
_LibuiProcess () {
  ${_S} && ((_c_LibuiProcess++))
  ${_M} && _Trace '_LibuiProcess [%s]' "${*}"

  ${_M} && _Trace 'Find operation.'
  if ${helloworld}
  then
    ${_M} && _Trace 'Display hello world.'
    printf 'Hello World.\n'
    Exit 0
  elif ${testing}
  then
    if ${debug}
    then
      LibuiTest -d -t "${_Util_libuitest}" "${param[@]}"
    else
      LibuiTest -t "${_Util_libuitest}" "${param[@]}"
    fi
  elif ${version}
  then
    Version -a
    Tell "${Dfc}Note: For %s programs, please use -Xv to get version information.${D}" "${CMD}"
  elif ${mpath}
  then
    [[ "${MANPATH}" =~ (.*:|^)"${LIBUI%/*/*/*}/share/man"($|:.*) ]] && printf 'MANPATH="%s"\n' "${MANPATH}" || \
        printf 'MANPATH="%s/share/man%s"\n' "${LIBUI%/*/*/*}" "${MANPATH:+:${MANPATH}}"
  elif ${mpage}
  then
    LibuiManpage "${param}"
  elif ${config}
  then
    LibuiConfig
  elif ${demo}
  then
    LibuiDemo
  elif ${stats}
  then
    LibuiStats
  elif ${cachereset}
  then
    LibuiResetCache
  elif ${statereset}
  then
    LibuiResetState
  elif ${userreset}
  then
    ${_M} && _Trace 'Reset user info.'
    Verify 'Really update user info?' && _SetUserInfo -u
  elif ${unlock}
  then
    LibuiUnlock
  elif ${prepackage}
  then
    LibuiTimestamp
    LibuiUpdateMan
    Action -q 'Remove readme?' "mv ${_Util_libuiroot}/README.md ${_Util_tmpdir}"
    Action -q 'Copy readme?' "cp ${FMFLAGS} ${_Util_libuiroot}/share/doc/libui-readme.md ${_Util_libuiroot}/README.md"
  elif ${list}
  then
    LibuiPackageList
  elif ${package}
  then
    LibuiPackage -i "${_Util_installer}" "${param}"
  elif ${install}
  then
    LibuiInstall
  elif ${verify} || ${update} || ${defer}
  then
    if [[ -n "${vlevel[2]+x}" ]]
    then
      LibuiDefer -d $(${verify} && printf -- '-v '; ${update} && printf -- '-u '; ${defer} && printf -- '-D') | less -R
    else
      LibuiDefer $(${verify} && printf -- '-v '; ${update} && printf -- '-u '; ${defer} && printf -- '-D')
    fi
  elif ${new}
  then
    LibuiNew -t "${_Util_template}" "${param}"
  elif ${empty}
  then
    LibuiNew -e -t "${_Util_template}" "${param}"
  else
    ${_M} && _Trace 'Display usage.'
    UsageInfo
    true # disable error wait
  fi
  local _Util_rv=${?}

  ${_M} && _Trace '_LibuiProcess return. (%s)' "${_Util_rv}"
  return ${_Util_rv}
}

${_M} && _Trace 'Setup libui utility functions.'
_LibuiSetup

return 0
