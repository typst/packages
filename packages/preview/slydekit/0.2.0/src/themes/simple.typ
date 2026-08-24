#import "../slydekit-defaults.typ": *
#import "../slydekit-utils.typ": *
#import "../slydekit-outline.typ": *

#let simple-colors = (
  primary: rgb("#014682"),
  secondary: rgb("#637382"),
  focus: rgb("#014682"),
  background: none,
  header: rgb("#014682"),
  footer: rgb("#014682"),
)

#let simple-fonts = (
  body: "Fira Sans",
  math: "Fira Math",
  raw: "Fira Code",
)

#let simple-theme(body) = context {
  // Page setup
  let simple-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 3.25cm)
  }
  set page(fill: sk-states.colors.get().background, margin: margins + simple-margin)

  // Heading styles
  set heading(numbering: (..nums) => {
    if sk-states.appendix.get() {
      numbering("A.1.", ..nums)
    } else {
      numbering("1.1.", ..nums)
    }
  })

  // Heading styles
  show heading.where(level: 1): it => {
    let header-content = {
      let dy = if sk-states.navigation-style.get() == "topbar" { 0em } else { -0.2em }
      [#move(dx: 1em, dy: dy)[*#sk-states.localization.get().toc*]]

      if sk-states.navigation-style.get() == "minislide" {
        place(dy: 0.5em, line(length: 100%, stroke: 0.05em + sk-states.colors.get().primary))
      }
    }
    let header = full-width(fill: none, align(horizon, text(size: 1.399em, fill: sk-states.colors.get().primary)[#header-content]))

    set page(header: header, footer: none)
    set align(horizon)

    progressive-outline(it, sk-states.colors.get().primary, sk-states.colors.get().secondary.lighten(60%))
  }

  let header = context if sk-states.navigation-style.get() == "topbar" {
    let header-title = [#h(1em)*#sk-states.current-slide-title.get()*]
    full-width(fill: none, align(horizon, text(size: 1.2em, fill: sk-states.colors.get().primary)[#header-title]))
  } else if sk-states.navigation-style.get() == "minislide" {
    let mini-content = [
      #let pad-lr = 3.5%
      #pad(left: pad-lr, right: pad-lr, top: 0.5em)[#mini-slides()]
      #place(dy: 0.5em, line(length: 100%, stroke: 0.05em + sk-states.colors.get().primary))

      #place(dx: 3.5%, dy: 1.25em)[#text(size: 1.25em, weight: "bold", fill: sk-states.colors.get().header, sk-states.current-slide-title.get())]
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
      #let footer-content = [
        #let pad-lr = 3.5%
        #show: pad.with(left: pad-lr, right: pad-lr, top: 0.5em)
        #grid(
          columns: (1fr,)*2,
          align: (left + horizon, right),
          [#place(dy: -1em, sk-states.logo.get())],
          [#text(size: 0.8em, fill: sk-states.colors.get().footer)[#prefix#current-page]]
        )
      ]
      #full-width(footer-content)
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

  // Links
  show link: set text(fill: sk-states.colors.get().primary)

  body
}

// Title page
#let simple-title = context {
  let simple-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 2cm)
  }
  set page(header: none, footer: none, margin: margins + simple-margin)

  let title-info = sk-states.pres-info.get()

  if title-info.logo != none {
    place(top, row-img(title-info.logo))
  }

  v(-1em)
  if title-info.title != none {
    smallcaps(text(size: 1.5em, fill: sk-states.colors.get().primary)[*#title-info.title*])
  }

  if title-info.subtitle != none {
    linebreak()
    text(size: 1em, title-info.subtitle)
  }


  place(bottom)[
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

#let simple-toc = context {
  let header-content = {
    let dy = if sk-states.navigation-style.get() == "topbar" { 0em } else { -0.2em }
    [#move(dx: 1em, dy: dy)[*#sk-states.localization.get().toc*]]

    if sk-states.navigation-style.get() == "minislide" {
      place(dy: 0.5em, line(length: 100%, stroke: 0.05em + sk-states.colors.get().primary))
    }
  }
  let header = full-width(fill: none, align(horizon, text(size: 1.2em, fill: sk-states.colors.get().primary)[#header-content]))

  set page(header: header, footer: none)

  toc
}

#let simple-focus-slide(body) = context {
  set page(header:none, footer: none, fill: sk-states.colors.get().focus)
  set align(center + horizon)
  text(size: 2em, fill: white)[*#body*]
}

#let simple-link-box(location, name) = {
  block(fill: sk-states.colors.get().primary, radius: 1em, inset: 0.5em)[
    #set text(size: 0.8em, weight: "bold")
    #show link: set text(fill: white)
    #link(location, name)
  ]
}

#let simple-boxeq(body) = context{
  set align(center)
  box(
    stroke: 1.75pt + sk-states.colors.get().primary,
    radius: 5pt,
    inset: 0.5em,
  )[#body]
}

#let simple-custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  set text(size: 0.8em)
  let box-title = move(dy: -0.5em)[#box-title(color-svg("resources/images/icons/" + icon + ".svg", color, width: 1em), text(fill: color)[*#title*])]

  let box-content = block(breakable: true, box(fill: color.lighten(85%), stroke: 1pt + color, width: 100%, inset: (top: 1em, bottom: 1em, rest: 0.5em), radius: 0.5em)[#body])

  stack(
    dir: btt,
    box-content,
    box-title,
  )
}

#let simple = (theme: simple-theme, title: simple-title, toc: simple-toc, focus-slide: simple-focus-slide, link-box: simple-link-box, boxeq: simple-boxeq, custom-box: simple-custom-box, colors: simple-colors, fonts: simple-fonts)
