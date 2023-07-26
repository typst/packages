# Local Outline

This package provides the `local_outline` command that does the same thing as the `outline` command but only for headings under the heading above it.

This is inspired by minitoc package for LaTeX.

## Example

```typst
#import "@preview/local-outline:0.1.0": *
#set heading(numbering: "1.1")

#outline()

= Heading 1

#local_outline()

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

The `local_outline` function has the following signature:

```typst
#let local_outline(
  title: none,
  depth: none,
  indent: none,
  fill: repeat([.])
) { /* .. */ }
```

This is designed to be as close to the [`outline`](https://typst.app/docs/reference/meta/outline/) funtions as possible. The arguments are:

- **title**: The title for the local outline. This can either be `none` or `content` but not `auto`. `auto` for `outline` uses the appropriate title for the current language. I don't know how to do this so it has been excluded. Titles are not numbered (see [below](#things-to-do))
- **depth**: The maximum depth different to include.`` For example, if depth was 1 in the example, "Heading 1.1.1" would not be included
- **indent**: How the entries should be indented. Takes the same types as for `outline` with the exception of not accepting `boolean` values (will likely be deprecated for `outline` so has not been included)
- **fill**: Content to put between the numbering and title, and the page number. Same types as for [`outline`](https://typst.app/docs/reference/meta/outline/#parameters-fill)

## Things to do

`outline` uses `outline.entry` to format entries. `local_outline` does not have that at the moment. It's also importan to note that `outline.entry` can take either one or five arguments and is treated differently depending on this. I am currently unaware of any way to determine the number of argumets to a function so full compatability in this way will probably not be available.

`outline` also has a `target` argument. This specifies what kind of content that should be included. Since not all content listable by `outline` can neatly be split into sections like sections can, this is not included. Also I couldn't work out how to do that properly

`outline` allows `auto` for the `title` argument. If it's possible to work out how to use this inside Typst code, I would love to be able to include it. `outline` can also use `show outline: set heading(numbering: "1.")` to display numbering for headings. This is not possible for `local_outline` 

