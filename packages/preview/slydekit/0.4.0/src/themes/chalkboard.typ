#import "../slydekit-defaults.typ": *
#import "../slydekit-utils.typ": *
#import "../slydekit-outline.typ": *

#let chalkboard-colors = (
  primary: rgb("#8fd3ff"),
  secondary: rgb("#a9aaa3"),
  focus: none,
  background: none,
  header: rgb("#8fd3ff"),
  footer: rgb("#8fd3ff"),
)

#let chalkboard-colors-variant = (
  primary: rgb("#e57373"),
  secondary: rgb("#a9aaa3"),
  focus: none,
  background: none,
  header: rgb("#e57373"),
  footer: rgb("#e57373"),
)

#let chalkboard-fonts = (
  body: "Pennstander",
  math: "Pennstander Math",
  raw: "Fantasque Sans Mono",
)

#let header-size = 1.2em

#let chalkboard-theme(body) = context{
  set text(fill: rgb("#f2f1ea"))

  // Page setup
  let chalkboard-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 3.25cm)
  }
  set page(fill: sk-states.colors.get().background, margin: default-margins + chalkboard-margin)

  let slide-level = sk-states.slide-level.get()

  // Heading styles
  show heading.where(level: slide-level - 1): it => {
    set strong(delta: 0)
    set page(header: none, footer: none, margin: default-margins)

    set align(horizon)
    show: pad.with(10%)
    set text(size: 1.3em)
    v(-0.7em)

    stack(
      dir: ttb,
      spacing: 0.5em,
      [*#text(sk-states.colors.get().primary, formatted-number()) #it.body*],
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        section-progress-bar(sk-states.colors.get().primary, sk-states.colors.get().secondary, slide-level: slide-level)
      ),
    )
  }

  let header = context {
    set text(size: sk-states.fonts.get().size)
    if sk-states.navigation-style.get() == "topbar" {
      let header-title = [#h(1em)*#slide-subtitle()*]
      full-width(fill: none, align(horizon, text(size: header-size, fill: sk-states.colors.get().primary)[#header-title]))

      full-width(place(dy: 2em, line(length: 100%, stroke: 0.05em + sk-states.colors.get().header)))
    } else if sk-states.navigation-style.get() == "minislide" {
      let mini-content = [
        #let pad-lr = 3.5%
        #pad(left: pad-lr, right: pad-lr, top: 0.5em)[#mini-slides(slide-level: slide-level)]
        #place(dy: 0.5em, line(length: 100%, stroke: 0.05em + sk-states.colors.get().header))

        #place(dx: 3.5%, dy: 1.25em)[#text(size: header-size, weight: "bold", fill: sk-states.colors.get().header, slide-subtitle())]
      ]
      full-width(mini-content)
    }
  }

  let footer = context {
    set text(size: sk-states.fonts.get().size)
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
          [#text(size: 0.9em, fill: sk-states.colors.get().footer)[*#prefix#current-page*]]
        )
      ]
      #full-width(footer-content)
    ]
  }

  set page(
    header: header,
    footer: footer,
    background: image("../resources/images/chalkboard.png", ),
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
#let chalkboard-title = context {
  let chalkboard-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 2cm)
  }
  set page(header: none, footer: none, margin: default-margins + chalkboard-margin)

  let title-info = sk-states.pres-info.get()

  if title-info.logo != none {
    place(top, row-img(title-info.logo))
  }

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

#let chalkboard-toc = context {
  set text(size: sk-states.fonts.get().size)

  let header-content = {
    let dy = if sk-states.navigation-style.get() == "topbar" { 0em } else { 0.5em }
    [
      #move(dx: 1em, dy: -dy)[*#sk-states.localization.get().toc*]
      #place(dy: 0.5em - dy, line(length: 100%, stroke: 0.05em + sk-states.colors.get().header))
    ]
  }
  let header = full-width(fill: none, align(horizon, text(size: header-size, fill: sk-states.colors.get().primary)[#header-content]))

  set page(header: header, footer: none)

  toc(fill: (entry: white), slide-level: sk-states.slide-level.get())
}

#let chalkboard-focus-slide(body) = context {
  set page(header:none, footer: none, fill: sk-states.colors.get().focus)
  set align(center + horizon)
  text(size: 2em, fill: white)[*#body*]
}

#let chalkboard-link-box(location, name) = {
  block(fill: sk-states.colors.get().primary.darken(20%), radius: 1em, inset: 0.5em)[
    #set text(size: 0.8em, weight: "bold")
    #show link: set text(fill: rgb("#f2f1ea"))
    #link(location, name)
  ]
}

#let chalkboard-boxeq(body) = context{
  set align(center)
  box(
    stroke: 1.75pt + sk-states.colors.get().primary,
    radius: 5pt,
    inset: 0.5em,
  )[#body]
}

#let chalkboard-custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  set text(size: 0.8em, fill: color)
  let box-title = move(dy: -0.5em)[#box-title(color-svg("resources/images/icons/" + icon + ".svg", color, width: 1em), text(fill: color)[*#title*])]

  let box-content = block(breakable: true, box(fill: color.lighten(85%), stroke: 1pt + color, width: 100%, inset: (top: 1em, bottom: 1em, rest: 0.5em), radius: 0.5em)[#body])

  stack(
    dir: btt,
    box-content,
    box-title,
  )
}

#let chalkboard = (theme: chalkboard-theme, title: chalkboard-title, toc: chalkboard-toc, focus-slide: chalkboard-focus-slide, link-box: chalkboard-link-box, boxeq: chalkboard-boxeq, custom-box: chalkboard-custom-box, colors: chalkboard-colors, fonts: chalkboard-fonts)
