#!/usr/bin/env libui
#####
#
#	Libui Sort Mod - Sort Utilities
#
#	F Harvell - Tue Jan 25 22:27:34 EST 2022
#
#####
#
# Provides sort utility commands.
#
# Man page available for this mod: man 3 libuiSort.sh
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

Version -r 2.000 -m 1.4

# defaults

# Sort a list in an array
#
# Syntax: Sort [-a|-A|-l|-L|-n|-N|-p] [-c <compare_function>] <array_var_name> ...
#
# Example: Sort list
#
# Result: Sorts the list array (using default ASCII ascending sort)
#
UICMD+=( 'Sort' )
Sort () { # [-a|-A|-l|-L|-n|-N|-p] [-c <compare_function>] <array_var_name> ...
  ${_S} && ((_cSort++))
  ${_M} && _Trace 'Sort [%s]' "${*}"

  local _Sort_cmp
  local _Sort_results
  local _Sort_source; _Sort_source=( )
  local _Sort_locale

  # sort compares
  ${ZSH} || cmpa () { [ "${1}" \< "${2}" ]; } # ASCII ascending
  ${ZSH} && cmpa () { [[ "${1}" < "${2}" ]]; }
  ${ZSH} || cmpA () { [ "${2}" \< "${1}" ]; } # ASCII descending
  ${ZSH} && cmpA () { [[ "${2}" < "${1}" ]]; }
  cmpl () { [[ "${1}" < "${2}" ]]; } # lexically ascending
  cmpL () { [[ "${2}" < "${1}" ]]; } # lexically descending
  cmpn () { [ "${1}" -lt "${2}" ]; } # numeric ascending
  cmpN () { [ "${2}" -lt "${1}" ]; } # numeric descending
  cmpp () { local _Sort_l="${1//[!\/]}"; local _Sort_r="${2//[!\/]}"; [[ "${#_Sort_l}" -gt "${#_Sort_r}" ]]; } # depth-first

  ${_M} && _Trace 'Process Sort options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':aAc:lLnNp' opt
  do
    case ${opt} in
      a)
        ${_M} && _Trace 'ASCII ascending.'
        _Sort_locale=${LC_ALL}
        LC_ALL=C
        _Sort_cmp='cmpa'
        ;;

      A)
        ${_M} && _Trace 'ASCII descending.'
        _Sort_locale=${LC_ALL}
        LC_ALL=C
        _Sort_cmp='cmpA'
        ;;

      c)
        ${_M} && _Trace 'Compare function. (%s)' "${OPTARG}"
        _Sort_cmp="${OPTARG}"
        ;;

      l)
        ${_M} && _Trace 'Lexically ascending.'
        _Sort_cmp='cmpl'
        ;;

      L)
        ${_M} && _Trace 'Lexically descending.'
        _Sort_cmp='cmpL'
        ;;

      n)
        ${_M} && _Trace 'Numeric ascending.'
        _Sort_cmp='cmpn'
        ;;

      N)
        ${_M} && _Trace 'Numeric descending.'
        _Sort_cmp='cmpN'
        ;;

      p)
        ${_M} && _Trace 'Path depth-first.'
        _Sort_cmp='cmpp'
        ;;

      *)
        Tell -E -f -L '(Sort) Option error. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((${#})) || Tell -E -f -L '(Sort) Called without a variable name.'
  [[ -z "${_Sort_cmp}" ]] && _Sort_cmp='cmpl' # default to ASCII ascending

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'Sort error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    while [[ -n "${1}" ]]
    do
      # get variable values
      eval "_Sort_results=( \"\${${1}[@]}\" )"

      # check for zsh native sort
      if ${ZSH}
      then
        case "${_Sort_cmp}" in
          cmpa)
            _Sort_results=( "${(o)_Sort_results[@]}" )
            ;;

          cmpA)
            _Sort_results=( "${(O)_Sort_results[@]}" )
            ;;

          cmpl)
            _Sort_results=( "${(i)_Sort_results[@]}" )
            ;;

          cmpL)
            _Sort_results=( "${(Oi)_Sort_results[@]}" )
            ;;

          cmpn)
            _Sort_results=( "${(n)_Sort_results[@]}" )
            ;;

          cmpN)
            _Sort_results=( "${(On)_Sort_results[@]}" )
            ;;

          *)
            _Sort_source=( ${AO} $((${#_Sort_results[@]} + AO - 1)) )
            ;;

        esac
      else
        if ${ZSH} && ((${+commands[sort]})) || command -v sort &> /dev/null
        then
          case "${_Sort_cmp}" in
            cmpa)
              _Sort_results=( $(printf '%s\n' "${_Sort_results[@]}" | LC_ALL=C sort) )
              ;;

            cmpA)
              _Sort_results=( $(printf '%s\n' "${_Sort_results[@]}" | LC_ALL=C sort -r) )
              ;;

            cmpl)
              _Sort_results=( $(printf '%s\n' "${_Sort_results[@]}" | sort -f) )
              ;;

            cmpL)
              _Sort_results=( $(printf '%s\n' "${_Sort_results[@]}" | sort -f -r) )
              ;;

            cmpn)
              _Sort_results=( $(printf '%s\n' "${_Sort_results[@]}" | sort -n) )
              ;;

            cmpN)
              _Sort_results=( $(printf '%s\n' "${_Sort_results[@]}" | sort -n -r) )
              ;;

            *)
              _Sort_source=( ${AO} $((${#_Sort_results[@]} + AO - 1)) )
              ;;

          esac
        else
          _Sort_source=( ${AO} $((${#_Sort_results[@]} + AO - 1)) )
        fi
      fi

      ${_M} && _Trace 'Perform quick sort on %s. (%s)' "${1}" "${#_Sort_results[*]}"
      local _Sort_b
      local _Sort_e
      local _Sort_g
      local _Sort_i
      local _Sort_l
      local _Sort_p
      while ((0 < ${#_Sort_source[@]}))
      do
        _Sort_b=${_Sort_source[${AO}]}
        _Sort_e=${_Sort_source[$((AO + 1))]}
        _Sort_g=( )
        _Sort_l=( )
        _Sort_p=${_Sort_results[${_Sort_b}]}
        _Sort_source=( "${_Sort_source[@]:2}" )
        _Sort_i=$((_Sort_b + 1))
        while ((_Sort_i <= _Sort_e))
        do
          if "${_Sort_cmp}" "${_Sort_results[${_Sort_i}]}" "${_Sort_p}"
          then
            _Sort_l+=( "${_Sort_results[${_Sort_i}]}" )
          else
            _Sort_g+=( "${_Sort_results[${_Sort_i}]}" )
          fi
          ((_Sort_i++))
        done
        _Sort_results=( "${_Sort_results[@]:0:$((_Sort_b - AO))}" "${_Sort_l[@]}" "${_Sort_p}" "${_Sort_g[@]}" "${_Sort_results[@]:$((_Sort_e - AO + 1))}" )
        ((0 < ${#_Sort_l[@]} - AO)) && _Sort_source+=( "${_Sort_b}" "$((_Sort_b + ${#_Sort_l[@]} + AO - 1))" )
        ((0 < ${#_Sort_g[@]} - AO)) && _Sort_source+=( "$((_Sort_e - ${#_Sort_g[@]} + 1))" "${_Sort_e}" )
      done

      ${_M} && _Trace 'Save results to %s. (%s)' "${1}" "${#_Sort_results[*]}"
      eval "${1}=( \"\${_Sort_results[@]}\" )"

      shift
    done

    [[ -n "${_Sort_locale}" ]] && LC_ALL=${_Sort_locale}
    return 0
  fi
}

return 0
