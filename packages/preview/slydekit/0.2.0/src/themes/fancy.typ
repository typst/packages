#import "../slydekit-deps.typ": *
#import "../slydekit-defaults.typ": *
#import "../slydekit-utils.typ": *
#import "../slydekit-outline.typ": *

#let fancy-colors = (
  primary: rgb("#c1002a"),
  secondary: rgb("#405a68").lighten(50%),
  background: rgb("#405a68").lighten(95%),
  focus: rgb("#c1002a"),
  header: rgb("#c1002a"),
  footer: rgb("#c1002a"),
)

#let fancy-fonts = (
  body: "Lato",
  math: "Lete Sans Math",
  raw: "Cascadia Code",
)

#let fancy-theme(body) = context {
  // Page setup
  let fancy-margin = if sk-states.navigation-style.get() == "minislide" {
    (top: 3.25cm)
  }
  set page(fill: sk-states.colors.get().background, margin: margins + fancy-margin)

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

  // Header and footer
  let header = context if sk-states.navigation-style.get() == "topbar" {
    let header-title = [#h(1em)*#sk-states.current-slide-title.get()*]
    full-width(fill: sk-states.colors.get().header, align(horizon, text(size: 1.2em, fill: white)[#header-title]))
  } else if sk-states.navigation-style.get() == "minislide" {
    let mini-content = [
      #let pad-lr = 3.5%
      #if sk-states.colors.get().background != none {
        place(top, dy: -0.75em)[
          #cell(fill: gradient.linear(sk-states.colors.get().background.darken(10%), sk-states.colors.get().background, dir: ttb))
        ]
      }
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
      #let footer-content = {
        set align(bottom)
        set text(size: 0.8em)

        place(dy: -0.5em, {
          grid(
            columns: (1fr,)*3,
            align: (left + horizon, center + horizon, right + horizon),
            [
              #v(-0.5em)
              #set image(height: 1.75em)
              #move(dx: -1.75em, sk-states.logo.get())
            ],
            [
              #text(fill:sk-states.colors.get().footer, strong(sk-states.pres-info.get().short-title))
            ],
            [
              #set text(fill:sk-states.colors.get().footer, weight: "bold")
              #show: move.with(dx: 0.75em)
              #if sk-states.appendix.get() {
                context box(stroke: 1.75pt + sk-states.colors.get().footer, radius: 5pt, inset: -0.5em,outset: 1em)[A | #sk-states.app-slide-number.get().first() / #sk-states.slide-number.final().first()]
              } else {
                context box(stroke: 1.75pt + sk-states.colors.get().footer, radius: 5pt, inset: -0.5em,outset: 1em)[#sk-states.slide-number.get().first() / #sk-states.slide-number.final().first()]
              }
            ]
          )}
        )
      }
      #move(dy: 0.35em,footer-content)
      #full-width(anchor: bottom, slide-progress-bar(sk-states.colors.get().primary, sk-states.colors.get().secondary, height: 2.5pt))
    ]
  }

  set page(
    header: header,
    footer: footer
  )

  // Lists and enumerations
  set list(marker: ([#text(size: 0.9em, fill: sk-states.colors.get().primary)[#sym.circle.filled]], [#text(size: 0.9em, fill:sk-states.colors.get().primary)[#sym.triangle.filled.small.r]], [#text(size: 0.9em, fill:sk-states.colors.get().primary)[#sym.square.filled]]))

  set enum(numbering: n => context text(fill:sk-states.colors.get().primary)[#n.])

  // Tables
  show table.cell.where(y: 0): set text(weight: "bold", fill: white)
  let table-primary = sk-states.colors.get().primary
  let table-secondary = sk-states.colors.get().secondary
  set table(
    fill: (_, y) => if y == 0 {table-primary} ,
    stroke: (_, y) => if y == 0 {(bottom: 0pt)} else {(bottom: 01pt + table-secondary)},
    inset: 0.5em
  )
  show table: it => block(
    stroke: 1pt + sk-states.colors.get().primary,
    radius: 0.75em,
    clip: true
  )[#it]

  // Reference
  show ref: set text(fill: sk-states.colors.get().primary)
  show ref: it => show-ref(it)

  // Links
  show link: set text(fill: sk-states.colors.get().primary)

  body
}

// Title page
#let fancy-title = context {
  let fancy-margin = (left: 0.75cm, right: 0.75cm, top: 0.75cm, bottom: 0.75cm)

  set page(header: none, footer: none, margin: margins + fancy-margin)

  let title-info = sk-states.pres-info.get()

  set align(center + horizon)

  if title-info.logo != none {
    place(top, row-img(title-info.logo))
  }

  let title-line = line(length: 115%, stroke: 2pt + sk-states.colors.get().primary)
  block(width: 100%, inset: 2cm, {
      title-line
      text(size: 1.75em, strong(title-info.title))
      title-line

      if title-info.author != none {
        v(0.5em)
        set text(size: 1em)
        block(spacing: 1em, strong(title-info.author))
      }

      if title-info.institution != none {
        set text(size: 0.85em)
        block(spacing: 1em, title-info.institution)
      }

      if title-info.date != none {
        set text(size: 0.85em)
        move(dy: 1em, block(spacing: 1em, title-info.date))
      }
    }
  )
}

#let fancy-toc = context {
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

#let fancy-focus-slide(body) = context {
  set page(header:none, footer: none, fill: sk-states.colors.get().focus)
  set align(center + horizon)
  text(size: 2em, fill: white)[*#body*]
}

#let fancy-link-box(location, name) = {
  block(fill: sk-states.colors.get().primary, radius: 1em, inset: 0.5em)[
    #set text(size: 0.8em, weight: "bold")
    #show link: set text(fill: white)
    #link(location, name)
  ]
}

#let fancy-boxeq(body) = context{
  set align(center)
  box(
    stroke: 1.5pt + sk-states.colors.get().primary,
    radius: 5pt,
    inset: 0.5em,
    fill: sk-states.colors.get().secondary.lighten(70%),
  )[#body]
}

#let fancy-custom-box(title: none, icon: "info", color: rgb(29, 144, 208), body) = {
  set text(size: 0.8em)
  showybox(
    title: box-title(color-svg("resources/images/icons/" + icon + ".svg", color, width: 1em), [*#title*]),
    title-style: (
      color: color,
      sep-thickness: 0pt,
    ),
    frame: (
      title-color: color.lighten(80%),
      border-color: color,
      body-color: none,
      thickness: (left: 2pt),
      radius: (top-left: 0pt, bottom-right: 1em, top-right: 1em),
    )
  )[#body]
}

#let fancy = (theme: fancy-theme, title: fancy-title, toc: fancy-toc, focus-slide: fancy-focus-slide, link-box: fancy-link-box, boxeq: fancy-boxeq, custom-box: fancy-custom-box, colors: fancy-colors, fonts: fancy-fonts)