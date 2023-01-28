# Markdown to Better TlDr format converter

Converter from TlDr format to Better TlDr format.

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

Output Better TlDr page:

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

## Implementation details

- `file`, `executable`, `program`, `script`, `source` are recognized as keywords just
  right before `}}` or a file extension. It means that in `{{path/to/image_file}}`
  `file` is a keyword, but in `{{path/to/excluded_file_or_directory}}` just `directory`
  is a keyword. `{{path/to/file_or_directory}}`, `{{path/to/executable_or_directory}}`,
  `{{path/to/program_or_directory}}`, `{{path/to/script_or_directory}}`, `{{path/to/source_or_directory}}`
  are exceptions and handled separately.
- Everything before these keywords is treated as a placeholder description. It means
  that in `{{path/to/image_file}}` `image` is a description. The same applies to
  `{{path/to/excluded_file_or_directory}}` where `excluded_file_or` is treated as
  a description.

## Notes

- All Better TlDr placeholders are required by default as there is no special syntax
  to present optional placeholders in TlDr pages.
- All Better TlDr repeated placeholders allow 0 or more arguments to be substituted
  by default as there is no special syntax to present placeholders requiring other
  argument count in TlDr pages.
