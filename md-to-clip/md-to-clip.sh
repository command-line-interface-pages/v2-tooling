#!/usr/bin/env bash

# shellcheck disable=2016,2155,2181,1087,2120

declare -i SUCCESS=0
declare -i FAIL=1

declare PROGRAM_NAME="$(basename "$0")"

# Options
declare output_directory
declare special_placeholder_config="$HOME/.md-to-clip.yaml"
declare -i no_file_save=1

color_to_code() {
  declare color="$1"

  case "$color" in
  red)
    echo -n 31
    ;;
  green)
    echo -n 32
    ;;
  yellow)
    echo -n 33
    ;;
  blue)
    echo -n 34
    ;;
  magenta)
    echo -n 35
    ;;
  cyan)
    echo -n 36
    ;;
  light-gray)
    echo -n 37
    ;;
  gray)
    echo -n 90
    ;;
  light-red)
    echo -n 91
    ;;
  light-green)
    echo -n 92
    ;;
  light-yellow)
    echo -n 93
    ;;
  light-blue)
    echo -n 94
    ;;
  light-magenta)
    echo -n 95
    ;;
  light-cyan)
    echo -n 96
    ;;
  white)
    echo -n 97
    ;;
  *)
    echo -n 0
    ;;
  esac
}

# Error colors:
declare RESET_COLOR="\e[$(color_to_code none)m"
declare ERROR_COLOR="\e[$(color_to_code red)m"
declare SUCCESS_COLOR="\e[$(color_to_code green)m"

print_message() {
  declare source="$1"
  declare message="$2"

  echo -e "$PROGRAM_NAME: $source: ${SUCCESS_COLOR}$message$RESET_COLOR" >&2
}

throw_error() {
  declare source="$1"
  declare message="$2"

  echo -e "$PROGRAM_NAME: $source: ${ERROR_COLOR}$message$RESET_COLOR" >&2
  exit "$FAIL"
}

help() {
  export LESS_TERMCAP_mb=$'\e[1;32m'
  export LESS_TERMCAP_md=$'\e[1;32m'
  export LESS_TERMCAP_me=$'\e[0m'
  export LESS_TERMCAP_se=$'\e[0m'
  export LESS_TERMCAP_so=$'\e[01;33m'
  export LESS_TERMCAP_ue=$'\e[0m'
  export LESS_TERMCAP_us=$'\e[1;4;31m'
  man "$PROGRAM_NAME"
}

version() {
  echo "2.17.0" >&2
}

author() {
  echo "Emily Grace Seville" >&2
}

email() {
  echo "EmilySeville7cfg@gmail.com" >&2
}

throw_if_dependencies_are_not_satisfied() {
  which sed >/dev/null || throw_error "sed" "installed command expected"
}

check_layout_correctness() {
  declare content="$1"$'\n\n'

  sed -nE ':x
    N
    $! bx
    /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$content"
}

check_page_is_alias() {
  declare content="$1"$'\n\n'

  ! sed -nE '/^- View documentation for the original command:$/ Q1' <<<"$content"
}

check_page_has_more_information_tag() {
  declare content="$1"$'\n\n'

  ! sed -nE '/^> More information:/ Q1' <<<"$content"
}

convert_summary() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  in_file_content="$(sed -E '/^>/ {
    s/\.$//
    s/More +information: <(.*)>$/More information: \1/

    /See +also/ {
      s/,? +or +/, /g
      s/,,+/,/g
      s/`//g
    }
  }' <<<"$in_file_content")"
  
  if check_page_has_more_information_tag "$in_file_content"; then
    in_file_content="$(sed -E ':x
      N
      $! bx
      s/\n(> More information: [^\n]+)(\n.+)\n\n- (Show|Display|Print)( a| the)? help:\n\n`[^ \n]+ (--help|-h|-\?)`/\n> Help: \5\n\1\2/
      s/\n(> More information: [^\n]+)(\n.+)\n\n- (Show|Display|Print)( a| the)? version:\n\n`[^ \n]+ (--version|-v)`/\n> Version: \5\n\1\2/' <<<"$in_file_content")"
  fi

  echo "$in_file_content"
}

convert_code_descriptions() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^-/ {
    s/`(std(in|out|err))`/\1/g
    s/standard +input( +stream)?/stdin/g
    s/standard +output( +stream)?/stdout/g
    s/standard +error( +stream)?/stderr/g

    s/\<(a|the) +(given|specified)\>/a specific/g
  }' <<<"$in_file_content"
}

convert_code_examples_remove_broken_ellipsis() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    s/ *\{\{\.\.\.\}\} */ /g
  }' <<<"$in_file_content"
}

convert_code_examples_expand_plural_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    s|\{\{([^{}]+)(\(s\)\|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})\}\}|{{\11 \12 ...}}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_special_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  declare input_placeholder=
  declare input_allow_prefix=false
  declare -i input_index=0
  declare output_type=
  declare output_description=
  declare suffix=value
  shift
  while [[ -n "$1" ]]; do
    declare option="$1"

    case "$option" in
    --in-placeholder | -ip)
      input_placeholder="$2"
      shift 2
      ;;
    --in-allow-prefix | -iap)
      input_allow_prefix=true
      shift
      ;;
    --in-index | -ii)
      input_index="$2"
      shift 2
      ;;
    --out-type | -ot)
      output_type="$2"
      shift 2
      ;;
    --out-description | -od)
      output_description="$2"
      shift 2
      ;;
    --out-is-name | -oin)
      suffix=name
      shift
      ;;
    *)
      throw_error "$option" "valid option expected"
      ;;
    esac
  done

  [[ -z "$input_placeholder" ]] && return "$FAIL"
  [[ -z "$output_type" ]] && return "$FAIL"
  [[ -z "$output_description" ]] && output_description="$input_placeholder"
  declare input_placeholder_initial="$input_placeholder"

  declare -i group_multiplier=0
  ((input_index > 0)) && {
    input_placeholder="${input_placeholder:0:input_index}(${input_placeholder:input_index})?"
    group_multiplier=1
  }

  if [[ "$input_allow_prefix" == true ]]; then
    sed -E "/^\`/ {
      # Expansion
      ## General cases
      s|\{\{(${input_placeholder}s\|${input_placeholder}_*${suffix}s)[[:digit:]]*\}\}|{{${input_placeholder}1 ${input_placeholder}2 ...}}|g
      s|\{\{${input_placeholder}(_*${suffix})?([[:digit:]]*)\}\}|{{${input_placeholder}\\$((2 + group_multiplier))}}|g
      s|\{\{${input_placeholder}(_*${suffix})?[[:digit:]]* +${input_placeholder}(_*${suffix})?[[:digit:]]* +\.\.\.\}\}|{{${input_placeholder}1 ${input_placeholder}2 ...}}|g

      ## Cases with prefix like positive_integers
      s|\{\{([^{}_ ]+)_+(${input_placeholder}s\|${input_placeholder}_*${suffix}s)[[:digit:]]*\}\}|{{\1_${input_placeholder}1 \1_${input_placeholder}2 ...}}|g
      s|\{\{([^{}_ ]+)_+${input_placeholder}(_*${suffix})?([[:digit:]]*)\}\}|{{\1_${input_placeholder}\\$((3 + group_multiplier))}}|g
      s|\{\{([^{}_ ]+)_+${input_placeholder}(_*${suffix})?[[:digit:]]* +\1_+${input_placeholder}(_*${suffix})?[[:digit:]]* +\.\.\.\}\}|{{\1_${input_placeholder}1 \1_${input_placeholder}2 ...}}|g

      # Conversion
      ## General cases
      s|\{\{${input_placeholder}\}\}|{${output_type} ${output_description}}|g
      s|\{\{${input_placeholder}([[:digit:]])\}\}|{${output_type} ${output_description} \1}|g
      s|\{\{${input_placeholder}[[:digit:]]* +${input_placeholder}[[:digit:]]* +\.\.\.\}\}|{${output_type}* ${output_description}}|g

      ## Cases with prefix like positive_integers
      s|\{\{([^{}_ ]+)_+${input_placeholder}\}\}|{${output_type} \1 ${output_description}}|g
      s|\{\{([^{}_ ]+)_+${input_placeholder}([[:digit:]])\}\}|{${output_type} \1 ${output_description} \2}|g
      s|\{\{([^{}_ ]+)_+${input_placeholder}[[:digit:]]* +\1_+${input_placeholder}[[:digit:]]* +\.\.\.\}\}|{${output_type}* \1 ${output_description}}|g
    }" <<<"$in_file_content"
  else
    sed -E "/^\`/ {
      # Expansion
      s|\{\{(${input_placeholder}s\|${input_placeholder}_*${suffix}s)[[:digit:]]*\}\}|{{${input_placeholder_initial}1 ${input_placeholder_initial}2 ...}}|g
      s|\{\{${input_placeholder}(_*${suffix})?([[:digit:]]*)\}\}|{{${input_placeholder_initial}\\$((2 + group_multiplier))}}|g
      s|\{\{${input_placeholder}(_*${suffix})?[[:digit:]]* +${input_placeholder}(_*${suffix})?[[:digit:]]* +\.\.\.\}\}|{{${input_placeholder_initial}1 ${input_placeholder_initial}2 ...}}|g

      # Conversion
      s|\{\{${input_placeholder}\}\}|{${output_type} ${output_description}}|g
      s|\{\{${input_placeholder}([[:digit:]]+)\}\}|{${output_type} ${output_description} \1}|g
      s|\{\{${input_placeholder}[[:digit:]]* +${input_placeholder}[[:digit:]]* +\.\.\.\}\}|{${output_type}* ${output_description}}|g
    }" <<<"$in_file_content"
  fi
}

convert_code_examples_convert_integer_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(int(eger)?s\|int(eger)?_*values)[[:digit:]]*\}\}|{{integer1 integer2 ...}}|g
    s|\{\{int(eger)?(_*value)?([[:digit:]]*)\}\}|{{integer\3}}|g
    s|\{\{int(eger)?(_*value)?[[:digit:]]* +int(eger)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{integer1 integer2 ...}}|g

    ## Cases with prefix like positive_integer
    s|\{\{([^{}_ ]+)_+(int(eger)?s\|int(eger)?_*values)[[:digit:]]*\}\}|{{\1_integer1 \1_integer2 ...}}|g
    s|\{\{([^{}_ ]+)_+int(eger)?(_*value)?([[:digit:]]*)\}\}|{{\1_integer\4}}|g
    s|\{\{([^{}_ ]+)_+int(eger)?(_*value)?[[:digit:]]* +\1_+int(eger)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_integer1 \1_integer2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{integer\}\}|{int integer}|g
    s|\{\{integer([[:digit:]]+)\}\}|{int integer \1}|g
    s|\{\{integer[[:digit:]]* +integer[[:digit:]]* +\.\.\.\}\}|{int* integer}|g
    s|\{\{([-+]?[[:digit:]]+)\}\}|{int integer: \1}|g

    ## Cases with prefix like positive_integer
    s|\{\{([^{}_ ]+)_+integer\}\}|{int \1 integer}|g
    s|\{\{([^{}_ ]+)_+integer([[:digit:]]+)\}\}|{int \1 integer \2}|g
    s|\{\{([^{}_ ]+)_+integer[[:digit:]]* +\1_+integer[[:digit:]]* +\.\.\.\}\}|{int* \1 integer}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_float_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(float?s\|float?_*values)[[:digit:]]*\}\}|{{float1 float2 ...}}|g
    s|\{\{float?(_*value)?([[:digit:]]*)\}\}|{{float\2}}|g
    s|\{\{float?(_*value)?[[:digit:]]* +float?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{float1 float2 ...}}|g

    ## Cases with prefix like positive_float
    s|\{\{([^{}_ ]+)_+(float?s\|float?_*values)[[:digit:]]*\}\}|{{\1_float1 \1_float2 ...}}|g
    s|\{\{([^{}_ ]+)_+float?(_*value)?([[:digit:]]*)\}\}|{{\1_float\3}}|g
    s|\{\{([^{}_ ]+)_+float?(_*value)?[[:digit:]]* +\1_+float?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_float1 \1_float2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{float\}\}|{float float}|g
    s|\{\{float([[:digit:]]+)\}\}|{float float \1}|g
    s|\{\{float[[:digit:]]* +float[[:digit:]]* +\.\.\.\}\}|{float* float}|g
    s|\{\{([-+]?[[:digit:]]+[.,][[:digit:]]+)\}\}|{float float: \1}|g

    ## Cases with prefix like positive_float
    s|\{\{([^{}_ ]+)_+float\}\}|{float \1 float}|g
    s|\{\{([^{}_ ]+)_+float([[:digit:]]+)\}\}|{float \1 float \2}|g
    s|\{\{([^{}_ ]+)_+float[[:digit:]]* +\1_+float[[:digit:]]* +\.\.\.\}\}|{float* \1 float}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_option_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # Expansion
    s|\{\{(options\|option_*names)[[:digit:]]*\}\}|{{option1 option2 ...}}|g
    s|\{\{option(_*name)?([[:digit:]]*)\}\}|{{option\2}}|g
    s|\{\{option(_*name)?[[:digit:]]* +option(_*name)?[[:digit:]]* +\.\.\.\}\}|{{option1 option2 ...}}|g

    # Conversion
    s|\{\{option\}\}|{string option}|g
    s|\{\{option([[:digit:]]+)\}\}|{string option \1}|g
    s|\{\{option[[:digit:]]* +option[[:digit:]]* +\.\.\.\}\}|{string* option}|g
    s|\{\{(--?[^{}=: ]+)\}\}|{string option: \1}|g
    s|\{\{(--?[^{}=: ]+(([:=]\| +)[^{} ]*)?( +--?[^{}=: ]+(([:=]\| +)[^{} ]*)?)+)\}\}|{string* option: \1}|g
    s|\{\{(--?[^{}=: ]+)([:=]\| +)[^{} ]*\}\}|{string option: \1}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_device_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(\/?)(path/to/\|dev/)?device(_*name)?([[:digit:]]*)\}\}|{{\1device\4}}|g
    s|\{\{(\/?)(path/to/\|dev/)?(devices\|device_*names)[[:digit:]]*\}\}|{{\1device1 \1device2 ...}}|g
    s|\{\{(\/?)(path/to/\|dev/)?device(_*name)?[[:digit:]]* +\1(path/to/\|dev/)?device(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1device1 \1device2 ...}}|g

    ## Cases with prefix like drive_device
    s|\{\{(\/?)(path/to/\|dev/)?([^{}_/ ]+)_+device(_*name)?([[:digit:]]*)\}\}|{{\1\3_device\5}}|g
    s|\{\{(\/?)(path/to/\|dev/)?([^{}_/ ]+)_+(devices\|device_*names)[[:digit:]]*\}\}|{{\1\3_device1 \1\3_device2 ...}}|g
    s|\{\{(\/?)(path/to/\|dev/)?([^{}_/ ]+)_+device(_*name)?[[:digit:]]* +\1(path/to/\|dev/)?\3_+device(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1\3_device1 \1\3_device2 ...}}|g

    # Conversion
    s|\{\{(\/?)(device\|dev/sd[[:alpha:]])\}\}|{\1file device}|g
    s|\{\{(\/?)(device\|dev/sd[[:alpha:]])([[:digit:]]+)\}\}|{\1file device \3}|g
    s|\{\{(\/?)(device\|dev/sd[[:alpha:]])[[:digit:]]* +\1(device\|dev/sd[[:alpha:]])[[:digit:]]* +\.\.\.\}\}|{\1file* device}|g

    ## Cases with prefix like drive_device
    s|\{\{(\/?)([^{}_ ]+)_+device\}\}|{\1file \2 device}|g
    s|\{\{(\/?)([^{}_ ]+)_+device([[:digit:]]+)\}\}|{\1file \2 device \3}|g
    s|\{\{(\/?)([^{}_ ]+)_+device[[:digit:]]* +\1\2_+device[[:digit:]]* +\.\.\.\}\}|{\1file* \2 device}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_path_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # --- Windows ---
    # Expansion
    ## General cases
    s|\{\{(\\?)(path\\to\\)?(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path\\to\\file_or_directory1 \1path\\to\\file_or_directory2 ...}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path\\to\\file_or_directory\6}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path\\to\\)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path\\to\\file_or_directory1 \1path\\to\\file_or_directory2 ...}}|g

    ## Cases with prefix like excluded_path_or_directory
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path\\to\\\3_file_or_directory1 \1path\\to\\\3_file_or_directory2 ...}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path\\to\\\3_file_or_directory\7}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path\\to\\)?\3_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path\\to\\\3_file_or_directory1 \1path\\to\\\3_file_or_directory2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{path\\to\\file_or_directory\}\}|{path file or directory}|g
    s|\{\{\\path\\to\\file_or_directory\}\}|{/path file or directory}|g
    s|\{\{path\\to\\file_or_directory([[:digit:]]+)\}\}|{path file or directory \1}|g
    s|\{\{\\path\\to\\file_or_directory([[:digit:]]+)\}\}|{/path file or directory \1}|g
    s|\{\{path\\to\\file_or_directory[[:digit:]]* +path\\to\\file_or_directory[[:digit:]]* +\.\.\.\}\}|{path* file or directory}|g
    s|\{\{\\path\\to\\file_or_directory[[:digit:]]* +\\path\\to\\file_or_directory[[:digit:]]* +\.\.\.\}\}|{/path* file or directory}|g

    ## Cases with prefix like excluded_path_or_directory
    s|\{\{path\\to\\([^{}_ /]+)_+file_or_directory\}\}|{path \1 file or directory}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file_or_directory\}\}|{/path \1 file or directory}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file_or_directory([[:digit:]]+)\}\}|{path \1 file or directory \2}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file_or_directory([[:digit:]]+)\}\}|{/path \1 file or directory \2}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file_or_directory[[:digit:]]* +path\\to\\\1_+file_or_directory[[:digit:]]* +\.\.\.\}\}|{path* \1 file or directory}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file_or_directory[[:digit:]]* +\\path\\to\\\1_+file_or_directory[[:digit:]]* +\.\.\.\}\}|{/path* \1 file or directory}|g

    # --- Linux & Mac OS ---
    # Expansion
    ## General cases
    s|\{\{(/?)(path/to/)?(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/file_or_directory1 \1path/to/file_or_directory2 ...}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/file_or_directory\6}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/file_or_directory1 \1path/to/file_or_directory2 ...}}|g

    ## Cases with prefix like excluded_path_or_directory
    s|\{\{(/?)(path/to/)?([^{}_ /]+)_+(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file_or_directory1 \1path/to/\3_file_or_directory2 ...}}|g
    s|\{\{(/?)(path/to/)?([^{}_ /]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file_or_directory\7}}|g
    s|\{\{(/?)(path/to/)?([^{}_ /]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file_or_directory1 \1path/to/\3_file_or_directory2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{(/?)path/to/file_or_directory\}\}|{\1path file or directory}|g
    s|\{\{(/?)path/to/file_or_directory([[:digit:]]+)\}\}|{\1path file or directory \2}|g
    s|\{\{(/?)path/to/file_or_directory[[:digit:]]* +\1path/to/file_or_directory[[:digit:]]* +\.\.\.\}\}|{\1path* file or directory}|g

    ## Cases with prefix like excluded_path_or_directory
    s|\{\{(/?)path/to/([^{}_ /]+)_+file_or_directory\}\}|{\1path \2 file or directory}|g
    s|\{\{(/?)path/to/([^{}_ /]+)_+file_or_directory([[:digit:]]+)\}\}|{\1path \2 file or directory \3}|g
    s|\{\{(/?)path/to/([^{}_ /]+)_+file_or_directory[[:digit:]]* +\1path/to/\2_+file_or_directory[[:digit:]]* +\.\.\.\}\}|{\1path* \2 file or directory}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_file_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # --- Windows ---
    # Expansion
    ## General cases
    s|\{\{(\\?)(path\\to\\)?(files\|file_*names)[[:digit:]]*\}\}|{{\1path\\to\\file1 \1path\\to\\file2 ...}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?([[:digit:]]*)\}\}|{{\1path\\to\\file\4}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?[[:digit:]]* +\1(path\\to\\)?file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path\\to\\file1 \1path\\to\\file2 ...}}|g

    ## Cases with prefix like excluded_file
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+(files\|file_*names)[[:digit:]]*\}\}|{{\1path\\to\\\3_file1 \1path\\to\\\3_file2 ...}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?([[:digit:]]*)\}\}|{{\1path\\to\\\3_file\5}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?[[:digit:]]* +\1(path\\to\\)?\3_+file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path\\to\\\3_file1 \1path\\to\\\3_file2 ...}}|g

    ## Cases with optional extensions
    s|\{\{(\\?)(path\\to\\)?(files\|file_*names)[[:digit:]]*\[(\.([^{}]\| ])+)\]\}\}|{{\1path\\to\\file1[\4] \1path\\to\\file2[\4] ...}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?([[:digit:]]*)\[(\.([^{}]\| ])+)\]\}\}|{{\1path\\to\\file\4[\5]}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?[[:digit:]]*\[(\.([^{}]\| ])+)\] +\1(path\\to\\)?file(_*name)?[[:digit:]]*\[\4\] +\.\.\.\}\}|{{\1path\\to\\file1[\4] \1path\\to\\file2[\4] ...}}|g

    ## Cases with mandatory extension
    s|\{\{(\\?)(path\\to\\)?(files\|file_*names)[[:digit:]]*(\.([^{}]\| ])+)\}\}|{{\1path\\to\\file1\4 \1path\\to\\file2\4 ...}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?([[:digit:]]*)(\.([^{}]\| ])+)\}\}|{{\1path\\to\\file\4\5}}|g
    s|\{\{(\\?)(path\\to\\)?file(_*name)?[[:digit:]]*(\.([^{}]\| ])+) +\1(path\\to\\)?file(_*name)?[[:digit:]]*\4 +\.\.\.\}\}|{{\1path\\to\\file1\4 \1path\\to\\file2\4 ...}}|g

    ## Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+(files\|file_*names)[[:digit:]]*\[(\.([^{}]\| ])+)\]\}\}|{{\1path\\to\\\3_file1[\5] \1path\\to\\\3_file2[\5] ...}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?([[:digit:]]*)\[(\.([^{}]\| ])+)\]\}\}|{{\1path\\to\\\3_file\5[\6]}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?[[:digit:]]*\[(\.([^{}]\| ])+)\] +\1(path\\to\\)?\3_+file(_*name)?[[:digit:]]*\[\5\] +\.\.\.\}\}|{{\1path\\to\\\3_file1[\5] \1path\\to\\\3_file2[\5] ...}}|g

    ## Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+(files\|file_*names)[[:digit:]]*(\.([^{}]\| ])+)\}\}|{{\1path\\to\\\3_file1\5 \1path\\to\\\3_file2\5 ...}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?([[:digit:]]*)(\.([^{}]\| ])+)\}\}|{{\1path\\to\\\3_file\5\6}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+file(_*name)?[[:digit:]]*(\.([^{}]\| ])+) +\1(path\\to\\)?\3_+file(_*name)?[[:digit:]]*\5 +\.\.\.\}\}|{{\1path\\to\\\3_file1\5 \1path\\to\\\3_file2\5 ...}}|g

    # Conversion
    ## General cases
    s|\{\{path\\to\\file\}\}|{file file}|g
    s|\{\{\\path\\to\\file\}\}|{/file file}|g
    s|\{\{path\\to\\file([[:digit:]]+)\}\}|{file file \1}|g
    s|\{\{\\path\\to\\file([[:digit:]]+)\}\}|{/file file \1}|g
    s|\{\{path\\to\\file[[:digit:]]* +path\\to\\file[[:digit:]]* +\.\.\.\}\}|{file* file}|g
    s|\{\{\\path\\to\\file[[:digit:]]* +\\path\\to\\file[[:digit:]]* +\.\.\.\}\}|{/file* file}|g

    ## Cases with prefix like excluded_file
    s|\{\{path\\to\\([^{}_ /]+)_+file\}\}|{file \1 file}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file\}\}|{/file \1 file}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file([[:digit:]]+)\}\}|{file \1 file \2}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file([[:digit:]]+)\}\}|{/file \1 file \2}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file[[:digit:]]* +path\\to\\\1_+file[[:digit:]]* +\.\.\.\}\}|{file* \1 file}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file[[:digit:]]* +\\path\\to\\\1_+file[[:digit:]]* +\.\.\.\}\}|{/file* \1 file}|g

    ## Cases with optional extensions
    s|\{\{path\\to\\file\[(\.([^{}]\| ])+)\]\}\}|{file file with optional \1 extensions}|g
    s|\{\{\\path\\to\\file\[(\.([^{}]\| ])+)\]\}\}|{/file file with optional \1 extensions}|g
    s|\{\{path\\to\\file([[:digit:]]+)\[(\.([^{}]\| ])+)\]\}\}|{file file \1 with optional \2 extensions}|g
    s|\{\{\\path\\to\\file([[:digit:]]+)\[(\.([^{}]\| ])+)\]\}\}|{/file file \1 with optional \2 extensions}|g
    s|\{\{path\\to\\file[[:digit:]]*\[(\.([^{}]\| ])+)\] +path\\to\\file[[:digit:]]*\[\1\] +\.\.\.\}\}|{file* file with optional \1 extensions}|g
    s|\{\{\\path\\to\\file[[:digit:]]*\[(\.([^{}]\| ])+)\] +\\path\\to\\file[[:digit:]]*\[\1\] +\.\.\.\}\}|{/file* file with optional \1 extensions}|g

    ## Cases with mandatory extension
    s|\{\{path\\to\\file\((\.([^{}]\| ])+)\)\}\}|{file file with mandatory \1 extensions}|g
    s|\{\{\\path\\to\\file\((\.([^{}]\| ])+)\)\}\}|{/file file with mandatory \1 extensions}|g
    s|\{\{path\\to\\file([[:digit:]]+)\((\.([^{}]\| ])+)\)\}\}|{file file \1 with mandatory \2 extensions}|g
    s|\{\{\\path\\to\\file([[:digit:]]+)\((\.([^{}]\| ])+)\)\}\}|{/file file \1 with mandatory \2 extensions}|g
    s|\{\{path\\to\\file[[:digit:]]*\((\.([^{}]\| ])+)\) +path\\to\\+file[[:digit:]]*\(\1\) +\.\.\.\}\}|{file* file with mandatory \1 extensions}|g
    s|\{\{\\path\\to\\file[[:digit:]]*\((\.([^{}]\| ])+)\) +\\path\\to\\+file[[:digit:]]*\(\1\) +\.\.\.\}\}|{/file* file with mandatory \1 extensions}|g

    ## Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{path\\to\\([^{}_ /]+)_+file\[(\.([^{}]\| ])+)\]\}\}|{file \1 file with optional \2 extensions}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file\[(\.([^{}]\| ])+)\]\}\}|{/file \1 file with optional \2 extensions}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file([[:digit:]]+)\[(\.([^{}]\| ])+)\]\}\}|{file \1 file \2 with optional \3 extensions}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file([[:digit:]]+)\[(\.([^{}]\| ])+)\]\}\}|{/file \1 file \2 with optional \3 extensions}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file[[:digit:]]*\[(\.([^{}]\| ])+)\] +path\\to\\\1_+file[[:digit:]]*\[\2\] +\.\.\.\}\}|{file* \1 file with optional \2 extensions}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file[[:digit:]]*\[(\.([^{}]\| ])+)\] +\\path\\to\\\1_+file[[:digit:]]*\[\2\] +\.\.\.\}\}|{/file* \1 file with optional \2 extensions}|g

    ## Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{path\\to\\([^{}_ /]+)_+file\((\.([^{}]\| ])+)\)\}\}|{file \1 file with mandatory \2 extensions}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file\((\.([^{}]\| ])+)\)\}\}|{/file \1 file with mandatory \2 extensions}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file([[:digit:]]+)\((\.([^{}]\| ])+)\)\}\}|{file \1 file \2 with mandatory \3 extensions}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file([[:digit:]]+)\((\.([^{}]\| ])+)\)\}\}|{/file \1 file \2 with mandatory \3 extensions}|g
    s|\{\{path\\to\\([^{}_ /]+)_+file[[:digit:]]*\((\.([^{}]\| ])+)\) +path\\to\\\1_+file[[:digit:]]*\(\2\) +\.\.\.\}\}|{file* \1 file with mandatory \2 extensions}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+file[[:digit:]]*\((\.([^{}]\| ])+)\) +\\path\\to\\\1_+file[[:digit:]]*\(\2\) +\.\.\.\}\}|{/file* \1 file with mandatory \2 extensions}|g

    # --- Linux & Mac OS ---
    # Expansion
    ## General cases
    s|\{\{(/?)(path/to/)?(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/file1 \1path/to/file2 ...}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/file\4}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?[[:digit:]]* +\1(path/to/)?file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/file1 \1path/to/file2 ...}}|g

    ## Cases with prefix like excluded_file
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file\5}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g

    ## Cases with optional extensions
    s|\{\{(/?)(path/to/)?(files\|file_*names)[[:digit:]]*\[(\.([^{}]\| ])+)\]\}\}|{{\1path/to/file1[\4] \1path/to/file2[\4] ...}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?([[:digit:]]*)\[(\.([^{}]\| ])+)\]\}\}|{{\1path/to/file\4[\5]}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?[[:digit:]]*\[(\.([^{}]\| ])+)\] +\1(path/to/)?file(_*name)?[[:digit:]]*\[\4\] +\.\.\.\}\}|{{\1path/to/file1[\4] \1path/to/file2[\4] ...}}|g

    ## Cases with mandatory extension
    s|\{\{(/?)(path/to/)?(files\|file_*names)[[:digit:]]*(\.([^{}]\| ])+)\}\}|{{\1path/to/file1\4 \1path/to/file2\4 ...}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?([[:digit:]]*)(\.([^{}]\| ])+)\}\}|{{\1path/to/file\4\5}}|g
    s|\{\{(/?)(path/to/)?file(_*name)?[[:digit:]]*(\.([^{}]\| ])+) +\1(path/to/)?file(_*name)?[[:digit:]]*\4 +\.\.\.\}\}|{{\1path/to/file1\4 \1path/to/file2\4 ...}}|g

    ## Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\[(\.([^{}]\| ])+)\]\}\}|{{\1path/to/\3_file1[\5] \1path/to/\3_file2[\5] ...}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\[(\.([^{}]\| ])+)\]\}\}|{{\1path/to/\3_file\5[\6]}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]*\[(\.([^{}]\| ])+)\] +\1(path/to/)?\3_+file(_*name)?[[:digit:]]*\[\5\] +\.\.\.\}\}|{{\1path/to/\3_file1[\5] \1path/to/\3_file2[\5] ...}}|g

    ## Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*(\.([^{}]\| ])+)\}\}|{{\1path/to/\3_file1\5 \1path/to/\3_file2\5 ...}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)(\.([^{}]\| ])+)\}\}|{{\1path/to/\3_file\5\6}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]*(\.([^{}]\| ])+) +\1(path/to/)?\3_+file(_*name)?[[:digit:]]*\5 +\.\.\.\}\}|{{\1path/to/\3_file1\5 \1path/to/\3_file2\5 ...}}|g

    # Conversion
    ## General cases
    s|\{\{(/?)path/to/file\}\}|{\1file file}|g
    s|\{\{(/?)path/to/file([[:digit:]]+)\}\}|{\1file file \2}|g
    s|\{\{(/?)path/to/file[[:digit:]]* +\1path/to/file[[:digit:]]* +\.\.\.\}\}|{\1file* file}|g

    ## Cases with prefix like excluded_file
    s|\{\{(/?)path/to/([^{}_ ]+)_+file\}\}|{\1file \2 file}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)\}\}|{\1file \2 file \3}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+file[[:digit:]]* +\1path/to/\2_+file[[:digit:]]* +\.\.\.\}\}|{\1file* \2 file}|g

    ## Cases with optional extensions
    s|\{\{(/?)path/to/file\[(\.([^{}]\| ])+)\]\}\}|{\1file file with optional \2 extensions}|g
    s|\{\{(/?)path/to/file([[:digit:]]+)\[(\.([^{}]\| ])+)\]\}\}|{\1file file \2 with optional \3 extensions}|g
    s|\{\{(/?)path/to/file[[:digit:]]*\[(\.([^{}]\| ])+)\] +\1path/to/file[[:digit:]]*\[\2\] +\.\.\.\}\}|{\1file* file with optional \2 extensions}|g

    ## Cases with mandatory extension
    s|\{\{(/?)path/to/file\((\.([^{}]\| ])+)\)\}\}|{\1file file with mandatory \2 extensions}|g
    s|\{\{(/?)path/to/file([[:digit:]]+)\((\.([^{}]\| ])+)\)\}\}|{\1file file \2 with mandatory \3 extensions}|g
    s|\{\{(/?)path/to/file[[:digit:]]*\((\.([^{}]\| ])+)\) +\1path/to/+file[[:digit:]]*\(\2\) +\.\.\.\}\}|{\1file* file with mandatory \2 extensions}|g

    ## Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{(/?)path/to/([^{}_ ]+)_+file\[(\.([^{}]\| ])+)\]\}\}|{\1file \2 file with optional \3 extensions}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)\[(\.([^{}]\| ])+)\]\}\}|{\1file \2 file \3 with optional \4 extensions}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+file[[:digit:]]*\[(\.([^{}]\| ])+)\] +\1path/to/\2_+file[[:digit:]]*\[\3\] +\.\.\.\}\}|{\1file* \2 file with optional \3 extensions}|g

    ## Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{(/?)path/to/([^{}_ ]+)_+file\((\.([^{}]\| ])+)\)\}\}|{\1file \2 file with mandatory \3 extensions}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)\((\.([^{}]\| ])+)\)\}\}|{\1file \2 file \3 with mandatory \4 extensions}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+file[[:digit:]]*\((\.([^{}]\| ])+)\) +\1path/to/\2_+file[[:digit:]]*\(\3\) +\.\.\.\}\}|{\1file* \2 file with mandatory \3 extensions}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_directory_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # --- Windows ---
    # Expansion
    ## General cases
    s|\{\{(\\?)(path\\to\\)?(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path\\to\\directory1 \1path\\to\\directory2 ...}}|g
    s|\{\{(\\?)(path\\to\\)?dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path\\to\\directory\5}}|g
    s|\{\{(\\?)(path\\to\\)?dir(ectory)?(_*name)?[[:digit:]]* +\1(path\\to\\)?dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path\\to\\directory1 \1path\\to\\directory2 ...}}|g

    ## Cases with prefix like excluded_directory
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path\\to\\\3_directory1 \1path\\to\\\3_directory2 ...}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path\\to\\\3_directory\6}}|g
    s|\{\{(\\?)(path\\to\\)?([^{}_ /]+)_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path\\to\\)?\3_dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path\\to\\\3_directory1 \1path\\to\\\3_directory2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{path\\to\\directory\}\}|{directory directory}|g
    s|\{\{\\path\\to\\directory\}\}|{/directory directory}|g
    s|\{\{path\\to\\directory([[:digit:]]+)\}\}|{directory directory \1}|g
    s|\{\{\\path\\to\\directory([[:digit:]]+)\}\}|{/directory directory \1}|g
    s|\{\{path\\to\\directory[[:digit:]]* +path\\to\\directory[[:digit:]]* +\.\.\.\}\}|{directory* directory}|g
    s|\{\{\\path\\to\\directory[[:digit:]]* +\\path\\to\\directory[[:digit:]]* +\.\.\.\}\}|{/directory* directory}|g

    ## Cases with prefix like excluded_directory
    s|\{\{path\\to\\([^{}_ /]+)_+directory\}\}|{directory \1 directory}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+directory\}\}|{/directory \1 directory}|g
    s|\{\{path\\to\\([^{}_ /]+)_+directory([[:digit:]]+)\}\}|{directory \1 directory \2}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+directory([[:digit:]]+)\}\}|{/directory \1 directory \2}|g
    s|\{\{path\\to\\([^{}_ /]+)_+directory[[:digit:]]* +path\\to\\\1_+directory[[:digit:]]* +\.\.\.\}\}|{directory* \1 directory}|g
    s|\{\{\\path\\to\\([^{}_ /]+)_+directory[[:digit:]]* +\\path\\to\\\1_+directory[[:digit:]]* +\.\.\.\}\}|{/directory* \1 directory}|g

    # --- Linux & Mac OS ---
    # Expansion
    ## General cases
    s|\{\{(/?)(path/to/)?(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/directory1 \1path/to/directory2 ...}}|g
    s|\{\{(/?)(path/to/)?dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/directory\5}}|g
    s|\{\{(/?)(path/to/)?dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/directory1 \1path/to/directory2 ...}}|g

    ## Cases with prefix like excluded_directory
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/\3_directory1 \1path/to/\3_directory2 ...}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_directory\6}}|g
    s|\{\{(/?)(path/to/)?([^{}_ ]+)_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?\3_dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_directory1 \1path/to/\3_directory2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{(/?)path/to/directory\}\}|{\1directory directory}|g
    s|\{\{(/?)path/to/directory([[:digit:]]+)\}\}|{\1directory directory \2}|g
    s|\{\{(/?)path/to/directory[[:digit:]]* +\1path/to/directory[[:digit:]]* +\.\.\.\}\}|{\1directory* directory}|g

    ## Cases with prefix like excluded_directory
    s|\{\{(/?)path/to/([^{}_ ]+)_+directory\}\}|{\1directory \2 directory}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+directory([[:digit:]]+)\}\}|{\1directory \2 directory \3}|g
    s|\{\{(/?)path/to/([^{}_ ]+)_+directory[[:digit:]]* +\1path/to/\2_+directory[[:digit:]]* +\.\.\.\}\}|{\1directory* \2 directory}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_boolean_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(bool(ean)?s\|bool(ean)?_*values)[[:digit:]]*\}\}|{{boolean1 boolean2 ...}}|g
    s|\{\{bool(ean)?(_*value)?([[:digit:]]*)\}\}|{{boolean\3}}|g
    s|\{\{bool(ean)?(_*value)?[[:digit:]]* +bool(ean)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{boolean1 boolean2 ...}}|g

    ## Cases with prefix like default_boolean
    s|\{\{([^{}_ ]+)_+(bool(ean)?s\|bool(ean)?_*values)[[:digit:]]*\}\}|{{\1_boolean1 \1_boolean2 ...}}|g
    s|\{\{([^{}_ ]+)_+bool(ean)?(_*value)?([[:digit:]]*)\}\}|{{\1_boolean\4}}|g
    s|\{\{([^{}_ ]+)_+bool(ean)?(_*value)?[[:digit:]]* +\1_+bool(ean)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_boolean1 \1_boolean2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{boolean\}\}|{bool boolean}|g
    s|\{\{boolean([[:digit:]]+)\}\}|{bool boolean \1}|g
    s|\{\{boolean[[:digit:]]* +boolean[[:digit:]]* +\.\.\.\}\}|{bool* boolean}|g
    s|\{\{(true\|false\|yes\|no\|on\|off)\}\}|{bool boolean: \1}|ig
    s/\{\{(true|false|yes|no|on|off)\|(true|false|yes|no|on|off)\}\}/{bool boolean: \1, \2}/ig

    ## Cases with prefix like default_boolean
    s|\{\{([^{}_ ]+)_+boolean\}\}|{bool \1 boolean}|g
    s|\{\{([^{}_ ]+)_+boolean([[:digit:]]+)\}\}|{bool \1 boolean \2}|g
    s|\{\{([^{}_ ]+)_+boolean[[:digit:]]* +\1_+boolean[[:digit:]]* +\.\.\.\}\}|{bool* \1 boolean}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_character_placeholders() {
  declare in_file_content="$1"

  [[ -z "$in_file_content" ]] && {
    while read -r line; do
      in_file_content+="$line"$'\n'
    done
  }

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(char(acter)?s\|char(acter)?_*values)[[:digit:]]*\}\}|{{character1 character2 ...}}|g
    s|\{\{char(acter)?(_*value)?([[:digit:]]*)\}\}|{{character\3}}|g
    s|\{\{char(acter)?(_*value)?[[:digit:]]* +char(acter)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{character1 character2 ...}}|g

    ## Cases with prefix like default_character
    s|\{\{([^{}_ ]+)_+(char(acter)?s\|char(acter)?_*values)[[:digit:]]*\}\}|{{\1_character1 \1_character2 ...}}|g
    s|\{\{([^{}_ ]+)_+char(acter)?(_*value)?([[:digit:]]*)\}\}|{{\1_character\4}}|g
    s|\{\{([^{}_ ]+)_+char(acter)?(_*value)?[[:digit:]]* +\1_+char(acter)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_character1 \1_character2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{character\}\}|{char character}|g
    s|\{\{character([[:digit:]]+)\}\}|{char character \1}|g
    s|\{\{character[[:digit:]]* +character[[:digit:]]* +\.\.\.\}\}|{char* character}|g
    s|\{\{([^0-9])\}\}|{char character: \1}|g

    ## Cases with prefix like default_character
    s|\{\{([^{}_ ]+)_+character\}\}|{char \1 character}|g
    s|\{\{([^{}_ ]+)_+character([[:digit:]]+)\}\}|{char \1 character \2}|g
    s|\{\{([^{}_ ]+)_+character[[:digit:]]* +\1_+character[[:digit:]]* +\.\.\.\}\}|{char* \1 character}|g
  }' <<<"$in_file_content"
}

convert() {
  declare in_file="$1"

  declare file_content="$(cat "$in_file")"
  check_layout_correctness "$file_content" || throw_error "$in_file" "valid layout expected"
  check_page_is_alias "$file_content" && throw_error "$in_file" "non-alias page expected"

  # shellcheck disable=SC2119
  file_content="$(echo "$file_content" | convert_summary |
    convert_code_descriptions |
    convert_code_examples_remove_broken_ellipsis |
    convert_code_examples_expand_plural_placeholders)"

  declare special_placeholder_file_content="$(yq '.' "$special_placeholder_config")"
  declare -i special_placeholder_count="$(yq 'length' <<<"$special_placeholder_file_content")"
  
  for ((i = 0; i < special_placeholder_count; i++)); do
    declare special_placeholder="$(yq ".[$i]" <<<"$special_placeholder_file_content")"
    
    declare in_placeholder="$(yq '.in-placeholder' <<<"$special_placeholder")"
    declare out_type="$(yq '.out-type' <<<"$special_placeholder")"

    declare -i in_index="$(yq '.in-index // 0' <<<"$special_placeholder")"
    declare in_allow_prefix="$(yq '.in-allow-prefix // false' <<<"$special_placeholder")"
    declare out_description="$(yq '.out-description // ""' <<<"$special_placeholder")"
    declare out_is_name="$(yq '.out-is-name // false' <<<"$special_placeholder")"

    declare convert_args=(-ip "$in_placeholder"
      -ot "$out_type"
      -ii "$in_index")

    [[ "$in_allow_prefix" == true ]] && convert_args+=(-iap)
    convert_args+=(-od "$out_description")
    [[ "$out_is_name" == true ]] && convert_args+=(-oin)
    file_content="$(convert_code_examples_convert_special_placeholders "$file_content" "${convert_args[@]}")"
  done

  # shellcheck disable=SC2119
  file_content="$(echo "$file_content" | convert_code_examples_convert_integer_placeholders |
    convert_code_examples_convert_float_placeholders |
    convert_code_examples_convert_option_placeholders |
    convert_code_examples_convert_device_placeholders |
    convert_code_examples_convert_path_placeholders |
    convert_code_examples_convert_file_placeholders |
    convert_code_examples_convert_directory_placeholders |
    convert_code_examples_convert_boolean_placeholders |
    convert_code_examples_convert_character_placeholders)"

  file_content="$(sed -E '/^`/ {
    # Processing file placeholders with sample values.
    ## Conversion
    ### General cases
    s|\{\{(~/[^{}/]+(/[^{}/]+)*/?)\}\}|{file file: \1}|g

    # Processing all remaining placeholders.
    ## Conversion
    s|\{\{([^{}]+)([[:digit:]]+)\}\}|{string some description \2: \1}|g
    s|\{\{([^{}]+)\}\}|{string some description: \1}|g
  }' <<<"$file_content")"

  file_content="$(sed -E '/^`/ {
    # Processing placeholders with *_or_more prefix.
    ## Conversion
    ## Cases with prefix one_or_more
    s#\{string ([^{}:]+): one_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 1.. \1}#g
    s#\{string ([^{}:]+): /one_or_more_(files|directories|paths)\}#{/\2 1.. \1}#g
    s#\{string ([^{}:]+): /\?one_or_more_(files|directories|paths)\}#{/?\2 1.. \1}#g

    ## Cases with prefix two_or_more
    s#\{string ([^{}:]+): two_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 2.. \1}#g
    s#\{string ([^{}:]+): /two_or_more_(files|directories|paths)\}#{/\2 2.. \1}#g
    s#\{string ([^{}:]+): /\?two_or_more_(files|directories|paths)\}#{/?\2 2.. \1}#g

    ## Cases with prefix three_or_more
    s#\{string ([^{}:]+): three_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 3.. \1}#g
    s#\{string ([^{}:]+): /three_or_more_(files|directories|paths)\}#{/\2 3.. \1}#g
    s#\{string ([^{}:]+): /\?three_or_more_(files|directories|paths)\}#{/?\2 3.. \1}#g

    ## Cases with prefix four_or_more
    s#\{string ([^{}:]+): four_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 4.. \1}#g
    s#\{string ([^{}:]+): /four_or_more_(files|directories|paths)\}#{/\2 4.. \1}#g
    s#\{string ([^{}:]+): /\?four_or_more_(files|directories|paths)\}#{/?\2 4.. \1}#g

    ## Cases with prefix five_or_more
    s#\{string ([^{}:]+): five_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 5.. \1}#g
    s#\{string ([^{}:]+): /five_or_more_(files|directories|paths)\}#{/\2 5.. \1}#g
    s#\{string ([^{}:]+): /\?five_or_more_(files|directories|paths)\}#{/?\2 5.. \1}#g

    ## Cases with prefix six_or_more
    s#\{string ([^{}:]+): six_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 6.. \1}#g
    s#\{string ([^{}:]+): /six_or_more_(files|directories|paths)\}#{/\2 6.. \1}#g
    s#\{string ([^{}:]+): /\?six_or_more_(files|directories|paths)\}#{/?\2 6.. \1}#g

    ## Cases with prefix seven_or_more
    s#\{string ([^{}:]+): seven_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 7.. \1}#g
    s#\{string ([^{}:]+): /seven_or_more_(files|directories|paths)\}#{/\2 7.. \1}#g
    s#\{string ([^{}:]+): /\?seven_or_more_(files|directories|paths)\}#{/?\2 7.. \1}#g

    ## Cases with prefix eight_or_more
    s#\{string ([^{}:]+): eight_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 8.. \1}#g
    s#\{string ([^{}:]+): /eight_or_more_(files|directories|paths)\}#{/\2 8.. \1}#g
    s#\{string ([^{}:]+): /\?eight_or_more_(files|directories|paths)\}#{/?\2 8.. \1}#g

    ## Cases with prefix nine_or_more
    s#\{string ([^{}:]+): nine_or_more_(bools|ints|floats|chars|strings|files|directories|paths|anys)\}#{\2 9.. \1}#g
    s#\{string ([^{}:]+): /nine_or_more_(files|directories|paths)\}#{/\2 9.. \1}#g
    s#\{string ([^{}:]+): /\?nine_or_more_(files|directories|paths)\}#{/?\2 9.. \1}#g
  }' <<<"$file_content")"

  echo -n "$file_content"
}

handle_page() {
  declare in_tldr_file="$option"

  declare clip_file="$(sed -E 's/.*\///; s/\.md$/.clip/' <<<"$in_tldr_file")"
  ((no_file_save == 1)) && {
    if [[ -z "$output_directory" ]]; then
      clip_file="$(dirname "$in_tldr_file")/$clip_file"
    else
      clip_file="$output_directory/$clip_file"
    fi
  }

  declare clip_content
  clip_content="$(convert "$in_tldr_file")"
  (($? != 0)) && exit "$FAIL"

  if ((no_file_save == 1)); then
    echo "$clip_content" >"$clip_file"
    print_message "$in_tldr_file" "converted to '$clip_file'"
  else
    echo "$clip_content"
  fi
}

parse_options() {
  while [[ -n "$1" ]]; do
    declare option="$1"
    declare value="$2"

    case "$option" in
    --help | -h)
      help
      exit
      ;;
    --version | -v)
      version
      exit
      ;;
    --author | -a)
      author
      exit
      ;;
    --email | -e)
      email
      exit
      ;;
    --no-file-save | -nfs)
      no_file_save=0
      shift
      ;;
    --output-directory | -od)
      [[ -z "$value" ]] && throw_error "$option" "existing directory expected"
      [[ ! -d "$value" ]] && throw_error "$option" "directory expected"

      output_directory="$value"
      shift 2
      ;;
    --special-placeholder-config | -spc)
      [[ -z "$value" ]] && throw_error "$option" "existing config expected"
      [[ ! -f "$value" ]] && throw_error "$option" "config expected"

      special_placeholder_config="$value"
      shift 2
      ;;
    --* | -*)
      throw_error "$option" "valid option expected"
      ;;
    *)
      handle_page "$option"
      shift
      ;;
    esac
  done
}

throw_if_dependencies_are_not_satisfied

(($# == 0)) && {
  help
  exit
}

parse_options "$@"
exit "$SUCCESS"
