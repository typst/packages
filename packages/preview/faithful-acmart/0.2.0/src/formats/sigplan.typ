// Layout and typography for SIGPLAN proceedings.

#import "_base.typ": tp, size-ladder, make-format, bottom-margin, generic-sec-fonts

#let sigplan(font-size: 10pt) = make-format(
  name: "sigplan",
  kind: "proceedings",
  ladder: size-ladder(font-size, format: "sigplan"),
  paper: (width: 8.5in, height: 11in),
  margin: (inside: 54.2025 * tp, outside: 54.2025 * tp, top: 72.27 * tp,
    bottom: bottom-margin(font-size, 794.97, 72.27, ("8": 650, "9": 648, "10": 646, "11": 647, "12": 654))),
  foot-skip: 12 * tp,
  columns: 2,
  columnsep: 24 * tp,
  title-style: "conf-center",
  journal: false,
  urlstyle-sans: true,
  title-font: (family: "serif", weight: "bold", size: "Huge"),
  subtitle-font: (family: "serif", weight: "regular", size: "LARGE"),
  author-font: (family: "serif", weight: "regular", size: "Large"),
  affil-font: (family: "serif", weight: "regular", size: "normalsize"),
  sec-fonts: (
    section:       (family: "serif", weight: "bold", style: "normal", size: "Large"),
    subsection:    (family: "serif", weight: "bold", style: "normal", size: "normalsize"),
    subsubsection: (family: "serif", weight: "bold", style: "normal", size: "normalsize"),
    paragraph:     (family: "serif", weight: "bold", style: "italic", size: "normalsize"),
  ),
  thm: (
    plain-head: "bold", def-head: "bold", indent: 0pt,
    note-inherits-head: false, proof-head: "italic", proof-indent: 0pt,
  ),
)
