#!/usr/bin/env bash

# shellcheck disable=2016,2155

declare -i SUCCESS=0
declare -i FAIL=1

declare RESET_COLOR="\e[31m"
declare ERROR_COLOR="\e[31m"
declare SUCCESS_COLOR="\e[32m"

help() {
  echo "Converter from TlDr format to Better TlDr format.

Usage:
  $0 (--help|-h)
  $0 (--version|-v)
  $0 (--author|-a)
  $0 (--email|-e)
  $0 <file1.md file2.md ...>

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
    echo -e "$0: $page_file: ${ERROR_COLOR}invalid page layout$RESET_COLOR" >&2
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
    s/\{\{(\/?)dev\/sd.\}\}/{{\1path\/to\/device_file}}/g

    s/\{\{(\/?)file_?(name)?((\.[^.{}]+)?)\}\}/{{\1path\/to\/file\3}}/g
    s/\{\{(\/?)directory\}\}/{{\1path\/to\/directory}}/g

    s/\{\{(\/?)(([^{}/]+)_)file_?(name)?((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file\5}}/g
    s/\{\{(\/?)(([^{}/]+)_)directory\}\}/{{\1path\/to\/\3_directory}}/g

    s/\{\{(\/?)(files|file_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/file1\3 \1path\/to\/file2\3 ...}}/g
    s/\{\{(\/?)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/directory1 \1path\/to\/directory2 ...}}/g

    s/\{\{(\/?)(([^{}/]+)_)(files|file_?names)((\.[^.{}]+)?)\}\}/{{\1path\/to\/\3_file1\5 \1path\/to\/\3_file2\5 ...}}/g
    s/\{\{(\/?)(([^{}/]+)_)(dirs|directories|directory_?names)\}\}/{{\1path\/to\/\3_directory1 \1path\/to\/\3_directory2 ...}}/g
  }' <<< "$page_content"
}


if (($# == 0)); then
  help
fi

while [[ -n "$1" ]]; do
  declare option="$1"

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
  *)
    declare tldr_file="$option"
    declare btldr_file="$(dirname "$tldr_file")/$(sed -E 's/.*\///; s/\.md$/.btldr/' <<< "$tldr_file")"
    declare btldr_content
    btldr_content="$(convert "$tldr_file")"
    (($? != 0)) && exit $FAIL

    echo "$btldr_content" > "$btldr_file"

    echo -e "$0: $tldr_file: ${SUCCESS_COLOR}converted to $btldr_file$RESET_COLOR" >&2
    exit
    ;;
  esac
done

exit "$SUCCESS"
