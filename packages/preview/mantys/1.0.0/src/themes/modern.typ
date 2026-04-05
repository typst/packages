#let primary = rgb("#ed592f")
#let secondary = rgb("#05b5da")

#let fonts = (
  serif: ("Linux Libertine", "Liberation Serif"),
  sans: ("Source Sans Pro", "Roboto"),
  mono: ("Fira Code", "Liberation Mono"),
)

#let muted = (
  fill: luma(80%),
  bg: luma(95%),
)

#let text = (
  size: 12pt,
  font: fonts.sans,
  fill: rgb("#333333"),
)

#let header = (
  size: 10pt,
  fill: text.fill,
)
#let footer = (
  size: 9pt,
  fill: muted.fill,
)

#let heading = (
  size: 15pt,
  font: fonts.sans,
  fill: primary,
)

#import "@preview/gentle-clues:1.0.0"

#let _alert-funcs = (
  "info": gentle-clues.info,
  "warning": gentle-clues.warning,
  "error": gentle-clues.error,
  "success": gentle-clues.success,
  "default": gentle-clues.memo,
)

#let alert(alert-type, body) = {
  let alert-func = _alert-funcs.at(alert-type, default: _alert-funcs.default)
  alert-func(title: none, body)
}


#let tag(color, body) = box(
  stroke: none,
  fill: color,
  // radius: 50%,
  radius: 3pt,
  inset: (x: .5em, y: .25em),
  baseline: 1%,
  std.text(body),
)

#let code = (
  size: 12pt,
  font: fonts.mono,
  fill: rgb("#999999"),
)

#let emph = (
  link: secondary,
  package: primary,
  module: rgb("#8c3fb2"),
  since: rgb("#a6fbca"),
  until: rgb("#ffa49d"),
  changed: rgb("#fff37c"),
  deprecated: rgb("#ffa49d"),
  compiler: teal,
  "context": rgb("#fff37c"),
)

#let commands = (
  argument: rgb("#3c5c99"),
  option: rgb(214, 182, 93),
  command: blue, // rgb(75, 105, 197),
  builtin: eastern,
  comment: gray, // rgb(128, 128, 128),
  symbol: text.fill,
)

#let values = (
  default: rgb(181, 2, 86),
)

#let page-init(doc, theme) = (
  body => {
    show std.heading.where(level: 1): it => {
      pagebreak(weak: true)
      set std.text(fill: theme.primary)
      block(
        width: 100%,
        breakable: false,
        inset: (bottom: .33em),
        stroke: (bottom: .6pt + theme.secondary),
        [#if it.numbering != none {
            (
              std.text(
                weight: "semibold",
                theme.secondary,
                [Part ] + counter(std.heading.where(level: it.level)).display(it.numbering),
              )
                + h(1.28em)
            )
          } #it.body],
      )
    }
    body
  }
)

#let title-page(doc, theme) = {
  set align(center)
  v(2fr)

  block(
    width: 100%,
    inset: (y: 1.28em),
    stroke: (bottom: 2pt + theme.secondary),
    [
      #set std.text(40pt)
      #doc.title
    ],
  )

  if doc.subtitle != none {
    std.text(18pt, doc.subtitle)
    v(1em)
  }

  std.text(14pt)[Version #doc.package.version]
  if doc.date != none {
    h(3em)
    std.text(14pt, doc.date.display())
  }
  h(3em)
  std.text(14pt, doc.package.license)

  v(1fr)
  pad(
    x: 10%,
    {
      set align(left)
      doc.abstract
    },
  )
  v(1fr)
  if doc.show-outline {
    std.heading(level: 2, outlined: false, numbering: none, "Table of Contents")
    columns(
      2,
      outline(title: none),
    )
  }
  v(2fr)
  pagebreak()
}

#let last-page(doc, theme) = { }
