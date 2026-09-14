#let min-version = version(0, 12, 0)

#let section-bullet-point-radius = 2pt
#let section-underlined-bar-thickness = 2pt

#let chronology-bullet-point-radius = 2pt
#let chronology-bar-width = 1pt

#let progress-bar-height = 6pt


#let default-theme = (
  spacing: 14pt,
  gutter-width: 42pt,
  font: "Inria Sans",
  font-size: 11pt,
  accent-color: blue.darken(30%),
  body-color: rgb("222"),
  gutter-body-color: none, // inherit
  section-style: "bullet-point", // "underlined" | "outlined" | "box" | "bullet-point"
)


#let inline(body) = {
  set text(top-edge: "bounds")
  body
}


#let internal-display-size(size) = [
  #calc.round(size.width.pt())x#calc.round(size.height.pt())
]


#let chronology-fixed-height(
  height,
  start: [],
  end: [],
) = {
  let bullet-radius = chronology-bullet-point-radius
  let bar-width = chronology-bar-width

  context {
    let spacing = ellipse.outset
    let gap-height = 8pt + 0.4 * spacing
    let bar-spacing = 1.0 * spacing

    let start-height = if (start == []) { 0pt } else { measure(start).height }
    let end-height = if (end == []) { 0pt } else { measure(end).height }
    let top-gap = if (end == []) { 0pt } else { gap-height + end-height / 2 }
    let bot-gap = if (start == []) { 0pt } else { gap-height + start-height / 2 }

    block(
      inset: (right: 2.0 * bar-spacing),
      [
        // Bar.
        #place(
          top + right,
          dx: bar-spacing,
          dy: top-gap,
          rect(
            height: height - top-gap - bot-gap,
            width: bar-width,
            stroke: none,
          )
        )
        // Bullet points.
        #if (end != []) {
          place(
            top + right,
            dx: bar-spacing - bar-width / 2 + bullet-radius,
            dy: end-height / 2 - bullet-radius,
            circle(
              radius: bullet-radius,
              stroke: none,
            )
          )
        }
        #if (start != []) {
          place(
            bottom + right,
            dx: bar-spacing - bar-width / 2 + bullet-radius,
            dy: -start-height / 2 + bullet-radius,
            circle(
              radius: bullet-radius,
              stroke: none,
            )
          )
        }

        #stack(
          end,
          v(height - start-height - end-height),
          start,
        )
        #label("cv-chronology")
      ]
    )
  }
}


#let chronology(
  start: [],
  end: [],
) = {
  set align(right)

  [
    #stack(
      end,
      [], // placeholder.
      start,
    )
    #label("cv-chronology-auto")
  ]
}

#let internal-theme(
  theme: (),
  body,
) = {
  let th(field, v: none) = {
    field in theme and theme.at(field) != none and (
      v == none or theme.at(field) == v
    )
  }

  // Spacing.
  // HACK: Use `ellipse.outset` to store spacing.
  set ellipse(outset: theme.spacing) if th("spacing")

  set par(linebreaks: "simple", leading: 0.4 * theme.spacing) if th("spacing")
  set block(
    above: 4pt + 0.8 * theme.spacing,
    below: 1pt + 0.6 * theme.spacing,
    spacing: 2pt + 0.4 * theme.spacing,
  ) if th("spacing")

  set text(font: theme.font) if th("font")
  set text(size: theme.font-size) if th("font-size")
  set text(fill: theme.body-color) if th("body-color")

  show heading.where(level: 1): set text(size: 3.0 * theme.font-size) if th("font-size")
  show heading.where(level: 1): set text(fill: theme.accent-color) if th("accent-color")

  show heading.where(level: 2): set text(size: 1.6 * theme.font-size) if th("font-size")
  show heading.where(level: 2): set text(fill: theme.body-color.lighten(40%)) if th("body-color")
  show heading.where(level: 2): set block(
    above: 10pt + 1.0 * theme.spacing,
    below: 12pt + 1.0 * theme.spacing,
  ) if th("spacing")

  show heading.where(level: 3): set text(size: 1.2 * theme.font-size) if th("font-size")
  show heading.where(level: 3): set text(fill: theme.accent-color) if th("accent-color")
  show heading.where(level: 3): set block(
    above: 4pt + 1.2 * theme.spacing,
    below: 0pt + 0.6 * theme.spacing,
    spacing: 2pt + 0.6 * theme.spacing,
  ) if th("spacing")

  show heading.where(level: 4): set text(size: theme.font-size) if th("font-size")
  show heading.where(level: 4): set text(fill: theme.body-color) if th("body-color")
  show heading.where(level: 4): set block(
    above: 40pt + 1.4 * theme.spacing,
    below: 40pt + 0.6 * theme.spacing,
    spacing: 2pt + 0.6 * theme.spacing,
  ) if th("spacing")

  // Section.
  // HACK: Use `ellipse.inset` to store section style.
  show label("cv-section"): set ellipse(inset: 1pt) if th("section-style", v: "underlined")
  show label("cv-section"): set ellipse(inset: 2pt) if th("section-style", v: "outlined")
  //show label("cv-section"): set sys.inputs(toto: "") if th("section-style", v: "outlined")
  show label("cv-section"): set ellipse(inset: 3pt) if th("section-style", v: "box")
  show label("cv-section"): set ellipse(inset: 4pt) if th("section-style", v: "bullet-point")
  //if th("section-style") [#metadata("section-style(" + theme.section-style + ")") <cv-section-metadata>]

  // Gutter.
  show label("cv-entry"): set grid(columns: (theme.gutter-width, 1fr)) if th("gutter-width")
  show label("cv-section-header"): set grid(columns: (theme.gutter-width, 1fr)) if th("gutter-width")
  show label("cv-gutter"): set text(fill: theme.gutter-body-color) if th("gutter-body-color")
  show label("cv-gutter"): set text(fill: theme.body-color.lighten(40%)) if th("body-color") and not th("gutter-body-color")

  // Shapes used in section header, chronology and progress bar.
  // TODO: Filter by label (?)
  set rect(
    fill: theme.accent-color.lighten(60%),
    stroke: theme.accent-color.lighten(40%),
  ) if th("accent-color")
  set circle(
    fill: theme.accent-color.lighten(60%),
    stroke: theme.accent-color.lighten(40%),
  ) if th("accent-color")

  body
}


#let theme(
  spacing: none,
  gutter-width: none,
  font: none,
  font-size: none,
  accent-color: none,
  body-color: none,
  gutter-body-color: none,
  section-style: none,
  body,
) = internal-theme(
  theme: (
    spacing: spacing,
    gutter-width: gutter-width,
    font: font,
    font-size: font-size,
    accent-color: accent-color,
    body-color: body-color,
    gutter-body-color: gutter-body-color,
    section-style: section-style,
  ),
  body,
)


#let internal-version-warning() = {
  block(
    width: 100%,
    inset: 12pt,
    stroke: red,
    fill: red.lighten(80%),

    [
      *You Typst version (#sys.version)
      is lower than recommended version (#min-version).*

      Ignore this warning with flag `ignore-version` :
      ```typst
      #show: cv.with(
        theme: (...)
        ignore-version: true,
      )
      ```
    ]
  )
}


#let internal-outline(
  section,
) = context {
  let spacing = ellipse.outset
  let space-x = 4pt + 0.5 * spacing
  let space-y = 5pt + 0.5 * spacing

  place(
    left,
    dx: -space-x,
    dy: -space-y,

    layout(layout-section => {
      let dummy-section = box(width: layout-section.width, section)
      let section-size = measure(dummy-section)

      rect(
        width: section-size.width + 2 * space-x,
        height: section-size.height + 2 * space-y,
        fill: none,
      )
    })
  )
}


#let cv(
  theme: (),
  ignore-version: false,
  body,
) = {
  set text(costs: (
    hyphenation: 200%,
    runt: 200%,
  ))

  show heading.where(level: 2): set text(weight: "regular")

  show label("cv-gutter"): set text(tracking: -0.5pt, style: "italic")

  set list(marker: ([○], [•], [-]))

  // Section.
  show label("cv-section"): it-section => {
    // HACK: Use `ellipse.inset` to store section style.
    let section-style-index = ellipse.inset.length.pt()
    let section-style = if (section-style-index == 1) {
      "underlined"
    } else if (section-style-index == 2) {
      "outlined"
    } else if (section-style-index == 3) {
      "box"
    } else {
      "bullet-point"
    }

    show heading.where(level: 3): it-heading => {
      let spacing = ellipse.outset

      if (section-style == "underlined") {
        {
          set block(below: 0pt)
          it-heading
        }
        {
          set block(above: 0.6 * spacing)
          rect(
            height: section-underlined-bar-thickness,
            width: 100%,
            stroke: none,
          )
        }
      }
      else if (section-style == "outlined" or section-style == "box") {
        it-heading
        v(0.4 * spacing)
      }
      else if (section-style == "bullet-point") {
        let bullet-radius = section-bullet-point-radius

        grid(
          //columns: (inherited by theme),
          align(
            right + horizon,

            block(
              inset: (right: spacing - bullet-radius + 0.5pt),
              circle(radius: bullet-radius)
            )
          ),
          {
            it-heading
          }
        )
        v(8pt)
      }
      else {
        it-heading
      }
    }

    // DEBUG: Show section style.
    //[*SECTION STYLE = #section-style (#section-style-index)*]

    // Place rect outside section as an outline.
    if (section-style == "outlined") {
      internal-outline(it-section)
      it-section
      context {
        let spacing = ellipse.outset
        v(0.2 * spacing)
      }
    }
    else if (section-style == "box") {
      show label("cv-section-body"): it-section-body => [
        #internal-outline(it-section-body)
        #it-section-body
      ]

      it-section
      context {
        let spacing = ellipse.outset
        v(0.2 * spacing)
      }
    }
    else {
      it-section
    }
  }

  // Chronology auto height.
  show label("cv-entry"): it-entry => {
    let child-grid = it-entry.child
    let right-cell = it-entry.child.children.at(1)

    layout(layout-entry => {
      show label("cv-chronology-auto"): it-bar => {
        let end = it-bar.children.at(0)
        let start = it-bar.children.at(2)

        layout(layout-chronology => {
          // Create dummy right cell to measure .
          let right-cell-width = layout-entry.width - layout-chronology.width
          let right-cell-dummy = align(left, box(
            width: right-cell-width,
            {
              // Revert gutter styling.
              set text(tracking: 0pt, style: "normal")
              right-cell
            }))
          let right-cell-height = measure(right-cell-dummy).height

          // DEBUG: Highlight right-cell outline.
          //let debug-box = box(stroke: red, fill: white, width: right-cell-width, height: right-cell-height, right-cell-dummy)
          //#place(top + right, dx: 267pt, debug-box)
          //l1: #internal-display-size(layout-entry)
          //l2: #internal-display-size(layout-chronology)

          chronology-fixed-height(
            right-cell-height,
            start: start,
            end: end,
          )
        })
      }

      it-entry
    })
  }

  if (sys.version < min-version and not ignore-version) {
    internal-version-warning()
  }

  // Apply theme with first default theme then input theme.
  internal-theme(theme: default-theme, internal-theme(theme: theme, body))
}


#let entry(
  theme: (),
  right: none,
  gutter,
  title,
  body,
) = [#{
  show: internal-theme.with(theme: theme)

  grid(
    //columns: (inherited by theme),
    [
      #gutter
      #label("cv-gutter")
    ],
    {
      let has-title = title != none
      let has-right = right != none

      if has-title or has-right {
        grid(
          columns: (1fr, auto),
          heading(
            level: 4,
            title
          ),
          block(right)
        )
      }

      if body != none {
        context {
          let spacing = ellipse.outset

          set par(justify: true)
          set block(above: 0.6 * spacing)

          body
        }
      }
    }
  )
}#label("cv-entry")]


#let section(
  theme: (),
  title,
  body,
) = {
  show: internal-theme.with(theme: theme)

  [#{
    if (title != none) {
      [
        #heading(level: 3, title)
        #label("cv-section-header")
      ]
    }
    [
      #body
      #label("cv-section-body")
    ]
  }#label("cv-section")]
}


#let progress-bar(
  progress,
) = {
  context {
    let light-accent = rect.fill//.lighten(30%)

    rect(
      height: progress-bar-height,
      width: 100%,
      fill: rgb("#0000"),
      inset: 0pt,
      [
        #place(
          rect(
            width: progress,
            stroke: 0pt,
            fill: light-accent,
          )
        )
      ]
    )
  }
}
