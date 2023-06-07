#!/bin/zsh
#####
#
#	Libui Workspace Mod - Workspace Support
#
#	F Harvell - Sat Mar 18 08:38:03 EDT 2023
#
#####
#
# Provides workspace, i.e., directory containing git repos, utility commands.
#
# Man page available for this module: man 3 libuiWorkspace.sh
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

Version -r 1.822 -m 1.4

# defaults
_WS_wsfile="${_WS_wsfile:-${HOME}/.workspace}"

# load mods
LoadMod File

# Validate workspace
#
# Syntax: ValidateWorkspace [-w]
#
# Example: ValidateWorkspace
#
# Result: Configures and verifies the workspace. Sources ~/.workspace if needed.
#
# Options:
#   -w - Changes directory to the workspace (does not return to working dir)
#
# Note: If a WORKSPACE parameter is not provided, the path provided in the
# WORKSPACE environment variable will be used. If the WORKSPACE environment
# variable is not defined, the ~/.workspace file will be sourced (to define
# WORKSPACE). If WORKSPACE remains undefined, the current directory is used.
#
UICMD+=( 'ValidateWorkspace' )
ValidateWorkspace () { # [-w]
  ${_S} && ((_cValidateWorkspace++))
  ${_M} && _Trace 'ValidateWorkspace [%s]' "${*}"

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'ValidateWorkspace error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    local _WS_ws=false

    ${_M} && _Trace 'Process ValidateWorkspace options. (%s)' "${*}"
    local opt
    local OPTIND
    local OPTARG
    while getopts ':w' opt
    do
      case ${opt} in
        w)
          ${_M} && _Trace 'Remain in workspace directory.'
          _WS_ws=true
          ;;

        *)
          Error -L '(ValidateWorkspace) Unknown option. (-%s)' "${OPTARG}"
          ;;

      esac
    done
    shift $((OPTIND - 1))

    ${_M} && _Trace 'Validate WORKSPACE. (%s)' "${WORKSPACE}"
    if [[ -z "${WORKSPACE}" ]]
    then
      [[ -f "${_WS_wsfile}" ]] && source "${_WS_wsfile}" || WORKSPACE="${PWD}"
    fi
    ConfirmVar -q 'Please provide the workspace directory:' -d WORKSPACE && GetRealPath WORKSPACE

    ((0 == NRPARAM)) && ! PathMatches -P "${PWD}" "${WORKSPACE}" && \
        Warn -C 'Not using current path, using workspace "%s".' "${WORKSPACE##*/}"

    ${_M} && _Trace 'Remain in workspace. (%s)' "${_WS_ws}"
    ${_WS_ws} && cd "${WORKSPACE}" &> /dev/null
  fi

  ${_M} && _Trace 'ValidateWorkspace return. (%s)' 0
  return 0
}

return 0
