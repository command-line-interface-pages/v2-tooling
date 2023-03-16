# Markdown to Command Line Interface Pages format converter

Converter from TlDr format to Command Line Interface Pages format.

## Installation :smile:

```bash
temp="$(mktemp)"
wget -O "$temp" https://raw.githubusercontent.com/command-line-interface-pages/v2-tooling/main/md-to-clip/makefile
make -f "$temp" remote-install
```

## Example :book:

Input TlDr page:

```md
# mkdir

> Create directories and set their permissions.
> More information: <https://www.gnu.org/software/coreutils/mkdir>.

- Create specific directories:

`mkdir {{path/to/directory1 path/to/directory2 ...}}`

- Create specific directories and their [p]arents if needed:

`mkdir -p {{path/to/directory1 path/to/directory2 ...}}`

- Create directories with specific permissions:

`mkdir -m {{rwxrw-r--}} {{path/to/directory1 path/to/directory2 ...}}`
```

Output Command Line Interface Page:

```md
# mkdir

> Create directories and set their permissions
> More information: https://www.gnu.org/software/coreutils/mkdir

- Create specific directories:

`mkdir {directory* value}`

- Create specific directories and their [p]arents if needed:

`mkdir -p {directory* value}`

- Create directories with specific permissions:

`mkdir -m {string value: rwxrw-r--} {directory* value}`
```

## Completions :pencil:

### [Bash][bash]

```bash
__md_to_clip__complete() {
    declare current="$2"
    declare previous="$3"

    case "$previous" in
        --output-directory|-od)
            mapfile -t COMPREPLY < <(compgen -o dirnames -- "$current")
        ;;
        --special-placeholder-config|-spc)
            mapfile -t COMPREPLY < <(compgen -o filenames -- "$current")
        ;;
        *)
            mapfile -t COMPREPLY < <(compgen -W "--help -h
--version -v
--author -a
--email -e
--no-file-save -nfs
--output-directory -od
--special-placeholder-config -spc" -- "$current")
        ;;
    esac
}

complete -F __md_to_clip__complete md-to-clip
```

[bash]: https://www.gnu.org/software/bash/manual/bash.html

### [Fish][fish]

```fish
complete -c md-to-clip -s h -l help -d 'Display help'
complete -c md-to-clip -s v -l version -d 'Display version'
complete -c md-to-clip -s a -l author -d 'Display author'
complete -c md-to-clip -s e -l email -d 'Display author email'
complete -c md-to-clip -o nfs -l no-file-save -d 'Whether to display conversion result in stdout instead of writing it to a file'
complete -c md-to-clip -o od -l output-directory -d 'Directory where conversion result will be written'
complete -c md-to-clip -o spc -l special-placeholder-config -d 'Config with special placeholders'
```

[fish]: https://fishshell.com/

## Sample scripts :books:

The following script can be used to refresh all pages at once:

```sh
#!/usr/bin/env bash

declare tldr_pages="path/to/tldr-english-pages"
declare clip_pages="path/to/clip-english-pages"

for category_path in "$tldr_pages/"*; do
    declare category="${category_path##*/}"
    echo "Refreshing pages in '$category' category"

    for file in "$category_path/"*.md; do
        bash md-to-clip.sh -od "$clip_pages/$category" "$file"
    done
done
```
