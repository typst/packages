#import "@preview/touying-quarto-clean:0.1.2": *

#show: clean-theme.with()

#title-slide(
  title: [A title],
  subtitle: [A subtitle],
  authors: (
    (
      name: [Your Name],
      affiliation: [Your Institution],
      email: [alias\@email.com],
      orcid: [0000-0000-0000-0000]
    ),
    (
      name: [Coauthor Name],
      affiliation: [Coauthor Institution],
      email: [coauthor\@email.com],
      orcid: [0000-0000-0000-0000]
    )
  ),
  date: [March 16, 2025],
)

= Section Slide as Header Level 1

== Slide Title as Header Level 2

=== Subtitle as Header Level 3

You can put any content here, including text, images, tables, code blocks, etc.

- first unorder list item
  - A sub item

+ first ordered list item
  + A sub item

Next, we’ll brief review some theme-specific components.

== Additional Theme Functions

=== Some extra things you can do with the clean theme

Special classes for emphasis

- `alert()` function for default emphasis, e.g.~#alert()[the second accent color].
- `fg()` class for custom color, e.g.~#fg(fill: rgb("#5D639E"))[with `options='fill: rgb("#5D639E")'`].
- `bg()` class for custom background, e.g.~#bg()[with the default color].

Cross-references

- `.button` class provides a Beamer-like button, e.g. #link(<sec-summary>)[#button()[Summary]]

== Summary
<sec-summary>
=== Quarto Clean Typst Theme

While you can use this theme as a Touying theme, it is designed to be used with #link("https://quarto.org")[Quarto].

- It allows markdown syntax, code execution (R, Python, Julia, etc.), and useful layouts (callouts, columns, etc.)
- Quarto gives you the Typst code if you set `keep-typ: true`

#v(0.5em)

=== Longer Quarto Demo

For a more comprehensive Quarto version's demo, see the #link("https://kazuyanagimoto.com/quarto-slides-typst/slides/quarto-clean-typst/clean.pdf")[demo slides] and #link("https://github.com/kazuyanagimoto/quarto-slides-typst/blob/main/slides/quarto-clean-typst/clean.qmd")[code];!
