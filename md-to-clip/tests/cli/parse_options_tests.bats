#!/usr/bin/env bats

@test "expect no error when --help option passed" {
    run bash -c './md-to-clip.sh --help && ./md-to-clip.sh -h'
    ((status == 0))
}

@test "expect no error when --version option passed" {
    run bash -c './md-to-clip.sh --version && ./md-to-clip.sh -v'
    ((status == 0))
}

@test "expect no error when --author option passed" {
    run bash -c './md-to-clip.sh --author && ./md-to-clip.sh -a'
    ((status == 0))
}

@test "expect no error when --email option passed" {
    run bash -c './md-to-clip.sh --email && ./md-to-clip.sh -e'
    ((status == 0))
}

@test "expect no error when --no-file-save option passed" {
    run bash -c './md-to-clip.sh --no-file-save && ./md-to-clip.sh -nfs'
    ((status == 0))
}

@test "expect no error when --output-directory option passed" {
    run bash -c './md-to-clip.sh --output-directory $(mktemp -d) && ./md-to-clip.sh -od $(mktemp -d)'
    ((status == 0))
}

@test "expect error when nothing to --output-directory option passed" {
    run ./md-to-clip.sh --output-directory
    ((status == 1))
}

@test "expect error when file to --output-directory option passed" {
    run ./md-to-clip.sh --output-directory placeholders.yaml
    ((status == 1))
}

@test "expect no error when --special-placeholder-config option passed" {
    run bash -c './md-to-clip.sh --special-placeholder-config placeholders.yaml && ./md-to-clip.sh -spc placeholders.yaml'
    ((status == 0))
}

@test "expect error when nothing to --special-placeholder-config option passed" {
    run ./md-to-clip.sh --special-placeholder-config
    ((status == 1))
}

@test "expect error when directory to --special-placeholder-config option passed" {
    run ./md-to-clip.sh --special-placeholder-config $(mktemp -d)
    ((status == 1))
}
