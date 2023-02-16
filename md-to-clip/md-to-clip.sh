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
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR[($HELP_OPTION_COLOR--output-directory$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-od$HELP_PUNCTUATION_COLOR) $HELP_PLACEHOLDER_COLOR<directory>$HELP_PUNCTUATION_COLOR] $HELP_PLACEHOLDER_COLOR<file1.md file2.md ...>

${HELP_HEADER_COLOR}Converters:$HELP_TEXT_COLOR
  - Command summary and tag simplification
  - Placeholder conversion and optimization

${HELP_HEADER_COLOR}Notes:$HELP_TEXT_COLOR
  Escaping and placeholders with alternatives are not recognized and treated literally."
}

version() {
  echo "1.5.1" >&2
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

convert() {
  declare in_file="$1"

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

  sed -E '
  # Correcting summary: removing a trailing dot and removing all not supported characters from syntax.
  /^>/ {
    s/\.$//
    s/More +information: <(.*)>$/More information: \1/

    /See +also/ {
      s/[, ] +or +/, /g
      s/`//g
    }
  }
  
  # Correcting code descriptions: standardizing all I/O stream names.
  /^-/ {
    s/`(std(in|out|err))`/\1/g
    s/standard +input( +stream)?/stdin/g
    s/standard +output( +stream)?/stdout/g
    s/standard +error( +stream)?/stderr/g

    s/\<(a|the) +(given|specified)\>/a specific/g
  }
  
  # Correcting code examples: fixing some broken placeholders and correcting some placeholders.
  /^`/ {
    # Removing broken ellipsis.
    s/ *\{\{\.\.\.\}\} */ /g

    # Process brace expansions and (s).
    ## Expansion
    s|\{\{([^{}]+)(\(s\)\|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})\}\}|{{\11 \12 ...}}|g
    
    # Processing user placeholders.
    ## Expansion
    s|\{\{(users\|user_*names)[[:digit:]]*\}\}|{{user1 user2 ...}}|g
    s|\{\{user(_*name)?([[:digit:]]*)\}\}|{{user\2}}|g
    s|\{\{user(_*name)?[[:digit:]]* +user(_*name)?[[:digit:]]* +\.\.\.\}\}|{{user1 user2 ...}}|g

    ## Conversion
    s|\{\{user\}\}|{string user}|g
    s|\{\{user([[:digit:]])\}\}|{string user \1}|g
    s|\{\{user[[:digit:]]* +user[[:digit:]]* +\.\.\.\}\}|{string* user}|g
  
    # Processing group placeholders.
    ## Expansion
    s|\{\{(groups\|group_*names)[[:digit:]]*\}\}|{{group1 group2 ...}}|g
    s|\{\{group(_*name)?([[:digit:]]*)\}\}|{{group\2}}|g
    s|\{\{group(_*name)?[[:digit:]]* +group(_*name)?[[:digit:]]* +\.\.\.\}\}|{{group1 group2 ...}}|g

    ## Conversion
    s|\{\{group\}\}|{string group}|g
    s|\{\{group([[:digit:]])\}\}|{string group \1}|g
    s|\{\{group[[:digit:]]* +group[[:digit:]]* +\.\.\.\}\}|{string* group}|g

    # Processing ip placeholders.
    ## Expansion
    s|\{\{(ips\|ip_*names)[[:digit:]]*\}\}|{{ip1 ip2 ...}}|g
    s|\{\{ip(_*name)?([[:digit:]]*)\}\}|{{ip\2}}|g
    s|\{\{ip(_*name)?[[:digit:]]* +ip(_*name)?[[:digit:]]* +\.\.\.\}\}|{{ip1 ip2 ...}}|g

    ## Conversion
    s|\{\{ip\}\}|{string ip}|g
    s|\{\{ip([[:digit:]])\}\}|{string ip \1}|g
    s|\{\{ip[[:digit:]]* +ip[[:digit:]]* +\.\.\.\}\}|{string* ip}|g

    # Processing database placeholders.
    ## Expansion
    s|\{\{(databases\|database_*names)[[:digit:]]*\}\}|{{database1 database2 ...}}|g
    s|\{\{database(_*name)?([[:digit:]]*)\}\}|{{database\2}}|g
    s|\{\{database(_*name)?[[:digit:]]* +database(_*name)?[[:digit:]]* +\.\.\.\}\}|{{database1 database2 ...}}|g

    ## Conversion
    s|\{\{database\}\}|{string database}|g
    s|\{\{database([[:digit:]])\}\}|{string database \1}|g
    s|\{\{database[[:digit:]]* +database[[:digit:]]* +\.\.\.\}\}|{string* database}|g

    # Processing integer placeholders.
    ## Expansion
    ### General cases
    s|\{\{(int(eger)?s\|int(eger)?_*values)[[:digit:]]*\}\}|{{integer1 integer2 ...}}|g
    s|\{\{int(eger)?(_*value)?([[:digit:]]*)\}\}|{{integer\3}}|g
    s|\{\{int(eger)?(_*value)?[[:digit:]]* +int(eger)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{integer1 integer2 ...}}|g

    ### Cases with prefix like positive_integer
    s|\{\{([^{}_ ]+)_+(int(eger)?s\|int(eger)?_*values)[[:digit:]]*\}\}|{{\1_integer1 \1_integer2 ...}}|g
    s|\{\{([^{}_ ]+)_+int(eger)?(_*value)?([[:digit:]]*)\}\}|{{\1_integer\4}}|g
    s|\{\{([^{}_ ]+)_+int(eger)?(_*value)?[[:digit:]]* +\1_+int(eger)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_integer1 \1_integer2 ...}}|g

    ## Conversion
    ### General cases
    s|\{\{integer\}\}|{int some description}|g
    s|\{\{integer([[:digit:]])\}\}|{int some description \1}|g
    s|\{\{integer[[:digit:]]* +integer[[:digit:]]* +\.\.\.\}\}|{int* some description}|g
    s|\{\{([-+]?[[:digit:]]+)\}\}|{int some description: \1}|g

    ### Cases with prefix like positive_integer
    s|\{\{([^{}_ ]+)_+integer\}\}|{int \1 integer}|g
    s|\{\{([^{}_ ]+)_+integer([[:digit:]])\}\}|{int \1 integer \2}|g
    s|\{\{([^{}_ ]+)_+integer[[:digit:]]* +\1_+integer[[:digit:]]* +\.\.\.\}\}|{int* \1 integer}|g

    # Processing float placeholders.
    ## Expansion
    ### General cases
    s|\{\{(float?s\|float?_*values)[[:digit:]]*\}\}|{{float1 float2 ...}}|g
    s|\{\{float?(_*value)?([[:digit:]]*)\}\}|{{float\2}}|g
    s|\{\{float?(_*value)?[[:digit:]]* +float?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{float1 float2 ...}}|g

    ### Cases with prefix like positive_float
    s|\{\{([^{}_ ]+)_+(float?s\|float?_*values)[[:digit:]]*\}\}|{{\1_float1 \1_float2 ...}}|g
    s|\{\{([^{}_ ]+)_+float?(_*value)?([[:digit:]]*)\}\}|{{\1_float\3}}|g
    s|\{\{([^{}_ ]+)_+float?(_*value)?[[:digit:]]* +\1_+float?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_float1 \1_float2 ...}}|g

    ## Conversion
    ### General cases
    s|\{\{float\}\}|{float some description}|g
    s|\{\{float([[:digit:]])\}\}|{float some description \1}|g
    s|\{\{float[[:digit:]]* +float[[:digit:]]* +\.\.\.\}\}|{float* some description}|g
    s|\{\{([-+]?[[:digit:]]+[.,][[:digit:]]+)\}\}|{float some description: \1}|g

    ### Cases with prefix like positive_float
    s|\{\{([^{}_ ]+)_+float\}\}|{float \1 float}|g
    s|\{\{([^{}_ ]+)_+float([[:digit:]])\}\}|{float \1 float \2}|g
    s|\{\{([^{}_ ]+)_+float[[:digit:]]* +\1_+float[[:digit:]]* +\.\.\.\}\}|{float* \1 float}|g

    # Processing argument placeholders.
    ## Expansion
    s|\{\{(arguments\|argument_*names)[[:digit:]]*\}\}|{{argument1 argument2 ...}}|g
    s|\{\{argument(_*name)?([[:digit:]]*)\}\}|{{argument\2}}|g
    s|\{\{argument(_*name)?[[:digit:]]* +argument(_*name)?[[:digit:]]* +\.\.\.\}\}|{{argument1 argument2 ...}}|g

    ## Conversion
    s|\{\{argument\}\}|{any argument}|g
    s|\{\{argument([[:digit:]])\}\}|{any argument \1}|g
    s|\{\{argument[[:digit:]]* +argument[[:digit:]]* +\.\.\.\}\}|{any* argument}|g

    # Processing option placeholders.
    ## Expansion
    s|\{\{(options\|option_*names)[[:digit:]]*\}\}|{{option1 option2 ...}}|g
    s|\{\{option(_*name)?([[:digit:]]*)\}\}|{{option\2}}|g
    s|\{\{option(_*name)?[[:digit:]]* +option(_*name)?[[:digit:]]* +\.\.\.\}\}|{{option1 option2 ...}}|g

    ## Conversion
    s|\{\{option\}\}|{string option}|g
    s|\{\{option([[:digit:]])\}\}|{string option \1}|g
    s|\{\{option[[:digit:]]* +option[[:digit:]]* +\.\.\.\}\}|{string* option}|g
    s|\{\{(--?[^{}=: ]+)\}\}|{option some description: \1}|g
    s|\{\{(--?[^{}=: ]+(([:=]\| +)[^{} ]*)?( +--?[^{}=: ]+(([:=]\| +)[^{} ]*)?)+)\}\}|{option* some description: \1}|g
    s|\{\{(--?[^{}=: ]+)([:=]\| +)[^{} ]*\}\}|{option some description: \1}|g

    # Processing setting placeholders.
    ## Expansion
    s|\{\{(settings\|setting_*names)[[:digit:]]*\}\}|{{setting1 setting2 ...}}|g
    s|\{\{setting(_*name)?([[:digit:]]*)\}\}|{{setting\2}}|g
    s|\{\{setting(_*name)?[[:digit:]]* +setting(_*name)?[[:digit:]]* +\.\.\.\}\}|{{setting1 setting2 ...}}|g

    ## Conversion
    s|\{\{setting\}\}|{string setting}|g
    s|\{\{setting([[:digit:]])\}\}|{string setting \1}|g
    s|\{\{setting[[:digit:]]* +setting[[:digit:]]* +\.\.\.\}\}|{string* setting}|g

    # Processing subcommand placeholders.
    ## Expansion
    s|\{\{(subcommands\|subcommand_*names)[[:digit:]]*\}\}|{{subcommand1 subcommand2 ...}}|g
    s|\{\{subcommand(_*name)?([[:digit:]]*)\}\}|{{subcommand\2}}|g
    s|\{\{subcommand(_*name)?[[:digit:]]* +subcommand(_*name)?[[:digit:]]* +\.\.\.\}\}|{{subcommand1 subcommand2 ...}}|g

    ## Conversion
    s|\{\{subcommand\}\}|{command subcommand}|g
    s|\{\{subcommand([[:digit:]])\}\}|{command subcommand \1}|g
    s|\{\{subcommand[[:digit:]]* +subcommand[[:digit:]]* +\.\.\.\}\}|{command* subcommand}|g

    # Processing extension placeholders.
    ## Expansion
    s|\{\{(extensions\|extension_*names)[[:digit:]]*\}\}|{{extension1 extension2 ...}}|g
    s|\{\{extension(_*name)?([[:digit:]]*)\}\}|{{extension\2}}|g
    s|\{\{extension(_*name)?[[:digit:]]* +extension(_*name)?[[:digit:]]* +\.\.\.\}\}|{{extension1 extension2 ...}}|g

    ## Conversion
    s|\{\{extension\}\}|{string extension}|g
    s|\{\{extension([[:digit:]])\}\}|{string extension \1}|g
    s|\{\{extension[[:digit:]]* +extension[[:digit:]]* +\.\.\.\}\}|{string* extension}|g

    # Processing device placeholders.
    ## Expansion
    s|\{\{(\/?)(devices\|device_*names)[[:digit:]]*\}\}|{{\1dev/sda1 \1dev/sda2 ...}}|g
    s|\{\{(\/?)device(_*name)?([[:digit:]]*)\}\}|{{\1dev/sda\3}}|g
    s|\{\{(\/?)device(_*name)?[[:digit:]]* +\1device(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1dev/sda1 \1dev/sda2 ...}}|g

    ## Conversion
    s|\{\{(\/?)dev/sd[[:alpha:]]\}\}|{\1file device}|g
    s|\{\{(\/?)dev/sd[[:alpha:]]([[:digit:]]+)\}\}|{\1file device \2}|g
    s|\{\{(\/?)dev/sd[[:alpha:]][[:digit:]]* +\1dev/sd[[:alpha:]][[:digit:]]* +\.\.\.\}\}|{\1file* device}|g

    # Processing file_or_directory like placeholders.
    ## Expansion
    ### General cases
    s|\{\{(\/?)(path/to/)?(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/file_or_directory1 \1path/to/file_or_directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/file_or_directory\6}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/file_or_directory1 \1path/to/file_or_directory2 ...}}|g

    ### Cases with prefix like excluded_path_or_directory
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files_+or_+dir(ectorie)?s\|file_*names_+or_+dir(ectorie)?s\|files_+or_+dir(ectory)?_*names\|file_*names_+or_+dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file_or_directory1 \1path/to/\3_file_or_directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file_or_directory\7}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?_+or_+dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file_or_directory1 \1path/to/\3_file_or_directory2 ...}}|g

    ## Conversion
    ### General cases
    s|\{\{(\/?)path/to/file_or_directory\}\}|{\1path some description}|g
    s|\{\{(\/?)path/to/file_or_directory([[:digit:]]+)\}\}|{\1path some description \2}|g
    s|\{\{(\/?)path/to/file_or_directory[[:digit:]]* +\1path/to/file_or_directory[[:digit:]]* +\.\.\.\}\}|{\1path* some description}|g

    ### Cases with prefix like excluded_path_or_directory
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file_or_directory\}\}|{\1path \2 file or directory}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file_or_directory([[:digit:]]+)\}\}|{\1path \2 file or directory \3}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file_or_directory[[:digit:]]* +\1path/to/\2_+file_or_directory[[:digit:]]* +\.\.\.\}\}|{\1path* \2 file or directory}|g

    # Processing file placeholders.
    ## Expansion
    ### General cases
    s|\{\{(\/?)(path/to/)?(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/file1 \1path/to/file2 ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/file\4}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?[[:digit:]]* +\1(path/to/)?file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/file1 \1path/to/file2 ...}}|g

    ### Cases with prefix like excluded_file
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file\5}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g

    ### Cases with optional extensions
    s|\{\{(\/?)(path/to/)?(files\|file_*names)[[:digit:]]*\[(\.[^{}| ]+)\]\}\}|{{\1path/to/file1[\4] \1path/to/file2[\4] ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?([[:digit:]]*)\[(\.[^{}| ]+)\]\}\}|{{\1path/to/file\4[\5]}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?[[:digit:]]*\[(\.[^{}| ]+)\] +\1(path/to/)?file(_*name)?[[:digit:]]*\[\4\] +\.\.\.\}\}|{{\1path/to/file1[\4] \1path/to/file2[\4] ...}}|g

    ### Cases with mandatory extension
    s|\{\{(\/?)(path/to/)?(files\|file_*names)[[:digit:]]*(\.[^{}| ]+)\}\}|{{\1path/to/file1\4 \1path/to/file2\4 ...}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?([[:digit:]]*)(\.[^{}| ]+)\}\}|{{\1path/to/file\4\5}}|g
    s|\{\{(\/?)(path/to/)?file(_*name)?[[:digit:]]*(\.[^{}| ]+) +\1(path/to/)?file(_*name)?[[:digit:]]*\4 +\.\.\.\}\}|{{\1path/to/file1\4 \1path/to/file2\4 ...}}|g

    ### Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\[(\.[^{}| ]+)\]\}\}|{{\1path/to/\3_file1[\5] \1path/to/\3_file2[\5] ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\[(\.[^{}| ]+)\]\}\}|{{\1path/to/\3_file\5[\6]}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]*\[(\.[^{}| ]+)\] +\1(path/to/)?\3_+file(_*name)?[[:digit:]]*\[\5\] +\.\.\.\}\}|{{\1path/to/\3_file1[\5] \1path/to/\3_file2[\5] ...}}|g

    ### Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*(\.[^{}| ]+)\}\}|{{\1path/to/\3_file1\5 \1path/to/\3_file2\5 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)(\.[^{}| ]+)\}\}|{{\1path/to/\3_file\5\6}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]*(\.[^{}| ]+) +\1(path/to/)?\3_+file(_*name)?[[:digit:]]*\5 +\.\.\.\}\}|{{\1path/to/\3_file1\5 \1path/to/\3_file2\5 ...}}|g

    ## Conversion
    ### General cases
    s|\{\{(\/?)path/to/file\}\}|{\1file some description}|g
    s|\{\{(\/?)path/to/file([[:digit:]]+)\}\}|{\1file some description \2}|g
    s|\{\{(\/?)path/to/file[[:digit:]]* +\1path/to/file[[:digit:]]* +\.\.\.\}\}|{\1file* some description}|g

    ### Cases with prefix like excluded_file
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file\}\}|{\1file \2 file}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)\}\}|{\1file \2 file \3}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file[[:digit:]]* +\1path/to/\2_+file[[:digit:]]* +\.\.\.\}\}|{\1file* \2 file}|g

    ### Cases with optional extensions
    s|\{\{(\/?)path/to/file\[(\.[^{}| ]+)\]\}\}|{\1file file with optional \2 extensions}|g
    s|\{\{(\/?)path/to/file([[:digit:]]+)\[(\.[^{}| ]+)\]\}\}|{\1file file \2 with optional \3 extensions}|g
    s|\{\{(\/?)path/to/file[[:digit:]]*\[(\.[^{}| ]+)\] +\1path/to/file[[:digit:]]*\[\2\] +\.\.\.\}\}|{\1file* file with optional \2 extensions}|g

    ### Cases with mandatory extension
    s|\{\{(\/?)path/to/file(\.[^{}| ]+)\}\}|{\1file file with mandatory \2 extension}|g
    s|\{\{(\/?)path/to/file([[:digit:]]+)(\.[^{}| ]+)\}\}|{\1file file \2 with mandatory \3 extension}|g
    s|\{\{(\/?)path/to/file[[:digit:]]*(\.[^{}| ]+) +\1path/to/+file[[:digit:]]*\2 +\.\.\.\}\}|{\1file* file with mandatory \2 extension}|g

    ### Cases with optional extensions and prefix like excluded_file[.txt,.jpeg]
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file\[(\.[^{}| ]+)\]\}\}|{\1file \2 file with optional \3 extensions}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)\[(\.[^{}| ]+)\]\}\}|{\1file \2 file \3 with optional \4 extensions}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file[[:digit:]]*\[(\.[^{}| ]+)\] +\1path/to/\2_+file[[:digit:]]*\[\3\] +\.\.\.\}\}|{\1file* \2 file with optional \3 extensions}|g

    ### Cases with mandatory extension and prefix like excluded_file.txt
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file(\.[^{}| ]+)\}\}|{\1file \2 file with mandatory \3 extension}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file([[:digit:]]+)(\.[^{}| ]+)\}\}|{\1file \2 file \3 with mandatory \4 extension}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+file[[:digit:]]*(\.[^{}| ]+) +\1path/to/\2_+file[[:digit:]]*\3 +\.\.\.\}\}|{\1file* \2 file with mandatory \3 extension}|g

    # Processing directory placeholders.
    ## Expansion
    ### General cases
    s|\{\{(\/?)(path/to/)?(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/directory1 \1path/to/directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/directory\5}}|g
    s|\{\{(\/?)(path/to/)?dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/directory1 \1path/to/directory2 ...}}|g

    ### Cases with prefix like excluded_file
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(files\|file_*names)[[:digit:]]*\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_file\5}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+file(_*name)?[[:digit:]]* +\1(path/to/)?\3_+file(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_file1 \1path/to/\3_file2 ...}}|g

    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+(dir(ectorie)?s\|dir(ectory)?_*names)[[:digit:]]*\}\}|{{\1path/to/\3_directory1 \1path/to/\3_directory2 ...}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+dir(ectory)?(_*name)?([[:digit:]]*)\}\}|{{\1path/to/\3_directory\6}}|g
    s|\{\{(\/?)(path/to/)?([^{}_ ]+)_+dir(ectory)?(_*name)?[[:digit:]]* +\1(path/to/)?\3_dir(ectory)?(_*name)?[[:digit:]]* +\.\.\.\}\}|{{\1path/to/\3_directory1 \1path/to/\3_directory2 ...}}|g

    ## Conversion
    ### General cases
    s|\{\{(\/?)path/to/directory\}\}|{\1directory some description}|g
    s|\{\{(\/?)path/to/directory([[:digit:]]+)\}\}|{\1directory some description \2}|g
    s|\{\{(\/?)path/to/directory[[:digit:]]* +\1path/to/directory[[:digit:]]* +\.\.\.\}\}|{\1directory* some description}|g

    ### Cases with prefix like excluded_file
    s|\{\{(\/?)path/to/([^{}_ ]+)_+directory\}\}|{\1directory \2 directory}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+directory([[:digit:]]+)\}\}|{\1directory \2 directory \3}|g
    s|\{\{(\/?)path/to/([^{}_ ]+)_+directory[[:digit:]]* +\1path/to/\2_+directory[[:digit:]]* +\.\.\.\}\}|{\1directory* \2 directory}|g

    # Processing boolean placeholders.
    ## Expansion
    s|\{\{(bool(ean)?s\|bool(ean)?_*values)[[:digit:]]*\}\}|{{boolean1 boolean2 ...}}|g
    s|\{\{bool(ean)?(_*value)?([[:digit:]]*)\}\}|{{boolean\3}}|g
    s|\{\{bool(ean)?(_*value)?[[:digit:]]* +bool(ean)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{boolean1 boolean2 ...}}|g

    ### Cases with prefix like default_boolean
    s|\{\{([^{}_ ]+)_+(bool(ean)?s\|bool(ean)?_*values)[[:digit:]]*\}\}|{{\1_boolean1 \1_boolean2 ...}}|g
    s|\{\{([^{}_ ]+)_+bool(ean)?(_*value)?([[:digit:]]*)\}\}|{{\1_boolean\4}}|g
    s|\{\{([^{}_ ]+)_+bool(ean)?(_*value)?[[:digit:]]* +\1_+bool(ean)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_boolean1 \1_boolean2 ...}}|g

    ## Conversion
    # General cases
    s|\{\{boolean\}\}|{bool some description}|g
    s|\{\{boolean([[:digit:]])\}\}|{bool some description \1}|g
    s|\{\{boolean[[:digit:]]* +boolean[[:digit:]]* +\.\.\.\}\}|{bool* some description}|g
    s|\{\{(true\|false\|yes\|no)\}\}|{bool some description: \1}|g
    s/\{\{(true|false|yes|no)\|(true|false|yes|no)\}\}/{bool some description: \1, \2}/g

    ### Cases with prefix like default_boolean
    s|\{\{([^{}_ ]+)_+boolean\}\}|{bool \1 boolean}|g
    s|\{\{([^{}_ ]+)_+boolean([[:digit:]])\}\}|{bool \1 boolean \2}|g
    s|\{\{([^{}_ ]+)_+boolean[[:digit:]]* +\1_+boolean[[:digit:]]* +\.\.\.\}\}|{bool* \1 boolean}|g

    # Processing char placeholders.
    ## Expansion
    ### General cases
    s|\{\{(char(acter)?s\|char(acter)?_*values)[[:digit:]]*\}\}|{{character1 character2 ...}}|g
    s|\{\{char(acter)?(_*value)?([[:digit:]]*)\}\}|{{character\3}}|g
    s|\{\{char(acter)?(_*value)?[[:digit:]]* +char(acter)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{character1 character2 ...}}|g

    ### Cases with prefix like default_character
    s|\{\{([^{}_ ]+)_+(char(acter)?s\|char(acter)?_*values)[[:digit:]]*\}\}|{{\1_character1 \1_character2 ...}}|g
    s|\{\{([^{}_ ]+)_+char(acter)?(_*value)?([[:digit:]]*)\}\}|{{\1_character\4}}|g
    s|\{\{([^{}_ ]+)_+char(acter)?(_*value)?[[:digit:]]* +\1_+char(acter)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_character1 \1_character2 ...}}|g

    ## Conversion
    ### General cases
    s|\{\{character\}\}|{char some description}|g
    s|\{\{character([[:digit:]])\}\}|{char some description \1}|g
    s|\{\{character[[:digit:]]* +character[[:digit:]]* +\.\.\.\}\}|{char* some description}|g
    s|\{\{([^0-9])\}\}|{char some description: \1}|g

    ### Cases with prefix like default_character
    s|\{\{([^{}_ ]+)_+character\}\}|{char \1 character}|g
    s|\{\{([^{}_ ]+)_+character([[:digit:]])\}\}|{char \1 character \2}|g
    s|\{\{([^{}_ ]+)_+character[[:digit:]]* +\1_+character[[:digit:]]* +\.\.\.\}\}|{char* \1 character}|g

    # Processing string placeholders.
    ## Expansion
    ### General cases
    s|\{\{(str(ing)?s\|str(ing)?_*values)[[:digit:]]*\}\}|{{string1 string2 ...}}|g
    s|\{\{str(ing)?(_*value)?([[:digit:]]*)\}\}|{{string\3}}|g
    s|\{\{str(ing)?(_*value)?[[:digit:]]* +str(ing)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{string1 string2 ...}}|g

    ### Cases with prefix like default_string
    s|\{\{([^{}_ ]+)_+(str(ing)?s\|str(ing)?_*values)[[:digit:]]*\}\}|{{\1_string1 \1_string2 ...}}|g
    s|\{\{([^{}_ ]+)_+str(ing)?(_*value)?([[:digit:]]*)\}\}|{{\1_string\4}}|g
    s|\{\{([^{}_ ]+)_+str(ing)?(_*value)?[[:digit:]]* +\1_+str(ing)?(_*value)?[[:digit:]]* +\.\.\.\}\}|{{\1_string1 \1_string2 ...}}|g

    ## Conversion
    ### General cases
    s|\{\{string\}\}|{string some description}|g
    s|\{\{string([[:digit:]])\}\}|{string some description \1}|g
    s|\{\{string[[:digit:]]* +string[[:digit:]]* +\.\.\.\}\}|{string* some description}|g

    ### Cases with prefix like default_string
    s|\{\{([^{}_ ]+)_+string\}\}|{string \1 string}|g
    s|\{\{([^{}_ ]+)_+string([[:digit:]])\}\}|{string \1 string \2}|g
    s|\{\{([^{}_ ]+)_+string[[:digit:]]* +\1_+string[[:digit:]]* +\.\.\.\}\}|{string* \1 string}|g
q
    # Expanding singular placeholders without /path/to prefix for futher processing.
    s/\{\{(\/?)dev\/sd.([[:digit:]]*)\}\}/{{\1path\/to\/device_file\2}}/g
    s/\{\{char(acter)?([[:digit:]]*)\}\}/{{character\2}}/g

    s/\{\{(\/?)device([[:digit:]]*)\}\}/{{\1path\/to\/device_file\2}}/g
    s/\{\{(\/?)(file|executable|program|script|source)_or_directory([[:digit:]]*)\}\}/{{\1path\/to\/file_or_directory\3}}/g

    s/\{\{(\/?)(file|executable|program|script|source)_?(name)?([[:digit:]]*)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file\4\5}}/g
    s/\{\{(\/?)dir(ectory)?_?(name)?([[:digit:]]*)\}\}/{{\1path\/to\/directory\4}}/g

    s/\{\{(\/?)(([^{}/]+)_)(file|executable|program|script|source)_?(name)?([[:digit:]]*)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file\6\7}}/g
    s/\{\{(\/?)(([^{}/]+)_)dir(ectory)?_?(name)?([[:digit:]]*)\}\}/{{\1path\/to\/\3_directory\6}}/g

    # Expanding plural placeholders without path/to prefix for futher processing.
    s/\{\{(char(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|char_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|character(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|character_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}))\}\}/{{character1 character2 ...}}/g
    s/\{\{(\/?)(device(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|device_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}))\}\}/{{\1path\/to\/device_file1 \1path\/to\/device_file2 ...}}/g
    s/\{\{(user(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|user_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}))\}\}/{{user1 user2 ...}}/g
    s/\{\{(group(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|group_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}))\}\}/{{group1 group2 ...}}/g
    s/\{\{(url(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|url_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}))\}\}/{{url1 url2 ...}}/g
    s/\{\{(ip(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|ip_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}))\}\}/{{ip1 ip2 ...}}/g
    s/\{\{(db(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|db_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|database(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})|database_?name(s|\(s\)|\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}))\}\}/{{database1 database2 ...}}/g

    s/\{\{(\/?)(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g

    s/\{\{(\/?)(([^{}/]+)_)(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)(([^{}/]+)_)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g


    s/\{\{(\/?)(file\(s\)|file_?name\(s\)|executable\(s\)|executable_?name\(s\)|program\(s\)|program_?name\(s\)|script\(s\)|script_?name\(s\)|source\(s\)|source_?name\(s\))((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)(dir\(s\)|directory\(s\)|directory_?name\(s\))\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g

    s/\{\{(\/?)(([^{}/]+)_)(file\(s\)|file_?name\(s\)|executable\(s\)|executable_?name\(s\)|program\(s\)|program_?name\(s\)|script\(s\)|script_?name\(s\)|source\(s\)|source_?name\(s\))((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)(([^{}/]+)_)(dir\(s\)|directory\(s\)|directory_?name\(s\))\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g


    s/\{\{(\/?)(file\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|file_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)(dir\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g

    s/\{\{(\/?)(([^{}/]+)_)(file\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|file_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)(([^{}/]+)_)(dir\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g

    # Expanding plural placeholders with path/to prefix for futher processing.
    s/\{\{(\/?)path\/to\/(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)path\/to\/(dirs|directories|directory_?names)\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g
    
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g


    s/\{\{(\/?)path\/to\/(file\(s\)|file_?name\(s\)|executable\(s\)|executable_?name\(s\)|program\(s\)|program_?name\(s\)|script\(s\)|script_?name\(s\)|source\(s\)|source_?name\(s\))((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)path\/to\/(dir\(s\)|directory\(s\)|directory_?name\(s\))\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g
    
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(file\(s\)|file_?name\(s\)|executable\(s\)|executable_?name\(s\)|program\(s\)|program_?name\(s\)|script\(s\)|script_?name\(s\)|source\(s\)|source_?name\(s\))((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(dir\(s\)|directory\(s\)|directory_?name\(s\))\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g


    s/\{\{(\/?)path\/to\/(file\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|file_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)path\/to\/(dir\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g
    
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(file\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|file_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|executable_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|program_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|script_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|source_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(dir\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\}|directory_?name\{[[:digit:]]+,[[:digit:]]+(,[[:digit:]]+)*\})\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g

    # Converting singular boolean placeholders.
    s/\{\{(true|false|yes|no)[[:digit:]]*\}\}/{bool flag: \1}/g

    # Converting singular int/float placeholders.
    s/\{\{([-+]?[[:digit:]]+)\}\}/{int value: \1}/g
    s/\{\{([-+]?[[:digit:]]+\.[[:digit:]]+)\}\}/{float value: \1}/g

    # Converting singular character placeholders.
    s/\{\{character[[:digit:]]*\}\}/{char value}/g

    # Converting plural character placeholders.
    s/\{\{character[[:digit:]]+ +character[[:digit:]]+ +\.\.\.\}\}/{char* value}/g

    # Converting paired option placeholders.
    s/\{\{(--[^{} =:|]+)\|(-[^{} =:|]+)\}\}/{option flag: \1, \2}/g
    s/\{\{(-[^{} =:|]+)\|(--[^{} =:|]+)\}\}/{option flag: \2, \1}/g

    # Converting singular option placeholders.
    s/\{\{(--?[^{} =:]+)\}\}/{option flag: \1}/g

    # Converting singular range placeholders.
    s/\{\{([-+]?[[:digit:]]+)(\.\.|-)([-+]?[[:digit:]]+)\}\}/{int range: \1..\3}/g
    s/\{\{([-+]?[[:digit:]]+\.[[:digit:]]+)(\.\.|-)([-+]?[[:digit:]]+\.[[:digit:]]+)\}\}/{float range: \1..\3}/g

    # Converting singular special placeholders.
    s/\{\{user_?(name)?[[:digit:]]*\}\}/{string user}/g
    s/\{\{group_?(name)?[[:digit:]]*\}\}/{string group}/g
    s/\{\{url_?(name)?[[:digit:]]*\}\}/{string url}/g
    s/\{\{ip_?(name)?[[:digit:]]*\}\}/{string ip}/g
    s/\{\{db_?(name)?[[:digit:]]*\}\}/{string database}/g

    # Converting plural special placeholders.
    s/\{\{user[[:digit:]]+ +user[[:digit:]]+ +\.\.\.\}\}/{string* user}/g
    s/\{\{group[[:digit:]]+ +group[[:digit:]]+ +\.\.\.\}\}/{string* group}/g
    s/\{\{url[[:digit:]]+ +url[[:digit:]]+ +\.\.\.\}\}/{string* url}/g
    s/\{\{ip[[:digit:]]+ +ip[[:digit:]]+ +\.\.\.\}\}/{string* ip}/g
    s/\{\{database[[:digit:]]+ +database[[:digit:]]+ +\.\.\.\}\}/{string* database}/g

    # Converting singular path placeholders.
    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_or_directory[[:digit:]]*\}\}/{\1path value}/g

    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]*\}\}/{\1file value}/g
    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]*(\.[^.{}]+)\}\}/{\1file value: sample\4}/g
    s/\{\{(\/?)path\/to\/dir(ectory)?_?(name)?[[:digit:]]*\}\}/{\1directory value}/g

    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(file|executable|program|script|source)_?(name)?[[:digit:]]*((\.[^.{}]+)?)\}\}/{\1file value: \3\6}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)?dir(ectory)?_?(name)?[[:digit:]]*\}\}/{\1directory value: \3}/g

    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_or_directory[[:digit:]]+ +\1path\/to\/\2_or_directory[[:digit:]]+ +\.\.\.\}\}/{\1path* value}/g

    # Converting plural path placeholders.
    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]+ +\1path\/to\/\2_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1file* value}/g
    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]+(\.[^.{}]+) +\1path\/to\/\2_?(name)?[[:digit:]]+\4 +\.\.\.\}\}/{\1file* value: sample\4}/g
    s/\{\{(\/?)path\/to\/dir(ectory)?_?(name)?[[:digit:]]+ +\1path\/to\/dir(ectory)?_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1directory* value}/g

    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(file|executable|program|script|source)_?(name)?[[:digit:]]+((\.[^.{}]+)?) \1path\/to\/\2\4_?(name)?[[:digit:]]+\6 +\.\.\.\}\}/{\1file* value: \3\6}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)dir(ectory)?_?(name)?[[:digit:]]+ \1path\/to\/\2dir(ectory)?_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1directory* value: \3}/g

    # Omptimizing Better TlDr placeholders
    s/\{(\/?)([^ {}:]+) +([^:{}]+)\} +\{\1\2\*\ \3}/{\1\2+ \3}/g
    s/\{(\/?)([^ {}:]+) +([^:{}]+):( +[^{}]+)\} +\{\1\2\*\ \3:\4}/{\1\2+ \3:\4}/g


    s/\{\{([^{}]+)\}\}/{string value: \1}/g

  }' <<<"$file_content"
}

check_dependencies_correctness || exit "$FAIL"

if (($# == 0)); then
  help
fi

declare output_directory
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
      echo -e "$PROGRAM_NAME: --output-directory: ${ERROR_COLOR}directory expected$RESET_COLOR" >&2
      exit "$FAIL"
    }
    output_directory="$value"
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
    clip_content="$(convert "$tldr_file")"
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
