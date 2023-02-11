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
