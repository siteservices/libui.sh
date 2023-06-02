#!/bin/zsh
#####
#
#	Libui SSH Mod - Secure Shell Utilities
#
#	F Harvell - Tue Apr  4 21:11:10 EDT 2023
#
#####
#
# Provides secure shell (ssh) utility commands.
#
# Man page available for this module: man 3 libuiSSH.sh
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

Version -r 1.822 -m 1.3

# defaults

# Is Target
#
# Syntax: IsTarget <target>
#
# Example: IsTarget alpha
#
# Result: Returns true if alpha is a valid target (and not localhost), otherwise
# returns false.
#
UICMD+=( 'IsTarget' )
IsTarget () { # <target>
  ${_S} && ((_cIsTarget++))
  ${_M} && _Trace 'IsTarget [%s]' "${*}"

  ${_M} && _Trace 'Check for localhost. (%s)' "${1}"
  [[ -z "${1}" ]] && return 1
  [[ 'localhost' == "${1}" ]] && return 1
  [[ '127.0.0.1' == "${1}" ]] && return 1
  [[ "${HOST}" == "${1}" ]] && return 1
  [[ "${HOST}.${DOMAIN}" == "${1}" ]] && return 1

  ${_M} && _Trace 'IsTarget return. (%s)' 0
  return 0
}

# Send file via SSH (scp)
#
# Syntax: SSHSend [-q|-v] -d <destination> [-p <password>] [-P <port>] [-t <target>] [-T <target_array_var>] [-u <user>] <file> ...
#
# Example: SSHSend -t alpha file.txt /tmp/
#
# Result: Uses scp to copy file.txt to the alpha system save it in the /tmp
# directory. Returns response in ${SSH_OUT}, errors in ${SSH_ERR}, and return
# value in ${SSH_RV}.
#
UICMD+=( 'SSHSend' )
SSHSend () { # [-q|-v] -d <destination> [-p <password>] [-P <port>] [-t <target>] [-T <target_array_var>] [-u <user>] <file> ...
  ${_S} && ((_cSSHSend++))
  ${_M} && _Trace 'SSHSend [%s]' "${*}"

  local _SSH_dest
  local _SSH_pass
  local _SSH_port
  local _SSH_quiet; Quiet && _SSH_quiet=true || _SSH_quiet=false
  local _SSH_targets; _SSH_targets=( )
  local _SSH_user="${USER}"
  local _SSH_verbose=false

  ${_M} && _Trace 'Process SSHSend options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':d:p:P:qt:T:u:v' opt
  do
    case ${opt} in
      d)
        ${_M} && _Trace 'Destination. (%s)' "${OPTARG}"
        _SSH_dest="${OPTARG}"
        ;;

      p)
        ${_M} && _Trace 'Password. (%s)' "${OPTARG}"
        _SSH_pass="${OPTARG}"
        ;;

      P)
        ${_M} && _Trace 'Port. (%s)' "${OPTARG}"
        _SSH_port="-P ${OPTARG}"
        ;;

      q)
        ${_M} && _Trace 'Quiet.'
        _SSH_quiet=true
        ;;

      t)
        ${_M} && _Trace 'Target. (%s)' "${OPTARG}"
        _SSH_targets+=( "${OPTARG}" )
        ;;

      T)
        ${_M} && _Trace 'Target variable. (%s)' "${OPTARG}"
        ${ZSH} && _SSH_targets=( "${(P@)OPTARG}" ) || eval "_SSH_targets=( \"\${${OPTARG}[@]}\" )"
        ;;

      u)
        ${_M} && _Trace 'User. (%s)' "${OPTARG}"
        _SSH_user="${OPTARG}"
        ;;

      v)
        ${_M} && _Trace 'Verbose.'
        _SSH_verbose=true
        ;;

      *)
        Error -L '(SSHSend) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  [[ -z "${_SSH_dest}" ]] && Error '(SSHSend) No destination provided.'
  [[ -z "${_SSH_targets}" ]] && Error '(SSHSend) No target provided.'
  ((1 > ${#})) && Error '(SSHSend) No file provided.'

  ${_M} && _Trace 'Check for local SSH ID file. (%s)' "${HOME}/.ssh/id_rsa"
  [[ ! -f "${HOME}/.ssh/id_rsa" ]] && Warn 'No local SSH ID, password will be required to send file to %s.' "${_SSH_targets[*]}"

  local _SSH_file; _SSH_file=( "${@}" )
  local _SSH_target

  ${_M} && _Trace 'Check for verbose. (%s)' "${verbose}"
  if ${_SSH_verbose}
  then
    local _SSH_tmperr
    local _SSH_tmpout
    LoadMod File
    GetTmp -f _SSH_tmperr
    GetTmp -f _SSH_tmpout
    SSH_RV=0
    for _SSH_target in "${_SSH_targets[@]}"
    do
      ${_M} && _Trace 'SSH Copy. (%s -> %s:%s)' "${_SSH_file[*]}" "${_SSH_target}" "${_SSH_dest}"
      Action "scp ${_SSH_port} \"${_SSH_file[@]}\" '${_SSH_user}${_SSH_pass:+:${_SSH_pass}}@${_SSH_target}:${_SSH_dest}' 2> >(tee -a '${_SSH_tmperr}') 1> >(tee -a '${_SSH_tmpout}')"
      ((SSH_RV+=${?}))
    done
    SSH_OUT=$(<"${_SSH_tmpout}")
    SSH_ERR=$(<"${_SSH_tmperr}")
  else
    for _SSH_target in "${_SSH_targets[@]}"
    do
      ${_M} && _Trace 'SSH Copy. (%s -> %s:%s)' "${_SSH_file[*]}" "${_SSH_target}" "${_SSH_dest}"
      Action "Capture SSH_OUT SSH_ERR SSH_RV scp ${_SSH_port} \"${_SSH_file[@]}\" '${_SSH_user}${_SSH_pass:+:${_SSH_pass}}@${_SSH_target}:${_SSH_dest}'"
    done
    ${_M} && _Trace 'Raw response: %s\nErrors: %s\nReturn value:' "${SSH_OUT}" "${SSH_ERR}" "${SSH_RV}"
    ${_SSH_quiet} || [[ -z "${SSH_OUT}" ]] || Tell '%s' "${SSH_OUT}"
    ${_SSH_quiet} || ((0 == SSH_RV)) || Tell "${DCaution}%s" "${SSH_ERR}"
  fi

  ${_M} && _Trace 'SSHSend return. (%s)' 0
  return 0
}

# Execute Command via SSH (ssh)
#
# Syntax: SSHExec [-d|-q|-v] [-i <message>] [-p <password>] [-P <port>] [-t <target>] [-T <target_array_var>] [-u <user>] <command> ...
#
# Example: SSHExec -t alpha ls /tmp
#
# Result: Uses ssh to connect to the alpha system and execute "ls /tmp". Returns
# response in ${SSH_OUT}, errors in ${SSH_ERR}, and return value in ${SSH_RV}.
#
UICMD+=( 'SSHExec' )
SSHExec () { # [-d|-q|-v] [-i <message>] [-p <password>] [-P <port>] [-t <target>] [-T <target_array_var>] [-u <user>] <command> ...
  ${_S} && ((_cSSHExec++))
  ${_M} && _Trace 'SSHExec [%s]' "${*}"

  local _SSH_disp
  local _SSH_info
  local _SSH_pass
  local _SSH_port
  local _SSH_quiet; Quiet && _SSH_quiet=true || _SSH_quiet=false
  local _SSH_targets; _SSH_targets=( )
  local _SSH_user="${USER}"
  local _SSH_verbose=false

  ${_M} && _Trace 'Process SSHExec options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':di:p:P:qt:T:u:v' opt
  do
    case ${opt} in
      d)
        ${_M} && _Trace 'Enable display.'
        _SSH_disp='-t'
        ;;

      i)
        ${_M} && _Trace 'Info. (%s)' "${OPTARG}"
        _SSH_info="${OPTARG}"
        ;;

      p)
        ${_M} && _Trace 'Password. (%s)' "${OPTARG}"
        _SSH_pass="${OPTARG}"
        ;;

      P)
        ${_M} && _Trace 'Port. (%s)' "${OPTARG}"
        _SSH_port="-p ${OPTARG}"
        ;;

      q)
        ${_M} && _Trace 'Quiet.'
        _SSH_quiet=true
        ;;

      t)
        ${_M} && _Trace 'Target. (%s)' "${OPTARG}"
        _SSH_targets+=( "${OPTARG}" )
        ;;

      T)
        ${_M} && _Trace 'Target variable. (%s)' "${OPTARG}"
        ${ZSH} && _SSH_targets=( "${(P@)OPTARG}" ) || eval "_SSH_targets=( \"\${${OPTARG}[@]}\" )"
        ;;

      u)
        ${_M} && _Trace 'User. (%s)' "${OPTARG}"
        _SSH_user="${OPTARG}"
        ;;

      v)
        ${_M} && _Trace 'Verbose.'
        _SSH_verbose=true
        ;;

      *)
        Error -L '(SSHExec) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  [[ -z "${_SSH_targets}" ]] && Error '(SSHExec) No target provided.'
  ((0 == ${#})) && Error '(SSHExec) No command provided.'

  ${_M} && _Trace 'Check for local SSH ID file. (%s)' "${HOME}/.ssh/id_rsa"
  [[ ! -f "${HOME}/.ssh/id_rsa" ]] && Warn 'No local SSH ID, password will be required to send command to %s.' "${_SSH_targets[*]}"

  local _SSH_cmd; _SSH_cmd=( "${@}" )
  local _SSH_target

  ${_M} && _Trace 'Check for verbose. (%s)' "${verbose}"
  SSH_RV=0
  if ${_SSH_verbose}
  then
    local _SSH_tmperr
    local _SSH_tmpout
    LoadMod File
    GetTmp -f _SSH_tmpout
    GetTmp -f _SSH_tmperr
    SSH_RV=0
    for _SSH_target in "${_SSH_targets[@]}"
    do
      ${_M} && _Trace 'Sending command via SSH (%s): %s' "${_SSH_user}@${_SSH_target}" "${_SSH_cmd[*]}"
      Action -i "${_SSH_info}" -f "Comand failed on ${_SSH_target}: ${_SSH_cmd[*]}" "ssh ${_SSH_disp} ${_SSH_port} '${_SSH_user}${_SSH_pass:+:${_SSH_pass}}@${_SSH_target}' \"\${_SSH_cmd[@]}\" 2> >(tee -a '${_SSH_tmperr}') 1> >(tee -a '${_SSH_tmpout}')"
      ((SSH_RV+=${?}))
    done
    SSH_OUT=$(<"${_SSH_tmpout}")
    SSH_ERR=$(<"${_SSH_tmperr}")
  else
    for _SSH_target in "${_SSH_targets[@]}"
    do
      ${_M} && _Trace 'Sending command via SSH (%s): %s' "${_SSH_user}@${_SSH_target}" "${_SSH_cmd[*]}"
      Action -s -i "${_SSH_info}" -f "Comand failed on ${_SSH_target}: ${_SSH_cmd[*]}" "Capture SSH_OUT SSH_ERR SSH_RV ssh ${_SSH_disp} ${_SSH_port} '${_SSH_user}${_SSH_pass:+:${_SSH_pass}}@${_SSH_target}' \"\${_SSH_cmd[@]}\""
    done
    ${_M} && _Trace 'Raw response: %s\nErrors: %s\nReturn value:' "${SSH_OUT}" "${SSH_ERR}" "${SSH_RV}"
    ${_SSH_quiet} || [[ -z "${SSH_OUT}" ]] || Tell '%s' "${SSH_OUT}"
    ${_SSH_quiet} || ((0 == SSH_RV)) || Tell "${DCaution}%s" "${SSH_ERR}"
  fi

  ${_M} && _Trace 'SSHExec return. (%s)' "${SSH_RV}"
  return ${SSH_RV}
}

return 0
