#import "../slydekit-defaults.typ": *
#import "../slydekit-utils.typ": *
#import "../slydekit-outline.typ": *

#let metropolis-colors = (
  primary: rgb("#eb811b"),
  secondary: rgb("#d6c6b7"),
  focus: rgb("#23373b"),
  background: rgb("#fafafa"),
  header: rgb("#23373b"),
  footer: rgb("#23373b").lighten(20%),
)

#let metropolis-fonts = (
  body: "Fira Sans",
  math: "Fira Math",
  raw: "Fira Code",
)

#let metropolis-theme(body) = context{
  // Page setup
  let metropolis-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 3.25cm)
  }
  set page(fill: sk-states.colors.get().background, margin: margins + metropolis-margin)

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
    set strong(delta: 0)
    set page(header: none, footer: none, margin: margins)

    set align(horizon)
    show: pad.with(10%)
    set text(size: 1.3em)
    v(-0.7em)

    stack(
      dir: ttb,
      spacing: 0.5em,
      [*#it.body*],
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        section-progress-bar(sk-states.colors.get().primary, sk-states.colors.get().secondary)
      ),
    )
  }

  let header = context if sk-states.navigation-style.get() == "topbar" {
    let header-title = [#h(1em)*#sk-states.current-slide-title.get()*]
    full-width(fill: sk-states.colors.get().header, align(horizon, text(size: 1.2em, fill: white)[#header-title]))
  } else if sk-states.navigation-style.get() == "minislide" {
    let mini-content = [
      #let pad-lr = 3.5%
      #pad(left: pad-lr, right: pad-lr, top: 0.5em)[#mini-slides()]
      #place(dy: 0.5em, line(length: 100%, stroke: 0.05em + sk-states.colors.get().header))

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
      #full-width(anchor: bottom, slide-progress-bar(sk-states.colors.get().primary, sk-states.colors.get().secondary, height: 2.5pt))
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
      top: if y <= 1 {1pt + table-primary} else {0pt},
      bottom: 1pt + table-primary
    ),
    inset: 0.5em
  )

  // Reference
  show ref: set text(fill: sk-states.colors.get().primary)
  show ref: it => show-ref(it)

  // Links
  show link: set text(fill: sk-states.colors.get().primary)

  body
}

// Title page
#let metropolis-title = context {
  let metropolis-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 2cm)
  }
  set page(header: none, footer: none, margin: margins + metropolis-margin)

  let title-info = sk-states.pres-info.get()

  if title-info.logo != none {
    place(top, row-img(title-info.logo))
  }

  if title-info.title != none {
    smallcaps(text(size: 1.5em)[*#title-info.title*])
  }

  if title-info.subtitle != none {
    linebreak()
    text(size: 1em, title-info.subtitle)
  }

  line(length: 100%, stroke: 0.05em + sk-states.colors.get().primary)

  set text(size: 0.85em)

  if title-info.author != none {
    block(spacing: 1em, title-info.author)
  }
  if title-info.date != none {
    block(spacing: 1em, title-info.date)
  }
  set text(size: 0.8em)
  if title-info.institution != none {
    block(spacing: 1em, title-info.institution)
  }

  if title-info.contact != none {
    block(spacing: 1em, title-info.contact)
  }
}

#let metropolis-toc = context {
  let (header-color, text-color) = if sk-states.navigation-style.get() == "topbar" {
    (sk-states.colors.get().header, white)
  } else {
    (none, sk-states.colors.get().header)
  }
  let header-content = {
    let dy = if sk-states.navigation-style.get() == "topbar" { 0em } else { -0.2em }
    [#move(dx: 1em, dy: dy)[*#sk-states.localization.get().toc*]]

    if sk-states.navigation-style.get() == "minislide" {
      place(dy: 0.5em, line(length: 100%, stroke: 0.05em + sk-states.colors.get().header))
    }
  }
  let header = full-width(fill: header-color, align(horizon, text(size: 1.2em, fill: text-color)[#header-content]))

  set page(header: header, footer: none)

  toc
}

#let metropolis-focus-slide(body) = context {
  set page(header:none, footer: none, fill: sk-states.colors.get().focus)
  set align(center + horizon)
  text(size: 2em, fill: white)[*#body*]
}

#let metropolis-link-box(location, name) = {
  block(fill: sk-states.colors.get().primary, radius: 1em, inset: 0.5em)[
    #set text(size: 0.8em, weight: "bold")
    #show link: set text(fill: white)
    #link(location, name)
  ]
}

#let metropolis-boxeq(body) = context{
  set align(center)
  box(
    stroke: 1.5pt + sk-states.colors.get().primary,
    radius: 5pt,
    inset: 0.5em,
  )[#body]
}

#let metropolis-custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.75em,
    align: top + left,
    [
      #v(0.5em)
      #color-svg("resources/images/icons/" + icon + ".svg", color, width: 1.2em)
    ],
    [
      #box(
      stroke: (left: 2pt + color),
      fill: color.lighten(90%),
      inset: (left: 0.5em, right: 0.5em, rest: 0.75em),
      width: 100%
      )[#text(size: 0.8em, body)]
    ]
  )
}

#let metropolis = (theme: metropolis-theme, title: metropolis-title, toc: metropolis-toc, focus-slide: metropolis-focus-slide, link-box: metropolis-link-box, boxeq: metropolis-boxeq, custom-box: metropolis-custom-box, colors: metropolis-colors, fonts: metropolis-fonts)
