#!/bin/zsh
#####
#
#	Libui Info Mod - Libui Information
#
#	F Harvell - Sat Sep 24 11:12:37 EDT 2022
#
#####
#
# Provides libui info utility commands.
#
# Man page available for this mod: man 3 libuiInfo.sh
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

Version -r 2.004 -m 1.10

# defaults

# Provides usage information for the main script.
#
# Syntax: UsageInfo
#
# Example: UsageInfo
#
# Result: Displays a "help" message that includes the main syntax and option
# information derived from libui and the AdOption / AddParameter libui commands.
#
UICMD+=( 'UsageInfo' )
UsageInfo () {
  ${_S} && ((_cUsageInfo++))
  ${_M} && _Trace 'UsageInfo [%s]' "${*}"

  # library provided options
  _osm+=( false false )
  _opm+=( false )

  {
    local _UsageInfo_d
    local _UsageInfo_i
    local _UsageInfo_m
    local _UsageInfo_p
    local _UsageInfo_s

    ${_M} && _Trace 'Display usage information.'
    printf "${DCES}\n"

    ${_M} && _Trace 'Display sample command line.'
    _os+=( 'h' 'H' )
    _UsageInfo_i="${AO}"
    printf "${DTell}USAGE: %s " "${CMD}"
    if [[ -n "${_os}" ]]
    then
      printf '['
      for _UsageInfo_p in "${_os[@]}"
      do
        ${_osm[${_UsageInfo_i}]} && _UsageInfo_m=' ...' || _UsageInfo_m=
        [[ "${_UsageInfo_i}" == "${AO}" ]] || _UsageInfo_s='|'
        printf '%s-%s%s' "${_UsageInfo_s}" "${_os[${_UsageInfo_i}]}" "${_UsageInfo_m}"
        ((_UsageInfo_i++))
      done
      printf ']'
    fi
    _opf+=( X )
    _oavar+=( option )
    _UsageInfo_i="${AO}"
    for _UsageInfo_p in "${_opf[@]}"
    do
      ${_opm[${_UsageInfo_i}]} && _UsageInfo_m=' ...' || _UsageInfo_m=
      printf ' [-%s <%s>]%s' "${_UsageInfo_p}" "${_oavar[${_UsageInfo_i}]:-value}" "${_UsageInfo_m}"
      ((_UsageInfo_i++))
    done
    if [[ -n "${_pvar}" ]]
    then
      for _UsageInfo_p in "${_pvar[@]}"
      do
        [[ -z "${_UsageInfo_d}" ]] || printf ' <%s>' "${_UsageInfo_d}"
        _UsageInfo_d="${_UsageInfo_p}"
      done
      ${_pr} && printf ' <%s>' "${_UsageInfo_p}" || printf ' [<%s>]' "${_UsageInfo_p}"
      ${_pm} && printf ' ...'
    fi
    printf "${D}\n\n"

    local _UsageInfo_x=0

    ${_M} && _Trace 'Determine max keyword length.'
    for _UsageInfo_p in "${_ok[@]}"
    do
      ((_UsageInfo_x < ${#_UsageInfo_p})) && _UsageInfo_x=${#_UsageInfo_p}
    done
    for _UsageInfo_p in "${_pvar[@]}"
    do
      ((_UsageInfo_x + 2 < ${#_UsageInfo_p})) && _UsageInfo_x=$((${#_UsageInfo_p} - 2))
    done

    ${_M} && _Trace 'Display options.'
    _UsageInfo_i="${AO}"
    for _UsageInfo_p in "${_ou[@]}"
    do
      _UsageInfo_d="$(printf "  -%s  %-${_UsageInfo_x}s - %s" "${_UsageInfo_p}" "${_ok[${_UsageInfo_i}]}" "${_od[${_UsageInfo_i}]}")"
      eval "_UsageInfo_d=\"${_UsageInfo_d//\"/\\\"}\""
      printf '%s\n' "${_UsageInfo_d}"
      ((_UsageInfo_i++))
    done

    ${_M} && _Trace 'Display debug help options. (%s)' "${_help}"
    printf "  -%s  %-${_UsageInfo_x}s - %s\n" 'H' 'Help' 'Display usage message, also available with -h. (help: true)'
    printf "  -%s  %-${_UsageInfo_x}s - %s" 'X' 'XOption' "XOptions, use -XH for details. (level: ${_xdb}"
    ${_confirm} && printf ', confirm'
    ${_force} && printf ', force'
    ${_help} && printf ', help'
    ${_overwrite} && printf ', overwrite'
    ${_noaction} && printf ', noaction'
    ${_quiet} && printf ', quiet'
    ${_yes} && printf ', yes'
    [[ -n "${_profile}" ]] && printf '%s' ", profile: ${_profile})"
    printf ')\n'
    if ${_help}
    then
      cat << EOF
        1   - Verify before executing Exit handlers.
        2   - Verbose actions.
        3   - Local debugging.
        5   - Profile with a timestamp in trace messages.
        6   - Context debugging with file / function / line in trace messages.
        7   - Remote debugging.
        8   - Mod debugging.
        9   - Library internals debugging.
        c|C - Confirm Actions before performing them.
        f|F - Force Actions.
        h|H - Display this debug help.
        n|N - Show but do not perform Actions.
        o|O - Overwrite mode.
        q|Q - Quiet operation.
        v|V - Version information.
        y|Y - Answer all question with the default or "yes".
        <file> - Profile configuration file to load.
EOF
    fi

    printf '\n'

    ${_M} && _Trace 'Display parameters.'
    _UsageInfo_i="${AO}"
    if ((0 < ${#_pd[@]}))
    then
      ((_UsageInfo_x=_UsageInfo_x+4))
      for _UsageInfo_p in "${_pd[@]}"
      do
        [[ -n "${_pk[${_UsageInfo_i}]}" ]] && eval "_UsageInfo_p=\"${_pk[${_UsageInfo_i}]}: ${_UsageInfo_p//\"/\\\"}\"" || eval "_UsageInfo_p=\"${_UsageInfo_p//\"/\\\"}\""
        printf "  %-${_UsageInfo_x}s - %s\n" "<${_pvar[${_UsageInfo_i}]}>" "${_UsageInfo_p}"
        ((_UsageInfo_i++))
      done
      printf '\n'
    fi

    ${_M} && _Trace 'Display required options.'
    local _m
    local _t
    _i=${AO}
    [[ -n "${_or}" ]] && for _t in "${_or[@]}"
    do
      ${_t} && _m+="${_ou[${_i}]}, "
      ((_i++))
    done
    if [[ -n "${_m}" ]]
    then
      printf '  Required options: %s\n\n' "${_m%, }"
    fi

    ${_M} && _Trace 'Display available option values.'
    if ((0 < ${#_ol[@]}))
    then
      printf '  Available option values:\n'
      ${ZSH} && printf '    For %s\n' "${_ol[@]}" || printf '    For %s\n' "${_ol[@]%, }"
      printf '\n'
    fi

    ${_M} && _Trace 'Display available parameter values.'
    if ((0 < ${#_pl[@]}))
    then
      printf '  Available parameter values:\n'
      ${ZSH} && printf '    For %s\n' "${_pl[@]}" || printf '    For %s\n' "${_pl[@]%, }"
      printf '\n'
    fi

    ${_M} && _Trace 'Display usage info.'
    declare -f InfoCallback > /dev/null && _Trace 'Call InfoCallback.' && InfoCallback

    ${_M} && _Trace 'Display version information.'
    printf "${DCES}\n"
    Version -a
    printf "${D}\n"
  } >> /dev/stderr

  return 2
}

return 0
