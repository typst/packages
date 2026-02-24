
#import "@preview/fauxreilly:0.1.1": orly


#import "../api/icons.typ": icon

#let primary = rgb("#b22784")
#let secondary = rgb("#0a0a0a")


#let fonts = (
  serif: ("TeX Gyre Schola", "Liberation Serif"),
  sans: ("TeX Gyre Heros", "Open Sans Condensed", "Open Sans", "Liberation Sans", "Helvetica Neue", "Helvetica"),
  mono: ("TeX Gyre Cursor", "Liberation Mono"),
)

#let muted = (
  fill: luma(210),
  bg: luma(240),
)

#let text = (
  size: 12pt,
  font: fonts.serif,
  fill: rgb(35, 31, 32),
)

#let heading = (
  font: fonts.serif,
  fill: text.fill,
)

#let header = (
  size: 10pt,
  fill: text.fill,
)

#let footer = (
  size: 9pt,
  fill: muted.fill,
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
  argument: navy,
  command: blue,
  variable: rgb("#9346ff"),
  builtin: eastern,
  comment: gray,
  symbol: text.fill,
)

#let values = (
  default: rgb(181, 2, 86),
)


#let page-init(doc, theme) = (
  body => {
    show std.heading: it => {
      let level = it.at("level", default: it.at("depth", default: 2))
      let scale = (1.4, 1.2, 1.1).at(level - 1, default: 1.0)

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

        block(
          below: .82em,
          stroke: (bottom: 2pt + theme.secondary),
          width: 100%,
          inset: (bottom: .64em),
          {
            if it.numbering != none {
              set std.text(fill: secondary)
              [Part ]
              counter(std.heading).display()
              linebreak()
            }

            set std.text(fill: primary, size: 2em)

            it.body

            // v(-.64em)
            // line(length: 100%, stroke: 2pt + theme.secondary)
          },
        )
      } else {
        block({
          set std.text(fill: secondary)
          if it.numbering != none {
            counter(std.heading).display()
            h(1.8em)
          }
          it.body
        })
      }
    }
    body
  }
)

#let _display-author(author) = block({
  smallcaps(author.name)
  if author.affiliation not in (none, ()) {
    footnote(smallcaps(author.affiliation))
  }
  set std.text(.88em)
  if author.email != none {
    " <" + link("mailto://" + author.email, icon("mail") + " " + author.email) + ">"
  }
  if author.github != none {
    let username = author.github.trim("@")
    [ (#link("https://github.com/" + username, icon("mark-github") + " " + username))]
  }
  // if author.urls != () {
  //   author.urls.map(link).join(linebreak())
  // }
})

#let title-page(doc, theme) = {
  let title = if doc.title == none {
    doc.package.name
  } else {
    doc.title
  }

  orly(
    color: theme.primary,
    title: title,
    subtitle: doc.package.description,
    signature: [
      #set std.text(14pt)
      v#doc.package.version
      #if doc.date != none [
        #h(4em)
        #doc.date.display()
      ]
      #h(4em)
      #doc.package.license
    ],
    publisher: doc.package.authors.map(_display-author).join(", "),
    pic: doc.theme-options.at("title-image", default: none),
    top-text: doc.subtitle,

    font: theme.heading.font,
    publisher-font: theme.fonts.sans,
  )

  set page(header: none, footer: none)
  std.heading(depth: 1, title, numbering: none)

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
        doc.abstract
      },
    )
    v(1em)
  }

  if doc.show-outline {
    set align(left)
    set block(spacing: 0.65em)
    show outline.entry.where(level: 1): it => {
      v(0.85em, weak: true)
      strong(link(it.element.location(), it.inner()))
    }

    v(1fr)
    std.heading(depth: 2, outlined: false, bookmarked: false, numbering: none, "Table of Contents")
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
