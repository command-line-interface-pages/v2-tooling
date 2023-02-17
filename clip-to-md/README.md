# Command Line Interface Pages to Markdown format converter

Converter from Command Line Interface Pages format to TlDr format.

## Example

Input Command Line Interface Page:

```md
# mkdir

> Create directories and set their permissions
> More information: https://www.gnu.org/software/coreutils/mkdir

- Create specific directories:

`mkdir {directory* some}`

- Create specific directories and their [p]arents if needed:

`mkdir -p {directory* some}`

- Create directories with specific permissions:

`mkdir -m {string value: rwxrw-r--} {directory* some}`
```

Output TlDr page:

```md
# mkdir

> Create directories and set their permissions.
> More information: <https://www.gnu.org/software/coreutils/mkdir>.

- Create specific directories:

`mkdir {{path/to/some_directory1 path/to/some_directory2 ...}}`

- Create specific directories and their [p]arents if needed:

`mkdir -p {{path/to/some_directory1 path/to/some_directory2 ...}}`

- Create directories with specific permissions:

`mkdir -m {{rwxrw-r--}} {{path/to/some_directory1 path/to/some_directory2 ...}}`
```

## Notes

- All TlDr placeholders are required even the corresponding Command Line Interface Pages ones are
  optional as there is no special syntax to present optional placeholders in TlDr pages.
- All TlDr repeated placeholders allow 0 or more arguments to be substituted even
  the corresponding Command Line Interface Pages ones specify repetition count as there is no special
  syntax to present placeholders requiring other argument count in TlDr pages.
