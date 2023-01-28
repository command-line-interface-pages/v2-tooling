#!/usr/bin/env bash

# shellcheck disable=2016,2155

declare -i SUCCESS=0
declare -i FAIL=1

declare RESET_COLOR="\e[0m"
declare ERROR_COLOR="\e[31m"
declare SUCCESS_COLOR="\e[32m"

help() {
  echo "Converter from TlDr format to Better TlDr format.

Usage:
  $0 (--help|-h)
  $0 (--version|-v)
  $0 (--author|-a)
  $0 (--email|-e)
  $0 [(--output-directory|-od) <directory>] <file1.md file2.md ...>

Notes:
  Output files are created in the same directories where the original ones existed.
  Escaping is not supported."
}

version() {
  echo "1.0" >&2
}

author() {
  echo "Emily Grace Seville" >&2
}

email() {
  echo "EmilySeville7cfg@gmail.com" >&2
}

convert() {
  declare page_file="$1"
  declare page_content="$(cat "$page_file")

"

  sed -nE ':x; N; $! bx; /^# [^\n]+\n\n(> [^\n]+\n)+\n(- [^\n]+:\n\n`[^\n]+`\n\n)+$/! Q1' <<< "$page_content" || {
    echo -e "$0: $page_file: ${ERROR_COLOR}valid page layout expected$RESET_COLOR" >&2
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
    s/\{\{(\/?)file_or_directory([[:digit:]]*)\}\}/{{\1path\/to\/file_or_directory\2}}/g

    s/\{\{(\/?)file_?(name)?([[:digit:]]*)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file\3\4}}/g
    s/\{\{(\/?)directory([[:digit:]]*)\}\}/{{\1path\/to\/directory\2}}/g

    s/\{\{(\/?)(([^{}/]+)_)file_?(name)?([[:digit:]]*)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file\5\6}}/g
    s/\{\{(\/?)(([^{}/]+)_)directory([[:digit:]]*)\}\}/{{\1path\/to\/\3_directory\4}}/g

    s/\{\{(\/?)(files|file_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g

    s/\{\{(\/?)(([^{}/]+)_)(files|file_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)(([^{}/]+)_)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g

    # converting TlDr placeholders to Better TlDr placeholders
    s/\{\{(true|false|yes|no)[[:digit:]]*\}\}/{bool flag: \1}/g

    s/\{\{([-+]?[[:digit:]]+)\}\}/{int value: \1}/g
    s/\{\{([-+]?[[:digit:]]+\.[[:digit:]]+)\}\}/{float value: \1}/g

    s/\{\{character[[:digit:]]*\}\}/{char value}/g

    s/\{\{([-+]?[[:digit:]]+)\.\.([-+]?[[:digit:]]+)\}\}/{int range: \1..\2}/g
    s/\{\{([-+]?[[:digit:]]+\.[[:digit:]]+)\.\.([-+]?[[:digit:]]+\.[[:digit:]]+)\}\}/{float range: \1..\2}/g

    s/\{\{user_?name[[:digit:]]*\}\}/{string user}/g
    s/\{\{group_?name[[:digit:]]*\}\}/{string group}/g
    s/\{\{url[[:digit:]]*\}\}/{string url}/g
    s/\{\{ip[[:digit:]]*\}\}/{string ip}/g
    s/\{\{db[[:digit:]]*\}\}/{string database}/g


    s/\{\{(\/?)path\/to\/file_or_directory[[:digit:]]*\}\}/{\1path value}/g

    s/\{\{(\/?)path\/to\/file_?(name)?[[:digit:]]*\}\}/{\1file value}/g
    s/\{\{(\/?)path\/to\/file_?(name)?[[:digit:]]*(\.[^.{}]+)\}\}/{\1file value: sample\3}/g
    s/\{\{(\/?)path\/to\/dir(ectory)?_?(name)?[[:digit:]]*\}\}/{\1directory value}/g

    s/\{\{(\/?)path\/to\/(([^{}/]+)_)file_?(name)?[[:digit:]]*((\.[^.{}]+)?)\}\}/{\1file value: \3\5}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)?dir(ectory)?_?(name)?[[:digit:]]*\}\}/{\1directory value: \3}/g

    s/\{\{(\/?)path\/to\/file_or_directory[[:digit:]]+ +\1path\/to\/file_or_directory[[:digit:]]+ +\.\.\.\}\}/{\1path* value}/g

    s/\{\{(\/?)path\/to\/file_?(name)?[[:digit:]]+ +\1path\/to\/file_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1file* value}/g
    s/\{\{(\/?)path\/to\/file_?(name)?[[:digit:]]+(\.[^.{}]+) +\1path\/to\/file_?(name)?[[:digit:]]+\3 +\.\.\.\}\}/{\1file* value: sample\3}/g
    s/\{\{(\/?)path\/to\/dir(ectory)?_?(name)?[[:digit:]]+ +\1path\/to\/dir(ectory)?_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1directory* value}/g

    s/\{\{(\/?)path\/to\/(([^{}/]+)_)file_?(name)?[[:digit:]]+((\.[^.{}]+)?) \1path\/to\/\2file_?(name)?[[:digit:]]+\5 +\.\.\.\}\}/{\1file* value: \3\5}/g
    s/\{\{(\/?)path\/to\/(([^{}/]+)_)dir(ectory)?_?(name)?[[:digit:]]+ \1path\/to\/\2dir(ectory)?_?(name)?[[:digit:]]+ +\.\.\.\}\}/{\1directory* value: \3}/g


    # omptimizing Better TlDr placeholders
    s/\{(\/?)([^ {}:]+) +([^:{}]+)\} +\{\1\2\*\ \3}/{\1\2+ \3}/g
    s/\{(\/?)([^ {}:]+) +([^:{}]+):( +[^{}]+)\} +\{\1\2\*\ \3:\4}/{\1\2+ \3:\4}/g


    s/\{\{([^{}]+)\}\}/{string value: \1}/g

  }' <<< "$page_content"
}


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
      echo -e "$0: --output-directory: ${ERROR_COLOR}directory expected$RESET_COLOR" >&2
      exit "$FAIL"
    }
    output_directory="$value"
    shift 2
    ;;
  *)
    declare tldr_file="$option"
    declare btldr_file="$(sed -E 's/.*\///; s/\.md$/.btldr/' <<< "$tldr_file")"
    if [[ -z "$output_directory" ]]; then
      btldr_file="$(dirname "$tldr_file")/$btldr_file"
    else
      btldr_file="$output_directory/$btldr_file"
    fi

    declare btldr_content
    btldr_content="$(convert "$tldr_file")"
    (($? != 0)) && exit "$FAIL"

    echo "$btldr_content" > "$btldr_file"

    echo -e "$0: $tldr_file: ${SUCCESS_COLOR}converted to $btldr_file$RESET_COLOR" >&2
    shift
    ;;
  esac
done

exit "$SUCCESS"
