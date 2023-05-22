#!/bin/zsh
#####
#
#	Libui File Mod - File Access / Manipulation
#
#	F Harvell - Sat Sep 24 11:31:25 EDT 2022
#
#####
#
# Provides file utility commands.
#
# Man page available for this module: man 3 libuiFile.sh
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
_File_ip=
_File_fd=( )
_File_fp=( )
_File_libui_ip=1 # libui prefix

# Close one (or more) open file IDs
#
# Syntax: Close [-1..-9] [<filep_path>]
#
# Example: Close -1
#
# Result: the lock (file) associated with the file ID is unlocked (removed) and
# the file association is removed.
#
UICMD+=( 'Close' )
Close () { #  [-0|-1..-9] [<file_path>]
  ${_S} && ((_cClose++))
  ${_M} && _Trace 'Close [(_File_ip="%s") %s]' "${_File_ip}" "${*}"

  local _File_i; _File_i=( )

  ${_M} && _Trace 'Process Close options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':0123456789' _o
  do
    case ${_o} in
      0)
        ${_M} && _Trace 'File ID. (10)'
        _File_i+=( 10 )
        ;;

      [1-9])
        ${_M} && _Trace 'File ID. (%s%s)' "${_File_ip}" "${_o}"
        _File_i+=( "${_File_ip}${_o}" )
        ;;

      *)
        Error -L '(Close) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 < ${#})) && [[ -n "${_File_i}" ]] && Error -L '(Close) Called with a file ID and a file path.'
  ((1 < ${#})) && Error -L '(Close) Called with multiple file paths.'

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'Close error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    local _File_l

    ${_M} && _Trace 'Check for file ID. (%s)' "${_File_i}"
    if [[ -z "${_File_i}" ]]
    then
      ${_M} && _Trace 'Check for file path. (%s)' "${*}"
      if ((0 == ${#}))
      then
        if ${ZSH}
        then
          for _File_l in "${(@)_File_fd}"
          do
            [[ -n "${_File_l}" ]] && _File_i+=( "${_File_fd[(ie)${_File_l}]}" )
          done
        else
          _File_i=( "${!_File_fd[@]}" )
        fi
      else
        if ${ZSH}
        then
          for _File_l in "${(@)_File_fp}"
          do
            [[ -n "${_File_l}" && "${1}" == "${_File_fp[${_File_l}]}" ]] && _File_i+=( "${_File_fp[(ie)${_File_l}]}" )
          done
        else
          for _File_l in "${!_File_fp[@]}"
          do
            [[ -n "${_File_l}" && "${1}" == "${_File_fp[${_File_l}]}" ]] && _File_i+=( "${_File_l}" )
          done
        fi
      fi
    fi

    ${_M} && _Trace 'Check for flock.'
    if command -v flock &> /dev/null
    then
      for _File_l in "${_File_i[@]}"
      do
        if [[ -n "${_File_l}" ]]
        then
          ${_M} && _Trace 'Remove flock. (%s)' "${_File_fd[${_File_l}]}"
          [[ -n "${_File_fd[${_File_l}]}" ]] && flock -u "${_File_fd[${_File_l}]}" && \
              ${_M} && _Trace 'Unlocked. (%s)' "${_File_fd[${_File_l}]}"
          unset "_File_fp[${_File_l}]"
          unset "_File_fd[${_File_l}]"
        fi
      done
    else
      local _File_d="${LIBUI_LOCKDIR:-${LIBUI_DOTFILE}/lock}"
      for _File_l in "${_File_i[@]}"
      do
        if [[ -n "${_File_l}" ]]
        then
          ${_M} && _Trace 'Remove lock file. (%s)'  "${_File_fp[${_File_l}]}.lock"
          [[ -n "${_File_fp[${_File_l}]}" ]] && rm -f "${_File_fp[${_File_l}]}.lock" && \
              ${_M} && _Trace 'Lock file removed. (%s)' "${_File_fp[${_File_l}]}.lock"
          [[ -e "${_File_d}/${_File_fp[${_File_l}]##*/}.lock" ]] && rm -f "${_File_d}/${_File_fp[${_File_l}]##*/}.lock"
          unset "_File_fp[${_File_l}]"
          unset "_File_fd[${_File_l}]"
        fi
      done
    fi

    ${_M} && _Trace 'Close return. (%s)' 0
    return 0
  fi
}

# Get a file listing and load it into the array variable with the provided name
#
# Syntax: GetFileList [-d|-e|-f|-n|-p|-r|-w] <var_name> <file_specification>
#
# Example: GetFileList -r *.cpp
#
# Result: obtains a listing of all of the files named '*.cpp' in the current
# directory and its subdirectories.
#
UICMD+=( 'GetFileList' )
GetFileList () { # [-d|-e|-f|-n|-p|-r|-w] <var_name> <file_specification> ...
  ${_S} && ((_cGetFileList++))
  ${_M} && _Trace 'GetFileList [%s]' "${*}"

  local _File_d=false
  local _File_e=false
  local _File_f=false
  local _File_n=false
  local _File_p=false
  local _File_r="${MAXINT}"
  local _File_w=false
  local _File_rv=1

  ${_M} && _Trace 'Process GetFileList options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':defnprw' _o
  do
    case ${_o} in
      d)
        ${_M} && _Trace 'Directories only.'
        _File_d=true
        ;;

      e)
        ${_M} && _Trace 'Error on empty.'
        _File_e=true
        ;;

      f)
        ${_M} && _Trace 'Files only.'
        _File_f=true
        ;;

      n)
        ${_M} && _Trace 'Return names.'
        _File_n=true
        ;;

      p)
        ${_M} && _Trace 'Return paths.'
        _File_p=true
        ;;

      r)
        ${_M} && _Trace 'Recursive file search.'
        _File_r=0 # continue search
        ;;

      w)
        ${_M} && _Trace 'Warn on empty.'
        _File_w=true
        ;;

      *)
        Error -L '(GetFileList) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((2 > ${#})) && Error -L '(GetFileList) Called without a variable name and file specification.'

  ${_M} && _Trace 'Build file list.'
  local _File_i
  local _File_g
  local _File_l; _File_l=( )
  local _File_s
  local _File_v="${1}" # var
  shift
  for _File_s in "${@}"
  do
    if ${ZSH}
    then
      _File_g='N'
      ${_File_d} && _File_g+='/'
      ${_File_f} && _File_g+='.'
      eval "_File_l+=( ${_File_s/ /\\ }(${_File_g}) )"
      _File_rv=${?}
      while ((${#_File_l[@]} > _File_r))
      do
        _File_r=${#_File_l[@]}
        _File_s+='/*'
        eval "_File_l+=( ${_File_s/ /\\ }(${_File_g}) )"
      done
    else
      eval "_File_g=( ${_File_s/ /\\ } )"
      _File_rv=${?}
      if ${_File_f} || ${_File_d}
      then
        for _File_i in "${_File_g[@]}"
        do
          ${_File_d} && [[ -d "${_File_i}" ]] && _File_l+=( "${_File_i}" )
          ${_File_f} && [[ -f "${_File_i}" ]] && _File_l+=( "${_File_i}" )
        done
      else
        [[ "${*}" == "${_File_g[*]}" ]] || _File_l+=( "${_File_g[@]}" )
      fi
      while ((${#_File_l[@]} > _File_r))
      do
        _File_r=${#_File_l[@]}
        _File_s+='/*'
        eval "_File_g=( ${_File_s/ /\\ } )"
        _File_rv=${?}
        if ${_File_f} || ${_File_d}
        then
          for _File_i in "${_File_g[@]}"
          do
            ${_File_d} && [[ -d "${_File_i}" ]] && _File_l+=( "${_File_i}" )
            ${_File_f} && [[ -f "${_File_i}" ]] && _File_l+=( "${_File_i}" )
          done
        else
          [[ "${_File_s}" == "${_File_g}" ]] || _File_l+=( "${_File_g[@]}" )
        fi
      done
    fi
  done
  ((0 != _File_rv)) && Error '(GetFileList) Unable to obtain file list. (%s)' "${*}"
  if [[ -z "${_File_l[@]}" ]] && _File_rv=2
  then
    ${_File_e} && Error -r 2 '(GetFileList) No file found. (%s)' "${*}"
    ${_File_w} && Warn -r 2 '(GetFileList) No file found. (%s)' "${*}"
  fi

  local _File_t
  if ${_File_n} || ${_File_p}
  then
    ${_M} && _Trace 'Remove duplicates. (%s)' "${_File_l[*]}"
    ${_File_p} && _File_g=( "${_File_l[@]%/*}" )
    ${_File_n} && _File_g=( "${_File_l[@]##*/}" )
    _File_l=( )
    for _File_i in "${_File_g[@]}"
    do
      if ${ZSH}
      then
        ((${_File_l[(Ie)${_File_i}]})) || _File_l+=( "${_File_i}" )
      else
        for _File_t in "${_File_l[@]}"
        do
          [[ "${_File_i}" == "${_File_t}" ]] && continue 2
        done
        _File_l+=( "${_File_i}" )
      fi
    done
  fi
  eval "${_File_v}=( \"\${_File_l[@]}\" )"

  ${_M} && _Trace 'GetFileList return. (%s)' "${_File_rv}"
  return ${_File_rv}
}

# Obtain the real, absolute path of the provided path specification
#
# Syntax: GetRealPath [-d] <var_name> [<path_specificatio>]
#
# Example: GetRealPath -d sourcedir
#
# Result: obtains the path_specification from the variable "sourcedir",
# determines the real, absolute path of the path_specification directory, and
# saves the directory path/file name in the variable "sourcedir".
#
UICMD+=( 'GetRealPath' )
GetRealPath () { # [-d] <var_name> [<path_specification>]
  ${_S} && ((_cGetRealPath++))
  ${_M} && _Trace 'GetRealPath [%s]' "${*}"

  local _File_d=false
  local _File_f
  local _File_rv=0
  local _File_s

  ${_M} && _Trace 'Process GetRealPath options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':d' _o
  do
    case ${_o} in
      d)
        ${_M} && _Trace 'Test directory.'
        _File_d=true
        ;;

      *)
        Error -L '(GetRealPath) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((2 < ${#})) && Error -L '(GetRealPath) Invalid parameter count.'
  if ((1 == ${#}))
  then
    if ${ZSH}
    then
      _File_s="${(P)1}"
      _File_s=${~_File_s}
    else
      _File_s="${!1// /\\ }"
      eval "_File_s=${_File_s}"
    fi
  else
    if ${ZSH}
    then
      _File_s=${~2}
    else
      _File_s="${2// /\\ }"
      eval "_File_s=${_File_s}"
    fi
  fi
  [[ -z "${_File_s}" ]] && Error '(GetRealPath) No path provided. (%s)' "${1}"
  [[ "${_File_s}" =~ .*/.* ]] || _File_s="${PWD}/${_File_s}"
  ${_File_d} && _File_f="/${_File_s##*/}" && _File_s="${_File_s%/*}" && [[ '/' == "${_File_f}" || '/.' == "${_File_f}" ]] && _File_f=
  [[ -e "${_File_s}" ]] || Error '(GetRealPath) Invalid path provided. (%s)' "${_File_s}"

  ${_M} && _Trace 'Check for realpath.'
  if command -v realpath &> /dev/null
  then
    ${_M} && _Trace 'Get real path. (%s)' "${_File_s}"
    eval "${1}='$(realpath "${_File_s}" 2> /dev/null)${_File_f}'"
  else
    ${_M} && _Trace 'Check for links. (%s)' "${_File_s}"
    local _File_l="$(readlink "${_File_s}")"
    _File_s="${_File_l:-${_File_s}}"

    ${_M} && _Trace 'Find directory path. (%s)' "${_File_s}"
    if [[ -d "${_File_s}" ]]
    then
      _File_s="$(cd "${_File_s}" && pwd -P)"
    else
      _File_f="/${_File_s##*/}"
      [[ '/' == "${_File_f}" || '/.' == "${_File_f}" ]] && _File_f=
      _File_s="$(cd "${_File_s%/*}" && pwd -P)"
    fi

    ${_M} && _Trace 'Save real path. (%s%s)' "${_File_s}" "${_File_f}"
    eval "${1}='${_File_s}${_File_f}'"
  fi

  ${_M} && _Trace 'GetRealPath return. (%s)' 0
  return 0
}

# Get a unique, temporary directory, subdirectory, or file path name
#
# Syntax: GetTmp [-d|-f|-s] <var_name>
#
# Example: GetTmp -f logfile
#
# Result: creates a temporary directory and a temporary file and saves the path
# in the variable "logfile".
#
UICMD+=( 'GetTmp' )
GetTmp () { # [-d|-f|-s] <var_name>
  ${_S} && ((_cGetTmp++))
  ${_M} && _Trace 'GetTmp [%s]' "${*}"

  local _f=false
  local _s=false

  ${_M} && _Trace 'Process GetTmp options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':dfs' _o
  do
    case ${_o} in
      d)
        ${_M} && _Trace 'Temp directory.'
        # default
        ;;

      f)
        ${_M} && _Trace 'Temp file.'
        _f=true
        ;;

      s)
        ${_M} && _Trace 'Temp subdirectory.'
        _s=true
        ;;

      *)
        Error -L '(GetTmp) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(GetTmp) Called without a variable name.'

  ${_M} && _Trace 'Check / Create tmp directory. (%s)' "${_tmpdir}"
  [[ -d "${_tmpdir}" ]] || _tmpdir="$(mktemp -q -d "${TMPDIR%/}/${CMD}.XXXXXX")"
  ((0 != ${?})) && Error '(GetTmp) Unable to create temp dir.'
  eval "${1}='${_tmpdir}'"

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'GetTmp error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    if ${_f}
    then
      ${_M} && _Trace 'Create tmp file.'
      eval "${1}=\"\$(TMPDIR='${_tmpdir}' mktemp -q '${_tmpdir}/${CMD}.XXXXXX')\""
      ((0 != ${?})) && Error '(GetTmp) Unable to create temp file.'
    fi

    if ${_s}
    then
      ${_M} && _Trace 'Create tmp subdirectory.'
      eval "${1}=\"\$(TMPDIR='${_tmpdir}' mktemp -q -d '${_tmpdir}/${CMD}.XXXXXX')\""
      ((0 != ${?})) && Error '(GetTmp) Unable to create temp subdirectory.'
    fi

    ${_M} && _Trace 'GetTmp return. (%s)' 0
    return 0
  fi
}

# Open a file, lock it, and assiciate the path with a file ID
#
# Syntax: Open [-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
#
# Example: Open -1 -c new_file
#
# Result: the lock (file) associated with the file ID is unlocked (removed) and
# the file association is removed.
#
# open
UICMD+=( 'Open' )
Open () { # [-0|-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
  ${_S} && ((_cOpen++))
  ${_M} && _Trace 'Open [(_File_ip="%s") %s]' "${_File_ip}" "${*}"

  local _File_b=false
  local _File_c=false
  local _File_i
  local _File_t="${LIBUI_LOCKTIMEOUT:-30}"
  local _File_w="${LIBUI_LOCKWARN:-5}"
  local _File_z

  ${_M} && _Trace 'Process Open options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':0123456789abB:ct:w:' _o
  do
    case ${_o} in
      0)
        ${_M} && _Trace 'File ID. (10)'
        _File_i=10
        ;;

      [1-9])
        ${_M} && _Trace 'File ID. (%s%s)' "${_File_ip}" "${_o}"
        _File_i="${_File_ip}${_o}"
        ;;

      a|c)
        ${_M} && _Trace 'File mode. (%s)' "${_o}"
        [[ 'a' == "${_o}" ]] && _File_c=false || _File_c=true
        ;;

      b)
        ${_M} && _Trace 'Backup file.'
        _File_b=true
        ;;

      B)
        ${_M} && _Trace 'Backup path. (%s)' "${OPTARG}"
        _File_b=true
        _File_z="${OPTARG}"
        ;;

      t)
        ${_M} && _Trace 'Lock timeout. (%s)' "${OPTARG}"
        _File_t="${OPTARG}"
        ;;

      w)
        ${_M} && _Trace 'Warning timeout. (%s)' "${OPTARG}"
        _File_w="${OPTARG}"
        ;;

      *)
        Error -L '(Open) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  [[ -z "${_File_i}" ]] && Error '(Open) No file ID provided.'
  ((0 == ${#})) && Error -L '(Open) Called without a file path.'
  ((1 < ${#})) && Error -L '(Open) Called with multiple file paths.'

  ${ZSH} && integer _File_e || local _File_e
  local _File_f
  local _File_s="${SECONDS}"
  local _File_p
  local _File_x

  [[ -n "${_File_z}" ]] && GetRealPath -d _File_z

  GetRealPath -d _File_p "${1}"

  ${_M} && _Trace 'Check for backup. (%s)' "${_File_b}"
  if ${_File_b}
  then
    if [[ -d "${_File_z}" ]]
    then
      ${_M} && _Trace 'Rotate backups. (%s)' "${_File_z}"
      for ((_File_x = $((${LIBUI_BACKUPS:-10} - 2)); 0 <= _File_x; _File_x--))
      do
        [[ -f "${_File_z}/${_File_p##*/}.${_File_x}.bz2" ]] &&
            Action "mv -f '${_File_z}/${_File_p##*/}.${_File_x}.bz2' '${_File_z}/${_File_p##*/}.$((_File_x + 1)).bz2'"
      done
      ${_M} && _Trace 'New backup. (%s)' "${_File_z}/${_File_p##*/}.0.bz2"
      [[ -f "${_File_p}" ]] && Action "bzip2 -c '${_File_p}' > '${_File_z}/${_File_p##*/}.0.bz2'"
    else
      ${_M} && _Trace 'Make backup. (%s)' "${_File_z:-${_File_p}}.0.bz2"
      [[ -f "${_File_p}" ]] && Action "bzip2 -c '${_File_p}' > '${_File_z:-${_File_p}}.0.bz2'"
    fi
  fi

  ${_M} && _Trace 'Open path. (%s)' "${_File_p}"
  if ${ZSH} || ((40 <= BV))
  then
    if ${_File_c}
    then
      exec {_File_f}>"${_File_p}"
    else
      exec {_File_f}>>"${_File_p}"
    fi
  else
    _File_f=$((_File_i % 10 + 10))
    if ${_File_c}
    then
      eval "exec ${_File_f}>'${_File_p}'" || _File_f=
    else
      eval "exec ${_File_f}>>'${_File_p}'" || _File_f=
    fi
  fi
  [[ -n "${_File_f}" ]] || Error '(Open) Unable to open file. (%s)' "${_File_p}"

  _File_fd[${_File_i}]="${_File_f}"

  if command -v flock &> /dev/null
  then
    ${_M} && _Trace 'Obtain flock %s. (%s)' "${_File_f}" "${_File_p}"
    while ! flock -n ${_File_f}
    do
      _File_e=$((SECONDS - _File_s))
      ((_File_t <= _File_e)) && printf "${DInfo}Unable to obtain flock %s. (%s)${D}${DCEL}\n" "${_File_f}" "${_File_p}" >> /dev/stderr && return 1
      ((_File_w <= _File_e)) && printf "${DInfo}WAIT: Waiting for flock %s. (%s)${D}${DCEL}\n" "${_File_f}" "${_File_p}" >> /dev/stderr && _File_w="${MAXINT}"
      ${_M} && _Trace 'Wait for flock %s. (%s)' "${_File_f}" "${_File_e}"
      sleep "0.1$((RANDOM % 10))"
    done
  else
    ${_M} && _Trace 'Create lock file. (%s)' "${_File_p}.lock"
    while ! (set -o noclobber; printf '%s %s\n' "${USER}" ${$} > "${_File_p}.lock") 2> /dev/null
    do
      _File_e=$((SECONDS - _File_s))
      ((_File_t <= _File_e)) && printf "${DInfo}Unable to create lock file. (%s)${D}${DCEL}\n" "${_File_p}.lock" >> /dev/stderr && return 1
      ((_File_w <= _File_e)) && printf "${DInfo}WAIT: Waiting for lock file. (%s)${D}\n" "${_File_p}.lock" >> /dev/stderr && _File_w="${MAXINT}"
      ${_M} && _Trace 'Wait for lock file removal. (%s)' "${_File_e}"
      sleep "0.1$((RANDOM % 10))"
    done
    local _File_d="${LIBUI_LOCKDIR:-${LIBUI_DOTFILE}/lock}"
    [[ -d "${_File_d}" ]] || mkdir -p "${_File_d}" || Error 'Invalid lock directory path. (%s)' "${_File_d}"
    printf '%s\n' "${_File_p}.lock" >"${_File_d}/${_File_p##*/}.lock"
  fi
  ${_M} && _Trace 'Save locked file. (%s)' "${_File_p}"
  _File_fp[${_File_i}]="${_File_p}"

  ${_M} && _Trace 'Open return. (%s)' 0
  return 0
}

# Check if provided paths match
#
# Syntax: PathMatches [-r] <path_specification_1> <path_specification_2>
#
# Example: PathMatches ~/Work/project /programs/build/Work/project
#
# Result: If the two paths result in the same absolute path, the function
# returns 0, otherwise, returns 1.
#
# Note: The -r (Root) option matches the path except for the "filename".
#
UICMD+=( 'PathMatches' )
PathMatches () { # [-r] <path_specification_1> <path_specification_2>
  ${_S} && ((_cPathMatches++))
  ${_M} && _Trace 'PathMatches [%s]' "${*}"

  local _File_r=false

  ${_M} && _Trace 'Process PathMatches options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':r' _o
  do
    case ${_o} in
      r)
        ${_M} && _Trace 'Root match.'
        _File_r=true
        ;;

      *)
        Error -L '(PathMatches) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((2 != ${#})) && Error -L '(PathMatches) Invalid parameter count.'

  if ${_File_r}
  then
    local _File_1; GetRealPath _File_1 "${1}"
    local _File_2; GetRealPath _File_2 "${2}"
    [[ "${_File_1%/*}/" == "${_File_2%/*}"/* || "${_File_2%/*}/" == "${_File_1%/*}"/* ]]
  else
    ${_M} && _Trace 'Find path inodes. (%s)' "${*}"
    stat -c %i . &> /dev/null && local _File_s='-c' || local _File_s='-f' # Linux vs. BSD
    [[ -e "${1}" && -e "${2}" && "$(stat -L ${_File_s} %i "${1}")" == "$(stat -L ${_File_s} %i "${2}")" ]]
  fi
  local _File_rv=${?}

  ${_M} && _Trace 'PathMatches return. (%s)' "${_File_rv}"
  return ${_File_rv}
}

# Remove the files in the array variable with the provided variable name
#
# Syntax: RemoveFileList [-f (force)] <name_of_array_variable> ...
#
# Example: RemoveFileList deadlist
#
# Result: Removes the files and directories listed in the array variable with
# the provided variable name.
#
UICMD+=( 'RemoveFileList' )
RemoveFileList () { # [-f (force)] <name_of_array_variable> ...
  ${_S} && ((_cRemoveFileList++))
  ${_M} && _Trace 'RemoveFileList [%s]' "${*}"

  local _File_f

  ${_M} && _Trace 'Process RemoveFileList options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':f' _o
  do
    case ${_o} in
      f)
        ${_M} && _Trace 'Force remove.'
        _File_f='-f'
        ;;

      *)
        Error -L '(RemoveFileList) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(RemoveFileList) Called without a variable name.'

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'RemoveFileList error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    local _File_d
    local _File_l
    local _File_x
    while [[ -n "${1}" ]]
    do
      ${ZSH} && _File_l=( "${(P)1[@]}" ) || eval "_File_l=( \"\${${1}[@]}\" )"

      ${_M} && _Trace 'If any files, remove them. (%s)' "${_File_l[*]}"
      _File_d=( )
      for _File_x in "${_File_l[@]}"
      do
        if [[ -d "${_File_x}" ]]
        then
          _File_d+=( "${_File_x}" )
        else
          Action "rm ${FMFLAGS} ${_File_f} \"${_File_x}\""
          ((0 != ${?})) && Error '(RemoveFileList) Unable to remove file. (%s)' "${_File_x}"
        fi
      done

      ${_M} && _Trace 'If any directories, remove them. (%s)' "${_File_d[*]}"
      if ((0 < ${#_File_d[@]}))
      then
        LoadMod Sort
        Sort -p _File_d
        for _File_x in "${_File_d[@]}"
        do
          Action "rmdir ${FMFLAGS} ${_File_f} \"${_File_x}\""
          ((0 != ${?})) && Error '(RemoveFileList) Unable to remove directory. (%s)' "${_File_x}"
        done
      fi

      shift
    done

    ${_M} && _Trace 'RemoveFileList return. (%s)' 0
    return 0
  fi
}

# Write Data
#
# Syntax: Write [-0|-1..-9|-a|-c] [-f <file_path>] [-p <format>] [-r <record_marker>] <data>
#
# Example: Write -1 "Data for the file."
#
# Result: Writes the data, "Data for the file." to the file identified by the
# File ID 1.
#
# Note: The -0 File ID option is reserved for libui library use only.
#
UICMD+=( 'Write' )
Write () { # [-0|-1..-9|-a|-c] [-f <file_path>] [-p <format>] [-r <record_marker>] <data>
  ${_S} && ((_cWrite++))
  ${_M} && _Trace 'Write [(_File_ip="%s") %s]' "${_File_ip}" "${*}"

  local _File_c=false
  local _File_f
  local _File_i
  local _File_p
  local _File_r=$'\n'
  local _File_rv=0

  ${_M} && _Trace 'Process Write options. (%s)' "${*}"
  local _o
  local OPTIND
  local OPTARG
  while getopts ':0123456789acf:p:r:' _o
  do
    case ${_o} in
      0)
        ${_M} && _Trace 'File ID. (10)'
        _File_i=10
        ;;

      [1-9])
        ${_M} && _Trace 'File ID. (%s%s)' "${_File_ip}" "${_o}"
        _File_i="${_File_ip}${_o}"
        [[ -z "${_File_fd[${_File_i}]}" ]] && Error 'File ID not open. (%s)' "${_File_i}"
        ;;

      a|c)
        ${_M} && _Trace 'File mode. (%s)' "${_o}"
        [[ 'a' == "${_o}" ]] && _File_c=false || _File_c=true
        ;;

      f)
        ${_M} && _Trace 'File path. (%s)' "${OPTARG}"
        ${ZSH} && _File_f=${~OPTARG} || _File_f=${OPTARG}
        ;;

      p)
        ${_M} && _Trace 'Print format. (%s)' "${OPTARG}"
        _File_p="${OPTARG}"
        ;;

      r)
        ${_M} && _Trace 'Record marker. (%s)' "${OPTARG}"
        _File_r="${OPTARG}"
        ;;

      *)
        Error -L '(Write) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((0 == ${#})) && Error -L '(Write) Called without data.'
  [[ -z "${_File_p}" ]] && _File_p="%s${_File_r}"

  ${_M} && _Trace -I 'WRITE: %s' "${*}"

  if [[ -n "${_File_i}" ]]
  then
    ${_M} && _Trace 'Write using ID %s to file %s via descriptor %s. (%s)' "${_File_i}" "${_File_fp[${_File_i}]}" "${_File_fd[${_File_i}]}" "${*}"
    printf -- "${_File_p}" "${@}" >&${_File_fd[${_File_i}]}
    ((0 == ${?})) || Error '(Write) Unable to write to file via file ID. (%s)' "${_File_i}"
  elif [[ -n "${_File_f}" ]]
  then
    ${_M} && _Trace 'Write to file %s. (%s)' "${_File_f}" "${*}"
    if ${_File_c}
    then
      printf -- "${_File_p}" "${@}" > "${_File_f}"
    else
      printf -- "${_File_p}" "${@}" >> "${_File_f}"
    fi
    _File_rv=${?}
    ((0 == ${_File_rv})) || Error '(Write) Unable to write to file. (%s)' "${_File_f}"
  else
    Error -L '(Write) No file ID or file path provided.'
  fi

  ${_M} && _Trace 'Write return. (%s)' "${_File_rv}"
  return ${_File_rv}
}

# module exit callback
FileExitCallback () {
  ${_M} && _Trace 'FileExitCallback [%s]' "${*}"
  Close
}

# register exit callback
_exitcallback+=( 'FileExitCallback' )

return 0
