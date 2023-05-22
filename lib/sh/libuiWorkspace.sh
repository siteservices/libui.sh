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

Version -r 1.822 -m 1.2

# defaults
_WS_wsfile="${_WS_wsfile:-${HOME}/.workspace}"

# load mods
LoadMod File

# Validate workspace
#
# Syntax: ValidateWorkspace [-W]
#
# Example: ValidateWorkspace
#
# Result: Configures and verifies the workspace. Sources ~/.workspace if needed.
#
# Options:
#   -W - Changes directory to the workspace (does not return to working dir)
#
# Note: If a WORKSPACE parameter is not provided, the path provided in the
# WORKSPACE environment variable will be used. If the WORKSPACE environment
# variable is not defined, the ~/.workspace file will be sourced (to define
# WORKSPACE). If WORKSPACE remains undefined, the current directory is used.
#
UICMD+=( 'ValidateWorkspace' )
ValidateWorkspace () { # [-W]
  ${_S} && ((_cValidateWorkspace++))
  ${_M} && _Trace 'ValidateWorkspace [%s]' "${*}"

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'ValidateWorkspace error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    local _WS_wd=true

    ${_M} && _Trace 'Process ValidateWorkspace options. (%s)' "${*}"
    local opt
    local OPTIND
    local OPTARG
    while getopts ':W' opt
    do
      case ${opt} in
        W)
          ${_M} && _Trace 'Do not return to working directory.'
          _WS_wd=false
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

    ((0 == NRPARAM)) && ! PathMatches -r "${PWD}" "${WORKSPACE}" && \
        Warn 'Not using current path, using workspace "%s".' "${WORKSPACE##*/}"

    ${_WS_wd} || cd "${WORKSPACE}"
  fi

  ${_M} && _Trace 'ValidateWorkspace return. (%s)' 0
  return 0
}

return 0
