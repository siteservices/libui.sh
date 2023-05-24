#!/bin/zsh
# also works with bash but, zsh improves profiling
#!/bin/bash
#####
#
#	Shell User Interface Library
#
#	F Harvell - Sat Apr 18 10:58:49 EDT 2020
#
#####
#
# To create a libui script, use the following shebang:
#
#   #!/usr/bin/env libui
#
# Alternatively, to source libui.sh in a zsh or bash script, include the line:
#
#   LIBUI="${SHLIBPATH:+${SHLIBPATH%/}/}libui.sh"; source "${LIBUI}" "${0}" "${@}"
#
# Every libui script (or libui mod) should contain the following command:
#
#   Version [-m] [-r <minimum_version>] <version>
#
#     Where <version> is the version of the script and <minimum_version>,
#     if provided, ensures the libui.sh library is at least that version.
#     The -m (mod) flag is used to indicate that the file is a libui.sh mod.
#
# Every libui script should initialize the library after configuration and
# before starting the main script by using the following command:
#
#   Initialize
#
# Every libui script should exit using the following:
#
#   Exit [return_value]
#
#     Where return_value is the value to be returned by the main script.
#
# Man page available for this library: man 3 libui.sh
#
#####
#
# Important note: libui.sh uses file index prefix (_File_ip) 1 for maintaining
# logs. Please be aware when building libui mods that make use of file indexes.
#
# Vim note: when using the shebang, add this to your ~/.vim/scripts.vim file:
#
#     if getline(1) =~ '^#!/usr/bin/env libui'
#       setfiletype zsh " or 'bash'
#     endif
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

[[ -n ${LIBUI_VERSION+x} ]] && return 0 || LIBUI_VERSION=1.825 # Wed May 24 00:41:01 EDT 2023

#####
#
# library functions
#
#####

# value exists in array
UICMD+=( 'Contains' )
Contains () { # <array_var> <value>
  ${_S} && ((_cContains++))
  ${_T} && _Trace 'Contains [%s]' "${*}"

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

  ${_T} && _Trace 'Contains return. (%s)' "${_rv}"
  return ${_rv}
}

# capture stdout, stderr, and rv
UICMD+=( 'Capture' )
Capture () { # <stdout_var> <stderr_var> <rv_var> <command_string>
  ${_S} && ((_cCapture++))
  ${_T} && _Trace 'Capture [%s]' "${*}"

  local _r="${3}"
  local _rv

  if ${ZSH}
  then
    {
      IFS=$'\n' read -r -d '' "${1}"
      IFS=$'\n' read -r -d '' "${2}"
      (IFS=$'\n' read -r -d '' _rv; return ${_rv})
    } < <( ( printf '\0%s\0%d\0' "$( ( ( ( { shift 3; "${@}"; printf '%s\n' ${?} 1>&3; } | tr -d '\0' 1>&4 ) 4>&2 2>&1 | tr -d '\0' 1>&4 ) 3>&1 | read x; exit ${x} ) 4>&1 )" ${?} 1>&2 ) 2>&1 )
  else
    {
      IFS=$'\n' read -r -d '' "${1}"
      IFS=$'\n' read -r -d '' "${2}"
      (IFS=$'\n' read -r -d '' _rv; return ${_rv})
    } < <( ( printf '\0%s\0%d\0' "$( ( ( ( { shift 3; "${@}"; printf '%s\n' ${?} 1>&3-; } | tr -d '\0' 1>&4- ) 4>&2- 2>&1- | tr -d '\0' 1>&4- ) 3>&1- | exit "$(cat)" ) 4>&1- )" ${?} 1>&2 ) 2>&1 )
  fi
  _rv=${?}

  ${_T} && _Trace 'Capture return. (%s)' "${_rv}"
  eval "${_r}=${_rv}"
  return ${_rv}
}

# get and check version
UICMD+=( 'Version' )
Version () { # [-m] [-r <required_libui_version>] <script_version>
  ${_S} && ((_cVersion++))
  ${_T} && _Trace 'Version [%s]' "${*}"

  local _m=false
  local _r
  local _s; ${ZSH} && _s=${funcfiletrace[${AO}]%:*} || _s=$(caller | cut -f 2 -d ' ')

  ${_T} && _Trace 'Process Version options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':mr:' _o
  do
    case ${_o} in
      m)
        ${_T} && _Trace 'Module version.'
        _m=true
        ;;

      r)
        ${_T} && _Trace 'Required libui version. (%s)' "${OPTARG}"
        _r="${OPTARG}"
        ;;

      *)
        Error -L '(Version) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && _Trace 'Display versions. (%s)' "${UIVERSION[*]}" && printf '%s %s\n' "${UIVERSION[@]}" && return 0

  [[ -n ${_r} && ${LIBUI_VERSION//.} -ge ${_r//.} ]] || \
      Error -e '%s requires libui.sh version %s. Please update libui.sh.' "${_s##*/}" "${LIBUI_VERSION}"

  UIVERSION+=( "${_s##*/}" "${1}" )
  ${_m} && UIMOD+=( "${_s##*/}" )

  ${_T} && _Trace 'Version return. (%s)' 0
  return 0
}

# add option pattern
_opt='CFhHNP:QVX:Y'
UICMD+=( 'AddOption' )
AddOption () { # [-a|-f|-m|-r|-t] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_var>] [-k <keyword>] [-n <var>] [-p <provided_value>] [-P <path>] [-s <selection_values>] [-S <selection_var>] [-v <callback>] <option>[:]
  ${_init} || Error -L '(AddOption) Must be called before Initialize.'
  ${_S} && ((_cAddOption++))
  ${_T} && _Trace 'AddOption [%s]' "${*}"

  local _a=false
  local _c
  local _d
  local _i
  local _k
  local _l
  local _m=false
  local _n
  local _p
  local _r=false
  local _s; _s=( )
  local _u
  local _v

  ${_T} && _Trace 'Process AddOption options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':ac:d:fi:I:k:mn:p:P:rs:S:tv:' _o
  do
    case ${_o} in
      a)
        ${_T} && _Trace 'Autodefault.'
        _a=true
        ;;

      c)
        ${_T} && _Trace 'Option callback. (%s)' "${OPTARG}"
        _c="${OPTARG}"
        ;;

      d)
        ${_T} && _Trace 'Option description. (%s)' "${OPTARG}"
        _d="${OPTARG}"
        ;;

      f)
        ${_T} && _Trace 'Set initial false, provided true.'
        _i=( 'false' )
        _u='true'
        ;;

      i|I)
        ${_T} && _Trace 'Initial option value. (%s)' "${OPTARG}"
        if [[ 'I' == "${_o}" ]]
        then
          ${ZSH} && _i=( "${(P@)OPTARG}" ) || eval "_i=( \"\${${OPTARG}[@]}\" )"
        else
          [[ -z "${_i}" ]] && _i=( "${OPTARG}" ) || _i=( "${_i[@]}" "${OPTARG}" )
        fi
        ;;

      k)
        ${_T} && _Trace 'Option keyword. (%s)' "${OPTARG}"
        _k="${OPTARG}"
        ;;

      m)
        ${_T} && _Trace 'Allow multiple option entries.'
        _m=true
        ;;

      n)
        ${_T} && _Trace 'Option variable name. (%s)' "${OPTARG}"
        _n="${OPTARG}"
        ;;

      p)
        ${_T} && _Trace 'Option value when provided. (%s)' "${OPTARG}"
        _u="${OPTARG}"
        ;;

      P)
        ${_T} && _Trace 'Path. (%s)' "${OPTARG}"
        _p="${OPTARG%/}"
        ;;

      r)
        ${_T} && _Trace 'Required option.'
        _r=true
        ;;

      s)
        ${_T} && _Trace 'Option selection value. (%s)' "${OPTARG}"
        [[ -z "${_l}" ]] && _l=( "${OPTARG}" ) || _l=( "${_l[@]}" "${OPTARG}" )
        ;;

      S)
        ${_T} && _Trace 'Option selection variable. (%s)' "${OPTARG}"
        _s="${OPTARG}"
        ;;

      t)
        ${_T} && _Trace 'Set initial true, provided false.'
        _i=( 'true' )
        _u='false'
        ;;

      v)
        ${_T} && _Trace 'Option validation callback. (%s)' "${OPTARG}"
        _v="${OPTARG}"
        ;;

      *)
        Error -L '(AddOption) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(AddOption) Called without an option.'
  [[ -z "${_n}" && -z "${_c}" ]] && Error -L '(AddOption) No variable name or callback provided.'

  ${_T} && _Trace 'Check for dups. (%s)' "${_opt}"
  case "${_opt}" in
    *${1:0:1}*)
      Error -L '(AddOption) Option %s is already defined. (%s)' "${1:0:1}" "${_opt}"
      ;;

  esac

  ${_T} && _Trace 'Get option type for usage. (%s)' "${1}"
  case "${1}" in
    *:*)
      ${_T} && _Trace 'Add option with parameter. (-%s)' "${1}"
      _opf+=( "${1:0:1}" ) # opt flag
      _opm+=( "${_m}" ) # multiple
      _oavar+=( "${_n}" ) # array variable
      [[ -z "${_u}" ]] && _u='${OPTARG}'
      ;;

    *)
      ${_T} && _Trace 'Add simple option. (-%s)' "${1}"
      _os+=( "${1:0:1}" ) # simple opt
      _osm+=( "${_m}" ) # multiple
      ;;

  esac

  ${_T} && _Trace 'Add option. (%s)' "${*}"
  _opt+="${1}"
  _ou+=( "${1:0:1}" ) # usage
  ${_r} && _or+=( true ) || _or+=( false ) # required
  _ovar+=( "${_n}" ) # variable
  _oval+=( "${_u}" ) # value
  _op+=( "${_p}" ) # path
  _oc+=( "${_c}" ) # callback
  _ov+=( "${_v}" ) # validation callback
  _ok+=( "${_k}" ) # keyword
  _osv+=( "${_s}" ) # selection var
  _oa+=( "${_a}" ) # autodefault
  [[ -n "${_l}" ]] && eval "_os_${1:0:1}=( \"\${_l[@]}\" )"

  ${_T} && _Trace 'Set description. (%s)' "${_d}"
  if [[ -z "${_n}" ]]
  then
    _om+=( false )
    _od+=( "${_d}" ) # desc
  else
    if ${_m}
    then
      ${_T} && _Trace 'Multiple option setup. (%s=( %s ))' "${_n}" "${_i[*]}"
      _om+=( true )
      ${ZSH} && _od+=( "${_d} (${_n}: \${(j:, :)${_n}})" ) || _od+=( "${_d} (${_n}: \${${_n}[*]})" ) # desc
      [[ -n "${_i}" ]] && eval "${_n}=( \"\${_i[@]}\" )"
    else
      ${_T} && _Trace 'Single option setup. (%s="%s")' "${_n}" "${_i[*]}"
      _om+=( false )
      _od+=( "${_d} (${_n}: \${${_n}})" ) # desc
      [[ -n "${_i}" ]] && eval "${_n}='${_i[${AO}]}'"
    fi
  fi

  ${_T} && _Trace 'AddOption return. (%s)' 0
  return 0
}

# add parameter pattern
_pm=false
_pr=false
UICMD+=( 'AddParameter' )
AddParameter () { # [-a|-m|-r] [-c <callback>] [-d <desc>] [-i <initial_value>] [-I <initial_var>] [-k <keyword>] [-n <var>] [-P <path>] [-s <selection_values>] [-S <selection_var>] [-v <callback>] [<var>]
  ${_init} || Error -L '(AddParameter) Must be called before Initialize.'
  ${_S} && ((_cAddParameter++))
  ${_T} && _Trace 'AddParameter [%s]' "${*}"

  local _a=false
  local _c
  local _d
  local _i
  local _k
  local _l
  local _n
  local _p
  local _s; _s=( )
  local _v

  ${_T} && _Trace 'Process AddParameter options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':ac:d:i:I:k:mn:P:rs:S:v:' _o
  do
    case ${_o} in
      a)
        ${_T} && _Trace 'Autodefault.'
        _a=true
        ;;

      c)
        ${_T} && _Trace 'Parameter callback. (%s)' "${OPTARG}"
        _c="${OPTARG}"
        ;;

      d)
        ${_T} && _Trace 'Parameter description. (%s)' "${OPTARG}"
        _d="${OPTARG}"
        ;;

      i|I)
        ${_T} && _Trace 'Initial parameter value. (%s)' "${OPTARG}"
        if [[ 'I' == "${_o}" ]]
        then
          ${ZSH} && _i=( "${(P@)OPTARG}" ) || eval "_i=( \"\${${OPTARG}[@]}\" )"
        else
          [[ -z "${_i}" ]] && _i=( "${OPTARG}" ) || _i=( "${_i[@]}" "${OPTARG}" )
        fi
        ;;

      k)
        ${_T} && _Trace 'Parameter keyword. (%s)' "${OPTARG}"
        _k="${OPTARG}"
        ;;

      m)
        ${_T} && _Trace 'Allow multiple (last) parameter entries.'
        _pm=true
        ;;

      n)
        ${_T} && _Trace 'Parameter variable. (%s)' "${OPTARG}"
        _n="${OPTARG}"
        ;;

      P)
        ${_T} && _Trace 'Path. (%s)' "${OPTARG}"
        _p="${OPTARG%/}"
        ;;

      r)
        ${_T} && _Trace 'Required parameter.'
        _pr=true
        ;;

      s)
        ${_T} && _Trace 'Parameter selection value. (%s)' "${OPTARG}"
        [[ -z "${_l}" ]] && _l=( "${OPTARG}" ) || _l=( "${_l[@]}" "${OPTARG}" )
        ;;

      S)
        ${_T} && _Trace 'Parameter selection variable. (%s)' "${OPTARG}"
        _s="${OPTARG}"
        ;;

      v)
        ${_T} && _Trace 'Parameter validation callback. (%s)' "${OPTARG}"
        _v="${OPTARG}"
        ;;

      *)
        Error -L '(AddParameter) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  [[ -z "${_n}" ]] && ((1 == ${#})) && _n="${1}" && shift
  ((1 < ${#})) && Error -L '(AddParameter) Too many parameters provided. (%s)' "${*}"
  [[ -z "${_n}" && -z "${_c}" ]] && Error -L '(AddParameter) No variable name or callback provided.'

  ${_T} && _Trace 'Add parameter. (%s)' "${_k}"
  _pvar+=( "${_n}" ) # var
  _pp+=( "${_p}" ) # path
  _pc+=( "${_c}" ) # callback
  _pv+=( "${_v}" ) # validation callback
  _pk+=( "${_k}" ) # keyword
  _psv+=( "${_s}" ) # selection var
  _pa+=( "${_a}" ) # autodefault
  [[ -n "${_l}" ]] && eval "_ps_${_n}=( \"\${_l[@]}\" )"

  ${_T} && _Trace 'Set parameter initial value. (%s="%s")' "${_n}" "${_i[*]}"
  if ${_pm}
  then
    ${_T} && _Trace 'Multiple parameter setup. (%s=( %s ))' "${_n}" "${_i[*]}"
    ${ZSH} && _pd+=( "${_d} (${_n}: \${(j:, :)${_n}})" ) || _pd+=( "${_d} (${_n}: \${${_n}[*]})" ) # desc
    [[ -n "${_i}" ]] && eval "${_n}=( \"\${_i[@]}\" )"
  else
    ${_T} && _Trace 'Single parameter setup. (%s="%s")' "${_n}" "${_i[*]}"
    _pd+=( "${_d} (${_n}: \${${_n}})" ) # desc
    [[ -n "${_i}" ]] && eval "${_n}='${_i[${AO}]}'"
  fi

  ${_T} && _Trace 'AddParameter return. (%s)' 0
  return 0
}

# perform an action
_action=true
UICMD+=( 'Action' )
Action () { # [-1..-9|-a|-c|-C|-e|-F|-R|-s|-t|-W] [-i <info_message>] [-f <failure_message>] [-l <file_path>] [-p <pipe_element>] [-q <question>] [-r <retries>] [-w <retry_wait>] <command_string_to_evaluate>
  ${_S} && ((_cAction++))
  ${_T} && _Trace 'Action [%s]' "${*}"

  local _a=true
  local _b; ${ZSH} && _b=' ; _ps=( "${pipestatus[@]}" )' || _b=' ; _ps=( "${PIPESTATUS[@]}" )'
  local _c='-a'
  local _e=false
  local _f
  local _h='Failure while evaluating command.'
  local _i
  local _l
  local _m=false
  local _pe
  local _ps; _ps=( )
  local _q
  local _r=1
  local _rv=1
  local _s=0
  local _t=false
  local _v=${_confirm}
  local _w=true

  ${_T} && _Trace 'Process Action options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':123456789acCef:Fi:l:p:q:r:Rstw:W' _o
  do
    case ${_o} in
      [1-9])
        ${_T} && _Trace 'File ID. (%s)' "${_o}"
        _f="${_o}"
        ;;

      a|c)
        ${_T} && _Trace 'File mode. (%s)' "${_o}"
        _c="-${_o}"
        ;;

      C)
        ${_T} && _Trace 'Confirm action.'
        _v=true
        ;;

      e)
        ${_T} && _Trace 'Action error out.'
        _e=true
        ;;

      f)
        ${_T} && _Trace 'Failure message. (%s)' "${OPTARG}"
        _h="${OPTARG}"
        ;;

      F)
        ${_T} && _Trace 'No action after failure.'
        _a=false
        ;;

      i)
        ${_T} && _Trace 'Info message. (%s)' "${OPTARG}"
        _i="${OPTARG}"
        ;;

      l)
        ${_T} && _Trace 'File path. (%s)' "${OPTARG}"
        ${ZSH} && _l=${~OPTARG} || _l=${OPTARG}
        ;;

      p)
        ${_T} && _Trace 'Use pipe element return value. (%s)' "${OPTARG}"
        _pe="${OPTARG}"
        ;;

      q)
        ${_T} && _Trace 'Question. (%s)' "${OPTARG}"
        _q="${OPTARG}"
        ;;

      r)
        ${_T} && _Trace 'Retry. (%s)' "${OPTARG}"
        _r="${OPTARG}"
        ;;

      R)
        ${_T} && _Trace 'Reset action state.'
        _action=true
        ;;

      s)
        ${_T} && _Trace 'Use spinner.'
        LoadMod Spinner
        _m=true
        ;;

      t)
        ${_T} && _Trace 'Tee log file path. (%s)' "${OPTARG}"
        _t=true
        ;;

      w)
        ${_T} && _Trace 'Retry wait. (%s)' "${OPTARG}"
        _s="${OPTARG}"
        ;;

      W)
        ${_T} && _Trace 'No warnings.'
        _w=false
        ;;

      *)
        Error -L '(Action) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ${_T} && _Trace 'Action state: %s (%s)' "${_action}" "${_a}"
  ((0 == ${#})) && _Trace 'Return action state. (%s)' "${_action}" && return $(${_action})
  if [[ -z "${_f}" && -z "${_l}" ]]
  then
    ${_t} && Error -L '(Action) Called with -t but without -[1-9] or -l <path>.'
  else
    [[ -n "${_f}" && -n "${_l}" ]] && Error -L '(Action) Called with both -%s and -l %s.' "${_f}" "${_l}"
    ${_confirm} && _t=true
  fi

  ${_T} && _Trace 'Check for error.'
  if Error
  then
    ${_T} && _Trace 'Action error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    if ${_a} || ${_action}
    then
      [[ -n "${*//[^|]/}" ]] && _pe="${_pe:-${AO}}" || _pe=-1

      ${_T} && _Trace 'Check if confirming action. (%s)' "${_v}"
      if ! ${_v} || Verify "${DConfirm}(Confirm)${D} ${_q:-${*}}"
      then
        ${_T} && _Trace 'Check for no action. (%s)' "${_noaction}"
        if ${_noaction}
        then
          ${_T} && _Trace -I 'NO ACTION: %s' "${*}"
          ${_vdb} && printf "${DJBL}${DNoAction}(No Action) %s (PWD: %s)${D}${DCEL}\n" "${*}" "${PWD}" || \
              printf "${DJBL}${DNoAction}(No Action) %s${D}${DCEL}\n" "${*}"
          _rv=0
        else
          ${_T} && _Trace 'Check for verbose. (%s)' "${_vdb}"
          ${_vdb} && printf "${DJBL}${DAction}(Action) %s (PWD: %s)${D}${DCEL}\n" "${*}" "${PWD}"

          local _p
          local _x
          while [[ 0 -ne ${_rv} && 0 -lt ${_r} ]]
          do
            ((_r--))

            ${_T} && _Trace 'Process info message. (%s)' "${_i}"
            ${_quiet} || if ${_m}
            then
              ${_confirm} || StartSpinner "${_i}"
            else
              [[ -n "${_i}" ]] && printf "${DJBL}${DAction}%s${D} ${DCEL}" "${_i}"
            fi

            ${_L} && [[ -z "${_f}" && -z "${_l}" ]] && _f=0 && _x=10
            ${_T} && _Trace 'Check if logging. (%s)' "${_f:-${_l}}"
            if ${_multiuser} && [[ -n "${_l}" ]] || [[ -n "${_f}" ]]
            then
              [[ -z "${_f}" ]] && _p=${_File_ip:-${_File_libui_ip}} && _f=2 && _File_ip=${_p} Open ${_c} "-${_f}" "${_l}"
              ${_T} && _Trace 'Log action. (%s%s)' "${_p}" "${_f}"
              ((_File_libui_ip)) || LoadMod File
              _File_ip=${_p} Write "-${_f}" "ACTION $(date): ${*}" || Warn 'Unable to log action. (%s)' "${*}"

              ${_T} && _Trace -I 'ACTION: %s' "${*}"
              if ${_t}
              then
                if ${ZSH}
                then
                  eval "${@}${_b}" >&1 >&${_File_fd[((${_p:-0} * 10 + _x + _f))]} 2>&1
                else
                  _l="${_File_fp[((${_p:-0} * 10 + _x + _f))]}"
                  _File_ip=${_p} Close "-${_f}"
                  eval "${@} 2>&1 | tee -a '${_l}'${_b}"
                  _File_ip=${_p} Open "-${_f}" "${_l}"
                  ((0 > _pe)) && ((_pe--))
                fi
              else
                eval "${@}${_b}" >&${_File_fd[((${_p:-0} * 10 + _x + _f))]} 2>&1
              fi
              ${_T} && _Trace 'Log action. (%s%s)' "${_p}" "${_f}"
            elif [[ -n "${_l}" ]]
            then
              ${_T} && _Trace 'Log action. (%s)' "${_l}"
              ((_File_libui_ip)) || LoadMod File
              Write ${_c} -f "${_l}" "ACTION $(date): ${*}" || Warn 'Unable to log action. (%s)' "${*}"

              ${_T} && _Trace -I 'ACTION: %s' "${*}"
              if ${_t}
              then
                eval "${@} 2>&1 | tee -a '${_l}'${_b}"
                ((0 > _pe)) && ((_pe--))
              else
                eval "${@}${_b}" >> "${_l}" 2>&1
              fi
            else
              ${_T} && _Trace -I 'ACTION: %s' "${*}"
              eval "${@}${_b}"
            fi

            ${_m} && StopSpinner

            ${_T} && _Trace 'Test return value. (%s)' "${_ps[*]}"
            if ${ZSH}
            then
              _rv="${_ps[${_pe}]}"
            else
              ((0 > _pe)) && _rv="${_ps[${#_ps[@]} + ${_pe}]}" || _rv="${_ps[${_pe}]}"
            fi

            ${_T} && _Trace 'Check return value. (%s)' "${_rv}"
            if ((0 != _rv))
            then
              ${_T} && _Trace 'Attempt failed, sleep before retry. (%s / %s)' "${_s}" "${_r}"
              ((0 < _r)) && sleep ${_s}
            fi
          done

          ${_T} && _Trace 'Close log. (%s, %s, %s)' "${multiuser}" "${_L}" "${_p}${_f}"
          ${_multiuser} && ! ${_L} && [[ -n "${_f}" ]] && _File_ip=${_p} Close "-${_f}" && _f=

          ${_T} && _Trace 'Check for success. (%s)' "${_rv}"
          if ((0 == _rv))
          then
            _action=true
          else
            _action=false
            if ${_vdb}
            then
              ${_e} && Error ${_f:+-${_f}} ${_l:+-l} ${_l:+"${_l}"} "(Action) ${_h} (%s, PWD: %s)" "${*}" "${PWD}"
              ${_w} && Warn ${_f:+-${_f}} ${_l:+-l} ${_l:+"${_l}"} "(Action) ${_h} (%s, PWD: %s)" "${*}" "${PWD}"
            else
              ${_e} && Error ${_f:+-${_f}} ${_l:+-l} ${_l:+"${_l}"} "(Action) ${_h}"
              ${_w} && Warn ${_f:+-${_f}} ${_l:+-l} ${_l:+"${_l}"} "(Action) ${_h}"
            fi
          fi
        fi
      fi
    else
      ${_w} && _rv=2 && Warn ${_c} ${_f:+-${_f}} ${_l:+-l} ${_l:+"${_l}"} '(Action) Skipping due to previous failure: %s' "${*}"
    fi

    ${_T} && _Trace 'Action return. (%s)' "${_rv}"
    return ${_rv}
  fi
}

# confirm variables
UICMD+=( 'ConfirmVar' )
ConfirmVar () { # [-A|-d|-e|-f|-n|-z] [-D <default>] [-P <path>] [-q|-Q <question>] [-s <selection_value>] [-S <selection_var>] <variable> ...
  ${_S} && ((_cConfirmVar++))
  ${_T} && _Trace 'ConfirmVar [%s]' "${*}"

  local _a=false
  local _d
  local _e; ${_init} || _e='-e'
  local _f=false
  local _m='The variable "%s%s" is required but not defined.'
  local _p
  local _q
  local _rv=0
  local _s
  local _t='n' # default test is variable not defined
  local _z

  ${_T} && _Trace 'Process ConfirmVar options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':AdD:efnP:q:Q:s:S:z' _o
  do
    case ${_o} in
      A)
        ${_T} && _Trace 'Associative array test.'
        _a=true
        _m='The variable "%s%s" is not an associative array.'
        ;;

      d)
        ${_T} && _Trace 'Directory exists test.'
        _t='d'
        _m='The directory "%s" does not exist. (%s)'
        ;;

      D)
        ${_T} && _Trace 'Default answer. (%s)' "${OPTARG}"
        _d="${OPTARG}"
        ;;

      e)
        ${_T} && _Trace 'Path exists test.'
        _t='e'
        _m='The path "%s" does not exist. (%s)'
        ;;

      f)
        ${_T} && _Trace 'File exists test.'
        _t='f'
        _m='The file "%s" does not exist. (%s)'
        ;;

      n)
        ${_T} && _Trace 'Not empty test.'
        # default
        ;;

      P)
        ${_T} && _Trace 'Path. (%s)' "${OPTARG}"
        _p="${OPTARG%/}"
        ;;

      q|Q)
        ${_T} && _Trace 'Question. (%s)' "${OPTARG}"
        _q="${OPTARG}"
        [[ 'Q' == "${_o}" ]] && _f=true
        ;;

      s|S)
        ${_T} && _Trace 'Selection value. (%s)' "${OPTARG}"
        _s+=" -${_o} \"${OPTARG}\""
        ;;

      z)
        ${_T} && _Trace 'Allow empty response.'
        _z='-z'
        ;;

      *)
        Error -L '(ConfirmVar) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(ConfirmVar) Called without a variable name.'

  local _v
  local _x
  ${_error} && _rv=1 || for _v in "${@}"
  do
    if ${_a}
    then
      ${_T} && _Trace 'AA test %s.' "${_v}"
      [[ "$(declare -p "${_v}" 2> /dev/null)" =~ .*\ -A\ .* ]]
    else
      ${ZSH} && _x="${(P)_v}" || _x="${!_v}"

      ${_T} && _Trace 'Check for interaction. (%s)' "${_f}"
      if ! Error && [[ -z "${_x}" && -n "${_q}" ]] || ${_f}
      then
        ${_T} && _Trace 'Query and test -%s ${%s}. (%s)' "${_t}" "${_v}" "${_x}"
        until ! ${_f} && [[ -n "${_x}" ]] && test -${_t} "${_x}" # must use test
        do
          ${_T} && _Trace 'Check value. (%s)' "${_x}"
          if [[ -z "${_x}" ]] || ${_f}
          then
            _f=false
            ${_T} && _Trace 'Ask question. (%s)' "${_q}"
            eval "Ask -n '${_v}'${_s} ${_p:+-P ${_p}} -d '${_x:-${_d}}' ${_z} '${_q}'"
            _x="${ANSWER}"
            ${_T} && _Trace 'Check if empty and allowed. (%s / %s)' "${_x}" "${_z}"
            [[ -n "${_z}" && -z "${_x}" ]] && break
            ${_T} && _Trace 'Loop and test -%s %s. (%s)' "${_t}" "${_v}" "${_x}"
          else
            Verify 'Response invalid (%s). Try again?' "${_x}" && _f=true || break
          fi
        done
      fi

      ${_T} && _Trace 'Test -%s "%s". (%s)' "${_t}" "${_x}" "${_v}"
      if [[ -z "${_x}" ]]
      then
        ${_T} && _Trace 'Check if empty allowed. (%s)' "${_z}"
        [[ -n "${_z}" ]]
      else
        test -${_t} "${_x}" # must use test
      fi
    fi
    if ((0 != ${?}))
    then
      Error ${_e} "${_m}" "${_x}" "${_v}" # _e no quotes
      _rv=1
    fi
  done

  ${_T} && _Trace 'ConfirmVar return. (%s)' "${_rv}"
  return ${_rv}
}

# ask a question and return a response
_yes=false
UICMD+=( 'Ask' )
Ask () { # [-b|-C|-N|-Y|-z] [-d <default>] [-n <varname>] [-P <path>] [-r <required_regex>] [-s <selection_value>] [-S <selection_var>] <question_text>
  ${_S} && ((_cAsk++))
  ${_T} && _Trace 'Ask [%s]' "${*}"

  local _a; _a=( )
  local _b
  local _c=false
  local _d="${LIBUI_DEFAULT:-}"; ${_yes} && _d="${_d:-yes}"
  local _n
  local _p
  local _r
  local _z=false

  ${_T} && _Trace 'Process Ask options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':bCd:n:NP:r:s:S:Yz' _o
  do
    case ${_o} in
      b)
        ${_T} && _Trace 'Boolean (y/n).'
        _b="${D} ${DOptions}(y/n)"
        _r='[nNyY]'
        ;;

      C)
        ${_T} && _Trace 'Confirm only. (%s)' "${_confirm}"
        ${_confirm} || _c=true
        ;;

      d)
        ${_T} && _Trace 'Default answer. (%s)' "${OPTARG}"
        _d="${OPTARG}"
        ;;

      n)
        ${_T} && _Trace 'Answer variable name. (%s)' "${OPTARG}"
        _n="${OPTARG}"
        ${ZSH} && _d="${_d:-${(P)_n}}" || _d="${_d:-${!_n}}"
        ;;

      N)
        ${_T} && _Trace 'No.'
        _d='no'
        ;;

      P)
        ${_T} && _Trace 'Path. (%s)' "${OPTARG}"
        _p="${OPTARG%/}"
        ;;

      r)
        ${_T} && _Trace 'Required regex. (%s)' "${OPTARG}"
        _r="${OPTARG}"
        ;;

      s)
        ${_T} && _Trace 'Answer selection value. (%s)' "${OPTARG}"
        [[ -z "${_a}" ]] && _a=( "${OPTARG}" ) || _a=( "${_a[@]}" "${OPTARG}" )
        ;;

      S)
        ${_T} && _Trace 'Answer selection variable. (%s)' "${OPTARG}"
        ${ZSH} && _a=( "${(P@)OPTARG}" ) || eval "_a=( \"\${${OPTARG}[@]}\" )"
        ;;

      Y)
        ${_T} && _Trace 'Yes.'
        _d='yes'
        ;;

      z)
        ${_T} && _Trace 'Allow empty response.'
        _z=true
        ;;

      *)
        Error -L '(Ask) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(Ask) Called without a question.'
  ! ${TERMINAL} && [[ -z "${_d}" ]] && ! ${_z} && Error '(Ask) Question asked without a terminal, no default, and a response required.'
  ! ${_z} && [[ -z "${_d}" && 1 -eq ${#_a[@]} ]] && _d="${_a[${AO}]}"

  ${_T} && _Trace 'Confirm only? (%s)' "${_c}"
  ${_c} && ANSWER="${_d}" && return 0

  ${_T} && _Trace -I 'ASK: %s' "${*}"

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
  local _q="$(printf "${DJBL}${DQuestion}${_s}${_b}${D} ${DAnswer}[%s]${D} ${DCEL}" "${@}" "${_d/${_p:+${_p}\/}}")"
  ANSWER=

  ((0 < ${_spinner:-0})) && PauseSpinner

  ${_T} && _Trace 'Check for selection. (%s)' "${#_a[@]}"
  ${_quiet} || if ((0 != ${#_a[@]}))
  then
    printf "${DJBL}${DCEL}${DCES}\n${DOptions}The possible responses are:\n"
    local _i
    if ${ZSH}
    then
      for ((_i = 1; _i <= ${#_a}; _i++))
      do
        printf "%4s. %s${DCEL}\n" ${_i} "${_a[${_i}]/${_p:+${_p}\/}}"
      done
    else
      for _i in "${!_a[@]}"
      do
        printf "%4s. %s${DCEL}\n" $((_i + 1)) "${_a[${_i}]/${_p:+${_p}\/}}"
      done
    fi
    printf "${D}${DCEL}\n"
  fi

  ${_T} && _Trace 'Check if auto "yes". (%s | ! %s)' "${_yes}" "${TERMINAL}"
  if ${_yes} || ! ${TERMINAL}
  then
    ${_T} && _Trace 'Default answer. (%s)' "${_d}"
    ANSWER="${_d}"
    ${_quiet} || printf "${_q}${DAnswer}%s${D}\n" "${ANSWER}"
  else
    local _l=true
    local _f=false
    local _t
    ${_T} && _Trace 'Prompt for answer. (%s)' "${_s} ${*}"
    while ${_l}
    do
      if ${ZSH} && [[ -t 1 ]]
      then
        vared -p "${_q}" ANSWER
      else
        printf "${_q}"
        [[ -t 1 ]] && read -e ANSWER || read ANSWER
      fi
      [[ -n "${_b}" && 'q' == "${ANSWER}" ]] && Error -e -r 9 'Quit requested.'
      if [[ -z "${ANSWER}" ]]
      then
        ANSWER="${_d}"
        break
      else
        ${_T} && _Trace 'Validate answer. (%s)' "${ANSWER}"
        if ((0 != ${#_a[@]}))
        then
          if [[ -n "${_p}" && "${ANSWER}" =~ .*/.* ]]
          then
            _f=true
            _Trace 'Path provided. (%s) Ignoring path option. (%s)' "${ANSWER}" "${_p}"
            _p=
          else
            _f=false
            case "${ANSWER}" in
              [0-9]*) # number
                ANSWER="${_a[$((ANSWER + AO - 1))]}" && _f=true
                ;;

              *) # nan
                _t="${_p:+${_p}/}${ANSWER}"
                if ${ZSH}
                then
                  ((${_a[(Ie)${_t}]})) && ANSWER="${_t}" && _f=true
                else
                  for _i in "${!_a[@]}"
                  do
                    [[ "${_t}" == "${_a[${_i}]}" ]] && ANSWER="${_t}" && _f=true && break
                  done
                fi
                ;;

            esac
          fi
          ${_f} || ANSWER=
        fi
        if [[ -n "${ANSWER}" ]] || ${_z}
        then
          [[ -n "${_r}" && ! "${ANSWER}" =~ ${_r} ]] || _l=false
        fi
      fi
      ${_l} && Tell 'Invalid response provided.'
    done
  fi

  ((0 < ${_spinner:-0})) && ResumeSpinner

  ${_T} && _Trace -I 'ANSWER: %s' "${ANSWER}"

  ${_T} && _Trace 'Assign answer. (%s=%s)' "${_n}" "${ANSWER}"
  [[ -n "${_n}" ]] && eval "${_n}='${ANSWER}'"

  ${_T} && _Trace 'Ask return. (%s)' 0
  return 0
}

# check if answer matches parameter
UICMD+=( 'AnswerMatches' )
AnswerMatches () { # [-r] <answer_match_string>
  ${_S} && ((_cAnswerMatches++))
  ${_T} && _Trace 'AnswerMatches [%s]' "${*}"

  local _e=false

  ${_T} && _Trace 'Process AnswerMatches options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':r' _o
  do
    case ${_o} in
      r)
        ${_T} && _Trace 'Regex match.'
        _e=true
        ;;

      *)
        Error -L '(AnswerMatches) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(AnswerMatches) Called without a match string.'

  local _rv=1
  local _m="${*}"

  ${_T} && _Trace 'Check for match. (%s)' "${*}"
  if ${_e}
  then
    [[ "${ANSWER}" =~ ${_m} ]] && _rv=0
  else
    ${ZSH} && _m="${_m:l}"; ((40 <= BV)) && _m="${_m,,}"
    local _a="${ANSWER:0:${#_m}}"; ${ZSH} && _a="${_a:l}"; ((40 <= BV)) && _a="${_a,,}"
    [[ -n "${_m}" && "${_m}" == "${_a}" ]] && _rv=0
  fi
  ${_T} && _Trace -I 'Answer match: %s=%s. (%s)' "${ANSWER}" "${_m}" "${_rv}"

  ${_T} && _Trace 'AnswerMatches return. (%s)' "${_rv}"
  return ${_rv}
}

# ask a question and verify a positive response
UICMD+=( 'Verify' )
_verify=false
Verify () { # [-C|-N|-Y] [-d <default>] [-n <varname>] [-r <required_regex>] <question_text>
  ${_S} && ((_cVerify++))
  ${_T} && _Trace 'Verify [%s]' "${*}"

  ((0 == ${#})) && _Trace 'Return verify state. (%s)' "${_verify}" && return $(${_verify})

  local _a="${ANSWER}"
  Ask -b -d 'yes' "${@}"
  AnswerMatches -r '[yY].*' && _verify=true || _verify=false
  ANSWER="${_a}"

  ${_T} && _Trace 'Verify return. (%s)' "${_verify}"
  ${_verify} && return 0 || return 1
}

# send user message
UICMD+=( 'Tell' )
Tell () { # [-1..-9|-a|-c|-i|-n|-N] [-l <file_path>] <message_text>
  ${_S} && ((_cTell++))
  ${_T} && _Trace 'Tell [%s]' "${*}"

  local _c
  local _f
  local _i="${DJBL}"
  local _l
  local _n=$'\n'

  ${_T} && _Trace 'Process Tell options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':123456789acil:nN' _o
  do
    case ${_o} in
      [1-9])
        ${_T} && _Trace 'File ID. (%s)' "${_o}"
        _f="${_o}"
        ;;

      a|c)
        ${_T} && _Trace 'File mode. (%s)' "${_o}"
        _c="-${_o}"
        ;;

      i)
        ${_T} && _Trace 'In place.'
        _i=
        ;;

      l)
        ${_T} && _Trace 'File path. (%s)' "${OPTARG}"
        ${ZSH} && _l=${~OPTARG} || _l=${OPTARG}
        ;;

      n)
        ${_T} && _Trace 'No newline.'
        _n=
        ;;

      N)
        ${_T} && _Trace 'No linefeed.'
        _n="${DJBL}"
        ;;

      *)
        Error -L '(Tell) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  ${_T} && _Trace -I 'TELL: %s' "${*}"

  local _m
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
  ${_L} && [[ -z "${_f}" && -z "${_l}" ]] && _f=0
  if [[ -n "${_f}" || -n "${_l}" ]]
  then
    local _p
    ${_T} && _Trace 'Log tell. (%s)' "${_f:-${_l}}"
    ${PV} && printf -v _m "${_s}" "${@}" || _m="$(printf "${_s}" "${@}")"
    ((_File_libui_ip)) || LoadMod File
    if [[ -n "${_f}" ]]
    then
      Write "-${_f}" "${_m}" || Warn 'Unable to write message to log file. (%s)' "${_m}"
    else
      ${_multiuser} && _f=2 && _p=${_File_ip:-${_File_libui_ip}} && _File_ip=${_p} Open ${_c} "-${_f}" "${_l}" && _l=
      _File_ip=${_p} Write ${_c} -${_f:-f} ${_l:+"${_l}"} "${_m}" || Warn 'Unable to write message to log file. (%s)' "${_m}"
      ${_multiuser} && ! ${_L} && _File_ip=${_p} Close "-${_f}"
    fi
  fi
  ${_quiet} || printf -- "${_i}${DTell}${_s}${D}${DCEL}${_n}" "${@}"

  ${_T} && _Trace 'Tell return. (%s)' 0
  return 0
}

# send user alert
UICMD+=( 'Alert' )
Alert () { # [-1..-9|-a|-c] [-l <file_path>] <message_text>
  ${_S} && ((_cAlert++))
  ${_T} && _Trace 'Alert [%s]' "${*}"

  local _c
  local _f
  local _l

  ${_T} && _Trace 'Process Alert options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':123456789acl:' _o
  do
    case ${_o} in
      [1-9])
        ${_T} && _Trace 'File ID. (%s)' "${_o}"
        _f="${_o}"
        ;;

      a|c)
        ${_T} && _Trace 'File mode. (%s)' "${_o}"
        _c="-${_o}"
        ;;

      l)
        ${_T} && _Trace 'File path. (%s)' "${OPTARG}"
        ${ZSH} && _l=${~OPTARG} || _l=${OPTARG}
        ;;

      *)
        Error -L '(Alert) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(Alert) Called without a message.'

  ${_T} && _Trace -I 'ALERT: %s' "${*}"

  local _m
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
  ${_L} && [[ -z "${_f}" && -z "${_l}" ]] && _f=0
  if [[ -n "${_f}" || -n "${_l}" ]]
  then
    ${_T} && _Trace 'Log alert. (%s)' "${_f:-${_l}}"
    ${PV} && printf -v _m "ALERT: ${_s}" "${@}" || _m="$(printf "ALERT: ${_s}" "${@}")"
    ((_File_libui_ip)) || LoadMod File
    if [[ -n "${_f}" ]]
    then
      Write "-${_f}" "${_m}" || Warn 'Unable to write alert to log file. (%s)' "${_m}"
    else
      ${_multiuser} && _f=2 && _p=${_File_ip:-${_File_libui_ip}} && _File_ip=${_p} Open ${_c} "-${_f}" "${_l}" && _l=
      _File_ip=${_p} Write ${_c} -${_f:-f} ${_l:+"${_l}"} "${_m}" || Warn 'Unable to write alert to log file. (%s)' "${_m}"
      ${_multiuser} && ! ${_L} && _File_ip=${_p} Close "-${_f}"
    fi
  fi
  ${_quiet} || printf -- "${DJBL}${DAlert}${_s}${D}${DCEL}\n" "${@}"

  ${_T} && _Trace 'Alert return. (%s)' 0
  return 0
}

# send user warning
UICMD+=( 'Warn' )
Warn () { # [-1..-9|-a|-c] [-l <file_path>] [-r <retval>] <warning_message>
  ${_S} && ((_cWarn++))
  ${_T} && _Trace 'Warn [%s]' "${*}"

  local _c
  local _f
  local _l
  local _rv=1

  ${_T} && _Trace 'Process Warn options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':123456789acl:r:' _o
  do
    case ${_o} in
      [1-9])
        ${_T} && _Trace 'File ID. (%s)' "${_o}"
        _f="${_o}"
        ;;

      a|c)
        ${_T} && _Trace 'File mode. (%s)' "${_o}"
        _c="-${_o}"
        ;;

      l)
        ${_T} && _Trace 'File path. (%s)' "${OPTARG}"
        ${ZSH} && _l=${~OPTARG} || _l=${OPTARG}
        ;;

      r)
        ${_T} && _Trace 'Return value. (%s)' "${OPTARG}"
        _rv="${OPTARG}"
        ;;

      *)
        Error -L '(Warn) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(Warn) Called without a message.'

  ${_T} && _Trace -I 'WARNING: %s' "${*}"

  local _m
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
  ${_L} && [[ -z "${_f}" && -z "${_l}" ]] && _f=0
  if [[ -n "${_f}" || -n "${_l}" ]]
  then
    local _p
    ${_T} && _Trace 'Log warning. (%s)' "${_f:-${_l}}"
    ${PV} && printf -v _m "WARNING: ${_s}" "${@}" || _m="$(printf "WARNING: ${_s}" "${@}")"
    ((_File_libui_ip)) || LoadMod File
    if [[ -n "${_f}" ]]
    then
      Write "-${_f}" "${_m}" || Warn 'Unable to write warning to log file. (%s)' "${_m}"
    else
      ${_multiuser} && _f=2 && _p=${_File_ip:-${_File_libui_ip}} && _File_ip=${_p} Open ${_c} "-${_f}" "${_l}" && _l=
      _File_ip=${_p} Write ${_c} -${_f:-f} ${_l:+"${_l}"} "${_m}" || Warn 'Unable to write warning to log file. (%s)' "${_m}"
      ${_multiuser} && ! ${_L} && _File_ip=${_p} Close "-${_f}"
    fi
  fi
  [[ -t 2 ]] && printf "${DJBL}${DWarn}WARNING: ${_s}${D}${DCEL}\n" "${@}" >> /dev/stderr || \
      printf "${DJBL}${DWarn}WARNING: ${_s}${D}${DCEL}\n" "${@}" | tee -a /dev/stderr >&3 # duplicated stderr

  ${_T} && _Trace 'Warn return. (%s)' "${_rv}"
  return "${_rv}"
}

# error handler
_error=false
UICMD+=( 'Error' )
Error () { # [-1..-9|-a|-c|-e|-E|-L] [-l <file_path>] [-r <retval>] <error_message>
  ${_S} && ((_cError++))
  ${_T} && _Trace 'Error [%s]' "${*}"

  local _c
  local _e; ${_init} && _e=false || _e=true
  local _f
  local _l
  local _i
  local _rv=1

  ${_T} && _Trace 'Process Error options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':123456789aceEl:Lr:' _o
  do
    case ${_o} in
      [1-9])
        ${_T} && _Trace 'File ID. (%s)' "${_o}"
        _f="${_o}"
        ;;

      a|c)
        ${_T} && _Trace 'File mode. (%s)' "${_o}"
        _c="-${_o}"
        ;;

      e)
        ${_T} && _Trace 'Force exit.'
        _e=true # ensures exit
        ;;

      E)
        ${_T} && _Trace 'Do not exit.'
        _e=false # cancels exit
        ;;

      l)
        ${_T} && _Trace 'File path. (%s)' "${OPTARG}"
        ${ZSH} && _l=${~OPTARG} || _l=${OPTARG}
        ;;

      L)
        _i=true
        _e=true # ensures exit
        ;;

      r)
        ${_T} && _Trace 'Exit return value. (%s)' "${OPTARG}"
        _rv="${OPTARG}"
        ;;

      *)
        Error -L '(Error) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && _Trace 'Return error state. (%s)' "${_error}" && return $(${_error})

  if [[ -n "${_i}" ]] || ((0 < _xdb))
  then
    ${_T} && _Trace 'Get error location.'
    if ${ZSH}
    then
      _i=" in ${funcfiletrace[1]}"
    else
      _i=( $(caller 1 || caller) )
      _i=" in ${_i[2]:-${_i[1]}}:${_i[0]}"
    fi
  fi

  ${_T} && _Trace 'Report error. (%s)' "${*}"
  _error=true

  ${_T} && _Trace -I 'ERROR%s: %s' "${_i}" "${*}"

  local _m
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
  ${_L} && [[ -z "${_f}" && -z "${_l}" ]] && _f=0
  if [[ -n "${_f}" || -n "${_l}" ]]
  then
    local _p
    ${_T} && _Trace 'Log error. (%s)' "${_f:-${_l}}"
    ${PV} && printf -v _m "ERROR%s: ${_s}" "${_i}" "${@}" || _m="$(printf "ERROR%s: ${_s}" "${_i}" "${@}")"
    ((_File_libui_ip)) || LoadMod File
    if [[ -n "${_f}" ]]
    then
      Write "-${_f}" "${_m}" || Warn 'Unable to write error message to log file. (%s)' "${_m}"
    else
      ${_multiuser} && _f=2 && _p=${_File_ip:-${_File_libui_ip}} && _File_ip=${_p} Open ${_c} "-${_f}" "${_l}" && _l=
      _File_ip=${_p} Write ${_c} -${_f:-f} ${_l:+"${_l}"} "${_m}" || Warn 'Unable to write error message to log file. (%s)' "${_m}"
      ${_multiuser} && ! ${_L} && _File_ip=${_p} Close "-${_f}"
    fi
  fi
  [[ -t 2 ]] && printf "${DJBL}${DError}ERROR%s: ${_s}${D}${DCEL}\n" "${_i}" "${@}" >> /dev/stderr || \
      printf "${DJBL}${DError}ERROR%s: ${_s}${D}${DCEL}\n" "${_i}" "${@}" | tee -a /dev/stderr >&3 # duplicated stderr

  ${_T} && _Trace 'Check for exit. (%s)' "${_e}"
  if ${_e}
  then
    ${_T} && _Trace 'Exit. (%s)' "${_rv}"
    Exit ${_rv}
  fi

  ${_T} && _Trace 'Error return. (%s)' "${_rv}"
  return ${_rv}
}

# trace
UICMD+=( 'Trace' )
Trace () { # <trace_message>
  ${_S} && ((_cTrace++))

  ((0 == ${#})) && Error -L '(Trace) Called without a message.'

  if ${_hdb} || ${_tdb}
  then
    _Trace -u "${@}"
  fi

  return 0
}

# library trace
typeset -F SECONDS # use zsh to improve profiling
UICMD+=( '_Trace' )
_Trace () { # [-I|-u] <trace_message>
  ${_S} && ((_c_Trace++))

  if ${_hdb} || ${_tdb} || ${_udb} || ${_mdb}
  then
    local _d=1
    local _I=false
    local _u=false

    # process options
    local _o
    local OPTIND
    local OPTARG
    while getopts ':Iu' _o
    do
      case ${_o} in
        I) # don't interpret
          _I=true
          ;;

        u) # user
          ${ZSH} && _d=-1 || _d=0
          _u=true
          ;;

        *)
          Error -L '(_Trace) Option error. (-%s)' "${OPTARG}"
          ;;

      esac
    done
    shift $((OPTIND - 1))

    # build message
    local _c; ${_u} && ${_cdb} && _c='#' || _c=' '
    local _p
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
    if ${_I}
    then
      _p="${*//\\/\\\\}"
      _p=( "${_p//\%/%%}" )
    else
      _p=( "${@}" )
    fi
    if ${_u}
    then
      _c+='TRACE: '
    fi
    if ${_cdb}
    then
      if ${ZSH}
      then
        _c+="${functrace[${_d}]}: "
      else
        local _t=( $(caller ${_d}) )
        _c+="${_t[1]}:${_t[0]}: "
      fi
    fi

    # write trace file
    ${_tdb} && printf "%s:%s${_s}\n" "${SECONDS}" "${_c}" "${_p[@]}" >> "${_tfile}"

    # write to tty
    if ${_udb} || (${_u} && ${_hdb}) || ${_mdb}
    then
      printf "${DTrace}"
      ${_pdb} && printf '+%s:' "${SECONDS}"
      printf "%s${_s}${D}${DCEL}\n" "${_c}" "${_p[@]}"
    fi
  fi

  return 0
}

# initialize
_allowroot=false
_confirm=false
_force=false
_init=true
_initcallback=( )
_multiuser=false
_noaction=false
_profile=false
_quiet=false
_requireroot=false
_xdb=0
UICMD+=( 'Initialize' )
Initialize () {
  ${_S} && ((_cInitialize++))
  ${_T} && _Trace 'Initialize [%s]' "${*}"

  local _a; _a=( "${CMDARGS[@]}" )
  local _i
  local _p
  local _r; [[ -n "${_or}" ]] && _r=( "${_or[@]}" ) || _r=( )
  local _x

  ${_T} && _Trace 'Load profile. (%s)' "${_profile}"
  ${_profile} && _LoadProfile "${CMDARGS[@]}"

  ${_T} && _Trace 'Process initialize options. (%s)' "${_a[*]}"
  local _o
  local OPTIND
  local OPTARG
  NROPT=0
  while getopts ":${_opt}" _o "${_a[@]}"
  do
    ((NROPT++))
    ${_T} && _Trace 'Check for user provided options. (%s)' "${_o}"
    _i=${AO}
    for _p in "${_ou[@]}"
    do
      if [[ "${_p}" == "${_o}" ]]
      then
        if ${_om[${_i}]}
        then
          ${_T} && _Trace 'Process multiple option value. (%s+=( "%s" ) [%s])' "${_ovar[${_i}]}" "${_oval[${_i}]}" "${OPTARG}"
          [[ ! "${_x}" =~ ${_o} ]] && _x="${_o}" && eval "${_ovar[${_i}]}=( )"
          eval "${_ovar[${_i}]}+=( \"${_oval[${_i}]}\" )"
        else
          ${_T} && _Trace 'Process simple option value. (%s="%s" [%s])' "${_ovar[${_i}]}" "${_oval[${_i}]}" "${OPTARG}"
          [[ -n "${_oval[${_i}]}" ]] && eval "${_ovar[${_i}]}=\"${_oval[${_i}]}\""
        fi

        ${_T} && _Trace 'Process option callback. (%s)' "${_oc[${_i}]}"
        [[ -n "${_oc[${_i}]}" ]] && eval ${_oc[${_i}]} "${OPTARG}"

        ${_T} && _Trace 'Process required option. (%s)' "${_r[*]}"
        _r[${_i}]=false
      fi
      ((_i++))
    done

    ${_T} && _Trace 'Check for standard libui options. (%s)' "${_o}"
    case ${_o} in
      C)
        Confirm
        ${_T} && _Trace 'Confirm operation.'
        _confirm=true
        CHFLAGS+='-C '
        FMFLAGS='-i'
        ;;

      F)
        ${_T} && _Trace 'Force operation.'
        _force=true
        CHFLAGS+='-F '
        FMFLAGS='-f'
        ;;

      h|H)
        ${_T} && _Trace 'Display usage.'
        _error=true
        ;;

      N)
        ${_T} && _Trace 'Perform no actions.'
        _noaction=true
        CHFLAGS+='-N '
        ;;

      P)
        ${_profile} || Error 'To use a profile, please load the Profile mod. (-%s)' "${_o}"
        ;;

      Q)
        ${_T} && _Trace 'Quiet operation.'
        _quiet=true
        CHFLAGS+='-Q '
        ;;

      V)
        LoadMod Info
        Version
        Exit 2
        ;;

      X)
        ${_T} && _Trace 'XDebug value. (%s)' "${OPTARG}"
        [[ -z "${OPTARG//[0-9]}" ]] && _xdb="${OPTARG}" || Error 'Invalid XDebug option value. (%s)' "${OPTARG}"
        CHFLAGS+="-X ${_xdb} "
        ;;

      Y)
        ${_T} && _Trace 'Provide "yes" response.'
        _yes=true
        CHFLAGS+='-Y '
        ;;

      \:)
        Error 'Option argument missing. (%s)' "${OPTARG}"
        ;;

      \?)
        Error 'Invalid option provided. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  ${ZSH} && shift $((OPTIND - 1)) _a || _a=( "${_a[@]:$((OPTIND - 1))}" )
  NRPARAM=${#_a[@]}

  ${_T} && _Trace 'Set up debugging. (%s)' "${_xdb}"
  ((9 <= _xdb)) && _pdb=true && _cdb=true && _udb=true && _T=true && _Trace 'xdb:%s Libui debug enabled.' "${_xdb}"
  ((6 <= _xdb)) && _pdb=true && _cdb=true && ${_T} && _Trace 'xdb:%s Context debug enabled.' "${_xdb}"
  ((5 <= _xdb)) && _pdb=true && ${_T} && _Trace 'xdb:%s Profiling enabled.' "${_xdb}"
  ((8 <= _xdb)) && _mdb=true && _M=true && ${_T} && _Trace 'xdb:%s Mod debug enabled.' "${_xdb}"
  ((7 <= _xdb)) && _rdb=true && ${_T} && _Trace 'xdb:%s Remote debug enabled.' "${_xdb}"
  ((3 <= _xdb)) && _hdb=true && ${_T} && _Trace 'xdb:%s Host debug enabled.' "${_xdb}"
  ((2 <= _xdb)) && _vdb=true && ${_T} && _Trace 'xdb:%s Verbose actions enabled.' "${_xdb}"
  ((1 <= _xdb)) && _wdb=true && ${_T} && _Trace 'xdb:%s Wait debug enabled.' "${_xdb}"

  ${_T} && _Trace 'libui %s. (%s)' "${Version[${#Version[@]} - ${AO} + 1]##*/}" "${SHELL}"

  ${_T} && _Trace 'Check for required options. (%s)' "${_r[*]}"
  local _m
  local _t
  _i=${AO}
  for _t in "${_r[@]}"
  do
    ${_t} && _m+="${_ou[${_i}]}, "
    ((_i++))
  done
  if [[ -n "${_m}" ]]
  then
    Error 'Required option(s) missing. (%s)' "${_m%, }"
  fi

  ${_T} && _Trace 'Obtain parameters. (%s)' "${_pvar[*]}"
  if ((0 < ${#_pvar[@]}))
  then
    _i=$((AO - 1))

    for _p in "${_pvar[@]}"
    do
      ((_i++))

      if [[ -z "${_a[${AO}]}" ]]
      then
        ${_pr} && Error 'Missing parameter. (%s)' "${_p}"
      else
        ${_T} && _Trace 'Process parameter callback. (%s)' "${_pc[${_i}]}"
        [[ -n "${_pc[${_i}]}" ]] && eval ${_pc[${_i}]} "${_a[${AO}]}"

        ${_T} && _Trace 'Capture value. (%s)' "${_a[${AO}]}"
        [[ -n "${_p}" ]] && eval "unset ${_p}; ${_p}='${_a[${AO}]}'"
      fi

      _a=( ${_a[@]:1} )
    done
  fi

  ${_T} && _Trace 'Check for multiple parameter. (%s)' "${_pm}"
  if ${_pm}
  then
    if [[ 1 -lt "${#_a[@]}" && -n "${_pc[${_i}]}" ]]
    then
      ${_T} && _Trace 'Callback and capture multiple values. (%s)' "${_a[*]}"
      [[ -n "${_p}" ]] && eval "${_p}=( \"\${${_p}[@]}\" )"

      while [[ 0 -lt "${#_a[@]}" ]]
      do
        ${_T} && _Trace 'Process parameter callback. (%s)' "${_pc[${_i}]}"
        eval ${_pc[${_i}]} "${_a[${AO}]}"

        ${_T} && _Trace 'Capture value. (%s)' "${_a[${AO}]}"
        [[ -n "${_p}" ]] && eval "${_p}=( \"\${${_p}[@]}\" '${_a[${AO}]}' )"

        _a=( ${_a[@]:1} )
      done
    else
      ${_T} && _Trace 'Capture multiple values. (%s)' "${_a[*]}"
      eval "${_p}=( \"\${${_p}[@]}\" \"\${_a[@]}\" )"
    fi
  elif ((0 < ${#_a[@]}))
  then
    Error 'Too many parameters provided. (%s)' "${_a[*]}"
  fi

  ${_T} && _Trace 'Check if root. (%s)' "${EUID}"
  if ((0 == EUID || 0 == $(id -u)))
  then
    ${_allowroot} || Error 'You cannot execute %s as root.' "${CMD}"
  else
    ${_requireroot} && Error 'You must execute %s as root.' "${CMD}"
  fi

  local _b
  local _d
  local _j
  local _s
  local _v
  ${_T} && _Trace 'Verify option values. (%s)' "${_ou[*]}"
  _i=${AO}
  for _p in "${_ou[@]}"
  do
    ${_T} && _Trace 'Call option validation callback. (%s)' "${_ov[${_i}]}"
    [[ -n "${_ov[${_i}]}" ]] && eval "${_ov[${_i}]}"
    eval "_s=( \"\${_os_${_p}[@]}\" )" && [[ -z "${_s}" ]] && _s=( )
    if [[ -n "${_osv[${_i}]}" ]]
    then
      ${ZSH} && _s+=( "${(P@)_osv[${_i}]}" ) || eval "_s+=( \"\${${_osv[${_i}]}[@]}\" )"
    fi
    ${_T} && _Trace 'Available option selection values. (%s)' "${_s}"
    if [[ -n "${_s}" ]]
    then
      ${ZSH} && _ol+=( "-${_p} (${_ok[${_i}]}): ${(j:, :)${_s[@]/${_op[${_i}]}\/}}" ) || _ol+=( "-${_p} (${_ok[${_i}]}): $(printf '%s, ' "${_s[@]/${_op[${_i}]}\/}")" ) # avail values

      ${_om[${_i}]} && eval "_v=( \"\${${_ovar[${_i}]}[@]}\" )" || eval "_v=\"\${${_ovar[${_i}]}}\""
      ${_T} && _Trace 'Option value. (%s)' "${_v}"

      ${_T} && _Trace 'Build option autodefault. (%s)' "${_oa[${_i}]}"
      if ${_oa[${_i}]} && [[ -z "${_v}" && 1 -eq ${#_s[@]} ]]
      then
        ${_om[${_i}]} && eval "${_ovar[${_i}]}=( \"${_s[${AO}]}\" )" || eval "${_ovar[${_i}]}=\"${_s[${AO}]}\""
        _d+="${DCaution}CAUTION:${D} Option -${_p} (${_ok[${_i}]}) was defaulted to: ${DConfirm}"
        [[ -n "${_op[${_i}]}" ]] && _d+="${_s[${AO}]/${_op[${_i}]}\/}${D}.${DCEL}\n" || _d+="${_s[${AO}]}${D}.${DCEL}\n"
      fi

      ${_T} && _Trace 'Check if required or empty. (%s / %s)' "${_or[${_i}]}" "${_v}"
      if ${_or[${_i}]} || [[ -n "${_v}" ]]
      then
        ${_T} && _Trace 'Check option value. (%s)' "${_v}"
        for _j in "${_v[@]}"
        do
          _b=true
          for _t in "${_s[@]}"
          do
            [[ "${_t/${_op[${_i}]:+${_op[${_i}]}\/}}" == "${_j}" ]] && _b=false && continue 2
          done
          ${_b} && Error 'The value provided for -%s (%s) is not an available option value. (%s)' "${_p}" "${_ok[${_i}]}" "${_j}"
        done
      fi
    fi
    ((_i++))
  done

  ${_T} && _Trace 'Verify parameter values. (%s)' "${_pvar[*]}"
  _i=${AO}
  for _p in "${_pvar[@]}"
  do
    ${_T} && _Trace 'Call parameter validation callback. (%s)' "${_pv[${_i}]}"
    [[ -n "${_pv[${_i}]}" ]] && eval "${_pv[${_i}]}"
    eval "_s=( \"\${_ps_${_p}[@]}\" )" && [[ -z "${_s}" ]] && _s=( )
    if [[ -n "${_psv[${_i}]}" ]]
    then
      ${ZSH} && _s+=( "${(P@)_psv[${_i}]}" ) || eval "_s+=( \"\${${_psv[${_i}]}[@]}\" )"
    fi
    ${_T} && _Trace 'Available parameter selection values. (%s)' "${_s}"
    if [[ -n "${_s}" ]]
    then
      ${ZSH} && _pl+=( "${_p}${_pk[${_i}]:+ (${_pk[${_i}]})}: ${(j:, :)${_s[@]/${_pp[${_i}]}\/}}" ) || _pl+=( "${_p}${_pk[${_i}]:+ (${_pk[${_i}]})}: $(printf '%s, ' "${_s[@]/${_pp[${_i}]}\/}")" ) # avail values

      ${_pm} && ((${#_pvar[@]} + AO - 1 == _i)) && eval "_v=( \"\${${_p}[@]}\" )" || eval "_v=\"\${${_p}}\""
      ${_T} && _Trace 'Parameter value. (%s)' "${_v}"

      ${_T} && _Trace 'Build parameter autodefault. (%s)' "${_pa[${_i}]}"
      if ${_pa[${_i}]} && [[ -z "${_v}" && 1 -eq ${#_s[@]} ]]
      then
        ${_pm} && ((${#_pvar[@]} + AO - 1 == _i)) && eval "${_pvar[${_i}]}=( \"${_s[${AO}]}\" )" || eval "${_pvar[${_i}]}=\"${_s[${AO}]}\""
        _d+="${DCaution}CAUTION:${D} Parameter ${_p}${_pk[${_i}]:+ (${_pk[${_i}]})} was defaulted to: ${DConfirm}"
        [[ -n "${_pp[${_i}]}" ]] && _d+="${_s[${AO}]/${_pp[${_i}]}\/}${D}.${DCEL}\n" || _d+="${_s[${AO}]}${D}.${DCEL}\n"
      fi

      ${_T} && _Trace 'Check if empty. (%s)' "${_v}"
      if [[ -n "${_v}" ]]
      then
        ${_T} && _Trace 'Check parameter value. (%s)' "${_v}"
        for _j in "${_v[@]}"
        do
          _b=true
          for _t in "${_s[@]}"
          do
            [[ "${_t/${_pp[${_i}]:+${_pp[${_i}]}\/}}" == "${_j}" ]] && _b=false && continue 2
          done
          ${_b} && Error 'The value provided for %s%s is not an available parameter value. (%s)' "${_p}" "${_pk[${_i}]:+ (${_pk[${_i}]})}" "${_j}"
        done
      fi
    fi
    ((_i++))
  done

  local _c
  declare -f InitCallback > /dev/null && _initcallback+=( 'InitCallback' )
  for _c in "${_initcallback[@]}"
  do
    ${_T} && _Trace 'Call InitCallback: %s (%s)' "${_c}" "${CMDARGS[*]}"
    ${_c} "${CMDARGS[@]}"
  done

  ${_T} && _Trace 'Check for autodefaults. (%s)' "${_d}"
  if ! ${_error} && [[ -n "${_d}" ]]
  then
    printf "${DCEL}\n${_d}${DCEL}\n"
    Verify 'Do you wish to continue with these default values?' || Error 'Default values were rejected.'
  fi

  ${_T} && _Trace 'Check for default init hook. (%s)' "${LIBUI_HOOKDIR}/init"
  [[ -f "${LIBUI_HOOKDIR}/init" ]] && _Trace 'Source default init hook. (%s)' "${LIBUI_HOOKDIR}/init" && source "${LIBUI_HOOKDIR}/init"
  ${_T} && _Trace 'Check for global program init hook. (%s)' "${LIBUI_HOOKDIR}/${CMD}-init"
  [[ -f "${LIBUI_HOOKDIR}/${CMD}-init" ]] && _Trace 'Source global program init hook. (%s)' "${LIBUI_HOOKDIR}/${CMD}-init" && source "${LIBUI_HOOKDIR}/${CMD}-init"
  ${_T} && _Trace 'Check for local program init hook. (%s)' "${IWD}/${LIBUI_HOOKPREFIX}init"
  [[ -f "${IWD}/${LIBUI_HOOKPREFIX}init" ]] && _Trace 'Source local program init hook. (%s)' "${IWD}/${LIBUI_HOOKPREFIX}init" && source "${IWD}/${LIBUI_HOOKPREFIX}init"

  if ${_error}
  then
    LoadMod Info
    UsageInfo
    Exit ${?}
  fi

  ${_T} && _Trace 'Libui initialized.'
  _init=false

  ${_T} && _Trace 'Initialize return. (%s)' 0
  return 0
}

# confirm check
UICMD+=( 'Confirm' )
Confirm () {
  ${_S} && ((_cConfirm++))
  ${_T} && _Trace 'Confirm [%s]' "${*}"

  ${_T} && _Trace 'Return confirm state. (%s)' "${_confirm}"
  ${_confirm} && return 0 || return 1
}

# force check
UICMD+=( 'Force' )
Force () {
  ${_S} && ((_cForce++))
  ${_T} && _Trace 'Force [%s]' "${*}"

  ${_T} && _Trace 'Return force state. (%s)' "${_force}"
  ${_force} && return 0 || return 1
}

# no action check
UICMD+=( 'NoAction' )
NoAction () {
  ${_S} && ((_cNoAction++))
  ${_T} && _Trace 'NoAction [%s]' "${*}"

  ${_T} && _Trace 'Return no action state. (%s)' "${_noaction}"
  ${_noaction} && return 0 || return 1
}

# quiet check
UICMD+=( 'Quiet' )
Quiet () {
  ${_S} && ((_cQuiet++))
  ${_T} && _Trace 'Quiet [%s]' "${*}"

  ${_T} && _Trace 'Return quiet state. (%s)' "${_quiet}"
  ${_quiet} && return 0 || return 1
}

# verbose check
UICMD+=( 'Verbose' )
Verbose () {
  ${_S} && ((_cVerbose++))
  ${_T} && _Trace 'Verbose [%s]' "${*}"

  ${_T} && _Trace 'Return verbose state. (%s)' "${_vdb}"
  ${_vdb} && return 0 || return 1
}

# yes check
UICMD+=( 'Yes' )
Yes () { # [-e|-E]
  ${_S} && ((_cYes++))
  ${_T} && _Trace 'Yes [%s]' "${*}"

  ${_T} && _Trace 'Process Yes options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':eE' _o
  do
    case ${_o} in
      e)
        ${_T} && _Trace 'Enable. (%s)' "${_o}"
        _yes=true
        ;;

      E)
        ${_T} && _Trace 'Disable. (%s)' "${_o}"
        _yes=false
        ;;

      *)
        Error -L '(Yes) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  ${_T} && _Trace 'Return yes state. (%s)' "${_yes}"
  ${_yes} && return 0 || return 1
}

# exit script
_exitcleanup=true
_exitcallback=( )
UICMD+=( 'Exit' )
Exit () { # [<return_value>]
  local _rv="${1:-${?}}"
  ${_S} && ((_cExit++))
  ${_T} && _Trace 'Exit [%s]' "${*}"

  ${_T} && _Trace 'Resetting traps.'
  trap - HUP #1
  trap - INT #2
  trap - QUIT #3
  trap - KILL #9
  trap - ALRM #14
  trap - TERM #15

  ${_wdb} && Verify -r '^[yY]' 'Debug wait. Exit? (%s)' "${_tmpdir}"

  ${_T} && _Trace 'Check for local program exit hook. (%s)' "${IWD}/${LIBUI_HOOKPREFIX}exit"
  [[ -f "${IWD}/${LIBUI_HOOKPREFIX}exit" ]] && _Trace 'Source local program exit hook. (%s)' "${IWD}/${LIBUI_HOOKPREFIX}exit" && source "${IWD}/${LIBUI_HOOKPREFIX}exit"
  ${_T} && _Trace 'Check for global program exit hook. (%s)' "${LIBUI_HOOKDIR}/${CMD}-exit"
  [[ -f "${LIBUI_HOOKDIR}/${CMD}-exit" ]] && _Trace 'Source global program exit hook. (%s)' "${LIBUI_HOOKDIR}/${CMD}-exit" && source "${LIBUI_HOOKDIR}/${CMD}-exit"
  ${_T} && _Trace 'Check for default exit hook. (%s)' "${LIBUI_HOOKDIR}/exit"
  [[ -f "${LIBUI_HOOKDIR}/exit" ]] && _Trace 'Source default exit hook. (%s)' "${LIBUI_HOOKDIR}/exit" && source "${LIBUI_HOOKDIR}/exit"

  ${_T} && _Trace 'Check for cleanup. (%s)' "${_exitcleanup}"
  if ${_exitcleanup} # for debug
  then
    local _e
    declare -f ExitCallback > /dev/null && _exitcallback+=( 'ExitCallback' )
    for _e in "${_exitcallback[@]}"
    do
      ${_T} && _Trace 'Call ExitCallback: %s (%s)' "${_e}" "${_rv}"
      ${_e} "${_rv}"
    done

    ${_T} && _Trace 'Remove temp directory. (%s)' "${_tmpdir}"
    [[ -d "${_tmpdir}" ]] && rm -rf "${_tmpdir}"
  fi

  local _ctime="${SECONDS}"
  local _f

  ${_T} && _Trace 'Check for ledger. (%s)' "${_ldb}"
  if ${_ldb}
  then
    local _l="${LIBUI_LEDGERFILE:-${LIBUI_DOTFILE}/ledger}"
    if [[ ! -f "${_l}" && "${_l}" =~ .*/.* ]]
    then
      ${_T} && _Trace 'Check ledger dir. (%s)' "${_l}"
      [[ -d "${_l%/*}" ]] || mkdir -p "${_l%/*}" || Error 'Invalid LIBUI_LEDGERFILE path. (%s)' "${_l}"
    fi

    ${_T} && _Trace 'Save ledger entry. (%s)' "${_l}"
    ${_multiuser} && _f=1 && _File_ip=${_File_libui_ip} Open -a "-${_f}" "${_l}" && _l=
    if [[ -n "${_f}" ]]
    then
      _File_ip=${_File_libui_ip} Write -${_f} -p '%s "%s" in %s seconds on %s.\n' "${SHELL}" "${CMDLINE[*]}" "${_ctime}" "$(date)" || Warn 'Unable to write ledger file. (%s)' "${_l}"
    elif [[ -n "${_l}" ]]
    then
      printf '%s "%s" in %s seconds on %s.\n' "${SHELL}" "${CMDLINE[*]}" "${_ctime}" "$(date)" >> "${_l}" || Warn 'Unable to write ledger file. (%s)' "${_l}"
    fi
    ${_multiuser} && _File_ip=${_File_libui_ip} Close "-${_f}"
  fi

  ${_T} && _Trace 'Check for stats. (%s)' "${_sdb}"
  if ${_sdb}
  then
    ${_T} && _Trace 'Prepare stats.'
    local _c; _c=( "# libui stats on $(date):" "_lrun='${CMDLINE[*]}'" "_ltime='${_ctime}'" )
    local _m
    if ! ${ZSH}
    then
      local _d
      local _u; _u=( )
      for _m in "${UICMD[@]}"
      do
        for _d in "${_u[@]}"
        do
          [[ "${_m}" == "${_d}" ]] && continue 2
        done
        _u+=( "${_m}" )
      done
      UICMD=( "${_u[@]}" )
    fi
    for _m in "${UICMD[@]}"
    do
      _l="_l${_m}=\${_c${_m}:-0}"
      eval "_c+=( \"${_l}\" )"
    done

    local _s="${LIBUI_STATSFILE:-${LIBUI_DOTFILE}/stats}"
    if [[ -f "${_s}" ]]
    then
      ${_T} && _Trace 'Merge stats. (%s)' "${_s}"
      source "${_s}"
      _ctime="$(printf '%.6f' ${_ctime})" # broken floats
    else
      if [[ "${_s}" =~ .*/.* ]]
      then
        ${_T} && _Trace 'Check stats dir. (%s)' "${_s}"
        [[ -d "${_s%/*}" ]] || mkdir -p "${_s%/*}" || Error 'Invalid LIBUI_STATSFILE path. (%s)' "${_s}"
        _cstart="$(date)"
      fi
    fi

    _c+=( "_cstart='${_cstart}'" )
    _c+=( "\${ZSH} && _ctime=\$((_ctime + ${_ctime:-0})) || _ctime=\$(bc <<< \"\${_ctime:-0} + ${_ctime:-0}\")" )
    ((_crun++)); _c+=( "_crun=${_crun}" )
    if ! ${ZSH}
    then
      _u=( )
      for _m in "${UICMD[@]}"
      do
        for _d in "${_u[@]}"
        do
          [[ "${_m}" == "${_d}" ]] && continue 2
        done
        _u+=( "${_m}" )
      done
      UICMD=( "${_u[@]}" )
    fi
    for _m in "${UICMD[@]}"
    do
      _l="_l=\${_c${_m}:-0}"
      eval "${_l}"
      _c+=( "((_c${_m} = _c${_m} + ${_l}))" )
    done
    _c+=( "UICMD+=( $(printf '%s ' "${UICMD[@]}"))" )

    ${_T} && _Trace 'Save stats. (%s)' "${_s}"
    ${_multiuser} && _f=1 && _File_ip=${_File_libui_ip} Open -c "-${_f}" "${_s}" && _s=
    if [[ -n "${_f}" ]]
    then
      _File_ip=${_File_libui_ip} Write -c -${_f} -p '%s\n' "${_c[@]}" || Warn 'Unable to write stats file. (%s)' "${_s}"
    elif [[ -n "${_s}" ]]
    then
      printf '%s\n' "${_c[@]}" > "${_s}" || Warn 'Unable to write stats file. (%s)' "${_s}"
    fi
    ${_multiuser} && _File_ip=${_File_libui_ip} Close "-${_f}"
  fi

  ${_T} && _Trace 'Exit %s. (%s)' "${CMD}" "${_rv}"

  ${_T} && _Trace 'Check for global log. (%s)' "${_L}"
  ${_L} && Close -0

  ${_T} && _Trace 'Check for trace. (%s)' "${_tdb}"
  if ${_tdb}
  then
    local _t="${LIBUI_TRACEFILE:-${LIBUI_DOTFILE}/trace}"
    if [[ ! -f "${_t}" && "${_t}" =~ .*/.* ]]
    then
      ${_T} && _Trace 'Check trace dir. (%s)' "${_t}"
      [[ -d "${_t%/*}" ]] || mkdir -p "${_t%/*}" || Error 'Invalid LIBUI_TRACEFILE path. (%s)' "${_t}"
    fi
    ${_T} && _Trace 'Save trace file. (%s)' "${_t}"
    mv -f "${_tfile}" "${_t}" || Warn 'Unable to save trace file. (%s)' "${_t}"
    _tdb=false
  fi
  [[ -e "${_tfile}" ]] && rm -f "${_tfile}"

  ${_T} && _Trace 'Program exit. (%s)' "${_rv}"
  exit ${_rv}
}

# load mod
UICMD+=( 'LoadMod' )
LoadMod () { # [-P <path>] <libui_mod_name>
  ${_S} && ((_cLoadMod++))
  ${_T} && _Trace 'LoadMod [%s]' "${*}"

  local _p="${SHLIBPATH}"
  local _rv=0

  ${_T} && _Trace 'Process LoadMod options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':P:' _o
  do
    case ${_o} in
      P)
        ${_T} && _Trace 'libui mod path. (%s)' "${OPTARG}"
        _p="${OPTARG%/}/"
        ;;

      *)
        Error -L '(LoadMod) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  local _m="${1}"
  shift

  ${_T} && _Trace 'Check if %s libui mod is loaded.' "${_m}"
  local _l=true
  if ${ZSH}
  then
    ((${UIMOD[(Ie)${_m}]})) && _l=false
  else
    local _c
    for _c in "${UIMOD[@]}"
    do
      [[ "${_m}" == "${_c}" ]] && _l=false && break
    done
  fi
  ${_T} && _Trace 'Check if %s libui mod needs to be loaded. (%s)' "${_l}"
  if ${_l}
  then
    ${_T} && _Trace 'Load libui mod. (%s / %s)' "${_p}" "${_m}"
    [[ -f "${_p}libui${_m}.sh" ]] || Error -L -r ${?} 'Unable to locate %s libui mod. (%s)' "libui${_m}.sh" "${_p}"
    source "${_p}libui${_m}.sh" "${@}"
  fi
  _rv=${?}

  ${_T} && _Trace 'LoadMod return. (%s)' "${_rv}"
  return ${_rv}
}

# terminal codes
UICMD+=( '_Terminal' )
_Terminal () {
  ${_S} && ((_c_Terminal++))
  ${_T} && _Trace '_Terminal [%s]' "${*}"

  local _rv=0

  ${_T} && _Trace 'Check for terminal. (%s)' "${TERMINAL}"
  if ${TERMINAL} && [[ -n "${TERM}" ]] && ((8 <= $(tput colors)))
  then
    local _d="${LIBUI_DOTFILE}/display-${TERM}"
    if [[ ! -f "${_d}" ]]
    then
      ${_T} && _Trace 'Define display codes. (%s)' "${_d}"
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
        printf "Dbr='$(tput bold; tput setab 1)'\n" # red
        printf "Dbg='$(tput setab 2)'\n" # green
        printf "Dby='$(tput bold; tput setab 3)'\n" # yellow
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
        printf 'DAnswer="${Dd}${Dfy}"\n'
        printf 'DCaution="${Db}${DFr}"\n'
        printf 'DConfirm="${Db}${DFy}"\n'
        printf 'DError="${Dbr}${Db}${DFy}"\n'
        printf 'DInfo="${Db}${DFm}"\n'
        printf 'DNoAction="${Dfm}"\n'
        printf 'DOptions="${Db}"\n'
        printf 'DQuestion="${Db}${DFc}"\n'
        printf 'DSpinner="${Db}${DFc}"\n'
        printf 'DTell="${Db}"\n'
        printf 'DTrace="${Dfc}"\n'
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
      } > "${_d}"
    fi

    ${_T} && _Trace 'Load display codes. (%s)' "${_d}"
    source "${_d}"
    _rv=${?}
  fi

  ${_T} && _Trace '_Terminal return. (%s)' "${_rv}"
  return ${_rv}
}

# sigwinch handler
UICMD+=( '_WINCH' )
_WINCH () {
  ${_S} && ((_c_WINCH++))
  ${_T} && _Trace '_WINCH [%s]' "${*}"

  # local _x; [[ -n "${DRP}" ]] && printf "${DRP}" && IFS='[;' read -sd R _x CROW CCOL
  ${TERMINAL} && SCOLS="$(tput cols)" && SROWS="$(tput lines)" && \
      declare -f WINCHCallback > /dev/null && _Trace 'Call WINCHCallback.' && WINCHCallback

  ${_T} && _Trace '_WINCH return. (%s)' 0
  return 0
}


#####
#
# setup
#
#####

# load config
LIBUI_DOTFILE="${LIBUI_DOTFILE:-${HOME}/.libui}"
[[ -d "${LIBUI_DOTFILE}" ]] || mkdir -p "${LIBUI_DOTFILE}" || Error 'Invalid LIBUI_DOTFILE path. (%s)' "${LIBUI_DOTFILE}"
[[ -f "${LIBUI_CONF:-${LIBUI_DOTFILE}/libui.conf}" ]] && source "${LIBUI_CONF:-${LIBUI_DOTFILE}/libui.conf}"

# defaults
LIBUI_HOOKDIR="${LIBUI_HOOKDIR:-${LIBUI_DOTFILE}/hook}"
ZSH=false; AO=0; [[ -n "${ZSH_VERSION}" ]] && ZSH=true && AO=1 && SHELL="${ZSH_NAME:t}" || SHELL="${BASH_VERSION:+bash}"
BV="${BASH_VERSION%.*}"; [[ -n "${BV}" ]] && BV="${BV//.}" || BV=0; ! ${ZSH} && ((40 > BV)) && AA=false || AA=true
ZV="${ZSH_VERSION%.*}"; [[ -n "${ZV}" ]] && ZV="${ZV//.}" || ZV=0; ${ZSH} && ((53 > ZV)) && PV=false || PV=true
CMDPATH="${1}"; CMDPATH="${CMDPATH:-${0}}"; CMD="${CMDPATH##*/}"
CMDARGS=( "${@:2}" )
CMDLINE=( "${CMDPATH}" "${CMDARGS[@]}" )
IWD="${PWD}"
LIBUI="${BASH_SOURCE:-${(%):-%x}}"
LIBUI_HOOKPREFIX="${LIBUI_HOOKPREFIX:-.${CMD}-}"
SHLIBPATH="${SHLIBPATH:-${LIBUI%/*}}/"
[[ "${PATH}" =~ (.*:|^)"${SHLIBPATH%/}"($|:.*) ]] || PATH="${SHLIBPATH%/}${PATH:+:${PATH}}"
DOMAIN="${DOMAIN:-$(/bin/hostname -f 2> /dev/null | cut -d . -f 2-)}"
[[ 'local' == "${DOMAIN}" ]] && DOMAIN=
DOMAIN="${DOMAIN:-$(/usr/bin/grep '^search ' /etc/resolv.conf 2> /dev/null | cut -d ' ' -f 2)}"
${ZSH} && DOMAIN="${(L)DOMAIN}" || DOMAIN="$(printf '%s' "${DOMAIN}" | tr '[:upper:]' '[:lower:]')"
HOST="${HOST:-${HOSTNAME}}"
HOST="${HOST:-$(hostname -s 2> /dev/null)}"
HOST="${HOST:-$(uname -n 2> /dev/null)}"
HOST="${HOST%\.*}"
${ZSH} && HOST="${(L)HOST}" || HOST="$(printf '%s' "${HOST}" | tr '[:upper:]' '[:lower:]')"
OS="${OS:-$(uname -s)}"
TMPDIR="${TMPDIR:-/tmp}"
MAXINT=9223372036854775807; ((2147483647 > MAXINT)) && MAXINT=2147483647
CHFLAGS=
FMFLAGS=
N=$'\n'
[[ -t 1 ]] && TERMINAL="${TERMINAL:-true}" || TERMINAL="${TERMINAL:-false}"
ERRV=100
${ZSH} && typeset -aU UIMOD && typeset -aU UICMD
UIVERSION=( "${LIBUI##*/}" "${LIBUI_VERSION}" )

# debug
_ldb="${LIBUI_LEDGER:-true}"; # ledger
_sdb="${LIBUI_STATS:-true}"; _S="${_sdb}" # stats
_tdb="${LIBUI_TRACE:-false}"; _T="${_tdb}" # trace
_udb="${LIBUI_LIBUI:-false}"; ${_T} || _T="${_udb}" # libui
_cdb="${LIBUI_CONTEXT:-false}" # context
_rdb="${LIBUI_RDEBUG:-false}" # remote
_mdb="${LIBUI_MDEBUG:-false}"; _M="${_mdb}" # mod
_pdb="${LIBUI_PROFILE:-false}" # profiling
_hdb="${LIBUI_HDEBUG:-false}" # host
_vdb="${LIBUI_VERBOSE:-false}" # verbose
_wdb="${LIBUI_WDEBUG:-false}" # wait
if ${_tdb}
then
  _tfile="$(mktemp -q "${TMPDIR%/}/${CMD}-trace.XXXXXX")"
  printf 'Executed "%s" on %s.\n' "${CMDLINE[*]}" "$(date)" > "${_tfile}" ||
      Error -e -l '' 'Unable to reset trace file. (%s)' "${_tfile}"
fi

# check version
#[[ -z "${@:${#}:1}" ]] || (_r="${@:${#}:1}"; ((${_r//.} <= ${LIBUI_VERSION//.}))) || \
#    Error -e -l '' '%s: Script requires libui.sh version %s. Please update libui.sh.' "${CMD}" "${@:${#}:1}"

# check user
[[ -z "${USER}" ]] && Error -e -l '' 'USER environment variable not defined.'
[[ -z "${EUID}" ]] && Error -e -l '' 'EUID environment variable not defined.'

# global log
_L=false
if [[ -d "${LIBUI_LOGFILE%/*}" ]]
then
  LoadMod File
  Open -a -0 "${LIBUI_LOGFILE}"
  _L=true
else
  [[ -z "${LIBUI_LOGFILE}" ]] || Error -e -l '' 'Invalid log file. (%s)' "${LIBUI_LOGFILE}"
fi

# display / status
_Terminal
_WINCH
${_pdb} && _Trace 'Profiling enabled.' # 5
${_cdb} && _Trace 'Context debug enabled.' # 6
${_udb} && _Trace 'Libui debug enabled.' # 9
${_mdb} && _Trace 'Mod debug enabled.' # 8
${_rdb} && _Trace 'Remote debug enabled.' # 7
${_hdb} && _Trace 'Host debug enabled.' # 3
${_vdb} && _Trace 'Verbose actions enabled.' # 2
${_wdb} && _Trace 'Wait debug enabled.' # 1
${_ldb} && _Trace 'Ledger enabled.'
${_sdb} && _Trace 'Stats enabled.'
${_tdb} && _Trace 'Trace enabled.'

# traps
trap 'Error -e -r 129 "Received HUP signal. ($(date))"' HUP #1
trap 'Error -e -r 130 "Received INT signal. ($(date))"' INT #2
trap 'Error -e -r 131 "Received QUIT signal. ($(date))"' QUIT #3
trap 'Error -e -r 137 "Received KILL signal. ($(date))"' KILL #9
${TERMINAL} && trap 'printf "${DAlarm}Received ALRM signal. ($(date))${D} " >> /dev/stderr' ALRM #14
trap 'Error -e -r 143 "Received TERM signal. ($(date))"' TERM #15
trap '_WINCH' WINCH #28

# duplicate stderr
exec 3>&2

_Trace 'READY (%s)' "${SHLIBPATH}"
