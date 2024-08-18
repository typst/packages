# Typst miniTOC

This package provides the `minitoc` command that does the same thing as the `outline` command but only for headings under the heading above it.

This is inspired by minitoc package for LaTeX.

## Example

```typst
#import "@preview/minitoc:0.1.0": *
#set heading(numbering: "1.1")

#outline()

= Heading 1

#minitoc()

== Heading 1.1

#lorem(20)

=== Heading 1.1.1

#lorem(30)

== Heading 1.2

#lorem(10)

= Heading 2

```

This produces

![](https://gitlab.com/human_person/typst-local-outline/-/raw/main/example/example.png)

## Usage

The `minitoc` function has the following signature:

```typst
#let minitoc(
  title: none, target: heading.where(outlined: true),
	depth: none, indent: none, fill: repeat([.])
) { /* .. */ }
```

This is designed to be as close to the [`outline`](https://typst.app/docs/reference/meta/outline/) funtions as possible. The arguments are:

- **title**: The title for the local outline. This is the same as for [`outline.title`](https://typst.app/docs/reference/meta/outline/#parameters-title).
- **target**: What should be included. This is the same as for [`outline.target`](https://typst.app/docs/reference/meta/outline/#parameters-target)
- **depth**: The maximum depth different to include. For example, if depth was 1 in the example, "Heading 1.1.1" would not be included
- **indent**: How the entries should be indented. Takes the same types as for [`outline.indent`](https://typst.app/docs/reference/meta/outline/#parameters-indent) and is passed directly to it
- **fill**: Content to put between the numbering and title, and the page number. Same types as for [`outline.fill`](https://typst.app/docs/reference/meta/outline/#parameters-fill)

## Unintended consequences

Because `minitoc` uses `outline`, if you apply numbering to the title of outline with `#show outline: set heading(numbering: "1.")` or similar, any title in `minitoc` will be numbered and be a level 1 heading. This cannot be changed with `#show outline: set heading(level: 3)` or similar unfortunately.
