// Plastic Labs Memo Template
// Web-doc style with nav, cards, and dark sections

// ============================================
// PACKAGE IMPORTS
// ============================================
#import "@preview/fontawesome:0.6.0": *
#import "@preview/showybox:2.0.4": showybox
#import "@preview/gentle-clues:1.2.0": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "@preview/cetz:0.4.2"
#import "@preview/tablex:0.0.9": tablex, rowspanx, colspanx
#import "@preview/lilaq:0.3.0" as lq
#import "@preview/meander:0.1.0": *
#import "@preview/pavemat:0.2.0": pavemat
#import "@preview/umbra:0.1.1": *
#import "@preview/biceps:0.0.1": *
#import "@preview/colorful-boxes:1.4.1": *
#import "@preview/fractusist:0.3.1": *
#import "@preview/libra:0.1.0": *

// ============================================
// DEFAULT COLORS
// ============================================
#let default-accent = rgb("#5B9BD5")
#let default-accent-light = rgb("#A8D4FF")
#let default-dark = rgb("#1a1a1a")
#let default-bg = rgb("#ffffff")
#let default-text = rgb("#333333")
#let default-text-secondary = rgb("#666666")
#let default-border = rgb("#cccccc")

// Code block theme colors
#let default-code-bg = rgb("#0d1117")
#let default-code-header = rgb("#161b22")
#let default-code-border = rgb("#30363d")
#let default-code-text = rgb("#e6edf3")

// ============================================
// SPACING SCALE (consistent vertical rhythm)
// ============================================
#let sp-xs = 0.25em
#let sp-sm = 0.5em
#let sp-md = 1em
#let sp-lg = 1.5em
#let sp-xl = 2em

// ============================================
// MEMO TEMPLATE
// ============================================
#let memo(
  // Content
  title: none,
  subtitle: none,
  meta: none,
  description: none,
  author: "Plastic Labs",
  logo: none,
  icon: none,
  logo-width: 2in,
  confidential: false,

  // Style options
  toc-style: "dark",  // "dark" or "light"
  font: "Departure Mono",

  // Colors (all customizable with defaults)
  accent-color: default-accent,
  accent-light: default-accent-light,
  dark-color: default-dark,
  bg-color: default-bg,
  text-color: default-text,
  text-secondary: default-text-secondary,
  border-color: default-border,

  // Code block theming
  code-bg: default-code-bg,
  code-header: default-code-header,
  code-border: default-code-border,
  code-text: default-code-text,

  // Component styling
  shadow-intensity: 70%,  // 0% = no shadows, 100% = full shadows
  card-radius: 4pt,
  accent-bar-width: 3pt,

  body,
) = {
  // Resolve colors for use throughout
  let c-accent = accent-color
  let c-accent-light = accent-light
  let c-dark = dark-color
  let c-bg = bg-color
  let c-text = text-color
  let c-text-sec = text-secondary
  let c-border = border-color

  // Code theme colors
  let c-code-bg = code-bg
  let c-code-header = code-header
  let c-code-border = code-border
  let c-code-text = code-text

  set document(title: if title != none { title } else { "Memo" })

  // Base typography
  set text(font: font, size: 9pt, fill: c-text)
  set par(justify: true, leading: 0.7em, spacing: 0.9em)

  // Nav components using current colors
  let nav-breadcrumb(..items) = {
    set text(size: 7pt, font: font)
    let parts = items.pos()
    for (i, item) in parts.enumerate() {
      if i > 0 {
        text(fill: c-border)[ #sym.slash ]
      }
      if i == parts.len() - 1 {
        text(weight: "bold", fill: c-dark)[#upper(item)]
      } else {
        text(fill: c-text-sec)[#upper(item)]
      }
    }
  }

  let nav-breadcrumb-linked(home-label, section-label, home-loc, section-loc) = {
    set text(size: 7pt, font: font)
    link(home-loc)[#text(fill: c-text-sec)[#upper(home-label)]]
    text(fill: c-border)[ #sym.slash ]
    if section-loc != none {
      link(section-loc)[#text(weight: "bold", fill: c-dark)[#upper(section-label)]]
    } else {
      text(weight: "bold", fill: c-dark)[#upper(section-label)]
    }
  }

  let nav-arrows-linked() = {
    set text(size: 9pt, fill: c-text-sec)
    context {
      let here-page = here().page()
      let total-pages = counter(page).final().first()
      let all-anchors = query(selector(<page-anchor>))

      let prev-target = if here-page > 1 {
        let prev-page = here-page - 1
        if prev-page == 1 {
          label("title-page")
        } else {
          let on-prev = all-anchors.filter(a => a.location().page() == prev-page)
          if on-prev.len() > 0 { on-prev.first().location() } else { label("title-page") }
        }
      } else { none }

      let next-target = if here-page < total-pages {
        let next-page = here-page + 1
        let on-next = all-anchors.filter(a => a.location().page() == next-page)
        if on-next.len() > 0 { on-next.first().location() } else { none }
      } else { none }

      if prev-target != none {
        link(prev-target)[‹]
      } else {
        text(fill: c-border)[‹]
      }
      h(0.5em)
      if next-target != none {
        link(next-target)[›]
      } else {
        text(fill: c-border)[›]
      }
    }
  }

  let dashed-divider() = {
    align(center)[
      #set text(size: 8pt, fill: c-border, tracking: 2pt)
      ─────
    ]
  }

  // ============================================
  // TITLE PAGE
  // ============================================
  page(
    paper: "us-letter",
    fill: c-bg,
    margin: (top: 0.5in, bottom: 0.5in, left: 0.75in, right: 0.75in),
  )[
    #place(hide[Title Page]) <title-page>

    // Nav bar at top
    #grid(
      columns: (auto, 1fr, auto),
      align: (left, left, right),
      gutter: 1em,
      {
        set text(size: 9pt, fill: c-text-sec)
        text(fill: c-border)[‹]
        h(0.5em)
        context {
          let all-anchors = query(selector(<page-anchor>))
          let page2-anchor = all-anchors.filter(a => a.location().page() == 2)
          if page2-anchor.len() > 0 {
            link(page2-anchor.first().location())[›]
          } else {
            let all-h1 = query(heading.where(level: 1))
            if all-h1.len() > 0 {
              link(all-h1.first().location())[›]
            } else {
              text(fill: c-border)[›]
            }
          }
        }
      },
      nav-breadcrumb("Plastic Labs", "Seed Memo"),
      [],
    )

    // Flexible space to center title content
    #v(1fr)

    // Logo
    #if logo != none {
      align(center, image(logo, width: logo-width))
      v(0.5em)
    }

    // Subtitle
    #if subtitle != none {
      align(center)[
        #set text(size: 16pt, fill: c-accent)
        #subtitle
      ]
      v(0.25em)
    }

    // Meta
    #if meta != none {
      align(center)[
        #set text(size: 7pt, fill: c-text-sec, tracking: 0.5pt)
        #upper(meta)
      ]
    }

    #v(0.3in)

    // Memory fractal - dragon curve representing branching memory
    #align(center)[
      #dragon-curve(
        10,
        step-size: 3,
        stroke: stroke(paint: c-accent.transparentize(60%), thickness: 0.5pt, cap: "round"),
      )
    ]

    #v(0.3in)

    // Description
    #align(center)[
      #set text(size: 9pt, fill: c-text-sec)
      #set par(justify: false)
      #if description != none {
        description
      } else {
        [A technical overview of memory infrastructure for AI agents. \
        Product · Architecture · Business · Vision]
      }
    ]

    // Flexible space to push TOC to bottom
    #v(1fr)

    // TOC Block - Dark or Light style
    #if toc-style == "dark" {
      block(
        width: 100%,
        fill: c-dark,
        inset: (x: 24pt, y: 20pt),
        radius: 4pt,
      )[
        #set text(fill: c-bg)

        #grid(
          columns: (1fr, auto),
          text(weight: "bold", size: 7pt, tracking: 1pt)[CONTENTS],
          context {
            let secs = query(heading.where(level: 1))
            text(size: 6pt, fill: c-accent-light)[#secs.len() SECTIONS]
          },
        )

        #v(0.3em)
        #line(length: 100%, stroke: 0.5pt + rgb("#333"))
        #v(0.5em)

        #context {
          let headings = query(heading.where(level: 1))
          let subheadings = query(heading.where(level: 2))

          set text(size: 7pt)

          let items = ()
          for (i, h) in headings.enumerate() {
            let num = i + 1
            let subs = subheadings.filter(s => {
              let h-page = h.location().page()
              let s-page = s.location().page()
              let next-h-page = if i + 1 < headings.len() { headings.at(i + 1).location().page() } else { 9999 }
              s-page >= h-page and s-page < next-h-page
            })

            items.push(
              block(spacing: 0.4em)[
                #link(h.location())[
                  #text(weight: "bold", fill: c-bg, size: 7pt)[#num. #upper(h.body)]
                ]
                #v(0.05em)
                #for sub in subs.slice(0, calc.min(subs.len(), 3)) {
                  link(sub.location())[#text(size: 6pt, fill: c-text-sec)[• #sub.body]]
                  linebreak()
                }
              ]
            )
          }

          grid(
            columns: (1fr, 1fr, 1fr),
            gutter: 1em,
            ..items
          )
        }
      ]
    } else {
      // Light TOC style
      block(
        width: 100%,
        stroke: 0.5pt + c-border,
        inset: (x: 24pt, y: 20pt),
        radius: 4pt,
      )[
        #grid(
          columns: (auto, 1fr, auto),
          align: (left, center, right),
          gutter: 0.5em,
          text(weight: "bold", size: 8pt, fill: c-text, tracking: 1pt)[TABLE OF CONTENTS],
          box(width: 100%, stroke: (bottom: 0.5pt + c-border)),
          context {
            let secs = query(heading.where(level: 1))
            text(size: 7pt, fill: c-text-sec)[\[ SECTIONS: #secs.len() \]]
          },
        )

        #v(0.4in)

        #context {
          let headings = query(heading.where(level: 1))
          let subheadings = query(heading.where(level: 2))

          let items = ()
          for (i, h) in headings.enumerate() {
            let num = i + 1
            let subs = subheadings.filter(s => {
              let h-page = h.location().page()
              let s-page = s.location().page()
              let next-h-page = if i + 1 < headings.len() { headings.at(i + 1).location().page() } else { 9999 }
              s-page >= h-page and s-page < next-h-page
            })

            items.push(
              block(spacing: 0.6em)[
                #link(h.location())[
                  #text(weight: "bold", fill: c-accent, size: 8pt)[#num. #upper(h.body)]
                ]
                #v(0.15em)
                #for sub in subs.slice(0, calc.min(subs.len(), 4)) {
                  grid(
                    columns: (1fr, auto),
                    gutter: 0.3em,
                    link(sub.location())[
                      #text(size: 7pt, fill: c-text)[• #sub.body]
                    ],
                    text(size: 6pt, fill: c-border)[#sub.location().page()],
                  )
                }
              ]
            )
          }

          grid(
            columns: (1fr, 1fr, 1fr),
            column-gutter: 1.5em,
            row-gutter: 0.5em,
            ..items
          )
        }
      ]
    }

    #v(0.3in)

    #if confidential {
      align(center)[
        #text(size: 6pt, fill: c-text-sec)[CONFIDENTIAL]
      ]
    }
  ]

  // ============================================
  // CONTENT PAGES
  // ============================================
  set page(
    paper: "us-letter",
    fill: c-bg,
    margin: (top: 0.5in, bottom: 0.6in, left: 0.75in, right: 0.75in),
    header: {
      // Page anchor for navigation
      [#place(hide[Page]) <page-anchor>]
      set text(size: 7pt, font: font)
      grid(
        columns: (auto, 1fr, auto),
        align: (left, left, right),
        gutter: 1em,
        nav-arrows-linked(),
        context {
          let here-page = here().page()
          let all-h1 = query(heading.where(level: 1))
          let current = all-h1.filter(h => h.location().page() <= here-page)
          if current.len() > 0 {
            let h = current.last()
            nav-breadcrumb-linked("Honcho", h.body, label("title-page"), h.location())
          } else {
            nav-breadcrumb-linked("Honcho", "Memo", label("title-page"), none)
          }
        },
        context {
          text(fill: c-text-sec)[#counter(page).display("1")]
        },
      )
      v(0.15em)
    },
    footer: if confidential {
      set text(size: 6pt, fill: c-text-sec)
      align(center)[CONFIDENTIAL]
    },
  )

  // Heading styles
  set heading(numbering: "1.")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.3in)
    text(size: 7pt, fill: c-text-sec, tracking: 1pt)[SECTION #counter(heading).display("1")]
    v(0.15em)
    text(size: 22pt, weight: "bold", fill: c-dark)[#it.body]
    v(0.15em)
    line(length: 100%, stroke: 0.5pt + c-border)
    v(0.5em)
  }

  show heading.where(level: 2): it => {
    v(0.75em)
    text(size: 12pt, weight: "bold", fill: c-accent)[#it.body]
    v(0.35em)
  }

  show heading.where(level: 3): it => {
    v(0.5em)
    text(size: 10pt, weight: "bold", fill: c-text)[#it.body]
    v(0.25em)
  }

  // Links
  show link: set text(fill: c-accent)

  // Tables - elegant minimal style
  set table(
    stroke: none,
    inset: (x: 10pt, y: 8pt),
    fill: (x, y) => if y == 0 { c-bg } else if calc.odd(y) { rgb("#fafafa") } else { c-bg },
  )
  show table: it => {
    v(0.5em)
    set text(size: 8pt)
    block(
      breakable: false,
      width: 100%,
      stroke: (bottom: 0.5pt + c-border),
      it
    )
    v(0.5em)
  }
  show table.cell.where(y: 0): it => {
    set text(weight: "bold", size: 7pt, tracking: 0.5pt, fill: c-accent)
    upper(it)
  }

  // Code blocks with elevated styling and depth
  show raw.where(block: true): it => {
    set text(size: 8pt, fill: c-code-text)
    v(sp-md)
    block(
      width: 100%,
      fill: c-code-bg,
      stroke: (
        left: accent-bar-width + c-accent.transparentize(40%),
        rest: 0.5pt + c-code-border,
      ),
      radius: (left: 0pt, right: card-radius + 2pt),
      inset: 0pt,
    )[
      // Header bar with language indicator
      #block(
        width: 100%,
        fill: c-code-header,
        inset: (x: 16pt, y: 8pt),
        radius: (top-right: card-radius + 2pt),
      )[
        #grid(
          columns: (1fr, auto),
          align: (left, right),
          text(fill: c-code-text.transparentize(40%), size: 7pt, tracking: 0.5pt)[CODE],
          grid(
            columns: (auto, auto, auto),
            gutter: 6pt,
            circle(radius: 4pt, fill: rgb("#f85149").transparentize(60%)),
            circle(radius: 4pt, fill: rgb("#f0883e").transparentize(60%)),
            circle(radius: 4pt, fill: rgb("#3fb950").transparentize(60%)),
          ),
        )
      ]
      // Code content
      #block(
        width: 100%,
        inset: (x: 16pt, y: 14pt),
        it
      )
    ]
    v(sp-md)
  }

  show raw.where(block: false): it => {
    set text(size: 8pt)
    box(fill: rgb("#eee"), inset: (x: 3pt, y: 2pt), radius: 2pt, it)
  }

  // Lists
  set list(marker: ([•], [◦], [·]), spacing: 0.5em)
  set enum(numbering: "1.", spacing: 0.5em)

  body
}

// ============================================
// UTILITIES (use default colors, can be overridden)
// ============================================

#let highlight-text(body) = text(fill: default-accent, weight: "bold", body)

#let key-insight(body) = {
  v(sp-md)
  showybox(
    frame: (
      border-color: default-accent,
      title-color: default-accent.lighten(90%),
      body-color: white,
      thickness: (left: 3pt, rest: 0pt),
      radius: (right: 4pt, left: 0pt),
    ),
    title-style: (
      color: default-accent,
      weight: "bold",
      sep-thickness: 0pt,
    ),
    shadow: (
      color: default-border.transparentize(70%),
      offset: (x: 2pt, y: 2pt),
    ),
    title: text(size: 7pt, tracking: 0.5pt)[KEY INSIGHT],
    body
  )
  v(sp-md)
}

// Pull quote for emphasis (larger, centered) with subtle depth
#let pull-quote(body) = {
  v(sp-lg)
  align(center)[
    #block(
      width: 85%,
      inset: (x: sp-lg, y: sp-md),
      fill: rgb("#fafbfc"),
      radius: 4pt,
    )[
      #align(center)[
        #text(fill: default-accent, size: 20pt, weight: "light")[""]
      ]
      #v(-sp-sm)
      #set text(size: 11pt, fill: default-text)
      #set par(justify: false, leading: 0.75em)
      #emph[#body]
      #v(-sp-xs)
      #align(center)[
        #text(fill: default-accent, size: 20pt, weight: "light")[""]
      ]
    ]
  ]
  v(sp-lg)
}

// Callout with icon-like marker and subtle background
#let callout(body, marker: "→") = {
  v(sp-sm)
  block(
    width: 100%,
    fill: rgb("#f8f9fa"),
    radius: 3pt,
    inset: (left: 24pt, right: 14pt, y: 10pt),
  )[
    #place(left + top, dx: -18pt, dy: 4pt)[
      #text(fill: default-accent, size: 11pt, weight: "bold")[#marker]
    ]
    #set text(size: 9pt)
    #body
  ]
  v(sp-sm)
}

#let metric(label, value, subtext: none) = {
  block(
    width: 100%,
    fill: white,
    stroke: (
      top: 3pt + default-accent,
      rest: 0.5pt + default-border.transparentize(30%),
    ),
    radius: (bottom: 4pt),
    inset: 0pt,
  )[
    // Metric content with layered depth
    #block(
      width: 100%,
      inset: (x: 16pt, top: 14pt, bottom: 12pt),
    )[
      #text(size: 7pt, fill: default-text-secondary, tracking: 0.8pt, weight: "medium")[#upper(label)]
      #v(sp-sm)
      #text(size: 28pt, weight: "bold", fill: default-accent, tracking: -1pt)[#value]
      #if subtext != none {
        v(sp-xs)
        block(
          fill: default-accent.transparentize(92%),
          radius: 2pt,
          inset: (x: 8pt, y: 4pt),
        )[
          #text(size: 7pt, fill: default-accent, weight: "medium", tracking: 0.3pt)[#upper(subtext)]
        ]
      }
    ]
  ]
}

#let dark-section(title: none, body) = {
  v(sp-md)
  showybox(
    frame: (
      border-color: default-dark,
      body-color: default-dark,
      thickness: 0pt,
      radius: 6pt,
      inset: (x: 18pt, y: 16pt),
    ),
    shadow: (
      color: rgb("#00000030"),
      offset: (x: 2pt, y: 3pt),
    ),
    [
      #set text(fill: default-bg, size: 9pt)
      #if title != none {
        text(weight: "bold", size: 8pt, fill: default-accent-light, tracking: 0.5pt)[#upper(title)]
        v(sp-sm)
      }
      #body
    ]
  )
  v(sp-md)
}

#let content-card(body) = {
  showybox(
    frame: (
      border-color: default-border.transparentize(50%),
      body-color: white,
      thickness: 0.5pt,
      radius: 4pt,
      inset: (x: 20pt, y: 16pt),
    ),
    shadow: (
      color: default-border.transparentize(75%),
      offset: (x: 1pt, y: 2pt),
    ),
    body
  )
}

#let agent-card(name, body) = {
  block(
    width: 100%,
    fill: default-dark,
    radius: 4pt,
    inset: (x: 16pt, y: 12pt),
    below: sp-sm,
  )[
    #set text(fill: default-bg, size: 8pt)
    #text(weight: "bold", fill: default-accent-light, size: 8pt, tracking: 0.5pt)[#upper(name)]
    #h(0.75em)
    #text(fill: rgb("#888"))[―]
    #h(0.75em)
    #body
  ]
}

#let note(body) = {
  set text(size: 8pt, fill: default-text-secondary, style: "italic")
  body
}

// ============================================
// SEPARATORS & DIVIDERS
// ============================================

// Primary dotted line separator - more visible
#let dotted-line() = {
  v(sp-lg)
  line(length: 100%, stroke: (paint: default-border.darken(10%), thickness: 1pt, dash: (2pt, 3pt), cap: "round"))
  v(sp-lg)
}

// Elegant ornamental separator with centered diamond
#let ornament-separator() = {
  v(sp-lg)
  align(center)[
    #grid(
      columns: (1fr, auto, 1fr),
      align: (right, center, left),
      gutter: sp-sm,
      line(length: 100%, stroke: (paint: default-border, thickness: 0.75pt, dash: (3pt, 3pt))),
      text(fill: default-accent, size: 8pt)[◆],
      line(length: 100%, stroke: (paint: default-border, thickness: 0.75pt, dash: (3pt, 3pt))),
    )
  ]
  v(sp-lg)
}

// Subtle section divider with gradient fade effect
#let section-divider() = {
  v(sp-xl)
  align(center)[
    #box(width: 70%)[
      #line(length: 100%, stroke: (paint: gradient.linear(white, default-border, white), thickness: 1pt))
    ]
  ]
  v(sp-xl)
}

// Decorative centered dots - more prominent
#let dot-separator() = {
  v(sp-md)
  align(center)[
    #text(fill: default-border, size: 10pt, tracking: 12pt)[· · ·]
  ]
  v(sp-md)
}

// Simple line break with subtle styling
#let line-break() = {
  v(sp-sm)
  line(length: 40%, stroke: (paint: default-border.transparentize(30%), thickness: 0.5pt))
  v(sp-sm)
}

// Decorative flourish separator
#let flourish() = {
  v(sp-lg)
  align(center)[
    #text(fill: default-accent.transparentize(30%), size: 12pt)[― ◇ ―]
  ]
  v(sp-lg)
}

// Breathing space (extra vertical room)
#let breathe() = v(sp-lg)

#let section-break() = {
  v(sp-md)
  line(length: 100%, stroke: (paint: default-border.transparentize(65%), thickness: 0.5pt, dash: "dotted"))
  v(sp-md)
}

#let check = text(fill: default-accent, weight: "bold")[✓]
#let cross = text(fill: default-border.darken(20%))[✗]

// ============================================
// TEAM & PEOPLE
// ============================================

#let team-member(name, role, body) = {
  block(
    width: 100%,
    inset: (y: sp-sm),
    below: sp-xs,
  )[
    #text(weight: "bold", fill: default-text, size: 9pt)[#name]
    #h(sp-sm)
    #text(fill: default-accent, size: 8pt)[#role]
    #v(sp-xs)
    #set text(size: 8pt, fill: default-text-secondary)
    #body
  ]
}

#let team-grid(..members) = {
  let items = members.pos()
  v(sp-sm)
  grid(
    columns: (1fr, 1fr),
    column-gutter: sp-lg,
    row-gutter: sp-md,
    ..items
  )
  v(sp-sm)
}

#let founder-card(name, role, body) = {
  block(
    width: 100%,
    stroke: (left: 2pt + default-accent),
    inset: (left: 14pt, y: 10pt),
    below: sp-md,
  )[
    #text(weight: "bold", size: 10pt, fill: default-text)[#name]
    #h(sp-sm)
    #text(size: 8pt, fill: default-accent)[#role]
    #v(sp-xs)
    #set par(leading: 0.55em)
    #set text(size: 8pt, fill: default-text-secondary)
    #body
  ]
}

// Compact inline person mention
#let person(name, role) = {
  text(weight: "bold", size: 9pt)[#name]
  text(fill: default-text-secondary, size: 8pt)[ (#role)]
}

// ============================================
// TERMINOLOGY & DEFINITIONS
// ============================================

// Simple inline term
#let term(word, definition) = {
  block(
    width: 100%,
    inset: (y: sp-xs),
    below: sp-xs,
  )[
    #text(weight: "bold", fill: default-accent, size: 9pt)[#word]
    #h(sp-sm)
    #text(fill: default-border)[―]
    #h(sp-sm)
    #text(fill: default-text, size: 9pt)[#definition]
  ]
}

// Card-style term with left accent
#let term-card(word, definition) = {
  block(
    width: 100%,
    stroke: (left: 2pt + default-accent.transparentize(40%)),
    inset: (left: 14pt, y: 10pt),
    below: sp-sm,
  )[
    #text(weight: "bold", fill: default-text, size: 9pt)[#word]
    #v(sp-xs)
    #set par(leading: 0.55em)
    #text(fill: default-text-secondary, size: 8pt)[#definition]
  ]
}

// Numbered definition (for ordered lists of concepts)
#let numbered-term(num, word, definition) = {
  block(
    width: 100%,
    fill: if calc.odd(num) { rgb("#fafbfc") } else { white },
    radius: 3pt,
    inset: (x: sp-sm, y: sp-sm),
    below: sp-xs,
  )[
    #grid(
      columns: (28pt, 1fr),
      gutter: sp-md,
      align(center)[
        #box(
          width: 24pt,
          height: 24pt,
          radius: 50%,
          fill: default-accent.transparentize(85%),
        )[
          #align(center + horizon)[
            #text(fill: default-accent, size: 11pt, weight: "bold")[#num]
          ]
        ]
      ],
      [
        #text(weight: "bold", fill: default-text, size: 9pt)[#word]
        #v(3pt)
        #text(fill: default-text-secondary, size: 8pt)[#definition]
      ],
    )
  ]
}

// Two-column definition layout
#let term-columns(..items) = {
  let pairs = items.pos()
  v(sp-sm)
  grid(
    columns: (1fr, 1fr),
    column-gutter: sp-lg,
    row-gutter: sp-md,
    ..pairs.map(((word, def)) => {
      block[
        #text(weight: "bold", fill: default-accent, size: 8pt)[#word]
        #v(2pt)
        #text(fill: default-text-secondary, size: 8pt)[#def]
      ]
    })
  )
  v(sp-sm)
}

#let definition-list(..items) = {
  let pairs = items.pos()
  for (word, def) in pairs {
    term(word, def)
  }
}

// ============================================
// COMPETITORS & COMPARISONS
// ============================================

// Compact competitor mention (inline style)
#let competitor(name, body) = {
  block(
    width: 100%,
    inset: (y: sp-xs),
    below: sp-xs,
  )[
    #text(weight: "bold", fill: default-text-secondary, size: 8pt)[#name]
    #h(sp-sm)
    #text(fill: default-border)[·]
    #h(sp-sm)
    #text(size: 8pt, fill: default-text)[#body]
  ]
}

// Two-column competitor grid with elegant styling
#let competitor-grid(..items) = {
  let comps = items.pos()
  v(sp-md)
  grid(
    columns: (1fr, 1fr),
    column-gutter: sp-lg,
    row-gutter: sp-md,
    ..comps.map(((name, desc)) => {
      block(
        width: 100%,
        stroke: (left: 2pt + default-border),
        inset: (left: 12pt, y: 8pt),
      )[
        #text(weight: "bold", fill: default-text-secondary, size: 8pt)[#name]
        #v(3pt)
        #text(size: 8pt, fill: default-text)[#desc]
      ]
    })
  )
  v(sp-md)
}

// Feature comparison (alternative to table)
#let feature-compare(feature, us, them) = {
  block(
    width: 100%,
    inset: (y: sp-xs),
    stroke: (bottom: 0.5pt + default-border.transparentize(70%)),
  )[
    #grid(
      columns: (1fr, auto, auto),
      gutter: sp-md,
      align: (left, center, center),
      text(size: 8pt, fill: default-text)[#feature],
      text(size: 8pt, fill: default-accent, weight: "bold")[#us],
      text(size: 8pt, fill: default-text-secondary)[#them],
    )
  ]
}

// ============================================
// REASONING TYPES & BADGES
// ============================================

#let reasoning-type(label, body) = {
  block(
    width: 100%,
    inset: (y: sp-xs),
    below: sp-xs,
  )[
    #box(
      fill: default-dark,
      radius: 3pt,
      inset: (x: 8pt, y: 4pt),
    )[
      #text(fill: default-accent-light, size: 7pt, weight: "bold")[#upper(label)]
    ]
    #h(sp-md)
    #text(size: 9pt, fill: default-text)[#body]
  ]
}

// Badge/tag for inline use
#let badge(label, color: default-accent) = {
  box(
    fill: color.transparentize(85%),
    stroke: 0.5pt + color.transparentize(50%),
    radius: 2pt,
    inset: (x: 5pt, y: 2pt),
  )[
    #text(fill: color, size: 7pt, weight: "bold")[#upper(label)]
  ]
}

// Status indicator
#let status(label, done: true) = {
  if done {
    text(fill: default-accent, size: 8pt)[✓ #label]
  } else {
    text(fill: default-text-secondary, size: 8pt)[○ #label]
  }
}

// ============================================
// COMPARISON & FEATURES
// ============================================

#let comparison-row(capability, us, ..others) = {
  let other-vals = others.pos()
  (
    text(fill: default-text, size: 8pt)[#capability],
    text(fill: default-accent, weight: "bold", size: 8pt)[#us],
    ..other-vals.map(v => text(fill: default-text-secondary, size: 8pt)[#v])
  )
}

#let feature-check(label, has: true) = {
  if has {
    [#text(fill: default-accent)[✓] #text(size: 8pt)[#label]]
  } else {
    [#text(fill: default-border)[✗] #text(fill: default-text-secondary, size: 8pt)[#label]]
  }
}

// Horizontal feature list (3-4 items in a row)
#let feature-row(..items) = {
  let features = items.pos()
  v(sp-sm)
  grid(
    columns: features.map(_ => 1fr),
    gutter: sp-md,
    ..features.map(f => {
      align(center)[
        #text(fill: default-accent, size: 10pt)[✓]
        #v(2pt)
        #text(size: 8pt, fill: default-text)[#f]
      ]
    })
  )
  v(sp-sm)
}

// Key-value pair for stats
#let stat(label, value) = {
  block(inset: (y: sp-xs))[
    #text(fill: default-text-secondary, size: 7pt, tracking: 0.3pt)[#upper(label)]
    #h(sp-sm)
    #text(fill: default-text, size: 9pt, weight: "bold")[#value]
  ]
}

// Stat row (multiple stats inline)
#let stat-row(..items) = {
  let stats = items.pos()
  v(sp-sm)
  grid(
    columns: stats.map(_ => auto),
    gutter: sp-lg,
    ..stats.map(((label, value)) => {
      [
        #text(fill: default-text-secondary, size: 7pt)[#upper(label)]
        #h(sp-xs)
        #text(fill: default-accent, size: 9pt, weight: "bold")[#value]
      ]
    })
  )
  v(sp-sm)
}

// Quote block for testimonials or citations
#let quote-block(body, source: none) = {
  v(sp-md)
  block(
    width: 100%,
    fill: rgb("#f9fafb"),
    radius: 4pt,
    inset: (left: 18pt, right: 14pt, y: 14pt),
    stroke: (left: 3pt + default-accent.transparentize(50%)),
  )[
    #set text(size: 9pt, fill: default-text, style: "italic")
    #body
    #if source != none {
      v(sp-sm)
      align(right)[
        #text(size: 8pt, fill: default-text-secondary, style: "normal")[— #source]
      ]
    }
  ]
  v(sp-md)
}

// Two-column layout helper
#let two-col(left-content, right-content, ratio: (1fr, 1fr)) = {
  v(sp-sm)
  grid(
    columns: ratio,
    gutter: sp-lg,
    left-content,
    right-content,
  )
  v(sp-sm)
}

// ============================================
// CHARTS & DATA VIZ (lilaq)
// ============================================

// Simple bar for inline metrics
#let inline-bar(value, max: 100, width: 60pt, color: default-accent) = {
  let pct = calc.min(value / max, 1.0)
  box(
    width: width,
    height: 6pt,
    fill: default-border.transparentize(70%),
    radius: 3pt,
  )[
    #box(
      width: pct * width,
      height: 6pt,
      fill: color,
      radius: 3pt,
    )
  ]
}

// ============================================
// BALANCED TEXT (libra)
// ============================================

#let balanced(body) = {
  import "@preview/libra:0.1.0": balance
  balance(body)
}
