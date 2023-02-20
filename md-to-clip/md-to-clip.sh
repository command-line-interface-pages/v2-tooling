#!/usr/bin/env bash

# shellcheck disable=2016,2155,2181,1087

declare -i SUCCESS=0
declare -i FAIL=1

declare PROGRAM_NAME="$(basename "$0")"

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

# Help colors:
declare HELP_HEADER_COLOR="\e[$(color_to_code blue)m"
declare HELP_TEXT_COLOR="\e[$(color_to_code black)m"
declare HELP_OPTION_COLOR="\e[$(color_to_code green)m"
declare HELP_PLACEHOLDER_COLOR="\e[$(color_to_code cyan)m"
declare HELP_PUNCTUATION_COLOR="\e[$(color_to_code gray)m"

help() {
  echo -e "${HELP_TEXT_COLOR}Converter from TlDr format to Command Line Interface Pages format.

${HELP_HEADER_COLOR}Usage:$HELP_TEXT_COLOR
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--help$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-h$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--version$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-v$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--author$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-a$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--email$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-e$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR($HELP_OPTION_COLOR--no-file-save$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-nfs$HELP_PUNCTUATION_COLOR)$HELP_TEXT_COLOR
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR[($HELP_OPTION_COLOR--output-directory$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-od$HELP_PUNCTUATION_COLOR) $HELP_PLACEHOLDER_COLOR<directory>$HELP_PUNCTUATION_COLOR] $HELP_PUNCTUATION_COLOR[($HELP_OPTION_COLOR--special-placeholder-config$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-spc$HELP_PUNCTUATION_COLOR) $HELP_PLACEHOLDER_COLOR<file.yaml>$HELP_PUNCTUATION_COLOR] $HELP_PLACEHOLDER_COLOR<file1.md file2.md ...>

${HELP_HEADER_COLOR}Converters:$HELP_TEXT_COLOR
  - Command summary and tag simplification
  - Placeholder conversion and optimization

${HELP_HEADER_COLOR}Notes:$HELP_TEXT_COLOR
  Escaping and placeholders with alternatives are not recognized and treated literally."
}

version() {
  echo "2.0.0" >&2
}

author() {
  echo "Emily Grace Seville" >&2
}

email() {
  echo "EmilySeville7cfg@gmail.com" >&2
}

check_dependencies_correctness() {
  which sed >/dev/null || {
    echo -e "$PROGRAM_NAME: sed: ${ERROR_COLOR}installed command expected$RESET_COLOR" >&2
    return "$FAIL"
  }
}

check_layout_correctness() {
  declare content="$1

"

  sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$content"
}

check_page_is_alias() {
  declare content="$1

"

  ! sed -nE '/^- View documentation for the original command:$/ Q1' <<<"$content"
}

convert_summary() {
  declare in_file_content="$1"

  sed -E '/^>/ {
    s/\.$//
    s/More +information: <(.*)>$/More information: \1/

    /See +also/ {
      s/[, ] +or +/, /g
      s/`//g
    }
  }' <<<"$in_file_content"
}

convert_code_descriptions() {
  declare in_file_content="$1"

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

  sed -E '/^`/ {
    s/ *\{\{\.\.\.\}\} */ /g
  }' <<<"$in_file_content"
}

convert_code_examples_expand_plural_placeholders() {
  declare in_file_content="$1"

  sed -E '/^`/ {
    s|\{\{([^{}]+)(\(s\)\|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})\}\}|{{\11 \12 ...}}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_special_placeholders() {
  declare in_file_content="$1"

  declare in_keyword=
  declare in_result_keyword=
  declare in_description_keyword=
  declare -i in_option_part_start_index=
  declare in_suffix=name
  declare allow_prefix=false

  shift
  while [[ -n "$1" ]]; do
    declare option="$1"

    case "$option" in
    --in-keyword | -ik)
      in_keyword="$2"
      shift 2
      ;;
    --result-keyword | -rk)
      in_result_keyword="$2"
      shift 2
      ;;
    --description-keyword | -dk)
      in_description_keyword="$2"
      shift 2
      ;;
    --option-part-start-index | -opsi)
      in_option_part_start_index="$2"
      shift 2
      ;;
    --is-value | -iv)
      in_suffix=value
      shift
      ;;
    --allow-prefix | -ap)
      allow_prefix=true
      shift
      ;;
    *)
      return "$FAIL"
      ;;
    esac
  done

  [[ -z "$in_keyword" ]] && return "$FAIL"

  [[ -z "$in_result_keyword" ]] && in_result_keyword="$in_keyword"
  [[ -z "$in_description_keyword" ]] && in_description_keyword="$in_keyword"

  declare -i group_multiplier=0
  ((in_option_part_start_index > 0)) && {
    in_keyword="${in_keyword:0:in_option_part_start_index}(${in_keyword:in_option_part_start_index})?"
    group_multiplier=1
  }

  if [[ "$allow_prefix" == true ]]; then
    sed -E "/^\`/ {
      # Expansion
      ## General cases
      s|\{\{(${in_keyword}s\|${in_keyword}_*${in_suffix}s)[[:digit:]]*\}\}|{{${in_result_keyword}1 ${in_result_keyword}2 ...}}|g
      s|\{\{${in_keyword}(_*${in_suffix})?([[:digit:]]*)\}\}|{{${in_result_keyword}\\$((2 + group_multiplier))}}|g
      s|\{\{${in_keyword}(_*${in_suffix})?[[:digit:]]* +${in_keyword}(_*${in_suffix})?[[:digit:]]* +\.\.\.\}\}|{{${in_result_keyword}1 ${in_result_keyword}2 ...}}|g

      ## Cases with prefix like positive_integer
      s|\{\{([^{}_ ]+)_+(${in_keyword}s\|${in_keyword}_*${in_suffix}s)[[:digit:]]*\}\}|{{\1_${in_result_keyword}1 \1_${in_result_keyword}2 ...}}|g
      s|\{\{([^{}_ ]+)_+${in_keyword}(_*${in_suffix})?([[:digit:]]*)\}\}|{{\1_${in_result_keyword}\\$((3 + group_multiplier))}}|g
      s|\{\{([^{}_ ]+)_+${in_keyword}(_*${in_suffix})?[[:digit:]]* +\1_+${in_keyword}(_*${in_suffix})?[[:digit:]]* +\.\.\.\}\}|{{\1_${in_result_keyword}1 \1_${in_result_keyword}2 ...}}|g

      # Conversion
      ## General cases
      s|\{\{${in_result_keyword}\}\}|{${in_result_keyword} ${in_description_keyword}}|g
      s|\{\{${in_result_keyword}([[:digit:]])\}\}|{${in_result_keyword} ${in_description_keyword} \1}|g
      s|\{\{${in_result_keyword}[[:digit:]]* +${in_result_keyword}[[:digit:]]* +\.\.\.\}\}|{${in_result_keyword}* ${in_description_keyword}}|g

      ## Cases with prefix like positive_integer
      s|\{\{([^{}_ ]+)_+${in_result_keyword}\}\}|{${in_result_keyword} \1 ${in_description_keyword}}|g
      s|\{\{([^{}_ ]+)_+${in_result_keyword}([[:digit:]])\}\}|{${in_result_keyword} \1 ${in_description_keyword} \2}|g
      s|\{\{([^{}_ ]+)_+${in_result_keyword}[[:digit:]]* +\1_+${in_result_keyword}[[:digit:]]* +\.\.\.\}\}|{${in_result_keyword}* \1 ${in_description_keyword}}|g
    }" <<<"$in_file_content"
  else
    sed -E "/^\`/ {
      # Expansion
      s|\{\{(${in_keyword}s\|${in_keyword}_*${in_suffix}s)[[:digit:]]*\}\}|{{${in_result_keyword}1 ${in_result_keyword}2 ...}}|g
      s|\{\{${in_keyword}(_*${in_suffix})?([[:digit:]]*)\}\}|{{${in_result_keyword}\\$((2 + group_multiplier))}}|g
      s|\{\{${in_keyword}(_*${in_suffix})?[[:digit:]]* +${in_keyword}(_*${in_suffix})?[[:digit:]]* +\.\.\.\}\}|{{${in_result_keyword}1 ${in_result_keyword}2 ...}}|g

      # Conversion
      s|\{\{${in_result_keyword}\}\}|{${in_result_keyword} ${in_description_keyword}}|g
      s|\{\{${in_result_keyword}([[:digit:]]+)\}\}|{${in_result_keyword} ${in_description_keyword} \1}|g
      s|\{\{${in_result_keyword}[[:digit:]]* +${in_result_keyword}[[:digit:]]* +\.\.\.\}\}|{${in_result_keyword}* ${in_description_keyword}}|g
    }" <<<"$in_file_content"
  fi
}

convert_code_examples_convert_integer_placeholders() {
  declare in_file_content="$1"

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
    s|\{\{integer\}\}|{int some description}|g
    s|\{\{integer([[:digit:]])\}\}|{int some description \1}|g
    s|\{\{integer[[:digit:]]* +integer[[:digit:]]* +\.\.\.\}\}|{int* some description}|g
    s|\{\{([-+]?[[:digit:]]+)\}\}|{int some description: \1}|g

    ## Cases with prefix like positive_integer
    s|\{\{([^{}_ ]+)_+integer\}\}|{int \1 integer}|g
    s|\{\{([^{}_ ]+)_+integer([[:digit:]])\}\}|{int \1 integer \2}|g
    s|\{\{([^{}_ ]+)_+integer[[:digit:]]* +\1_+integer[[:digit:]]* +\.\.\.\}\}|{int* \1 integer}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_float_placeholders() {
  declare in_file_content="$1"

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
    s|\{\{float\}\}|{float some description}|g
    s|\{\{float([[:digit:]])\}\}|{float some description \1}|g
    s|\{\{float[[:digit:]]* +float[[:digit:]]* +\.\.\.\}\}|{float* some description}|g
    s|\{\{([-+]?[[:digit:]]+[.,][[:digit:]]+)\}\}|{float some description: \1}|g

    ## Cases with prefix like positive_float
    s|\{\{([^{}_ ]+)_+float\}\}|{float \1 float}|g
    s|\{\{([^{}_ ]+)_+float([[:digit:]])\}\}|{float \1 float \2}|g
    s|\{\{([^{}_ ]+)_+float[[:digit:]]* +\1_+float[[:digit:]]* +\.\.\.\}\}|{float* \1 float}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_option_placeholders() {
  declare in_file_content="$1"

  sed -E '/^`/ {
    # Expansion
    s|\{\{(options\|option_*names)[[:digit:]]*\}\}|{{option1 option2 ...}}|g
    s|\{\{option(_*name)?([[:digit:]]*)\}\}|{{option\2}}|g
    s|\{\{option(_*name)?[[:digit:]]* +option(_*name)?[[:digit:]]* +\.\.\.\}\}|{{option1 option2 ...}}|g

    # Conversion
    s|\{\{option\}\}|{string option}|g
    s|\{\{option([[:digit:]])\}\}|{string option \1}|g
    s|\{\{option[[:digit:]]* +option[[:digit:]]* +\.\.\.\}\}|{string* option}|g
    s|\{\{(--?[^{}=: ]+)\}\}|{option some description: \1}|g
    s|\{\{(--?[^{}=: ]+(([:=]\| +)[^{} ]*)?( +--?[^{}=: ]+(([:=]\| +)[^{} ]*)?)+)\}\}|{option* some description: \1}|g
    s|\{\{(--?[^{}=: ]+)([:=]\| +)[^{} ]*\}\}|{option some description: \1}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_device_placeholders() {
  declare in_file_content="$1"

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(\/?)(path/to/\|/dev/)?(devices\|device_*names)[[:digit:]]*\}\}|{{\1device1 \1device2 ...}}|g
    s|\{\{(\/?)(path/to/\|/dev/)?device(_*name)?([[:digit:]]*)\}\}|{{\1device\4}}|g
    s|\{\{(\/?)(path/to/\|/dev/)?device(_*name)?[[:digit:]]* +\1(path/to/\|/dev/)?device(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1device1 \1device2 ...}}|g

    ## Cases with prefix like drive_device
    s|\{\{(\/?)(path/to/\|/dev/)?([^{}_/ ]+)_+(devices\|device_*names)[[:digit:]]*\}\}|{{\1\3_device1 \1\3_device2 ...}}|g
    s|\{\{(\/?)(path/to/\|/dev/)?([^{}_/ ]+)_+device(_*name)?([[:digit:]]*)\}\}|{{\1\3_device\5}}|g
    s|\{\{(\/?)(path/to/\|/dev/)?([^{}_/ ]+)_+device(_*name)?[[:digit:]]* +\1(path/to/\|/dev/)?\3_+device(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1\3_device1 \1\3_device2 ...}}|g

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

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(\/?)(path/to/)?(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/file_or_directory1 \1path/to/file_or_directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/file_or_directory\6}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/file_or_directory1 \1path/to/file_or_directory2 ...}}|g

    ## Cases with prefix like excluded_path_or_directory
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file_or_directory1 \1path/to/\3_file_or_directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file_or_directory\7}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file_or_directory1 \1path/to/\3_file_or_directory2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{(\/?)path/to/file_or_directory\}\}|{\1path some description}|g
    s|\{\{(\/?)path/to/file_or_directory([[:digit:]]+)\}\}|{\1path some description \2}|g
    s|\{\{(\/?)path/to/file_or_directory[[:digit:]]* +\1path/to/file_or_directory[[:digit:]]* +\.\.\.\}\}|{\1path* some description}|g

    ## Cases with prefix like excluded_path_or_directory
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file_or_directory\}\}|{\1path \2 file or directory}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file_or_directory([[:digit:]]+)\}\}|{\1path \2 file or directory \3}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file_or_directory[[:digit:]]* +\1path/to/\2_+file_or_directory[[:digit:]]* +\.\.\.\}\}|{\1path* \2 file or directory}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_file_placeholders() {
  declare in_file_content="$1"

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(\/?)(path/to/)?(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/file1 \1path/to/file2 ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/file\4}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?[[:digit:]]* +\1(path/to/)?file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/file1 \1path/to/file2 ...}}|g

    ## Cases with prefix like excluded_file
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file\5}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g

    ## Cases with optional extensions
    s|\{\{(\/?)(path/to/)?(files\|file_*names)[[:digit:]]*\[(\.[^{}| ]+)\]\}\}|{{\1path/to/file1[\4] \1path/to/file2[\4] ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?([[:digit:]]*)\[(\.[^{}| ]+)\]\}\}|{{\1path/to/file\4[\5]}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?[[:digit:]]*\[(\.[^{}| ]+)\] +\1(path/to/)?file(_*name)?[[:digit:]]*\[\4\] +\.\.\.\}\}|{{\1path/to/file1[\4] \1path/to/file2[\4] ...}}|g

    ## Cases with mandatory extension
    s|\{\{(\/?)(path/to/)?(files\|file_*names)[[:digit:]]*(\.[^{}| ]+)\}\}|{{\1path/to/file1\4 \1path/to/file2\4 ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?([[:digit:]]*)(\.[^{}| ]+)\}\}|{{\1path/to/file\4\5}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?[[:digit:]]*(\.[^{}| ]+) +\1(path/to/)?file(_*name)?[[:digit:]]*\4 +\.\.\.\}\}|{{\1path/to/file1\4 \1path/to/file2\4 ...}}|g

    ## Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\[(\.[^{}| ]+)\]\}\}|{{\1path/to/\3_file1[\5] \1path/to/\3_file2[\5] ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\[(\.[^{}| ]+)\]\}\}|{{\1path/to/\3_file\5[\6]}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]*\[(\.[^{}| ]+)\] +\1(path/to/)?\3_+file(_*name)?[[:digit:]]*\[\5\] +\.\.\.\}\}|{{\1path/to/\3_file1[\5] \1path/to/\3_file2[\5] ...}}|g

    ## Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*(\.[^{}| ]+)\}\}|{{\1path/to/\3_file1\5 \1path/to/\3_file2\5 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)(\.[^{}| ]+)\}\}|{{\1path/to/\3_file\5\6}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]*(\.[^{}| ]+) +\1(path/to/)?\3_+file(_*name)?[[:digit:]]*\5 +\.\.\.\}\}|{{\1path/to/\3_file1\5 \1path/to/\3_file2\5 ...}}|g

    # Conversion
    ## General cases
    s|\{\{(\/?)path/to/file\}\}|{\1file some description}|g
    s|\{\{(\/?)path/to/file([[:digit:]]+)\}\}|{\1file some description \2}|g
    s|\{\{(\/?)path/to/file[[:digit:]]* +\1path/to/file[[:digit:]]* +\.\.\.\}\}|{\1file* some description}|g

    ## Cases with prefix like excluded_file
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file\}\}|{\1file \2 file}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)\}\}|{\1file \2 file \3}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file[[:digit:]]* +\1path/to/\2_+file[[:digit:]]* +\.\.\.\}\}|{\1file* \2 file}|g

    ## Cases with optional extensions
    s|\{\{(\/?)path/to/file\[(\.[^{}| ]+)\]\}\}|{\1file file with optional \2 extensions}|g
    s|\{\{(\/?)path/to/file([[:digit:]]+)\[(\.[^{}| ]+)\]\}\}|{\1file file \2 with optional \3 extensions}|g
    s|\{\{(\/?)path/to/file[[:digit:]]*\[(\.[^{}| ]+)\] +\1path/to/file[[:digit:]]*\[\2\] +\.\.\.\}\}|{\1file* file with optional \2 extensions}|g

    ## Cases with mandatory extension
    s|\{\{(\/?)path/to/file(\.[^{}| ]+)\}\}|{\1file file with mandatory \2 extension}|g
    s|\{\{(\/?)path/to/file([[:digit:]]+)(\.[^{}| ]+)\}\}|{\1file file \2 with mandatory \3 extension}|g
    s|\{\{(\/?)path/to/file[[:digit:]]*(\.[^{}| ]+) +\1path/to/+file[[:digit:]]*\2 +\.\.\.\}\}|{\1file* file with mandatory \2 extension}|g

    ## Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file\[(\.[^{}| ]+)\]\}\}|{\1file \2 file with optional \3 extensions}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)\[(\.[^{}| ]+)\]\}\}|{\1file \2 file \3 with optional \4 extensions}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file[[:digit:]]*\[(\.[^{}| ]+)\] +\1path/to/\2_+file[[:digit:]]*\[\3\] +\.\.\.\}\}|{\1file* \2 file with optional \3 extensions}|g

    ## Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file(\.[^{}| ]+)\}\}|{\1file \2 file with mandatory \3 extension}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)(\.[^{}| ]+)\}\}|{\1file \2 file \3 with mandatory \4 extension}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file[[:digit:]]*(\.[^{}| ]+) +\1path/to/\2_+file[[:digit:]]*\3 +\.\.\.\}\}|{\1file* \2 file with mandatory \3 extension}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_directory_placeholders() {
  declare in_file_content="$1"

  sed -E '/^`/ {
    # Expansion
    ## General cases
    s|\{\{(\/?)(path/to/)?(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/directory1 \1path/to/directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/directory\5}}|g
    s|\{\{(\/?)(path/to/)?dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/directory1 \1path/to/directory2 ...}}|g

    ## Cases with prefix like excluded_file
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file\5}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g

    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/\3_directory1 \1path/to/\3_directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_directory\6}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?\3_dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_directory1 \1path/to/\3_directory2 ...}}|g

    # Conversion
    ## General cases
    s|\{\{(\/?)path/to/directory\}\}|{\1directory some description}|g
    s|\{\{(\/?)path/to/directory([[:digit:]]+)\}\}|{\1directory some description \2}|g
    s|\{\{(\/?)path/to/directory[[:digit:]]* +\1path/to/directory[[:digit:]]* +\.\.\.\}\}|{\1directory* some description}|g

    ## Cases with prefix like excluded_file
    s|\{\{(\/?)path/to/([^{}_ ]+)_+directory\}\}|{\1directory \2 directory}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+directory([[:digit:]]+)\}\}|{\1directory \2 directory \3}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+directory[[:digit:]]* +\1path/to/\2_+directory[[:digit:]]* +\.\.\.\}\}|{\1directory* \2 directory}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_boolean_placeholders() {
  declare in_file_content="$1"

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
    s|\{\{boolean\}\}|{bool some description}|g
    s|\{\{boolean([[:digit:]])\}\}|{bool some description \1}|g
    s|\{\{boolean[[:digit:]]* +boolean[[:digit:]]* +\.\.\.\}\}|{bool* some description}|g
    s|\{\{(true\|false\|yes\|no\|on\|off)\}\}|{bool some description: \1}|g
    s/\{\{(true|false|yes|no|on|off)\|(true|false|yes|no|on|off)\}\}/{bool some description: \1, \2}/g

    ## Cases with prefix like default_boolean
    s|\{\{([^{}_ ]+)_+boolean\}\}|{bool \1 boolean}|g
    s|\{\{([^{}_ ]+)_+boolean([[:digit:]])\}\}|{bool \1 boolean \2}|g
    s|\{\{([^{}_ ]+)_+boolean[[:digit:]]* +\1_+boolean[[:digit:]]* +\.\.\.\}\}|{bool* \1 boolean}|g
  }' <<<"$in_file_content"
}

convert_code_examples_convert_character_placeholders() {
  declare in_file_content="$1"

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
    s|\{\{character\}\}|{char some description}|g
    s|\{\{character([[:digit:]])\}\}|{char some description \1}|g
    s|\{\{character[[:digit:]]* +character[[:digit:]]* +\.\.\.\}\}|{char* some description}|g
    s|\{\{([^0-9])\}\}|{char some description: \1}|g

    ## Cases with prefix like default_character
    s|\{\{([^{}_ ]+)_+character\}\}|{char \1 character}|g
    s|\{\{([^{}_ ]+)_+character([[:digit:]])\}\}|{char \1 character \2}|g
    s|\{\{([^{}_ ]+)_+character[[:digit:]]* +\1_+character[[:digit:]]* +\.\.\.\}\}|{char* \1 character}|g
  }' <<<"$in_file_content"
}

convert() {
  declare in_file="$1"
  declare in_special_placeholder_config="$2"

  declare file_content="$(cat "$in_file")"
  declare program_name="$(basename "$PROGRAM_NAME")"

  check_layout_correctness "$file_content" || {
    echo -e "$program_name: $in_file: ${ERROR_COLOR}valid page layout expected$RESET_COLOR" >&2
    return "$FAIL"
  }

  check_page_is_alias "$file_content" && {
    echo -e "$program_name: $in_file: ${ERROR_COLOR}non-alias page expected$RESET_COLOR" >&2
    return "$FAIL"
  }

  [[ -f "$in_special_placeholder_config" ]] || {
    echo -e "$program_name: $in_special_placeholder_config: ${ERROR_COLOR}existing special placeholder config expected$RESET_COLOR" >&2
    return "$FAIL"
  }

  file_content="$(convert_summary "$file_content")"
  file_content="$(convert_code_descriptions "$file_content")"
  file_content="$(convert_code_examples_remove_broken_ellipsis "$file_content")"
  file_content="$(convert_code_examples_expand_plural_placeholders "$file_content")"

  declare -i special_placeholder_count="$(yq 'length' "$special_placeholder_config")"
  for ((i=0; i < special_placeholder_count; i++)); do
    declare special_placeholder="$(yq ".[$i]" "$in_special_placeholder_config")"
    
    declare in_placeholder="$(yq '.in-placeholder' <<<"$special_placeholder")"
    declare out_type="$(yq '.out-type' <<<"$special_placeholder")"

    declare -i in_index="$(yq '.in-index // 0' <<<"$special_placeholder")"
    declare -i in_allow_prefix="$(yq '.in-allow-prefix // 1' <<<"$special_placeholder")"
    declare out_description="$(yq '.out-description // ""' <<<"$special_placeholder")"
    declare -i out_is_name="$(yq '.out-is-name // 1' <<<"$special_placeholder")"

    declare convert_args=(-ik "$in_placeholder"
      -rk "$out_type"
      -opsi "$in_index")
    
    ((in_allow_prefix == 0)) && convert_args+=(-ap)
    convert_args+=(-dk "$out_description")
    ((out_is_name == 0)) || convert_args+=(-iv)

    file_content="$(convert_code_examples_convert_special_placeholders "$file_content" "${convert_args[@]}")"
  done

  file_content="$(convert_code_examples_convert_integer_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_float_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_option_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_device_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_path_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_file_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_directory_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_boolean_placeholders "$file_content")"
  file_content="$(convert_code_examples_convert_character_placeholders "$file_content")"

  sed -E '/^`/ {
    # Processing file placeholders with sample values.
    ## Conversion
    ### General cases
    s|\{\{(~/[^{}/]+(/[^{}/]+)*/?)\}\}|{file some description: \1}|g

    # Processing all remaining placeholders.
    ## Conversion
    s|\{\{([^{}]+)([[:digit:]]+)\}\}|{string some description \2: \1}|g
    s|\{\{([^{}]+)\}\}|{string some description: \1}|g
  }' <<<"$file_content"
}

check_dependencies_correctness || exit "$FAIL"

if (($# == 0)); then
  help
fi

declare output_directory
declare special_placeholder_config="$HOME/.md-to-clip.yaml"
declare -i no_file_save=1

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
    [[ -z "$value" ]] && {
      echo -e "$PROGRAM_NAME: $option: ${ERROR_COLOR}directory expected$RESET_COLOR" >&2
      exit "$FAIL"
    }

    output_directory="$value"
    shift 2
    ;;
  --special-placeholder-config | -spc)
    [[ -z "$value" ]] && {
      echo -e "$PROGRAM_NAME: $option: ${ERROR_COLOR}config expected$RESET_COLOR" >&2
      exit "$FAIL"
    }

    special_placeholder_config="$value"
    shift 2
    ;;
  *)
    declare tldr_file="$option"
    declare clip_file="$(sed -E 's/.*\///; s/\.md$/.clip/' <<<"$tldr_file")"
    ((no_file_save == 1)) && {
      if [[ -z "$output_directory" ]]; then
        clip_file="$(dirname "$tldr_file")/$clip_file"
      else
        clip_file="$output_directory/$clip_file"
      fi
    }

    declare clip_content
    clip_content="$(convert "$tldr_file" "$special_placeholder_config")"
    (($? != 0)) && exit "$FAIL"

    if ((no_file_save == 1)); then
      echo "$clip_content" >"$clip_file"
      echo -e "$PROGRAM_NAME: $tldr_file: ${SUCCESS_COLOR}converted to $clip_file$RESET_COLOR" >&2
    else
      echo "$clip_content"
    fi

    shift
    ;;
  esac
done

exit "$SUCCESS"
