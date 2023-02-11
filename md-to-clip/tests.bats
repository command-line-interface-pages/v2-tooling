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