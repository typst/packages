#import "../api/icons.typ": icon

// TODO: (jneug) Maybe move to a "theme-utils" module?
#let _display-author(author) = block({
  smallcaps(author.name)
  set std.text(.88em)
  if author.email != none {
    linebreak()
    icon("mail")
    h(.25em)
    link("mailto://" + author.email, author.email)
  }
  if author.affiliation not in (none, ()) {
    linebreak()
    smallcaps(author.affiliation)
  }
  if author.urls not in (none, ()) {
    linebreak()
    author.urls.map(l => icon("link") + h(.25em) + link(l)).join(linebreak())
  }
  if author.github != none {
    linebreak()
    icon("mark-github")
    h(.25em)
    link("https://github.com/" + author.github, "@" + author.github)
  }
})

#let default = {
  let base = (
    primary: eastern,
    secondary: teal,
    muted: luma(120),
    fonts: (
      serif: ("TeX Gyre Schola", "Liberation Serif"),
      sans: ("TeX Gyre Heros", "Liberation Sans", "Helvetica Neue", "Helvetica"),
      mono: ("TeX Gyre Cursor", "Liberation Mono"),
    ),
    text: rgb(35, 31, 32),
  )

  (
    primary: base.primary,
    secondary: base.secondary,
    fonts: base.fonts,
    muted: (
      fill: base.muted,
      bg: base.muted.lighten(88%),
    ),
    text: (
      size: 11pt,
      font: base.fonts.serif,
      fill: base.text,
    ),
    heading: (
      font: base.fonts.sans,
      fill: base.text,
    ),
    header: (
      size: 10pt,
      fill: base.text,
    ),
    footer: (
      size: 9pt,
      fill: base.muted,
    ),
    code: (
      size: 9pt,
      font: base.fonts.mono,
      fill: rgb("#999999"),
    ),
    alert: (alert-type, body) => {
      let alert-colors = (
        info: rgb(23, 162, 184),
        warning: rgb(255, 193, 7),
        error: rgb(220, 53, 69),
        success: rgb(40, 167, 69),
      )

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
    },
    tag: (color, body) => box(
      stroke: none,
      fill: color,
      // radius: 50%,
      radius: 3pt,
      inset: (x: .5em, y: .25em),
      baseline: 1%,
      text(body),
    ),
    emph: (
      link: base.secondary,
      package: base.primary,
      module: rgb("#8c3fb2"),
      since: rgb("#a6fbca"),
      until: rgb("#ffa49d"),
      changed: rgb("#fff37c"),
      deprecated: rgb("#ffa49d"),
      compiler: base.secondary,
      "context": rgb("#fff37c"),
    ),
    commands: (
      argument: navy,
      command: blue,
      variable: rgb("#9346ff"),
      builtin: eastern,
      comment: gray,
      symbol: base.text,
    ),
    values: (
      default: rgb(181, 2, 86),
    ),
    page-init: (doc, theme) => (
      body => {
        show std.heading: it => {
          let level = it.at("level", default: it.at("depth", default: 2))
          let scale = (1.6, 1.4, 1.2, 1.1).at(level - 1, default: 1.0)

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

          set std.text(size: size, ..theme.heading)
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
          } else if level < 4 {
            block({
              if it.numbering != none {
                std.text(fill: theme.primary, counter(std.heading).display())
                [ ]
              }
              it.body
            })
          } else {
            block(it.body)
          }
        }
        body
      }
    ),
    title-page: (doc, theme) => {
      set align(center)
      set block(spacing: 2em)

      block(
        std.text(
          40pt,
          theme.primary,
          if doc.title == none {
            doc.package.name
          } else {
            doc.title
          },
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
        columns: calc.min(4, calc.max(doc.package.authors.len(), 1)),
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
          strong(link(it.element.location(), it.body))
        }

        std.text(font: base.fonts.sans, weight: "bold", size: 1.4em, "Table of Contents")
        columns(
          2,
          outline(
            title: none,
            indent: 1em,
            depth: 3,
            fill: repeat("."),
          ),
        )
      }

      pagebreak()
    },
    last-page: (doc, theme) => { },
  )
}
