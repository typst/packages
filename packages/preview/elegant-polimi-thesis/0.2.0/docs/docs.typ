#import "@preview/tidy:0.4.3": *
#import "../src/polimi-phd-thesis.typ"
#import "../src/utils.typ"
#import "../src/figures.typ"
#import "@preview/metalogo:1.2.0": LaTeX, TeX

#show "LaTeX": LaTeX

#set text(hyphenate: true)
#set par(justify: true)
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

This chapter is the result of the documentation generated from the source code. Since it's not strictly needed to use the template -- most of the functions are straightforward -- it's quite barebones.

This document contains them all, even those that are not exposed to the user, which are marked with "\_" before.

#set heading(numbering: none)

#let toc-block = columns[
  #heading(level: 1, outlined: false, "All functions")
  #outline(title: none, depth: 2, indent: 1em)
]

#context block(height: measure(toc-block).height / 2 + 1em, toc-block)

#show-module(
  parse-module(
    read("../src/polimi-phd-thesis.typ"),
    name: "User designated functions",
    scope: (polimi-phd-thesis: polimi-phd-thesis),
    preamble: "#import polimi-phd-thesis: *\n",
  ),
  style: styles.default,
  first-heading-level: 1,
  show-outline: false,
  show-module-name: true,
  omit-private-definitions: false,
  omit-private-parameters: false,
  sort-functions: none,
)

#v(1cm)

#show-module(
  parse-module(
    read("../src/utils.typ"),
    name: "Utilities",
    scope: (utils: utils),
    preamble: "#import utils: *\n",
  ),
  style: styles.default,
  first-heading-level: 1,
  show-outline: false,
  show-module-name: true,
  omit-private-definitions: false,
  omit-private-parameters: false,
  sort-functions: none,
)

#v(1cm)

#show-module(
  parse-module(
    read("../src/figures.typ"),
    name: "Figures styling",
    scope: (figures: figures),
    preamble: "#import figures: *\n",
  ),
  style: styles.default,
  first-heading-level: 1,
  show-outline: false,
  show-module-name: true,
  omit-private-definitions: false,
  omit-private-parameters: false,
  sort-functions: none,
)
