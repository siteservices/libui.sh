#!/bin/zsh
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
# Man page available for this module: man 3 libuiPackage.sh
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

Version -r 1.829 -m 1.12

# defaults

# Create Self-Extracting Package Header
#
# Syntax: _CreatePackageHeader [-a -S -T] [-d <description>] [-e <environment_spec>] [-i <installer>] [-s <source_directory>] <package_filename>
#
# Example: _CreatePackageHeader -T -i '\${d}/path/to/installer' -a package.tarp
#
# Result: Creates a package.tarp package containing a tarp self-extracting header
# configured to execute "<tempdir>/path/to/installer $@ <archive>" when executed.
#
UICMD+=( '_CreatePackageHeader' )
_CreatePackageHeader () { # [-a -S -T] [-d <description>] [-e <environment_spec>] [-i <installer>] [-s <source_directory>] <package_filename>
  ${_S} && ((_c_CreatePackageHeader++))
  ${_M} && _Trace '_CreatePackageHeader [%s]' "${*}"

  local _Package_append=''
  local _Package_archive='tar'
  local _Package_desc
  local _Package_env
  local _Package_installer="./installer"
  local _Package_null
  local _Package_srcdir
  local _Package_unarchive='tar xf'

  ${_M} && _Trace 'Process _CreatePackageHeader options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':ad:e:i:s:ST' opt
  do
    case ${opt} in
      a)
        ${_M} && _Trace 'Append archive.'
        _Package_append=' "${a}"'
        ;;

      d)
        ${_M} && _Trace 'Description. (%s)' "${OPTARG}"
        _Package_desc="${OPTARG}"
        ;;

      e)
        ${_M} && _Trace 'Environment variables. (%s)' "${OPTARG}"
        _Package_env="${OPTARG}"
        ;;

      i)
        ${_M} && _Trace 'Installer path. (%s)' "${OPTARG}"
        _Package_installer="${OPTARG}"
        ;;

      s)
        ${_M} && _Trace 'Source directory. (%s)' "${OPTARG}"
        _Package_srcdir="${OPTARG}"
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
    ${_M} && _Trace 'Generate self-extracting package header. (%s)' "${1}"
(
cat <<EOF
#!/bin/zsh
#####
#
#	${_Package_desc} (${_Package_archive}p)
#	Created by: ${USER}@${HOST}.${DOMAIN}
#		on: $(date | sed 's/  / /g')
#
# use -e to extract archive file
#####
# find payload
l=\$(head -n 33 "\${0}" | tail -n 1) && [ '__PAYLOAD__' = "\${l}" ] || exit 1

# extract installer
t="\$(mktemp -d)" || exit 1
a="\${0##*/}"; a="\${t}/\${a%\\.*}.${_Package_archive}"
tail -n +34 "\${0}" > "\${a}"
[ "\${1}" = "-e" ] && mv "\${a}" ./ && rmdir "\${t}" && exit 0
d="\${t}/a"
mkdir "\${d}" || exit 1
cd "\${d}" > /dev/null
${_Package_unarchive} "\${a}" 2>&1 > /dev/null || exit 1
cd - > /dev/null

# run installer
sh="\${ZSH_NAME:t}"; sh=\${sh:-bash}
[ 0 -eq \${#} ] && set -- -h
${_Package_env:+${_Package_env} }\${sh} ${_Package_installer} \${@}${_Package_append}

# done
rm -rf "\${t}"
exit 0

${_Package_null}__PAYLOAD__
EOF
) > "${1}"

    ${_M} && _Trace '_CreatePackageHeader return. (%s)' 0
    return 0
  fi
}

# Create Self-Extracting Package Archive
#
# Syntax: CreatePackage [-a -l -S -T] [-c <compression>] [-d <description>] [-e <environment_spec>] [-f <filelist_array_var_name>] [-h <header_command>] [-i <installer>] [-n <encoding>] [-s <source_directory>] [-x <exclude_array_var_name>] <package_filename>
#
# Example: CreatePackage -f filelist -s ''/source/dir' package.tarp
#
# Result: Creates a package.tarp package containing the files in the filelist array from the /source/dir directory.
#
UICMD+=( 'CreatePackage' )
CreatePackage () { # [-a -l -S -T] [-c <compression>] [-d <description>] [-e <environment_spec>] [-f <filelist_array_var_name>] [-h <header_command>] [-i <installer>] [-n <encoding>] [-s <source_directory>] [-x <exclude_array_var_name>] <package_filename>
  ${_S} && ((_cCreatePackage++))
  ${_M} && _Trace 'CreatePackage [%s]' "${*}"

  local _Package_append
  local _Package_desc
  local _Package_env
  local _Package_excludes; _Package_excludes=( )
  local _Package_files; _Package_files=( '.' )
  local _Package_header
  local _Package_installer
  local _Package_list=false
  local _Package_encoding='-T'
  local _Package_sharp=false
  local _Package_tarp=true
  local _Package_compression='-j'

  ${_M} && _Trace 'Process CreatePackage options. (%s)' "${*}"
  local opt
  local OPTIND
  local OPTARG
  while getopts ':ac:d:e:f:h:i:ln:o:s:STx:' opt
  do
    case ${opt} in
      a)
        ${_M} && _Trace 'Append archive.'
        _Package_append='-a'
        ;;

      c)
        ${_M} && _Trace 'Compression. (%s)' "${OPTARG}"
        _Package_compression="${OPTARG}"; [[ "${_Package_compression:0:1}" == '-' ]] || \
            _Package_compression="${_Package_compression:+-${_Package_compression}}"
        ;;

      d)
        ${_M} && _Trace 'Description. (%s)' "${OPTARG}"
        _Package_desc="${OPTARG}"
        ;;

      e)
        ${_M} && _Trace 'Environment variable. (%s)' "${OPTARG}"
        _Package_env="${OPTARG}"
        ;;

      f)
        ${_M} && _Trace 'File list. (%s)' "${OPTARG}"
        ${ZSH} && _Package_files=( "${(P@)OPTARG}" ) || eval "_Package_files=( \"\${${OPTARG}[@]}\" )"
        ;;

      h)
        ${_M} && _Trace 'Header function / command name. (%s)' "${OPTARG}"
        _Package_header="${OPTARG}"
        ;;

      i)
        ${_M} && _Trace 'Installer file path. (%s)' "${OPTARG}"
        _Package_installer="${OPTARG}"
        ;;

      l)
        ${_M} && _Trace 'List files flag.'
        _Package_list=true
        ;;

      n)
        ${_M} && _Trace 'Encoding. (%s)' "${OPTARG}"
        _Package_encoding="${OPTARG}"; [[ "${_Package_encoding:0:1}" == '-' ]] || _Package_encoding="${_Package_encoding:+-${_Package_encoding}}"
        ;;

      s)
        ${_M} && _Trace 'Source directory. (%s)' "${OPTARG}"
        _Package_srcdir="${OPTARG}"
        ;;

      S)
        ${_M} && _Trace 'Make shar.'
        _Package_sharp=true
        _Package_tarp=false
        ;;

      T)
        ${_M} && _Trace 'Make tar.'
        _Package_sharp=false
        _Package_tarp=true
        ;;

      x)
        ${_M} && _Trace 'Exclude list. (%s)' "${OPTARG}"
        ${ZSH} && _Package_excludes=( "${(P@)OPTARG}" ) || eval "_Package_excludes=( \"\${${OPTARG}[@]}\" )"
        ;;

      *)
        Tell -E -f -L '(CreatePackage) Unknown option. (-%s)' "${OPTARG}"
        ;;

    esac
  done
  shift $((OPTIND - 1))
  ((1 != ${#})) && Tell -E -f -L '(CreatePackage) Invalid parameters. (%s)' "${*}"
  ${_Package_sharp} && ${_Package_tarp} && Tell -E -f -L '(CreatePackage) Choose only one package type. (-s or -t)'
  ${_Package_sharp} || ${_Package_tarp} || Tell -E -f -L '(CreatePackage) Please choose a package type. (-s or -t)'
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
    else
      [[ ".sharp" == "${_Package_package: -6}" ]] || _Package_package+='.sharp'
    fi
    if ! Force
    then
      ${_M} && _Trace 'Check for existing package. (%s)' "${_Package_package}"
      if [[ -e "${_Package_package}" ]]
      then
        ${_Package_list} || Tell -E 'The package already exists (%s). Use the force option (-F) to overwrite.' "${_Package_package}"
      fi
    fi

    ${_M} && _Trace 'Check for source directory. (%s)' "${_Package_srcdir}"
    if [[ -d ${_Package_srcdir} ]]
    then
      ${_M} && _Trace 'Change directory to source. (%s)' "${_Package_srcdir}"
      cd ${_Package_srcdir} > /dev/null
    else
      Tell -E 'The source directory does not exist. (%s)' "${_Package_srcdir}"
    fi

    ${_M} && _Trace 'Check if listing files. (%s)' "${_Package_list}"
    if ${_Package_list}
    then
      ${_M} && _Trace 'List files. (%s)' "${#_Package_files[@]}"
      local _Package_glob
      local _Package_exclude
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
          local _Package_file
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
        if [[ 0 -eq ${#_Package_glob[@]} || ! ${_Package_exclude} =~ .*/.* ]]
        then
          if ${ZSH}
          then
            _Package_excludes=( "${(@)_Package_excludes:#${_Package_exclude}}" )
          else
            _Package_excludes=( "${_Package_excludes[@]/${_Package_exclude}}" )
          fi
        fi
      done
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
      local _Package_rv
      if ${_Package_tarp}
      then
        ${_M} && _Trace 'Create tar package: %s' "${_Package_package}"
        [[ -z "${_Package_header}" ]] && _Package_header="_CreatePackageHeader"
        Action -f -q "Create tar package header ${_Package_package}?" "${_Package_header} -T -s ${_Package_srcdir} -d '${_Package_desc}' -e '${_Package_env}' -i '${_Package_installer}' ${_Package_append} '${_Package_package}'"
        Action -q 'Append tar archive to package?' "cat '${_Package_tarball}' >> '${_Package_package}'"
        _Package_rv=${?}
        ${_M} && _Trace 'Created tarp package: %s' "${_Package_package}"
      else
        ${_M} && _Trace 'Create shar package: %s' "${_Package_package}"
        local _Package_subdir
        GetTmp -s _Package_subdir
        cd ${_Package_subdir} > /dev/null
        Action -f -q 'Unpack tar archive?' -i 'Unpacking tar archive.' "tar xf '${_Package_tarball}'"
        Action -f -q 'Remove tar archive?' "rm ${FMFLAGS} '${_Package_tarball}'"
        [[ -z "${_Package_header}" ]] && _Package_header="_CreatePackageHeader"
        Action -f -q "Create shar package header ${_Package_package}?" "${_Package_header} -S -s ${_Package_srcdir} -d '${_Package_desc}' -e '${_Package_env}' -i '${_Package_installer}' ${_Package_append} '${_Package_package}'"
        if [[ 'Darwin' == "${OS}" ]]
        then
          Action -q 'Create shar archive?' -i 'Creating shar archive.' "shar \$(find .) >> '${_Package_package}'"
        else
          Action -q 'Create shar archive?' -i 'Creating shar archive.' "shar -q ${_Package_encoding} . >> '${_Package_package}'"
        fi
        _Package_rv=${?}
        ${_M} && _Trace 'Created sharp package: %s' "${_Package_package}"
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
      cd "${_Package_subdir}" > /dev/null
      ${_M} && _Trace 'Extract shar. (%s)' "${_Package_subdir}"
      Action -q 'Extract shar.' -i 'Extracting shar.' "sh '${_Package_package}' > /dev/null"
      Action -q 'Remove shar?' "rm ${FMFLAGS} '${_Package_package}'"
      _Package_list=( $(ls -A | sed 's|^|./|') )
      cd - > /dev/null
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
