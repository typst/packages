#let primary = rgb(166, 9, 18)
#let secondary = primary


#let fonts = (
  serif: ("New Computer Modern", "Computer Modern", "Libertinus Serif", "Liberation Serif"),
  sans: ("New Computer Modern Sans", "Computer Modern Sans", "Libertinus Sans", "Helvetica Neue", "Helvetica"),
  mono: ("Liberation Mono",),
)

#let muted = (
  fill: rgb(128, 128, 128),
  bg: luma(233),
)

#let text = (
  size: 12pt,
  font: fonts.serif,
  fill: rgb(0, 0, 0),
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
  font: fonts.serif,
  fill: text.fill,
)

#let emph = (
  link: primary,
  package: primary,
  module: rgb(5, 10, 122),
  since: rgb("#a6fbca"),
  until: rgb("#ffa49d"),
  changed: rgb("#fff37c"),
  deprecated: rgb("#ffa49d"),
  compiler: teal,
  "context": rgb("#fff37c"),
)

#let code = (
  size: 9pt,
  font: fonts.mono,
  fill: rgb("#999999"),
)

#let alert-colors = (
  info: rgb(23, 162, 184),
  warning: rgb(255, 193, 7),
  error: rgb(220, 53, 69),
  success: rgb(40, 167, 69),
)

#let alert(alert-type, body) = {
  let color = if type(alert-type) == color {
    alert-type
  } else {
    alert-colors.at(alert-type, default: luma(100))
  }
  block(
    stroke: (left: 2pt + color, rest: 0pt),
    fill: color.lighten(88%),
    inset: 8pt,
    width: 100%,
    spacing: 2%,
    std.text(size: .88em, fill: color.darken(60%), body),
  )
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

#let commands = (
  argument: navy,
  command: rgb(153, 64, 39),
  variable: rgb(214, 181, 93),
  builtin: eastern,
  comment: rgb(128, 128, 128),
  symbol: text.fill,
)

#let values = (
  default: rgb(181, 2, 86),
)

#let page-init(doc, theme) = (
  body => {
    show std.heading: it => {
      let level = it.at("level", default: it.at("depth", default: 2))
      let scale = (1.6, 1.4, 1.2).at(level - 1, default: 1.0)

      let size = 1em * scale
      let above = (
        if level == 1 {
          1.8em
        } else {
          1.44em
        }
          / scale
      )
      let below = 0.75em / scale

      set std.text(size: size, ..heading)
      set block(above: above, below: below)

      if level == 1 {
        pagebreak(weak: true)
        block({
          if it.numbering != none {
            std.text(
              fill: theme.primary,
              {
                [Part ]
                counter(std.heading).display()
              },
            )
            linebreak()
          }
          it.body
        })
      } else {
        block({
          if it.numbering != none {
            std.text(fill: theme.primary, counter(std.heading).display())
            [ ]
          }
          set std.text(size: size, ..heading)
          it.body
        })
      }
    }
    body
  }
)

#let _display-author(author) = block({
  smallcaps(author.name)
  set std.text(.88em)
  if author.email != none {
    linebreak()
    " " + sym.lt + link("mailto://" + author.email, author.email) + sym.gt
  }
  if author.affiliation != () {
    linebreak()
    smallcaps(author.affiliation)
  }
  if author.urls != () {
    linebreak()
    author.urls.map(link).join(linebreak())
  }
  if author.github != none {
    linebreak()
    [GitHub: ] + link("https://github.com/" + author.github, author.github)
  }
})

#let title-page(doc, theme) = {
  set align(center)
  set block(spacing: 2em)

  block(
    smallcaps(
      std.text(
        40pt,
        theme.primary,
        if doc.title == none {
          doc.package.name
        } else {
          doc.title
        },
      ),
    ),
  )
  if doc.subtitle != none {
    block(above: 1em, std.text(18pt, doc.subtitle))
  }

  std.text(14pt)[v#doc.package.version]
  if doc.date != none {
    h(4em)
    std.text(14pt, doc.date.display())
  }
  h(4em)
  std.text(14pt, doc.package.license)

  if doc.package.description != none {
    block(doc.package.description)
  }

  grid(
    columns: calc.min(4, doc.package.authors.len()),
    gutter: .64em,
    ..doc.package.authors.map(_display-author)
  )

  if doc.urls != none {
    block(doc.urls.map(link).join(linebreak()))
  }

  if doc.abstract != none {
    pad(
      x: 10%,
      {
        set align(left)
        // set par(justify: true)
        // show par: set block(spacing: 1.3em)
        doc.abstract
      },
    )
  }

  if doc.show-outline {
    set align(left)
    set block(spacing: 0.65em)
    show outline.entry.where(level: 1): it => {
      v(0.85em, weak: true)
      strong(link(it.element.location(), it.inner()))
    }

    std.heading(level: 2, outlined: false, bookmarked: false, numbering: none, "Table of Contents")
    columns(
      2,
      outline(
        title: none,
        indent: 1em,
        depth: 3,
        // fill: repeat("."),
      ),
    )
  }

  pagebreak()
}

#let last-page(doc, theme) = { }
