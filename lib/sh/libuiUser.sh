#!/bin/zsh
#####
#
#	Libui User Mod - User Information
#
#	F Harvell - Sat Jan 15 21:11:34 EST 2022
#
#####
#
# Provides user information utility commands.
#
# Man page available for this mod: man 3 libuiUser.sh
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

Version -r 1.834 -m 1.10

# defaults
userdotfile="${userdotfile:-${HOME}/.user}"
defaultuserinfo=( 'NAME' 'ORG' 'TITLE' 'EMAIL' 'PHONE' 'COLORS' )

# Set user information
#
# Syntax: _SetUserInfo
#
# Example: _SetUserInfo
#
# Result: Ask questions to create the ~/.user file.
#
UICMD+=( '_SetUserInfo' )
_SetUserInfo () {
  ${_S} && ((_c_SetUserInfo++))
  ${_M} && _Trace '_SetUserInfo [%s]' "${*}"

  ${_quiet} && Tell -E -f 'User setup required. Please execute without -Q (Quiet) option.'

  local _User_entry
  local _User_test

  ${_M} && _Trace 'Load user information dotfile. (%s)' "${userdotfile}"
  [[ -f "${userdotfile}" ]] && source "${userdotfile}"

  ${_M} && _Trace 'Process _SetUserInfo options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':u' opt
  do
    case ${opt} in
      u)
        ${_M} && _Trace 'Update user info.'
        local _User_info; _User_info=( "${defaultuserinfo[@]}" )
        for _User_entry in "${userinfo[@]}"
        do
          if ${ZSH}
          then
            ((0 < ${_User_info[(Ie)${_User_entry}]})) && _User_entry=
          else
            for _User_test in "${_User_info[@]}"
            do
              [[ "${_User_entry}" == "${_User_test}" ]] && _User_entry= && break
            done
          fi
          [[ -n "${_User_entry}" ]] && _User_info+=( "${_User_entry}" )
        done
        userinfo=( "${_User_info[@]}" )
        ;;

      *)
        Tell -E -f -L '(_SetUserInfo) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace '_SetUserInfo error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    Tell 'Building user information dotfile. (%s)' "${userdotfile}"
    [[ -z "${userinfo}" ]] && userinfo=( "${defaultuserinfo[@]}" )
    for _User_entry in "${userinfo[@]}"
    do
      local _User_invalid=true
      case "${_User_entry}" in
        NAME)
          while ${_User_invalid}
          do
            Ask -n NAME -d "${NAME:-${USER}}" "What is the user's full name?"
            if [[ "${NAME}" =~ .*\ .* ]]
            then
              _User_invalid=false
            else
              Verify 'Are you sure? That response does not appear to be a full name.' && _User_invalid=false
            fi
          done
          ;;

        ORG)
          while ${_User_invalid}
          do
            Ask -n ORG -d "${ORG}" -z "What is the user's organization / company?"
            if [[ -n "${ORG}" ]]
            then
              _User_invalid=false
            else
              Verify 'Are you sure? That response is not an organization / company.' && _User_invalid=false
            fi
          done
          ;;

        TITLE)
          while ${_User_invalid}
          do
            Ask -n TITLE -d "${TITLE}" -z "What is the user's title?"
            if [[ -n "${TITLE}" ]]
            then
              _User_invalid=false
            else
              Verify 'Are you sure? That response is not a title.' && _User_invalid=false
            fi
          done
          ;;

        EMAIL)
          while ${_User_invalid}
          do
            Ask -n EMAIL -d "${EMAIL:-${USER}@${DOMAIN}}" "What is the user's email address?"
            if [[ "${EMAIL}" =~ .*@.*\..* ]]
            then
              _User_invalid=false
            else
              Verify 'Are you sure? That response does not appear to be an email address.' && _User_invalid=false
            fi
          done
          ;;

        PHONE)
          while ${_User_invalid}
          do
            _User_test="${PHONE}"
            Ask -n PHONE -d "${PHONE}" -z "What is the user's telephone number?"
            if [[ "${_User_test}" == "${PHONE}" ]]
            then
              _User_invalid=false
            else
              _User_test="${PHONE//[^0-9]/}"
              ((10 == ${#_User_test})) && PHONE="+1.${_User_test:0:3}.${_User_test:3:3}.${_User_test:6}"
              ((11 == ${#_User_test})) && ((1 == ${_User_test:0:1})) && PHONE="+1.${_User_test:1:3}.${_User_test:4:3}.${_User_test:7}"
              if Verify 'Save telephone number as "%s"?' "${PHONE}"
              then
                _User_invalid=false
              fi
            fi
          done
          ;;

        COLORS)
          COLORS="${COLORS:-y}"
          Ask -n COLORS -d "${COLORS}" 'Override default colors?'
          if AnswerMatches 'y' || AnswerMatches 'true'
          then
            COLORS=true
          else
            COLORS=false
          fi
          ;;

        *)
          ${ZSH} && Ask -n ${_User_entry} -d "${(P)_User_entry}" 'Enter value for %s:' "${_User_entry}"
          ${ZSH} || Ask -n ${_User_entry} -d "${!_User_entry}" 'Enter value for %s:' "${_User_entry}"
          eval "${_User_entry}=\"\${${_User_entry}}\""
          ;;

      esac
    done

    ${_M} && _Trace 'Write user information dotfile. (%s)' "${userdotfile}"
    {
      printf "#!%s\n##### User Information\n" "${SHELL:-/bin/zsh}"
      printf 'userinfo=('
      printf " '%s'" "${userinfo[@]}"
      printf ' )\n'
      for _User_entry in "${userinfo[@]}"
      do
        ${ZSH} && printf "%s='%s'\n" "${_User_entry}" "${(P)_User_entry}"
        ${ZSH} || printf "%s='%s'\n" "${_User_entry}" "${!_User_entry}"
      done
      printf 'export %s\n' "${userinfo[*]}"
    } > "${userdotfile}"
    if ((${?}))
    then
      Tell -W 'User information was not written to user dotfile. (%s)' "${userdotfile}"
    else
      Tell -A 'New user dotfile was installed. (%s)' "${userdotfile}"
    fi

    source "${userdotfile}"

    ${_M} && _Trace 'Check for quiet. (%s)' "${_quiet}"
    if ! ${_quiet}
    then
      Tell 'The following information is contained in the user dotfile:'
      for _User_entry in "${userinfo[@]}"
      do
        ${ZSH} && printf "    %s: %s\n" "${_User_entry}" "${(P)_User_entry}"
        ${ZSH} || printf "    %s: %s\n" "${_User_entry}" "${!_User_entry}"
      done
      printf '\n'
    fi
    local _User_rv=${?}

    ${_M} && _Trace '_SetUserInfo return. (%s)' "${_User_rv}"
    return ${_User_rv}
  fi
}

${_M} && _Trace 'User initialization.'
[[ -f "${userdotfile}" ]] && source "${userdotfile}" || _SetUserInfo

return ${?}
