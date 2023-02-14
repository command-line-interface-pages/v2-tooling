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
    s|\{\{user_*name?([[:digit:]]*)\}\}|{{user\1}}|g
    s|\{\{user_*name?[[:digit:]]* +user_*name?[[:digit:]]* +\.\.\.\}\}|{{user1 user2 ...}}|g

    ## Conversion
    s|\{\{user\}\}|{string user}|g
    s|\{\{user([[:digit:]])\}\}|{string user \1}|g
    s|\{\{user[[:digit:]]* +user[[:digit:]]* +\.\.\.\}\}|{string* user}|g
  
    # Processing device placeholders.
    ## Expansion
    s|\{\{(\/?)(devices\|device_*names)[[:digit:]]*\}\}|{{\1dev/sda1 \1dev/sda2 ...}}|g
    s|\{\{(\/?)device(_*(name))?([[:digit:]]*)\}\}|{{\1dev/sda\4}}|g
    s|\{\{(\/?)device(_*(name))?[[:digit:]]+ +\1device(_*(name))?[[:digit:]]+ +\.\.\.\}\}|{{\1dev/sda1 \1dev/sda2 ...}}|g

    ## Conversion
    s|\{\{(\/?)dev/sd[[:alpha:]]\}\}|{\1file device}|g
    s|\{\{(\/?)dev/sd[[:alpha:]]([[:digit:]]+)\}\}|{\1file device \2}|g
    s|\{\{(\/?)dev/sd[[:alpha:]][[:digit:]]* +\1dev/sd[[:alpha:]][[:digit:]]* +\.\.\.\}\}|{\1file* device}|g
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
