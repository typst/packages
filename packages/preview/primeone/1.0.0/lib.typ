// =============================================================================
// PrimeOne Typst Template
// Copyright (c) 2026 - Simon Eller
// Licensed under the MIT License — see LICENSE in the repository root:
// https://github.com/simon-eller/primeone-typst/blob/main/LICENSE
//
// Attribution: color palette and layout of the components
//              inspired by the PrimeReact Lara themes by PrimeTek
// https://primereact.org — used under MIT License
// =============================================================================

// Theme colors
#let theme-lara-cyan = (
  primary:          rgb("#06b6d4"),
  primary-dark:     rgb("#047f94"),
  primary-light:    rgb("#c3edf5"),
  primary-bg:       rgb("#ecfeff"),
)

#let theme-lara-purple = (
  primary:          rgb("#8b5cf6"),
  primary-dark:     rgb("#6140ac"),
  primary-light:    rgb("#e3d8fd"),
  primary-bg:       rgb("#f5f3ff"),
)

#let theme-lara-green = (
  primary:          rgb("#10b981"),
  primary-dark:     rgb("#0b825a"),
  primary-light:    rgb("#c6eee1"),
  primary-bg:       rgb("#f0fdfa"),
)

#let theme-lara-blue = (
  primary:          rgb("#3b82f6"),
  primary-dark:     rgb("#295bac"),
  primary-light:    rgb("#d0e1fd"),
  primary-bg:       rgb("#eff6ff"),
)

#let theme-lara-teal = (
  primary:          rgb("#14b8a6"),
  primary-dark:     rgb("#0e8174"),
  primary-light:    rgb("#c7eeea"),
  primary-bg:       rgb("#f0fdfa"),
)

#let theme-lara-indigo = (
  primary:          rgb("#6366f1"),
  primary-dark:     rgb("#4547a9"),
  primary-light:    rgb("#dadafc"),
  primary-bg:       rgb("#eef2ff"),
)

#let theme-lara-pink = (
  primary:          rgb("#ec4899"),
  primary-dark:     rgb("#a5326b"),
  primary-light:    rgb("#fad3e7"),
  primary-bg:       rgb("#fdf2f8"),
)

// Surface colors
#let pr-surface-a   = rgb("#ffffff")
#let pr-surface-b   = rgb("#f9fafb")
#let pr-surface-c   = rgb("#f3f4f6")
#let pr-surface-d   = rgb("#e5e7eb")
#let pr-surface-300 = rgb("#d1d5db")
#let pr-surface-400 = rgb("#9ca3af")
#let pr-surface-500 = rgb("#6b7280")
#let pr-surface-600 = rgb("#4b5563")
#let pr-surface-700 = rgb("#374151")
#let pr-surface-800 = rgb("#1f2937")
#let pr-surface-900 = rgb("#111827")
#let pr-border      = rgb("#dfe7ef")

// Text colors
#let pr-text           = rgb("#4b5563")
#let pr-text-secondary = rgb("#6b7280")

// Severity colors
#let pr-info-bg      = rgb("#e6f0fe")
#let pr-info-text    = rgb("#3b82f6")

#let pr-success-bg     = rgb("#ecfaf4")
#let pr-success-text   = rgb("#1ea97c")

#let pr-warn-bg     = rgb("#fff6eb")
#let pr-warn-text   = rgb("#cc8925")

#let pr-error-bg     = rgb("#ffeeed")
#let pr-error-text   = rgb("#ff5757")

#let pr-neutral-bg     = rgb("#f2f2f2")
#let pr-neutral-text   = rgb("#8394ae")

// Spacing scale
#let pr-space-xs = 0.5em
#let pr-space-sm = 0.75em
#let pr-space-md = 1em
#let pr-space-lg = 2em

// Set theme state
#let theme-state = state("primeone-typst:theme", theme-lara-cyan)

// Icons
#let gs(name) = text(font: "Material Symbols Rounded Filled", name)
#let icon-info = gs("\u{e88e}")
#let icon-success = gs("\u{e876}")
#let icon-warning = gs("\u{e002}")
#let icon-error = gs("\u{e000}")

// Badge colors
#let badge-colors = (
  info:      (bg: rgb(219, 234, 254, 70%), text: rgb("#3b82f6")),
  success:   (bg: rgb(228, 248, 240, 70%), text: rgb("#1ea97c")),
  warning:   (bg: rgb(255, 242, 226, 70%), text: rgb("#cc8925")),
  error:    (bg: rgb(255, 231, 230, 70%), text: rgb("#ff5757")),
  neutral:   (bg: rgb(237, 237, 237, 70%), text: rgb("#8394ae")),
)

// Badge component
#let badge(label, severity: "info", size: 1em) = {
  let colors = badge-colors.at(severity, default: badge-colors.info)
  box(
    fill: colors.bg,
    inset: (x: pr-space-xs),
    outset: (y: 0.25em),
    radius: 7.5pt,
  )[
    #text(
      fill: colors.text,
      size: size,
      weight: "semibold"
    )[#label]
  ]
}

// Card component
#let card(title: none, subtitle: none, image: none, footer: none, width: 100%, body) = {
  block(
    clip: true,
    fill: pr-surface-a,
    radius: 7.5pt,
    stroke: 0.75pt + pr-border,
    width: width,
  )[
    #if image != none {
      block(
        clip: true,
        width: 100%
      )[#image]
    }

    #block(
      inset: pr-space-md,
      width: 100%
    )[
      #if title != none {
        block(below: if subtitle != none { pr-space-xs } else { pr-space-md })[
          #text(
            fill: pr-surface-700,
            size: 1.5em,
            weight: "semibold"
          )[#title]
        ]
      }
      #if subtitle != none {
        block(below: pr-space-md)[
          #text(
            fill: pr-text-secondary,
            size: 1em
          )[#subtitle]
        ]
      }

      #block()[
        #text(
          fill: pr-text-secondary,
          size: 1em
        )[#body]
      ]
    ]

    #if footer != none {
      block(
        above: 0pt,
        fill: pr-surface-b,
        inset: pr-space-md,
        stroke: (top: 0.75pt + pr-border),
        width: width
      )[
        #text(size: 0.875em, fill: pr-text-secondary)[#footer]
      ]
    }
  ]
}

// Panel component
#let panel(title: none, width: 100%, body) = {
  block(
    clip: true,
    fill: pr-surface-a,
    radius: 7.5pt,
    stroke: 0.75pt + pr-border,
    width: width
  )[
    #if title != none {
      block(
        below: 0pt,
        fill: pr-surface-b,
        inset: pr-space-md,
        stroke: (bottom: 0.75pt + pr-border),
        width: 100%
      )[
        #text(
          fill: pr-surface-700,
          size: 1em,
          weight: "semibold",
        )[#title]
      ]
    }

    #block(
      inset: pr-space-md,
      width: 100%
    )[#body]
  ]
}

// Message style variants
#let _msg-style(severity) = {
  if severity == "success" {
    (pr-success-bg, pr-success-text, icon-success)
  }

  else if severity == "warn" or severity == "warning" {
    (pr-warn-bg, pr-warn-text, icon-warning)
  }

  else if severity == "error" {
    (pr-error-bg, pr-error-text, icon-error)
  }

  else if severity == "neutral" {
    (pr-neutral-bg, pr-neutral-text, icon-info)
  }

  else {
    (pr-info-bg, pr-info-text, icon-info)
  }
}

// Message component
#let message(severity: "info", size: 1em, body) = {
  let (bg, col, icon) = _msg-style(severity)
  block(
    fill: bg,
    inset: pr-space-sm,
    radius: 7.5pt,
  )[
    #text(
      fill: col,
      size: size,
      weight: "medium"
    )[
      #grid(
        columns: (auto, 1fr),
        column-gutter: pr-space-xs,
        align: left + horizon,
        text(
          fill: col,
          font: "Material Symbols Rounded Filled",
          size: 1em,
          weight: "bold",
          icon
        ),
        body
      )
    ]
  ]
}

// Messages component
#let messages(severity: "info", title: none, body) = {
  let (bg, col, icon) = _msg-style(severity)
  let content = {
    if title != none {
      block(
        below: pr-space-sm,
        text(
          fill: col,
          size: 1.25em,
          weight: "semibold",
          title
        )
      )
    }

    text(
      fill: col,
      size: 1em,
      body
    )
  }

  block(
    clip: true,
    fill: col,
    radius: 7.5pt,
    width: 100%,
    pad(
      left: 7.5pt,
      block(
        fill: bg,
        inset: pr-space-sm,
        radius: (right: 7.5pt),
        width: 100%,
        grid(
          columns: (auto, 1fr),
          column-gutter: pr-space-xs,
          align: top,
          text(
            font: "Material Symbols Rounded Filled",
            fill: col,
            size: 1.25em,
            weight: "bold",
            icon
          ),
          content
        )
      )
    )
  )
}

// Checkbox component.
#let checkbox(label: "", checked: false, disabled: false, theme: none) = context {
  let active = if theme == none { theme-state.get() } else { theme }
  let primary    = active.primary
  let box-fill   = if checked { primary }       else { pr-surface-a }
  let box-stroke = if checked { primary }       else { pr-surface-300 }
  let text-col   = if disabled { pr-surface-400 } else { pr-text }
  grid(
    align: horizon,
    columns: (14pt, auto),
    column-gutter: 8pt,
    block(
      fill: box-fill,
      height: 12pt,
      radius: 4.5pt,
      stroke: 0.75pt + box-stroke,
      width: 12pt,
    )[
      #if checked {
        align(center + horizon)[
          #text(
            fill: white,
            font: "Material Symbols Rounded Filled",
            size: 1em,
            weight: "bold",
            icon-success
          )
        ]
      }
    ],
    text(
      fill: text-col,
      size: 1em
    )[#label],
  )
}

// Main article function
#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 20mm, y: 20mm),
  paper: "a4",
  lang: "en",
  region: "GB",
  font: "Inter",
  fontsize: 1em,
  title-size: 3em,
  subtitle-size: 2em,
  heading-family: "Inter",
  heading-size: 1.5em,
  heading-weight: "semibold",
  heading-line-height: 1em,
  sectionnumbering: none,
  pagenumbering: "1",
  titlepage: false,
  toc: false,
  toc-title: none,
  toc-depth: none,
  toc-indent: 1.5em,
  theme: theme-lara-cyan,
  doc,
) = {
  let meta-authors = ()
  if authors != none {
    meta-authors = authors.map(a => a.name)
  }

  // Resolve theme-derived color used by this template (title-page
  // separator and author email accent).
  let primary = theme.primary

  // Publish the active theme so themed components (e.g. checkbox) can
  // read it via theme-state.get() without receiving it as an argument.
  theme-state.update(theme)

  set document(
    title: title,
    author: meta-authors
  )

  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
    footer: context [
      #set text(
        fill: pr-text-secondary,
        size: 8pt
      )

      #block(
        width: 100%,
        height: 0.5pt,
        fill: pr-border
      )

      #v(2pt)

      #grid(
        columns: (1fr, auto),
        align: (left, right),
        if authors != none {
          authors.map(a => a.name).join(", ")
        }
        else { "" },

        counter(page).display(pagenumbering),
      )
    ],
  )

  set par(
    justify: false,
    leading: 0.65em,
    spacing: pr-space-md,
  )

  set text(
    lang:   lang,
    region: region,
    font:   (font, "Liberation Sans", "Libertinus Serif"),
    size:   fontsize,
    fill:   pr-text,
  )
  set heading(numbering: sectionnumbering)

  show heading.where(level: 1): set block(above: pr-space-lg, below: pr-space-md)
  show heading.where(level: 2): set block(above: pr-space-lg, below: pr-space-sm)
  show heading.where(level: 3): set block(above: pr-space-md, below: pr-space-sm)

  show heading.where(level: 1): it => block[
    #text(
      font:   (heading-family, "Liberation Sans"),
      weight: heading-weight,
      size:   heading-size,
      fill:   pr-surface-700,
    )[#it.body]
  ]

  show heading.where(level: 2): it => block[
    #text(
      font:   (heading-family, "Liberation Sans"),
      weight: heading-weight,
      size:   heading-size * 0.75,
      fill:   pr-surface-700,
    )[#it.body]
  ]

  show heading.where(level: 3): it => block[
    #text(
      font:   (heading-family, "Liberation Sans"),
      weight: heading-weight,
      size:   heading-size * 0.65,
      fill:   pr-surface-700,
    )[#it.body]
  ]

  show line: _ => block(
    width: 100%,
    height: 0.75pt,
    fill: pr-border,
    above: pr-space-md,
    below: pr-space-md,
  )

  show table: set block(above: pr-space-md, below: pr-space-md)
  show table: set table(
    inset: (
      x: pr-space-md,
      y: pr-space-xs
    ),
    stroke: (_, y) => if y > 0 { (top: 0.75pt + pr-border) },
    fill: (_, y) => {
      if y == 0 { pr-surface-b }                       // Header row
      else if calc.rem(y, 2) == 0 { pr-surface-b }     // Even body rows
      else { pr-surface-a }                            // Odd body rows
    },
  )

  // Header row
  show table.cell.where(y: 0): set text(
    fill: pr-surface-700,
    weight: "medium",
  )
  show table.cell.where(y: 0): set table.cell(
    inset: (x: pr-space-md, y: pr-space-md),
  )

  // Outer rounded container around the table.
  show table: it => block(
    width: auto,
    fill: pr-surface-a,
    stroke: 0.75pt + pr-border,
    radius: 7.5pt,
    clip: true,
    inset: 0pt,
  )[#it]

  // Codeblock
  // Quarto specific style changes
  show raw.where(block: true): set block(
    fill: none,
    inset: 0pt,
    radius: 0pt,
  )

  show raw.where(block: true): it => block(
    width: 100%,
    fill: pr-surface-b,
    stroke: 0.75pt + pr-border,
    radius: 7.5pt,
    clip: true,
    inset: pr-space-md,
    above: pr-space-md,
    below: pr-space-md,
  )[
    #text(
      fill: pr-text,
      font: "Liberation Mono",
      size: 1em
    )[#it]
  ]

  // Inline raw
  show raw.where(block: false): set text(font: "Liberation Mono")

  // Titlepage
  if titlepage {
    // Title block
    if title != none {
      let title-content = {
        set par(leading: heading-line-height)
        align(
          center,
          {
            text(
              fill: pr-surface-700,
              font: (heading-family, "Liberation Sans"),
              weight: "bold",
              size: title-size,
              title,
            )
            if subtitle != none {
              parbreak()
              text(
                fill: pr-text-secondary,
                size: subtitle-size,
                weight: "medium",
                subtitle
              )
            }
          }
        )
      }

      block(
        width:  100%,
        stroke: (bottom: 3pt + primary),
        inset:  (x: 0pt, y: 3em),
        title-content,
      )
      v(pr-space-lg)
    }

    // Authors
    if authors != none {
      let ncols = calc.min(authors.len(), 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 1.5em,
        ..authors.map(a => align(center)[
          #text(
            fill: pr-text,
            size: 1.25em,
            weight: "semibold"
          )[#a.name]

          #if a.at("affiliation", default: none) != none and a.affiliation != [] and a.affiliation != "" [
            #v(0.25em)
            #text(
              fill: pr-text-secondary,
              size: 1em
            )[#a.affiliation]
          ]

          #if a.at("email", default: none) != none and a.email != "" [
            #v(0.25em)
            #text(
              fill: primary,
              size: 1em
            )[#a.email]
          ]
        ])
      )
      v(pr-space-lg)
    }

    // Date
    if date != none {
      align(center)[#text(
        fill: pr-text-secondary,
        size: 0.875em
      )[#date]]
      v(4em)
    }

    // Abstract
    if abstract != none {
      align(left)[
        #text(
          fill: pr-surface-700,
          size: 1.25em,
          weight: "semibold"
        )[#abstract-title]
        #v(pr-space-xs)
        #text(
          fill: pr-text-secondary,
          size: 1em
        )[#abstract]
      ]
    }

    pagebreak()
  }

  // Table of contents
  if toc {
    block(above: 0em, below: pr-space-lg)[
      #outline(
        title: toc-title,
        depth: toc-depth,
        indent: toc-indent
      )
    ]
    pagebreak()
  }

  // Document content
  doc
}
