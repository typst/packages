// Real-package TOC specimens for the three next-generation styles.
// Compile with `--input style=folio`, `terrace`, or `anchor`.
#import "@preview/beautitled:0.3.0": *

#let style-name = sys.inputs.at("style", default: "folio")
#let heading-font = if style-name == "folio" { "Libertinus Serif" } else { "Linux Biolinum" }

#set page(width: 12cm, height: 15cm, margin: 1.25cm)
#set text(font: "Libertinus Serif", size: 9.5pt)

#beautitled-setup(
  style: style-name,
  heading-font: heading-font,
  primary-color: rgb("#17212b"),
  secondary-color: rgb("#6f7b86"),
  accent-color: rgb("#1877a8"),
  enable-parts: true,
  part-prefix: "Part",
  chapter-prefix: "Chapter",
  section-prefix: "Section",
  toc-part-size: 11.5pt,
  toc-chapter-size: 11.5pt,
  toc-section-size: 9.5pt,
  toc-subsection-size: 8.5pt,
)

#beautitled-toc(title: "Contents", style: style-name, title-align: left, depth: 4)

#pagebreak()
#part[Foundations]
#chapter[Reading the built environment]
#section[Context and proportion]
#subsection[The human scale]
#section[Material and light]
#chapter[Making a coherent system]
#section[Rhythm and hierarchy]
#subsection[Details that orient]
#section[Structure and variation]
