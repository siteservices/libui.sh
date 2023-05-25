#!/bin/zsh
#####
#
#	Libui File Record Mod - Record-Based, CSV Data File Support
#
#	F Harvell - Sat Aug  6 12:13:26 EDT 2022
#
#####
#
# Provides record-based file utility commands.
#
# Man page available for this module: man 3 libuiFileRecord.sh
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
#
# Important note: This libui mod uses file index prefix (_fip) #2. Please be
# aware when building other libui mods that make use of file indexes.
#
#####

Version -r 1.822 -m 1.4

${AA} || Error -L '(libuiRecord) Requires associative arrays that %s does not provide.' "${SHELL}"

# load mods
LoadMod File

# defaults
declare -ga RecordColumns
declare -gA RecordData

# Open a record file
#
# Syntax: RecordOpen [-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
#
# Example: RecordOpen -1 /var/records.csv
#
# Result: Opens and locks the <file_path> file and associates the file with [-1..-9].
#
# Note: Uses the same parameters as the libui.sh Open command.
#
UICMD+=( 'RecordOpen' )
RecordOpen () { # [-1..-9|-a|-b|-c] [-B <path>] [-t <timeout>] [-w <interval>] <file_path>
  ${_S} && ((_cRecordOpen++))
  ${_M} && _Trace 'RecordOpen [%s]' "${*}"

  ${_M} && _Trace 'Open record file. (%s)' "${*}"
  _fip=2 Open "${@}"

  return ${?}
}

# Close a record file
#
# Syntax: RecordClose [-1..-9] [<file_path>]
#
# Example: RecordClose -1
#
# Result: Unlocks and closes the file associated with [-1..-9].
#
# Note: Uses the same parameters as the libui.sh Close command.
#
UICMD+=( 'RecordClose' )
RecordClose () { # [-1..-9] [<file_path>]
  ${_S} && ((_cRecordClose++))
  ${_M} && _Trace 'RecordClose [%s]' "${*}"

  ${_M} && _Trace 'Close record file. (%s)' "${*}"
  _fip=2 Close "${@}"

  return ${?}
}

# Save a record entry
#
# Syntax: RecordEntry [-1..-9] [<data_assoc_array>] [<column_array>]
#
# Example: RecordEntry -1
#
# Result: Records an entry using the columns in RecordColumns and data in RecordData.
#
UICMD+=( 'RecordEntry' )
RecordEntry () { # [-1..-9] [<data_assoc_array>] [<column_array>]
  ${_S} && ((_cRecordEntry++))
  ${_M} && _Trace 'RecordEntry [%s]' "${*}"

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'RecordEntry error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    ${_M} && _Trace 'Collect parameters. (%s)' "${*}"
    if ${ZSH}
    then
      [[ -n "${2}" ]] && RecordData=( ${(Pkv)2} )
      [[ -n "${3}" ]] && RecordColumns=( ${(P)3} )
    else
      if [[ -n "${2}" ]]
      then
        local _Record_data
        local _Record_i=0
        local _Record_keys
        eval "_Record_keys=( \"\${!${2}[@]}\" )"
        eval "_Record_data=( \"\${${2}[@]}\" )"
        for ((_Record_i=0; _Record_i <= ${#_Record_keys}; _Record_i++))
        do
          RecordData[${_Record_keys[${_Record_i}]}]="${_Record_data[${_Record_i}]}"
        done
      fi
      if [[ -n "${3}" ]]
      then
        local _Record_col
        local _Record_cols
        eval "_Record_cols=( \"\${${3}[@]}\" )"
        for _Record_col in "${_Record_cols[@]}"
        do
          RecordColumns+=( "${_Record_col}" )
        done
      fi
    fi

    ${_M} && _Trace 'Build entry. (%s)' "${RecordData[*]}"
    local _Record_key
    local _Record_entry
    for _Record_key in "${RecordColumns[@]}"
    do
      [[ ${RecordData[${_Record_key}]} =~ .*(,|\").* ]] && \
          _Record_entry+="\"${RecordData[${_Record_key}]//\"/\"\"}\"," || \
          _Record_entry+="${RecordData[${_Record_key}]//\"/\"\"},"
    done

    ${_M} && _Trace 'Record _Record_entry. (%s)' "${_Record_entry}"
    _fip=2 Write "${1}" "${_Record_entry:0:$((${#_Record_entry} - 1))}"

    return ${?}
  fi
}

return 0
