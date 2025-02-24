# Typst sub-outlines

This package provides the `suboutline` command that does the same thing as `outline` but
restricted to the current heading. This is inspired by
[minitoc](https://ctan.org/pkg/minitoc?lang=en) package for LaTeX.

*This package is a fork of the
[minitoc](https://gitlab.com/human_person/typst-local-outline) package, which is no
longer maintained by the original author.*

## Example

```typst
#import "@preview/suboutline:0.2.0": *
#set heading(numbering: "1.1")

#outline()

= Heading 1

#suboutline()

== Heading 1.1

#lorem(20)

=== Heading 1.1.1

#lorem(30)

== Heading 1.2

#lorem(10)

= Heading 2

```

This produces

![](https://github.com/sdiebolt/suboutline/blob/main/example/example.png?raw=true)

## Usage

The `suboutline` function has the following signature:

```typst
#let suboutline(
  title: none,
  target: heading.where(outlined: true),
  depth: none,
  indent: auto,
  fill: repeat([.], gap: 0.15em),
) { /* .. */ }
```

This is designed to be as close to the
[`outline`](https://typst.app/docs/reference/model/outline/) funtions as possible. The
arguments are:

- ``title``: The title for the local outline. This is the same as for
  [`outline.title`](https://typst.app/docs/reference/model/outline/#parameters-title).
- ``target``: What should be included. This is the same as for
  [`outline.target`](https://typst.app/docs/reference/model/outline/#parameters-target).
- ``depth``: The maximum depth different to include. For example, if depth was 1 in the
  example, "Heading 1.1.1" would not be included.
- ``indent``: How the entries should be indented. Takes the same types as for
  [`outline.indent`](https://typst.app/docs/reference/model/outline/#parameters-indent)
  and is passed directly to it.
- ``fill``: Content to put between the numbering and title, and the page number. Same
  types as for
  [`outline.entry`](https://typst.app/docs/reference/model/outline/#definitions-entry-fill).

## Unintended consequences

Because `suboutline` uses `outline`, if you apply numbering to the title of `outline`
with `#show outline: set heading(numbering: "1.")` or similar, any title in the
sub-outline will be numbered and be a level 1 heading. This cannot be changed with
`#show outline: set heading(level: 3)` or similar unfortunately.
