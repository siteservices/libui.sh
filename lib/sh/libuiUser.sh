#!/usr/bin/env libui
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

Version -r 2.020 -m 1.18

# defaults
userdotfile="${userdotfile:-${HOME}/.config/user}"
defaultuserinfo=( 'NAME' 'ORG' 'TITLE' 'EMAIL' 'PHONE' 'LOCATION' 'COLOR' 'MODE' 'FONTFACE' 'FONTSIZE' )

# Set user information
#
# Syntax: _SetUserInfo
#
# Example: _SetUserInfo
#
# Result: Ask questions to create the ~/.local/user file.
#
UICMD+=( '_SetUserInfo' )
_SetUserInfo () {
  ${_S} && ((_c_SetUserInfo++))
  ${_M} && _Trace '_SetUserInfo [%s]' "${*}"

  ! [[ -t 0 && -t 1 ]] && Tell -E -f 'User setup required. Please execute "libui -U" in an interactive shell first.'

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
            ((${_User_info[(Ie)${_User_entry}]} > 0)) && _User_entry=
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
            if [[ "${NAME}" =~ \  ]]
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
            if [[ "${EMAIL}" =~ @.*\. ]]
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
              ((11 == ${#_User_test})) && \
                  ((1 == ${_User_test:0:1})) && PHONE="+1.${_User_test:1:3}.${_User_test:4:3}.${_User_test:7}"
              Verify 'Save telephone number as "%s"?' "${PHONE}" && _User_invalid=false
            fi
          done
          ;;
        LOCATION)
          while ${_User_invalid}
          do
            _User_test="${LOCATION}"
            Ask -n LOCATION -d "${LOCATION}" -z "What is the user's location? (Address, City, ST[, Zip[, CC]])"
            if [[ "${_User_test}" == "${LOCATION}" ]]
            then
              _User_invalid=false
            else
              ${ZSH} && eval "_User_test=( \"\${(s:,:)LOCATION}\" )" || IFS=, read -r -a _User_test <<< "${LOCATION}"
              local _User_address="${_User_test[@]:0:1}"; _User_address="${_User_address## }"
              local _User_city="${_User_test[@]:1:1}"; _User_city="${_User_city## }"
              local _User_state="${_User_test[@]:2:1}"; _User_state="${_User_state## }"
              local _User_zip="${_User_test[@]:3:1}"; _User_zip="${_User_zip## }"
              local _User_country="${_User_test[@]:4:1}"; _User_country="${_User_country## }"
              if [[ -z "${_User_zip}" ]]
              then
                ${ZSH} && eval "_User_test=( \"\${(s: :)_User_state}\" )" || read -r -a _User_test <<< "${_User_state}"
                _User_state="${_User_test[@]:0:1}"
                _User_zip="${_User_test[@]:1:1}"
                _User_country="${_User_test[@]:2:1}"
              fi
              [[ ! "${_User_zip}" =~ ^[0-9][0-9]*$ ]] && _User_country="${_User_zip}" && _User_zip=
              ${ZSH} && eval "_User_state=\"\${(U)_User_state}\"" || \
                  _User_state="$(printf '%s' "${_User_state}" | tr '[:lower:]' '[:upper:]')"
              ${ZSH} && eval "_User_country=\"\${(U)_User_country}\"" || \
                  _User_country="$(printf '%s' "${_User_country}" | tr '[:lower:]' '[:upper:]')"
              [[ -z "${_User_country}" || "${_User_country}" =~ ^U\\.*S\\.*A*\\.*$ ]] && _User_country="US"
              ((2 != ${#_User_country})) && Info 'Please use a two-character country code.' && continue
              LOCATION="${_User_address}, ${_User_city}, ${_User_state}, ${_User_zip:+${_User_zip}, }${_User_country}"
              Verify 'Save location as "%s"?' "${LOCATION}" && _User_invalid=false
            fi
          done
          ;;
        COLOR)
          COLOR="${COLOR:-y}"
          Ask -n COLOR -d "${COLOR}" 'Use upated colors?'
          if AnswerMatches 'y' || AnswerMatches 'true'
          then
            COLOR=true
          else
            COLOR=false
          fi
          ;;
        MODE)
          MODE="${MODE:-vi}"
          Ask -n MODE -s 'vi' -s 'emacs' -d "${MODE}" 'Preferred edit mode?'
          ;;
        FONTFACE)
          FONTFACE="${FONTFACE:-Hack}"
          StartSpinner 'Searhcing for monospace fonts...'
          local _User_faces; _User_faces=( )
          if [[ "${OS}" == 'Darwin' ]]
          then
            fontfaces () {
osascript <<'APPLESCRIPT'
use framework "Foundation"
use framework "AppKit"
set fontManager to current application's NSFontManager's sharedFontManager()
set fontlist to fontManager's availableFontNamesWithTraits:(current application's NSFixedPitchFontMask)
set monolist to fontlist as list
set AppleScript's text item delimiters to linefeed
set monoFonts to monolist as text
return monoFonts
APPLESCRIPT
            }
            _User_faces=( $(fontfaces | cut -f 1 -d '-' | sort -u) )
          else
            if ${ZSH}
            then
              _User_faces+=( ${(f)"$(fc-list :spacing=100 family 2> /dev/null | grep -iv '\(^\.\|Emoji\)' | sort -u)"} )
            else
              readarray -t -O "${#_User_faces[@]}" _User_faces < <(fc-list :spacing=100 family | grep -iv '\(^\.\|Emoji\)' | sort -u)
            fi
          fi
          Contains _User_faces 'Hack' || _User_faces+=( 'Hack' )
          StopSpinner
          Ask -n FONTFACE -S _User_faces -d "${FONTFACE}" 'Desired termnial font face?'
          ;;
        FONTSIZE)
          FONTSIZE="${FONTSIZE:-9}"
          while ${_User_invalid}
          do
            Ask -n FONTSIZE -d "${FONTSIZE}" 'Desired termnial font size?'
            if ((FONTSIZE > 5 && FONTSIZE < 25 ))
            then
              _User_invalid=false
            else
              Verify 'Are you sure? That response does not appear to be a reasonable size.' && _User_invalid=false
            fi
          done
          ;;
        *)
          ${ZSH} && Ask -n ${_User_entry} -d "${(P)_User_entry}" 'Enter a value for %s:' "${_User_entry}"
          ${ZSH} || Ask -n ${_User_entry} -d "${!_User_entry}" 'Enter a value for %s:' "${_User_entry}"
          eval "${_User_entry}=\"\${${_User_entry}}\""
          ;;
      esac
    done

    ${_M} && _Trace 'Write user information dotfile. (%s)' "${userdotfile}"
    {
      printf "#!%s\n##### User Information\n" "${SHELL:-/bin/zsh}"
      printf 'userinfo=('
      printf " '%s'" "${userinfo[@]//'/'\\''}"
      printf ' )\n'
      local _User_value _User_export; _User_export=( )
      for _User_entry in "${userinfo[@]}"
      do
        ${ZSH} && _User_value="${(P)_User_entry}" || _User_value="${!_User_entry}"
        [[ -n "${_User_value}" ]] && printf "%s='%s'\n" "${_User_entry}" "${_User_value//'/'\\''}" && \
            _User_export+=( ${_User_entry} )
      done
      printf 'export %s\n' "${_User_export[*]}"
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
