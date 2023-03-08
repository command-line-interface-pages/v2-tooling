# Markdown to Command Line Interface Pages format converter

Converter from TlDr format to Command Line Interface Pages format.

## Example

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
