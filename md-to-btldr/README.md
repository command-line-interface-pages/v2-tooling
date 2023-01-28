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

## Notes

- All Better TlDr placeholders are required by default as there is no special syntax
  to present optional placeholders in TlDr pages.
- All Better TlDr repeated placeholders are allows 0 or more arguments to be substituted
  by default as there is no special syntax to present placeholders requiring other
  argument count in TlDr pages.
