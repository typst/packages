#import "../slydekit-deps.typ": *
#import "../slydekit-defaults.typ": *
#import "../slydekit-utils.typ": *
#import "../slydekit-outline.typ": *

#let cambfurt-colors = (
  primary: rgb("#a30100"),
  secondary: rgb("#d9d9d9"),
  focus: rgb("#a30100"),
  background: none,
  header: rgb("#a30100"),
  footer: rgb("#a30100"),
)

#let cambfurt-fonts = (
  body: "Lato",
  math: "Lete Sans Math",
  raw: "Cascadia Code",
)

#let cambfurt-theme(body, colors: none, fonts: none) = context{
  // Page setup
  let cambfurt-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 3.25cm)
  }
  set page(fill: sk-states.colors.get().background, margin: margins + cambfurt-margin)

  // Heading styles
  show heading.where(level: 1): it => {
    let dy = -2pt
    let header-content = if sk-states.navigation-style.get() == "topbar" {
      let topbar = grid(
        columns: (1fr, 1fr),
        align: right + horizon,
        rows: 1.5em,
        grid.cell(fill: sk-states.colors.get().header)[#text(fill: white)[*#sk-states.localization.get().toc* #h(0.75em)]],
        cell(fill: sk-states.colors.get().secondary),
      )
      move(dy: dy)[#topbar]
    } else {
      move(dx: 1em, dy: dy)[#box(width: 100%, fill: sk-states.colors.get().secondary.lighten(45%), outset: (left: 1em, rest: 0.5em))[*#sk-states.localization.get().toc*]]
    }
    let header = full-width(align(horizon, text(size: 1.399em, fill: sk-states.colors.get().header)[#header-content]))

    set page(header: header, footer: none, margin: margins)
    set align(horizon)

    progressive-outline(it, sk-states.colors.get().primary, sk-states.colors.get().secondary.lighten(60%))
  }

  let header = context if sk-states.navigation-style.get() == "topbar" {
    let sections = query(heading.where(level: 1).before(here()))
    let current-section = if sections.len() > 0 { sections.last().body } else { none }

    let topbar = grid(
        columns: (1fr, 1fr),
        align: (right + horizon, left + horizon),
        rows: 1.5em,
        grid.cell(fill: sk-states.colors.get().header)[#text(fill: white)[*#text(fill: white, formatted-number(type: "section")) #current-section* #h(0.75em)]],
        grid.cell(fill: sk-states.colors.get().secondary)[#text(fill: sk-states.colors.get().primary)[#h(0.75em) *#slide-subtitle()*]],
      )
      full-width(move(dy: -2pt)[#topbar])
  } else if sk-states.navigation-style.get() == "minislide" {
    let mini-content = [
      #let pad-lr = 3.5%
      #place(top, dy: -0.75em)[#cell(fill: sk-states.colors.get().secondary.lighten(60%))
      ]
      #pad(left: pad-lr, right: pad-lr, top: 0.5em)[#mini-slides()]
      #place(dx: 3.5%, dy: 1em)[#box(width: 100%, outset: (left: 2em, right: 1em, rest: 0.5em), fill: sk-states.colors.get().secondary.lighten(45%), text(size: 1.25em, weight: "bold", fill: sk-states.colors.get().header, slide-subtitle()))]
    ]
    full-width(mini-content)
  }

  let footer = context {
    let current-page = if sk-states.appendix.get() {
      sk-states.app-slide-number.get().first()
    } else {
      sk-states.slide-number.get().first()
    }
    let prefix = if sk-states.appendix.get() { "A." } else { "" }
    [
      #let slide-number = if sk-states.appendix.get() {
        [#prefix#sk-states.app-slide-number.get().first() / #sk-states.app-slide-number.final().first()]
      } else {
        [#sk-states.slide-number.get().first() / #sk-states.slide-number.final().first()]
      }

      #let dy
      #let footer-content = if sk-states.navigation-style.get() == "topbar" {
        set text(size: 0.8em)
        dy = 0.8em
        grid(
          columns: (1fr, 2fr, 1fr),
          rows: 1.5em,
          align: (center + horizon, center + horizon, right + horizon),
          grid.cell(fill: sk-states.colors.get().footer)[#text(fill: white)[*#sk-states.pres-info.get().author* #h(0.75em)]],
          grid.cell(fill: sk-states.colors.get().secondary)[#text(fill: sk-states.colors.get().footer)[#h(0.75em) *#sk-states.pres-info.get().short-title*]],
          grid.cell(fill: sk-states.colors.get().footer)[#text(fill: white)[*#slide-number* #h(1em)]],
        )

        place(bottom, dx: 0.1em, dy: -2.7em, sk-states.logo.get())
      } else {
        dy = 0em
        let pad-lr = 3.5%
        show: pad.with(left: pad-lr, right: pad-lr, top: 0.5em)
        grid(
          columns: (1fr,)*2,
          align: (left + horizon, right),
          [#place(dy: -1em, sk-states.logo.get())],
          [#text(size: 0.8em, fill: sk-states.colors.get().footer)[*#prefix#current-page*]]
        )
      }
      #move(dy: dy, full-width(footer-content))
    ]
  }

  set page(
    header: header,
    footer: footer
  )

  // Lists and enumerations
  set list(marker: ([#text(size: 0.9em, fill:sk-states.colors.get().primary)[#sym.circle.filled]], [#text(size: 0.9em, fill:sk-states.colors.get().primary)[#sym.triangle.filled.small.r]], [#text(size: 0.9em, fill:sk-states.colors.get().primary)[#sym.square.filled]]))

  set enum(numbering: n => context text(fill:sk-states.colors.get().primary)[#n.])

  // Tables
  show table.cell.where(y: 0): set text(weight: "bold")
  let table-primary = sk-states.colors.get().primary
  set table(
    stroke: (_, y) => (
      top: if y <= 1 {1.75pt + table-primary} else {0pt},
      bottom: 1.75pt + table-primary
    ),
    inset: 0.5em
  )

  // References
  show ref: set text(fill: sk-states.colors.get().primary)
  show ref: it => show-ref(it)

  // Links
  show link: set text(fill: sk-states.colors.get().primary)

  body
}

// Title page
#let cambfurt-title = context {
  set page(header: none, footer: none, margin: 1cm)

  set align(center + horizon)

  let title-info = sk-states.pres-info.get()

  if title-info.logo != none {
    place(top, row-img(title-info.logo))
  }

  let title-content = {
    if title-info.title != none {
      smallcaps(text(size: 2em, fill: sk-states.colors.get().primary)[*#title-info.title*])
    }

    if title-info.subtitle != none {
      linebreak()
      text(size: 1.25em, title-info.subtitle)
    }
  }

  box(width: 90%, inset: 1em, radius: 1em, fill: sk-states.colors.get().secondary, title-content)

  place(center + bottom, dy: -2em)[
    #set text(size: 0.85em)

    #if title-info.author != none {
      block(spacing: 1em, text(fill: sk-states.colors.get().primary)[#title-info.author])
    }

    #if title-info.date != none {
      block(spacing: 1em, title-info.date)
    }

    #set text(size: 0.8em)
    #if title-info.institution != none {
      block(spacing: 1em, title-info.institution)
    }

    #if title-info.contact != none {
      block(spacing: 1em, title-info.contact)
    }
  ]
}

#let cambfurt-toc = context {
  let header-content = if sk-states.navigation-style.get() == "topbar" {
      let topbar = grid(
        columns: (1fr, 1fr),
        align: right + horizon,
        rows: 1.5em,
        grid.cell(fill: sk-states.colors.get().primary)[#text(fill: white)[*#sk-states.localization.get().toc* #h(0.75em)]],
        cell(fill: sk-states.colors.get().secondary),
      )
      move(dy: -2pt)[#topbar]
    } else {
      move(dx: 1em, dy: -0.5em)[#box(width: 100%, fill: sk-states.colors.get().secondary.lighten(45%), outset: (left: 1em, rest: 0.5em))[*#sk-states.localization.get().toc*]]
    }
    let header = full-width(fill: none, align(horizon, text(size: 1.2em, fill: sk-states.colors.get().primary)[#header-content]))

  set page(header: header, footer: none)

  toc
}

#let cambfurt-focus-slide(body) = context {
  set page(header:none, footer: none, fill: sk-states.colors.get().focus)
  set align(center + horizon)
  text(size: 2em, fill: white)[*#body*]
}

#let cambfurt-link-box(location, name) = {
  block(fill: sk-states.colors.get().primary, radius: 1em, inset: 0.5em)[
    #set text(size: 0.8em, weight: "bold")
    #show link: set text(fill: white)
    #link(location, name)
  ]
}

#let cambfurt-boxeq(body) = context{
  set align(center)
  box(
    stroke: 1.75pt + sk-states.colors.get().primary,
    radius: 5pt,
    inset: 0.5em,
  )[#body]
}

#let cambfurt-custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  set text(size: 0.8em)
  showybox(
    title: box-title(color-svg("resources/images/icons/" + icon + ".svg", color, width: 1em), [*#title*]),
    title-style: (
      color: color,
      sep-thickness: 0pt,
    ),
    frame: (
      title-color: color.lighten(85%),
      border-color: color,
      body-color: none,
      thickness: (left: 1.25pt),
      radius: 0pt,
    ),
    breakable: true
  )[#body]
}

#let cambfurt = (theme: cambfurt-theme, title: cambfurt-title, toc: cambfurt-toc, focus-slide: cambfurt-focus-slide, link-box: cambfurt-link-box, boxeq: cambfurt-boxeq, custom-box: cambfurt-custom-box, colors: cambfurt-colors, fonts: cambfurt-fonts)
