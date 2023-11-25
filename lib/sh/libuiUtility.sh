#!/bin/zsh
# also works with bash but, zsh improves profiling
#!/bin/bash
#####
#
#	Libui Utilities - Libui Utility Commands Mod
#
#	F Harvell - Sun Jun 18 10:32:47 EDT 2023
#
#####
#
# Provides libui utility commands.
#
# No man page is available for this mod. Additional information can be found in
# the libui.sh man page: man 3 libui.sh
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

Version -r 2.003 -m 1.3

##### configuration

# load mods

# defaults

# capture stdout, stderr, and rv
UICMD+=( '_Capture' )
_Capture () { # <stdout_var> <stderr_var> <rv_var> <command_string>
  ${_S} && ((_c_Capture++))
  ${_T} && _Trace '_Capture [%s]' "${*}"

  local _r="${3}"
  local _rv

  if ${ZSH}
  then
    {
      IFS=$'\n' read -r -d '' "${1}"
      IFS=$'\n' read -r -d '' "${2}"
      (IFS=$'\n' read -r -d '' _rv; return ${_rv})
    } < <( ( printf '\0%s\0%d\0' "$( ( ( ( { shift 3; "${@}"; printf '%s\n' ${?} 1>&5; } | tr -d '\0' 1>&6 ) 6>&2 2>&1 | tr -d '\0' 1>&6 ) 5>&1 | read x; exit ${x} ) 6>&1 )" ${?} 1>&2 ) 2>&1 )
  else
    {
      IFS=$'\n' read -r -d '' "${1}"
      IFS=$'\n' read -r -d '' "${2}"
      (IFS=$'\n' read -r -d '' _rv; return ${_rv})
    } < <( ( printf '\0%s\0%d\0' "$( ( ( ( { shift 3; "${@}"; printf '%s\n' ${?} 1>&5-; } | tr -d '\0' 1>&6- ) 6>&2- 2>&1- | tr -d '\0' 1>&6- ) 5>&1- | exit "$(cat)" ) 6>&1- )" ${?} 1>&2 ) 2>&1 )
  fi
  _rv=${?}
  eval "${_r}=${_rv}"

  ${_T} && _Trace '_Capture return. (%s)' "${_rv}"
  return ${_rv}
}

# value exists in array
UICMD+=( '_Contains' )
_Contains () { # <array_var> <value>
  ${_S} && ((_c_Contains++))
  ${_T} && _Trace '_Contains [%s]' "${*}"

  local _rv=1

  ${_T} && _Trace 'Check %s in %s.' "${2}" "${1}"
  if ${ZSH}
  then
    ((${(P)1[(Ie)${2}]})) && _rv=0
  else
    local _a
    local _e
    eval "_a=( \"\${${1}[@]}\" )"
    for _e in "${_a[@]}"
    do
      [[ "${2}" == "${_e}" ]] && _rv=0 && break
    done
  fi

  ${_T} && _Trace '_Contains return. (%s)' "${_rv}"
  return ${_rv}
}

# drop value from array
UICMD+=( '_Drop' )
_Drop () { # <array_var> <value>|<value>: ...
  ${_S} && ((_c_Drop++))
  ${_T} && _Trace '_Drop [%s]' "${*}"

  local _a
  local _e=false
  local _f=false
  local _p
  local _r; _r=( )

  ${_T} && _Trace 'Process Drop options. (%s)' "${*}"
  local _opt
  local OPTIND
  local OPTARG
  while getopts ':r' _opt
  do
    case ${_opt} in
      r)
        ${_T} && _Trace 'Regex match.'
        _e=true
        ;;

      *)
        Tell -E -f -L '(Drop) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ${ZSH} && _a=( "${(P)1[@]}" ) || eval "_a=( \"\${${1}[@]}\" )"

  for _opt in "${_a[@]}"
  do
    if ${_f}
    then
      _f=false
      continue
    fi
    for _p in "${@:1}"
    do
      if ${_e}
      then
        [[ "${_opt}:" =~ ${_p} ]] && _f=true && continue 2
        [[ "${_opt}" =~ ${_p} ]] && continue 2
      else
        [[ "${_opt}:" == "${_p}" ]] && _f=true && continue 2
        [[ "${_opt}" == "${_p}" ]] && echo "found" && continue 2
      fi
    done
    _r+=( "${_opt}" )
  done
  eval "${1}=( \"\${_r[@]}\" )"

  ${_T} && _Trace '_Drop return. (%s)' 0
  return 0
}

# terminal cache
UICMD+=( '_Terminal' )
_Terminal () {
  ${_S} && ((_c_Terminal++))
  ${_T} && _Trace '_Terminal [%s]' "${*}"

  local _rv=0

  ${_T} && _Trace 'Check for terminal. (%s)' "${TERMINAL}"
  if ${TERMINAL}
  then
    if [[ -n "${TERM}" ]] && ((8 <= $(tput colors)))
    then
      ${_T} && _Trace 'Define display codes.'
      _display=true
      {
        printf '# display codes generated %s.\n' "$(date)"
        printf "DCS='$(tput clear)'\n" # clear screen (jump home)
        printf "DCEL='$(tput el)'\n" # clear end of line
        printf "DCES='$(tput ed || tput cd)'\n" # clear end of screen
        printf "DJBL='$(tput hpa 0)'\n" # jump begin of line
        printf "DJH='$(tput cup 0 0)'\n" # jump home (0, 0)
        printf "DRP='$(tput u7)'\n" # read cursor position
        if ((16 <= $(tput colors)))
        then
          printf "DB0='$(tput setab 8)'\n" # bright black
          printf "DBr='$(tput setab 9)'\n" # bright red
          printf "DBg='$(tput setab 10)'\n" # bright green
          printf "DBy='$(tput setab 11)'\n" # bright yellow
          printf "DBb='$(tput setab 12)'\n" # bright blue
          printf "DBm='$(tput setab 13)'\n" # bright magenta
          printf "DBc='$(tput setab 14)'\n" # bright cyan
          printf "DB7='$(tput setab 15)'\n" # bright white
          printf "DF0='$(tput setaf 8)'\n" # bright black
          printf "DFr='$(tput setaf 9)'; Dfr=\"\${DFr}\"\n" # bright / red
          printf "DFg='$(tput setaf 10)'\n" # bright green
          printf "DFy='$(tput setaf 11)'; Dfy=\"\${DFy}\"\n" # bright / yellow
          printf "DFb='$(tput setaf 12)'; Dfb=\"\${DFb}\"\n" # bright / blue
          printf "DFm='$(tput setaf 13)'\n" # bright magenta
          printf "DFc='$(tput setaf 14)'\n" # bright cyan
          printf "DF7='$(tput setaf 15)'; Df7=\"\${DF7}\"\n" # bright / white
        else
          printf "Dfr='$(tput bold; tput setaf 1)'\n" # red
          printf "Dfy='$(tput bold; tput setaf 3)'\n" # yellow
          printf "Dfb='$(tput bold; tput setaf 4)'\n" # blue
          printf "Df7='$(tput bold; tput setaf 7)'\n" # white
        fi
        printf "Db0='$(tput setab 0)'\n" # black
        printf "Dbr='$(tput setab 1)'\n" # red
        printf "Dbg='$(tput setab 2)'\n" # green
        printf "Dby='$(tput setab 3)'\n" # yellow
        printf "Dbb='$(tput setab 4)'\n" # blue
        printf "Dbm='$(tput setab 5)'\n" # magenta
        printf "Dbc='$(tput setab 6)'\n" # cyan
        printf "Db7='$(tput setab 7)'\n" # white
        printf "Df0='$(tput setaf 0)'\n" # black
        printf "Dfg='$(tput setaf 2)'\n" # green
        printf "Dfm='$(tput setaf 5)'\n" # magenta
        printf "Dfc='$(tput setaf 6)'\n" # cyan
        printf "Db='$(tput bold)'\n" # bold
        [[ -n "$(tput dim)" ]] && printf "Dd='$(tput dim)'\n" || printf 'Dd="${DF0:-${Df0}}"\n' # dim
        printf "Dsu='$(tput smul)'\n" # start underline
        printf "Deu='$(tput rmul)'\n" # end underline
        printf "Dr='$(tput rev)'\n" # reverse
        printf "Dss='$(tput smso)'\n" # start standout
        printf "Des='$(tput rmso)'\n" # exit standout
        printf "D='$(tput sgr0)'\n" # normal
        printf 'DAction="${Dfb}"\n' # display formats
        printf 'DAlarm="${Dd}${Dfr}"\n'
        printf 'DAlert="${Db}${DFg}"\n'
        printf 'DAnswer="${Dfy}"\n'
        printf 'DCaution="${DFm}"\n'
        printf 'DConfirm="${Db}${DFy}"\n'
        printf 'DError="${Dbr}${Db}${DFy}"\n'
        printf 'DInfo="${DFc}"\n'
        printf 'DOptions="${Db}"\n'
        printf 'DQuestion="${DFc}${Dsu}"\n'
        printf 'DSpinner="${Db}${DFc}"\n'
        printf 'DTell="${Db}"\n'
        printf 'DTrace="${Dd}"\n'
        printf 'DWarn="${Dby}${DBy}${Df0}"\n'
        printf 'D0="${D}${Db}${Dsu}"\n' # display modes
        printf 'D1="${D}${Db}${DFr}"\n'
        printf 'D2="${D}${Db}${DFg}"\n'
        printf 'D3="${D}${Db}${DFy}"\n'
        printf 'D4="${D}${Db}${DFb}"\n'
        printf 'D5="${D}${Db}${DFm}"\n'
        printf 'D6="${D}${Db}${DFc}"\n'
        printf 'D7="${D}${Db}"\n'
        printf 'D8="${D}"\n'
        printf 'D9="${D}${Dd}"\n'
      } > "${LIBUI_CONFIG}/display-${TERM}"
      source "${LIBUI_CONFIG}/display-${TERM}"
      _rv=${?}
    else
      _rv=2
    fi
  fi

  ${_T} && _Trace '_Terminal return. (%s)' "${_rv}"
  return ${_rv}
}

return 0
