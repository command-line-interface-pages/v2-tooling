#!/usr/bin/env bats

@test "expect layout error when empty page is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/empty_page.md"
}

@test "expect layout error when page without header is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_header.md"
}

@test "expect layout error when page without summary is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_summary.md"
}

@test "expect layout error when page without examples is passed" {
  ! ./md-to-clip.sh "./tests/inputs/invalid/page_without_examples.md"
}


@test "expect no layout error when valid page is passed" {
  ./md-to-clip.sh "./tests/inputs/valid/page.md"
}

@test "expect no header conversion error when valid page is passed" {
  declare output="$(./md-to-clip.sh -nfs "./tests/inputs/valid/page.md" | sed -n '1p')"
  [[ "$output" == "# am" ]]
}

@test "expect no summary description conversion error when valid page is passed" {
  declare output="$(./md-to-clip.sh -nfs "./tests/inputs/valid/page.md" | sed -nE '/^> [^:]+$/p')"
  [[ "$output" == "> Android activity manager" ]]
}

@test "expect no summary 'More information' conversion error when valid page is passed" {
  declare output="$(./md-to-clip.sh -nfs "./tests/inputs/valid/page_with_more_information.md" | sed -nE '/^> More +information:/p')"
  [[ "$output" == "> More information: https://some/documentation/url" ]]
}

@test "expect no summary 'See also' conversion error when valid page is passed" {
  declare output="$(./md-to-clip.sh -nfs "./tests/inputs/valid/page_with_see_also.md" | sed -nE '/^> See also:/p')"
  [[ "$output" == "> See also: command1, command2" ]]
}

@test "expect no stdin stream conversion error when valid page is passed" {
  declare header='# some

> Some text.

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'- `stdin`:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stdin:" ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'- standard input:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stdin:" ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'- standard input stream:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stdin:" ]]
}

@test "expect no stdout stream conversion error when valid page is passed" {
  declare header='# some

> Some text.

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'- `stdout`:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stdout:" ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'- standard output:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stdout:" ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'- standard output stream:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stdout:" ]]
}

@test "expect no stderr stream conversion error when valid page is passed" {
  declare header='# some

> Some text.

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'- `stderr`:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stderr:" ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'- standard error:

`some`') | sed -nE '/^- /p')"
  [[ "$output" == "- stderr:" ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'- standard error stream:

`some`') | sed -nE '/^- /p')"
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

@test "expect no device placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{dev/sda}} {{/dev/sda}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {file value: device} {/file value: device}`' ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{dev/sda1}} {{/dev/sda1}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {file value: device} {/file value: device}`' ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{device}} {{/device}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {file value: device} {/file value: device}`' ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{device1}} {{/device1}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {file value: device} {/file value: device}`' ]]
}

@test "expect no character placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{char}} {{character}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {char value} {char value}`' ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{char1}} {{character1}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {char value} {char value}`' ]]
}

@test "expect no path placeholder conversion error when valid page is passed" {
  declare header='# some

> Some text.

- Some text:

'
  declare output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{file_or_directory}} {{executable_or_directory}} {{program_or_directory}} {{script_or_directory}} {{source_or_directory}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {path value} {path value} {path value} {path value} {path value}`' ]]

  output="$(./md-to-clip.sh -nfs <(echo "$header"'`some {{/file_or_directory}} {{/executable_or_directory}} {{/program_or_directory}} {{/script_or_directory}} {{/source_or_directory}}`') | sed -nE '/^`/p')"
  [[ "$output" == '`some {/path value} {/path value} {/path value} {/path value} {/path value}`' ]]
}

@test "expect no file placeholder conversion error when valid page is passed" {
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

@test "expect no file placeholder with extension conversion error when valid page is passed" {
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

@test "expect no directory placeholder conversion error when valid page is passed" {
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