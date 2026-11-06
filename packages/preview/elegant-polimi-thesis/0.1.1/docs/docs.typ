#import "@preview/tidy:0.4.3": *
#import "../src/lib.typ"
#import "@preview/metalogo:1.2.0": LaTeX, TeX

#show "LaTeX": LaTeX

#set page(numbering: "1")
#set enum(numbering: "1.a.i.", indent: 1em)
#set list(indent: 1em)

#align(
  center,
  heading(
    text(size: 1.5em)[`elegant-polimi-thesis` documentation],
    outlined: false,
  ),
)

#v(1em)

This chapter is the result of the documentation generated from the source code. Since it's not strictly needed to use the template -- there are very little functions to actually use, which are only section organizers -- it's quite barebones.

The intended order of use of the functions is as follows:

#block(height: 2.4cm, columns[
  + frontmatter
    + toc
    + list-of-figures
    + list-of-tables
    + nomenclature
  + mainmatter
  + backmatter
  + acknowledgements
  + appendix
])

The acknowledgements section can be moved in frontmatter, as one prefers (or as the advisor requests).

#block(height: 3.5cm, columns[#outline(depth: 2, indent: 0em)])

#set heading(numbering: none)

#let docs = parse-module(
  read("../src/lib.typ"),
  name: "elegant-polimi-thesis",
  scope: (lib: lib),
  preamble: "#import lib: *\n",
)

#show-module(
  docs,
  style: styles.default,
  first-heading-level: 1,
  show-outline: false,
  show-module-name: false,
  omit-private-definitions: true,
  omit-private-parameters: true,
  sort-functions: none,
)
