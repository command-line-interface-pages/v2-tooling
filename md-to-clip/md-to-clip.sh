#!/usr/bin/env bash

# shellcheck disable=2016,2155

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
  $PROGRAM_NAME $HELP_PUNCTUATION_COLOR[($HELP_OPTION_COLOR--output-directory$HELP_PUNCTUATION_COLOR|$HELP_OPTION_COLOR-od$HELP_PUNCTUATION_COLOR) $HELP_PLACEHOLDER_COLOR<directory>$HELP_PUNCTUATION_COLOR] $HELP_PLACEHOLDER_COLOR<file1.md file2.md ...>

${HELP_HEADER_COLOR}Converters:$HELP_TEXT_COLOR
  - 'More information' and 'See also' tags simplification
  - Placeholder conversion and optimization

${HELP_HEADER_COLOR}Notes:$HELP_TEXT_COLOR
  Escaping and placeholders with alternatives are not recognized and treated literally."
}

version() {
  echo "1.1" >&2
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
  declare page_content="$1

"

  sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<<"$page_content"
}

convert() {
  declare in_file="$1"

  declare file_content="$(cat "$in_file")"
  declare program_name="$(basename "$PROGRAM_NAME")"

  check_layout_correctness "$file_content" || {
    echo -e "$program_name: $in_file: ${ERROR_COLOR}valid page layout expected$RESET_COLOR" >&2
    return "$FAIL"
  }

  sed -E '/^>/ {
    s/\.$//
    s/More +information: <(.*)>$/More information: \1/

    /See +also/ {
      s/[, ] +or +/, /g
      s/`//g
    }
  }
  
  /^-/ {
    s/`(std(in|out|err))`/\1/g
    s/standard +input( +stream)?/stdin/g
    s/standard +output( +stream)?/stdout/g
    s/standard +error( +stream)?/stderr/g
  }
  
  /^`/ {
    # correcting broken TlDr placeholders
    s/ *\{\{\.\.\.\}\} */ /g

    s/\{\{(\/?)dev\/sd.([[:digit:]]*)\}\}/{{\1path\/to\/device_file\2}}/g
    s/\{\{(\/?)(file|executable|program|script|source)_or_directory([[:digit:]]*)\}\}/{{\1path\/to\/file_or_directory\3}}/g

    s/\{\{(\/?)(file|executable|program|script|source)_?(name)?([[:digit:]]*)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file\4\5}}/g
    s/\{\{(\/?)dir(ectory)?_?(name)?([[:digit:]]*)\}\}/{{\1path\/to\/directory\4}}/g

    s/\{\{(\/?)(([^{}/]+)_)(file|executable|program|script|source)_?(name)?([[:digit:]]*)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file\6\7}}/g
    s/\{\{(\/?)(([^{}/]+)_)directory([[:digit:]]*)\}\}/{{\1path\/to\/\3_directory\4}}/g

    s/\{\{(\/?)(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g

    s/\{\{(\/?)(([^{}/]+)_)(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)(([^{}/]+)_)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g

    s/\{\{(\/?)path\/to\/(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)path\/to\/(dirs|directories|directory_?names)\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g

    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(files|file_?names|executables|executable_?names|programs|program_?names|scripts|script_?names|sources|source_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g

    # converting TlDr placeholders to Better TlDr placeholders
    s/\{\{(true|false|yes|no)[[:digit:]]*\}\}/{bool flag: \1}/g

    s/\{\{([-+]?[[:digit:]]+)\}\}/{int value: \1}/g
    s/\{\{([-+]?[[:digit:]]+\.[[:digit:]]+)\}\}/{float value: \1}/g

    s/\{\{character[[:digit:]]*\}\}/{char value}/g

    s/\{\{([-+]?[[:digit:]]+)(\.\.|-)([-+]?[[:digit:]]+)\}\}/{int range: \1..\3}/g
    s/\{\{([-+]?[[:digit:]]+\.[[:digit:]]+)(\.\.|-)([-+]?[[:digit:]]+\.[[:digit:]]+)\}\}/{float range: \1..\3}/g

    s/\{\{user_?name[[:digit:]]*\}\}/{string user}/g
    s/\{\{group_?name[[:digit:]]*\}\}/{string group}/g
    s/\{\{url[[:digit:]]*\}\}/{string url}/g
    s/\{\{ip[[:digit:]]*\}\}/{string ip}/g
    s/\{\{db[[:digit:]]*\}\}/{string database}/g


    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_or_directory[[:digit:]]*\}\}/{\1path value}/g

    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]*\}\}/{\1file value}/g
    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]*(\.[^.{}]+)\}\}/{\1file value: sample\4}/g
    s/\{\{(\/?)path\/to\/dir(ectory)?_?(name)?[[:digit:]]*\}\}/{\1directory value}/g

    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(file|executable|program|script|source)_?(name)?[[:digit:]]*((\.[^.{}]+)?)\}\}/{\1file value: \3\6}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)?dir(ectory)?_?(name)?[[:digit:]]*\}\}/{\1directory value: \3}/g

    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_or_directory[[:digit:]]+ +\1path\/to\/\2_or_directory[[:digit:]]+ +\.\.\.\}\}/{\1path* value}/g

    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]+ +\1path\/to\/\2_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1file* value}/g
    s/\{\{(\/?)path\/to\/(file|executable|program|script|source)_?(name)?[[:digit:]]+(\.[^.{}]+) +\1path\/to\/\2_?(name)?[[:digit:]]+\4 +\.\.\.\}\}/{\1file* value: sample\4}/g
    s/\{\{(\/?)path\/to\/dir(ectory)?_?(name)?[[:digit:]]+ +\1path\/to\/dir(ectory)?_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1directory* value}/g

    s/\{\{(\/?)path\/to\/(([^{}/]+)_)(file|executable|program|script|source)_?(name)?[[:digit:]]+((\.[^.{}]+)?) \1path\/to\/\2\4_?(name)?[[:digit:]]+\6 +\.\.\.\}\}/{\1file* value: \3\6}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)dir(ectory)?_?(name)?[[:digit:]]+ \1path\/to\/\2dir(ectory)?_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1directory* value: \3}/g

    # omptimizing Better TlDr placeholders
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
    if [[ -z "$output_directory" ]]; then
      clip_file="$(dirname "$tldr_file")/$clip_file"
    else
      clip_file="$output_directory/$clip_file"
    fi

    declare clip_content
    clip_content="$(convert "$tldr_file")"
    (($? != 0)) && exit "$FAIL"

    echo "$clip_content" >"$clip_file"

    echo -e "$PROGRAM_NAME: $tldr_file: ${SUCCESS_COLOR}converted to $clip_file$RESET_COLOR" >&2
    shift
    ;;
  esac
done

exit "$SUCCESS"
