#!/usr/bin/env libui
#####
#
#	Libui Package Mod - Self-Extracting Package Utilities
#
#	F Harvell - Sat Jan 15 10:06:08 EST 2022
#
#####
#
# Provides self-extracting package utility commands.
#
# Man page available for this mod: man 3 libuiPackage.sh
#
#####
#
# Copyright 2018-2024 siteservices.net, Inc. and made available in the public
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

Version -r 2.010 -m 1.21

# defaults

# Create Self-Extracting Package Header
#
# Syntax: _CreatePackageHeader [-P|-S|-T|-X] [-d <description>] [-i <installer>] [-I <installer_prep>] [-s <source_directory>] <package_filename>
#
# Example: _CreatePackageHeader -T -i '\${d}/path/to/installer \${@} \${a}' package.tarp
#
# Result: Creates a package.tarp package containing a tarp self-extracting
# header configured to execute "<tempdir>/path/to/installer $@ <archive>" when
# executed.
#
# When extracting, if the installer is contained within the package, it can be
# accessed using "\${d}/<installer> \${@} \${a}", where "\${d}" will be replaced
# with with the temporary directory path, path/to/installer is the path to the
# installer in the extracted directory, "\${@}" will be replaced with any
# user-provided option flags, and "\${a}" will be replaced with the archive
# path. The default installer is "\${d}/.installer \${@} \${a}".
#
UICMD+=( '_CreatePackageHeader' )
_CreatePackageHeader () { # [-P|-S|-T|-X] [-d <description>] [-i <installer>] [-I <installer_prep>] [-s <source_directory>] <package_filename>
  ${_S} && ((_c_CreatePackageHeader++))
  ${_M} && _Trace '_CreatePackageHeader [%s]' "${*}"

  local _Package_archive='tar'
  local _Package_desc
  local _Package_extract=true
  local _Package_installer='\${d}/.installer \${@} \${a}'
  local _Package_null
  local _Package_prep
  local _Package_srcdir
  local _Package_unarchive='tar xf'

  ${_M} && _Trace 'Process _CreatePackageHeader options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':d:i:I:Ps:STX' opt
  do
    case ${opt} in
      d)
        ${_M} && _Trace 'Description. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_desc="${OPTARG}"
        ;;

      i)
        ${_M} && _Trace 'Installer path. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_installer="${OPTARG}"
        ;;

      I)
        ${_M} && _Trace 'Installer prep. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_prep="${OPTARG}"
        ;;

      P)
        ${_M} && _Trace 'Make star.'
        _Package_archive='star'
        [[ -z "${_Package_prep}" ]] && \
            _Package_prep='s="$(command -v star 2> /dev/null)"; s="${s:-$(command -v starx 2> /dev/null)}"; s="${s:-error}"'
        _Package_unarchive='${s} -x -f'
        ;;

      s)
        ${_M} && _Trace 'Source directory. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_srcdir="${OPTARG}"
        ;;

      S)
        ${_M} && _Trace 'Make shar.'
        _Package_archive='shar'
        _Package_unarchive='sh'
        ;;

      T)
        ${_M} && _Trace 'Make tar.'
        _Package_archive='tar'
        _Package_unarchive='tar xf'
        ;;

      X)
        ${_M} && _Trace 'No extract.'
        _Package_extract=false
        ;;

      *)
        Tell -E -f -L '(_CreatePackageHeader) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((1 != ${#})) && Tell -E -f -L '(_CreatePackageHeader) Invalid parameters. (%s)' "${*}"
  [[ -z "${_Package_srcdir}" ]] && _Package_srcdir="${PWD}"
  [[ -z "${_Package_desc}" ]] && _Package_desc="Self-Extracting ${_Package_srcdir##*/} Package"

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace '_CreatePackageHeader error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    ${_M} && _Trace 'Prepare self-extracting package header. (%s)' "${_Package_installer}"
    local _Package_head="#!/bin/zsh
#####
#
#	${_Package_desc} (${1##*/})
#	Created by: ${USER}@${HOST}.${DOMAIN}
#		on: $(date | sed 's/  / /g')
#
#	Install with 'zsh ${1##*/}'; add '-h' for help or '-e' to extract archive file.
#####

# startup
\${_Package_prep:+\${_Package_prep}\${N}}error () { printf 'Self-extract failure.\\\n'; exit 1; }
l=\\\$(head -n \${_Package_headlen} \\\"\\\${0}\\\" | tail -n 1) && [ '__PAYLOAD__' = \\\"\\\${l}\\\" ] || error

# extract archive
t=\\\"\\\$(mktemp -d)\\\" || error
a=\\\"\\\${0##*/}\\\"; a=\\\"\\\${t}/\\\${a%\\\\\\.*}.\${_Package_archive}\\\"
[ \\\"\\\${1}\\\" = '-h' ] && printf '%s\\n' \\\"Executing 'zsh \\\${0}' will unarchive using '\${_Package_unarchive} \\\\"\\\"\\\${a}\\\\"\\\"'.\\\" && exit 0
printf 'Preparing...'
tail -n +\$((_Package_headlen + 1)) \\\"\\\${0}\\\" > \\\"\\\${a}\\\"
[ \\\"\\\${1}\\\" = '-e' ] && mv \\\"\\\${a}\\\" ./ && rmdir \\\"\\\${t}\\\" && printf 'Done.\\n' && exit 0
"

${_Package_extract} && _Package_head+="
# extract installer
d=\\\"\\\${t}/a\\\"
mkdir \\\"\\\${d}\\\" || error
cd \\\"\\\${d}\\\" > /dev/null
\${_Package_unarchive} \\\"\\\${a}\\\" > /dev/null 2>&1 || error
cd - > /dev/null
"

_Package_head+="
# run installer
\${_Package_installer}

# done
rm -rf \\\"\\\${t}\\\"
printf 'Done.\\n'
exit 0

\${_Package_null}__PAYLOAD__
"

    ${_M} && _Trace 'Generate self-extracting package header. (%s)' "${1}"
    local _Package_headlen=$(eval "printf '%s' \"${_Package_head}\"" | wc -l)
    eval "printf '%s' \"${_Package_head}\" > '${1}'"

    ${_M} && _Trace '_CreatePackageHeader return. (%s)' 0
    return 0
  fi
}

# Create Self-Extracting Package Archive
#
# Syntax: CreatePackage [-l|-N|-P|-S|-T|-X] [-c <compression>] [-d <description>] [-f <filelist_array_var_name>] [-h <header_command>] [-i <installer>] [-I <installer_prep>] [-n <encoding>] [-s <source_directory>] [-x <exclude_array_var_name>] <package_filename>
#
# Example: CreatePackage -f filelist -s '/source/dir' package.tarp
#
# Result: Creates a package.tarp package containing the files in the filelist array from the /source/dir directory.
#
UICMD+=( 'CreatePackage' )
CreatePackage () { # [-l|-N|-P|-S|-T|-X] [-c <compression>] [-d <description>] [-f <filelist_array_var_name>] [-h <header_command>] [-i <installer>] [-I <installer_prep>] [-n <encoding>] [-s <source_directory>] [-x <exclude_array_var_name>] <package_filename>
  ${_S} && ((_cCreatePackage++))
  ${_M} && _Trace 'CreatePackage [%s]' "${*}"

  local _Package_desc
  local _Package_excludes; _Package_excludes=( )
  local _Package_extract
  local _Package_files; _Package_files=( '.' )
  local _Package_header
  local _Package_installer
  local _Package_list=false
  local _Package_encoding=''
  local _Package_prep
  local _Package_sharp=false
  local _Package_starp=false
  local _Package_tarp=true
  local _Package_compression='-j'
  local _Package_rv=0

  ${_M} && _Trace 'Process CreatePackage options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':c:d:f:h:i:I:ln:No:Ps:STx:X' opt
  do
    case ${opt} in
      c)
        ${_M} && _Trace 'Compression. (%s)' "${OPTARG}"
        _Package_compression="${OPTARG}"
        [[ -n "${_Package_compression}" ]] &&[[ "${_Package_compression:0:1}" != '-' ]] && \
            _Package_compression="${_Package_compression:+-${_Package_compression}}"
        ;;

      d)
        ${_M} && _Trace 'Description. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_desc="${OPTARG}"
        ;;

      f)
        ${_M} && _Trace 'File list. (%s)' "${OPTARG}"
        ${ZSH} && _Package_files=( "${(P@)OPTARG}" ) || eval "_Package_files=( \"\${${OPTARG}[@]}\" )"
        ;;

      h)
        ${_M} && _Trace 'Header function / command name. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_header="${OPTARG}"
        ;;

      i)
        ${_M} && _Trace 'Installer file path. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_installer="${OPTARG}"
        ;;

      I)
        ${_M} && _Trace 'Installer prep. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_prep="${OPTARG}"
        ;;

      l)
        ${_M} && _Trace 'List files flag.'
        _Package_list=true
        ;;

      n)
        ${_M} && _Trace 'Encoding. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_encoding="${OPTARG}" && [[ "${_Package_encoding:0:1}" != '-' ]] && \
            _Package_encoding="${_Package_encoding:+-${_Package_encoding}}"
        ;;

      N)
        ${_M} && _Trace 'No package, tarball only.'
        _Package_sharp=false
        _Package_starp=false
        _Package_tarp=false
        ;;

      P)
        ${_M} && _Trace 'Make star package.'
        _Package_sharp=false
        _Package_starp=true
        _Package_tarp=false
        ;;

      s)
        ${_M} && _Trace 'Source directory. (%s)' "${OPTARG}"
        [[ -n "${OPTARG}" ]] && _Package_srcdir="${OPTARG}"
        ;;

      S)
        ${_M} && _Trace 'Make shar package.'
        _Package_sharp=true
        _Package_starp=false
        _Package_tarp=false
        ;;

      T)
        ${_M} && _Trace 'Make tar package.'
        _Package_sharp=false
        _Package_starp=false
        _Package_tarp=true
        ;;

      x)
        ${_M} && _Trace 'Exclude list. (%s)' "${OPTARG}"
        ${ZSH} && _Package_excludes=( "${(P@)OPTARG}" ) || eval "_Package_excludes=( \"\${${OPTARG}[@]}\" )"
        ;;

      X)
        ${_M} && _Trace 'No extract.'
        _Package_extract='-X'
        ;;

      *)
        Tell -E -f -L '(CreatePackage) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((1 != ${#})) && Tell -E -f -L '(CreatePackage) Invalid parameters. (%s)' "${*}"
  local _Package_package="${*}"
  [[ -z "${_Package_srcdir}" ]] && _Package_srcdir="${PWD}"
  ConfirmVar -d _Package_srcdir

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'CreatePackage error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    ${_M} && _Trace 'Check if tar package. (%s)' "${_Package_tarp}"
    if ${_Package_tarp}
    then
      [[ ".tarp" == "${_Package_package: -5}" ]] || _Package_package+='.tarp'
    elif ${_Package_sharp}
    then
      [[ ".sharp" == "${_Package_package: -6}" ]] || _Package_package+='.sharp'
    elif ${_Package_starp}
    then
      [[ ".starp" == "${_Package_package: -6}" ]] || _Package_package+='.starp'
    else
      [[ ".tar" == "${_Package_package: -4}" ]] || _Package_package+='.tar'
    fi
    if ! Overwrite
    then
      ${_M} && _Trace 'Check for existing package. (%s)' "${_Package_package}"
      if [[ -e "${_Package_package}" ]]
      then
        ${_Package_list} || Tell -E 'The package already exists (%s). Use -XO (Overwrite) to overwrite.' "${_Package_package}"
      fi
    fi

    ${_M} && _Trace 'Check if listing files. (%s)' "${_Package_list}"
    if ${_Package_list}
    then
      ${_M} && _Trace 'Exclude files. (%s)' "${_Package_excludes[*]}"
      local _Package_glob
      local _Package_exclude
      local _Package_file
      for _Package_exclude in "${_Package_excludes[@]}"
      do
        if ${ZSH}
        then
          eval "_Package_glob=( ${_Package_exclude}(N) )"
        else
          shopt -s nullglob
          _Package_glob=( ${_Package_exclude[@]} )
          shopt -u nullglob
        fi
        if ((0 < ${#_Package_glob[@]}))
        then
          for _Package_file in "${_Package_glob[@]}"
          do
            if ${ZSH}
            then
              _Package_files=( "${(@)_Package_files:#${_Package_file}}" )
            else
              _Package_files=( "${_Package_files[@]/${_Package_file}}" )
            fi
          done
        fi
      done
      ${_M} && _Trace 'List files. (%s)' "${_Package_files[*]}"
      Tell 'Source Directory:'
      printf '  %s\n' "${_Package_srcdir}"
      Tell 'Files Included:'
      printf '  %s\n' "${_Package_files[@]}"
      Tell 'Files Excluded:'
      printf '  %s\n' "${_Package_excludes[@]}"
    else
      ${_M} && _Trace 'Prepare tar command.'
      LoadMod File
      local _Package_cmd=''
      [[ 'Darwin' == "${OS}" ]] && _Package_cmd+="--no-mac-metadata " # don't include mac metadata
      for _Package_exclude in "${_Package_excludes[@]}"
      do
        [[ -n "${_Package_exclude}" ]] && _Package_cmd+="--exclude=\"${_Package_exclude}\" "
      done
      local _Package_tarball
      GetTmp -f _Package_tarball
      ${_M} && _Trace 'Create tar archive. (%s)' "${_Package_files[*]}"
      Action -f -q 'Create tar archive?' -i 'Creating tar archive.' "tar ${_Package_cmd} ${_Package_compression} -cf '${_Package_tarball}' \"\${_Package_files[@]}\""
      ${_M} && _Trace 'Created tar archive: %s' "${_Package_tarball}"

      ${_M} && _Trace 'Check if creating tar package. (%s)' "${_Package_tarp}"
      if ${_Package_tarp}
      then
        ${_M} && _Trace 'Create tar package: %s' "${_Package_package}"
        [[ -z "${_Package_header}" ]] && _Package_header="_CreatePackageHeader"
        Action -f -q "Create package header for ${_Package_package}?" "${_Package_header} -T -s '${_Package_srcdir}' -d '${_Package_desc}' ${_Package_extract} -I '${_Package_prep}' -i '${_Package_installer}' '${_Package_package}'"
        Action -q "Append tar archive to package ${_Package_package}?" "cat '${_Package_tarball}' >> '${_Package_package}'"
        _Package_rv=${?}
        ${_M} && _Trace 'Created tarp package: %s' "${_Package_package}"
      elif ${_Package_sharp}
      then
        ${_M} && _Trace 'Create shar package: %s' "${_Package_package}"
        local _Package_subdir
        GetTmp -s _Package_subdir
        pushd ${_Package_subdir} > /dev/null
        Action -f -q 'Unpack tar archive?' -i 'Unpacking tar archive.' "tar xf '${_Package_tarball}'"
        Action -f -q 'Remove tar archive?' "rm ${FMFLAGS} '${_Package_tarball}'"
        [[ -z "${_Package_header}" ]] && _Package_header="_CreatePackageHeader"
        Action -f -q "Create package header for ${_Package_package}?" "${_Package_header} -S -s '${_Package_srcdir}' -d '${_Package_desc}' ${_Package_extract} -I '${_Package_prep}' -i '${_Package_installer}' '${_Package_package}'"
        if [[ 'GNU' == "${UNIX}" ]]
        then
          Action -q "Create shar package archive for ${_Package_package}?" -i 'Creating shar archive.' "shar -q ${_Package_encoding} . >> '${_Package_package}'"
        else
          Action -q "Append shar archive to packge ${_Package_package}?" -i 'Creating shar archive.' "shar \$(find .) >> '${_Package_package}'"
        fi
        _Package_rv=${?}
        ${_M} && _Trace 'Created sharp package: %s' "${_Package_package}"
        popd > /dev/null
      elif ${_Package_starp}
      then
        ${_M} && _Trace 'Create star package: %s' "${_Package_package}"
        local _Package_subdir
        GetTmp -s _Package_subdir
        pushd ${_Package_subdir} > /dev/null
        Action -f -q 'Unpack tar archive?' -i 'Unpacking tar archive.' "tar xf '${_Package_tarball}'"
        Action -f -q 'Remove tar archive?' "rm ${FMFLAGS} '${_Package_tarball}'"
        [[ -z "${_Package_header}" ]] && _Package_header="_CreatePackageHeader"
        Action -f -q "Create package header for ${_Package_package}?" "${_Package_header} -P -s '${_Package_srcdir}' -d '${_Package_desc}' ${_Package_extract} -I '${_Package_prep}' -i '${_Package_installer}' '${_Package_package}'"
        Action -q "Append star archive to package ${Package_package}?" -i 'Creating star archive.' "star -c . >> '${_Package_package}'"
        _Package_rv=${?}
        ${_M} && _Trace 'Created starp package: %s' "${_Package_package}"
        popd > /dev/null
      else
        ${_M} && _Trace 'Rename tarball: %s' "${_Package_package}"
        Action -q 'Rename tar archive to package?' "mv ${FMFLAGS} '${_Package_tarball}' '${_Package_package}'"
      fi
    fi

    ${_M} && _Trace 'CreatePackage return. (%s)' "${_Package_rv}"
    return ${_Package_rv}
  fi
}

# ListPackage
#
# Syntax: ListPackage <package>
#
# Example: ListPackage package.tarp
#
# Result: Lists the files contained in the package.tarp package.
#
UICMD+=( 'ListPackage' )
ListPackage () { # <package>
  ${_S} && ((_cListPackage++))
  ${_M} && _Trace 'ListPackage [%s]' "${*}"

  local _Package_list

  ${_M} && _Trace 'Check package. (%s)' "${1}"
  [[ -f "${1}" ]] || Tell -E 'No package at path provided. (%s)' "${1}"

  ${_M} && _Trace 'Check for error.'
  if Error
  then
    ${_M} && _Trace 'ListPackage error return. (%s)' "${ERRV}"
    return ${ERRV}
  else
    ${_M} && _Trace 'Find payload. (%s)' "${1}"
    local _Package_ll=$(awk '/^__PAYLOAD__$/ { print NR + 1; exit 0; }' "${1}" 2> /dev/null)

    LoadMod File
    local _Package_package
    GetTmp -f _Package_package
    ${_M} && _Trace 'Extract package. (%s)' "${_Package_package}"
    Action -q 'Extract package?' "tail -n +${_Package_ll} '${1}' > '${_Package_package}'"

    if [[ ".sharp" == "${1: -6}" ]]
    then
      local _Package_subdir
      GetTmp -s _Package_subdir
      pushd "${_Package_subdir}" > /dev/null
      ${_M} && _Trace 'Extract shar. (%s)' "${_Package_subdir}"
      Action -q 'Extract shar.' -i 'Extracting shar.' "sh '${_Package_package}' > /dev/null"
      Action -q 'Remove shar?' "rm ${FMFLAGS} '${_Package_package}'"
      _Package_list=( $(ls -A | sed 's|^|./|') )
      popd - > /dev/null
    else
      _Package_list=( $(tar tf "${_Package_package}" | sed 's/^\.\///' | sed 's/\/$//'| grep -v '/') )
    fi

    ${_M} && _Trace 'Display file listing. (%s)' "${#_Package_list[@]}"
    printf 'Package Files:\n'
    printf '  %s\n' "${_Package_list[@]}"

    ${_M} && _Trace 'ListPackage return. (%s)' 0
    return 0
  fi
}

return 0
