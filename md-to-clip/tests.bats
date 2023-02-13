#!/usr/bin/env bats

# bats test_tags=layout
@test "expect layout error when empty page is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/empty_page.md"
}

# bats test_tags=layout
@test "expect layout error when page without header is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_header.md"
}

# bats test_tags=layout
@test "expect layout error when page without summary is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_summary.md"
}

# bats test_tags=layout
@test "expect layout error when page without examples is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_examples.md"
}

# bats test_tags=layout
@test "expect no layout error when valid page is passed" {
  ./md-to-clip.sh "./tests/inputs/valid/page.md"
}


# bats test_tags=header
@test "expect no header conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page.md' | sed -n '1p'"
  [[ "$output" == "# am" ]]
}


# bats test_tags=summary, description
@test "expect no summary description conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page.md' | sed -nE '/^> [^:]+$/p'"
  [[ "$output" == "> Android activity manager" ]]
}

# bats test_tags=summary, more-information
@test "expect no summary 'More information' conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page_with_more_information.md' | sed -nE '/^> More +information:/p'"
  [[ "$output" == "> More information: https://some/documentation/url" ]]
}

# bats test_tags=summary, see-also
@test "expect no summary 'See also' conversion error when valid page is passed" {
  run bash -c "./md-to-clip.sh -nfs './tests/inputs/valid/page_with_see_also.md' | sed -nE '/^> See also:/p'"
  [[ "$output" == "> See also: command1, command2" ]]
}

# bats test_tags=example, description, stream, stdin
@test "expect no stdin stream conversion error when valid page && stream inside backticks passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- \`stdin\`:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdin:" ]]
}

# bats test_tags=example, description, stream, stdin
@test "expect no stdin stream conversion error when valid page && full stream name passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard input:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdin:" ]]
}

# bats test_tags=example, description, stream, stdin
@test "expect no stdin stream conversion error when valid page && full stream name && stream keyword passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard input stream:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdin:" ]]
}

# bats test_tags=example, description, stream, stdout
@test "expect no stdout stream conversion error when valid page && stream inside backticks passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- \`stdout\`:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdout:" ]]
}

# bats test_tags=example, description, stream, stdout
@test "expect no stdout stream conversion error when valid page && full stream name passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard output:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdout:" ]]
}

# bats test_tags=example, description, stream, stdout
@test "expect no stdout stream conversion error when valid page && full stream name && stream keyword passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard output stream:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stdout:" ]]
}

# bats test_tags=example, description, stream, stderr
@test "expect no stderr stream conversion error when valid page && stream inside backticks passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- \`stderr\`:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stderr:" ]]
}

# bats test_tags=example, description, stream, stderr
@test "expect no stderr stream conversion error when valid page && full stream name passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard error:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stderr:" ]]
}

# bats test_tags=example, description, stream, stderr
@test "expect no stderr stream conversion error when valid page && full stream name && stream keyword passed" {
  run bash -c "./md-to-clip.sh -nfs <(echo '# some

> Some text.

- standard error stream:

\`some\`') | sed -nE '/^- /p'"
  [[ "$output" == "- stderr:" ]]
}

@test "expect no ellipsis removal error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'`some  {{...}}  --  {{...}}  `') | sed -nE '/^`/p')"
  [[ "$output" == '`some -- `' ]]
}

@test "expect no singular device placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  declare prefixes=("" /)
  declare suffixes=("" 1)
  declare input_contents=(dev/sda device)

  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$prefix$content$suffix}}\`") | sed -nE '/^`/p')"
        [[ "$output" == "\`some {${prefix}file value: device}\`" ]]
      done
    done
  done
}

@test "expect no plural device placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  declare prefixes=("" /)
  declare suffixes=(names _names
    "name(s)" "_name(s)"
    "name{1,2,3}" "_name{1,2,3}")
  declare input_contents=(device)

  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$prefix$content$suffix}}\`") | sed -nE '/^`/p')"
        [[ "$output" == "\`some {${prefix}file* value: device}\`" ]]
      done
    done
  done
}

@test "expect no singular character placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{char}} {{character}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {char value} {char value}`' ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{char1}} {{character1}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {char value} {char value}`' ]]
}

@test "expect no plural character placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  declare suffixes=(s "(s)" "{1,2,3}"
    names _names
    "name(s)" "_name(s)"
    "name{1,2,3}" "_name{1,2,3}")
  declare input_contents=(char character)

  for suffix in "${suffixes[@]}"; do
    for content in "${input_contents[@]}"; do
      declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$content$suffix}}\`") | sed -nE '/^`/p')"
      [[ "$output" == "\`some {char* value}\`" ]]
    done
  done
}

@test "expect no singular path placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  declare prefixes=(file "/file"
    executable "/executable"
    program "/program"
    script "/script"
    source "/source")
  declare suffixes=("" 1)
  declare input_contents=(_or_directory)

  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$prefix$content$suffix}}\`") | sed -nE '/^`/p')"
        declare output_content_prefix=""
        [[ "$prefix" =~ ^'/' ]] && output_content_prefix=/
        [[ "$output" == "\`some {${output_content_prefix}path value}\`" ]]
      done
    done
  done
}

@test "expect no singular file placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  declare prefixes=("" /)
  declare suffixes=("" name _name
    1 name1 _name1)
  declare input_contents=(file executable program script source)

  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$prefix$content$suffix}}\`") | sed -nE '/^`/p')"
        [[ "$output" == "\`some {${prefix}file value}\`" ]]
      done
    done
  done

  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{${prefix}image_$content$suffix}}\`") | sed -nE '/^`/p')"
        [[ "$output" == "\`some {${prefix}file value: image}\`" ]]
      done
    done
  done
}

@test "expect no singular file placeholder with extension conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  declare prefixes=("" /)
  declare suffixes=("" name _name
    1 name1 _name1)
  declare input_contents=(file executable program script source)

  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$prefix$content$suffix.ext}}\`") | sed -nE '/^`/p')"
        [[ "$output" == "\`some {${prefix}file value: sample.ext}\`" ]]
      done
    done
  done

  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{${prefix}image_$content$suffix.ext}}\`") | sed -nE '/^`/p')"
        [[ "$output" == "\`some {${prefix}file value: image.ext}\`" ]]
      done
    done
  done
}

@test "expect no singular directory placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  declare prefixes=("" /)
  declare suffixes=("" name _name
    1 name1 _name1)
  declare input_contents=(dir directory)
  
  for prefix in "${prefixes[@]}"; do
    for suffix in "${suffixes[@]}"; do
      for content in "${input_contents[@]}"; do
        declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$prefix$content$suffix}}\`") | sed -nE '/^`/p')"
        [[ "$output" == "\`some {${prefix}directory value}\`" ]]
      done
    done
  done
}

@test "expect no plural user placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  suffixes=(s "(s)" "{1,2,3}"
    names _names
    "name(s)" "_name(s)"
    "name{1,2,3}" "_name{1,2,3}")
  input_contents=(user)

  for suffix in "${suffixes[@]}"; do
    for content in "${input_contents[@]}"; do
      declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$content$suffix}}\`") | sed -nE '/^`/p')"
      [[ "$output" == "\`some {string* user}\`" ]]
    done
  done
}

@test "expect no plural group placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  suffixes=(s "(s)" "{1,2,3}"
    names _names
    "name(s)" "_name(s)"
    "name{1,2,3}" "_name{1,2,3}")
  input_contents=(group)

  for suffix in "${suffixes[@]}"; do
    for content in "${input_contents[@]}"; do
      declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$content$suffix}}\`") | sed -nE '/^`/p')"
      [[ "$output" == "\`some {string* group}\`" ]]
    done
  done
}

@test "expect no plural ip placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  suffixes=(s "(s)" "{1,2,3}"
    names _names
    "name(s)" "_name(s)"
    "name{1,2,3}" "_name{1,2,3}")
  input_contents=(ip)

  for suffix in "${suffixes[@]}"; do
    for content in "${input_contents[@]}"; do
      declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$content$suffix}}\`") | sed -nE '/^`/p')"
      [[ "$output" == "\`some {string* ip}\`" ]]
    done
  done
}

@test "expect no plural database placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'

  suffixes=(s "(s)" "{1,2,3}"
    names _names
    "name(s)" "_name(s)"
    "name{1,2,3}" "_name{1,2,3}")
  input_contents=(db database)

  for suffix in "${suffixes[@]}"; do
    for content in "${input_contents[@]}"; do
      declare output="$(./md-to-clip.sh -nfs <(echo "${header}\`some {{$content$suffix}}\`") | sed -nE '/^`/p')"
      [[ "$output" == "\`some {string* database}\`" ]]
    done
  done
}
