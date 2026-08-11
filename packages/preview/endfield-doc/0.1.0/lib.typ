// Endfield Document Theme
// A4 document template inspired by the visual style of @preview/touying-endfield
// Does NOT require Touying — suitable for regular flowing documents.

// ── Color palette (mirrors endfield theme defaults) ───────────────────────────
#let clr-darkest     = rgb("#191919")
#let clr-dark        = rgb("#5c5c5c")
#let clr-light       = rgb("#D9D9D9")
#let clr-lightest    = rgb("#E6E6E6")
#let clr-codebg      = rgb("#fdfde799")
#let clr-lightest-tr = rgb("#e6e6e6da")
#let clr-pink        = rgb("#E5007F")
#let clr-green       = rgb("#00FF9A")
#let clr-bar         = rgb("#777777")
#let clr-primary     = rgb("#FFFA01")             // characteristic yellow accent

// ── UI Components ────────────────────────────────────────────────────────────

// The characteristic multi-color accent bar that adapts to content height
#let _accent-bar(
  bar-width: .5em,
  container-height: 4em,
) = {
  let bar = stack(
    dir: ttb,
    spacing: 0pt,
    rect(width: bar-width, height: container-height * 0.2, fill: clr-pink),
    rect(width: bar-width, height: container-height * 0.2, fill: clr-green),
    // Main body fills the remaining 60% of the container height
    rect(width: bar-width, height: container-height * 0.4, fill: clr-primary),
  )

  stack(
    dir: ttb,
    v(container-height * 0.1),
    bar,
  )
}

// ── Page header ───────────────────────────────────────────────────────────────
// Displays the document title (left, primary color) and the current level-1
// heading (right, light color) inside a dark bar.
#let _doc-header(doc-title) = context {
  let headings = query(selector(heading.where(level: 1)).before(here()))
  let section  = if headings.len() > 0 { headings.last().body } else { [] }

  block(
    width: 100%,
    fill: clr-bar,
    inset: (x: 1.2em, y: .6em),
    stack(
      dir: ltr,
      spacing: 1em,
      text(fill: clr-primary, weight: "bold", size: .85em, doc-title),
      h(1fr),
      text(fill: clr-light, weight: "medium", size: .85em, section),
    ),
  )
}

// ── Page footer ───────────────────────────────────────────────────────────────
// Tri-color accent stripe + dark bar with custom text (left) and page number
// (right).
#let _doc-footer(doc-footer) = context {
  stack(
    dir: ttb,
    stack(
      dir: ltr,
      line(stroke: .28em + clr-pink,  length: 2em),
      line(stroke: .28em + clr-green, length: 2em),
      line(stroke: .28em + clr-primary, length: 100% - 4em),
    ),
    block(
      width: 100%,
      fill: clr-bar,
      inset: (x: 1.2em, y: .45em),
      grid(
        columns: (auto, 1fr, auto),
        align: horizon,
        text(fill: clr-light, weight: "bold", size: .78em, doc-footer),
        [],
        box(
          fill: clr-dark,
          inset: (x: .6em, y: .3em),
          text(fill: clr-primary, weight: "bold", size: .78em,
            counter(page).display("1"),
          ),
        ),
      ),
    ),
  )
}

// ── Cover page ────────────────────────────────────────────────────────────────
#let _cover-page(
  title: [],
  subtitle: none,
  author: none,
  date: none,
  institution: none,
  paper: "a4",
) = {
  page(
    paper: paper,
    margin: (x: 4em, top: 4em, bottom: 4em),
    header: none,
    footer: none,
    fill: gradient.linear(
      angle: 135deg,
      clr-lightest.lighten(10%),
      clr-lightest.darken(15%),
    ),
    background: place(bottom, image("contour_map.svg", width: 100%)),
  )[
    #set footnote.entry(
      separator: line(length: 30%, stroke: .5pt + clr-dark),
    )

    #v(1fr)

    #block(width: 100%)[
      #let title-stack = stack(
        dir: ttb,
        spacing: .5em,
        text(size: 2.5em, weight: "black", fill: clr-darkest, title),

        if subtitle != none {
          v(1.0em)
          text(size: 1.5em, fill: clr-dark, subtitle)
        },

        v(1.2em),
        if author != none {
          text(size: 1.0em, fill: clr-darkest, weight: "bold", author)
        },

        if date != none {
          v(.2em)
          text(size: .95em, fill: clr-dark, date)
        },

        if institution != none {
          v(.2em)
          text(size: .95em, fill: clr-dark, institution)
        },
      )

      #context {
        let content-height = measure(title-stack).height

        grid(
          columns: (auto, 1fr),
          column-gutter: 1.2em,
          _accent-bar(bar-width: .6em, container-height: content-height),
          title-stack
        )
      }
    ]

    // Larger spring at the bottom shifts the visual centre of gravity
    // slightly upward, matching the original endfield slide theme.
    #v(1.2fr)
  ]
}

// ── Main document template ────────────────────────────────────────────────────
// Usage:
//   #show: endfield-doc.with(
//     title:       [My Document],
//     subtitle:    [A Subtitle],
//     author:      [Your Name],
//     date:        datetime.today().display("[year]-[month]-[day]"),
//     institution: [Your Org],
//     doc-footer:  [Your Org],   // left side of footer bar
//     lang:        "zh",
//     region:      "cn",
//     font-cjk:    ("HarmonyOS Sans SC",),
//     font-latin:  ("HarmonyOS Sans",),
//     font-code:   ("JetBrains Mono",),
//   )
#let endfield-doc(
  title:       [Document Title],
  subtitle:    none,
  author:      none,
  date:        none,
  institution: none,
  paper:       "a4",
  lang:        "zh",
  region:      "cn",
  font-cjk:    ("HarmonyOS Sans SC", "HarmonyOS Sans Italic"),
  font-latin:  ("HarmonyOS Sans", "HarmonyOS Sans Italic"),
  font-code:   ("JetBrains Mono", "Consolas"),
  font-emoji:  ("Segoe UI Emoji", "Noto Emoji",),
  doc-footer:  text("ENDFIELD", weight: "bold") + text(" INDUSTRIES", size: 0.8em),
  body,
) = {
  // emoji fonts are excluded here; they are routed via a show rule below
  // to avoid adding them to the lookup chain for every non-emoji character.
  let main-font-stack = font-cjk + font-latin
  let code-font-stack = font-code + main-font-stack

  // CJK first: prevents Latin fonts that bundle CJK glyphs from overriding
  // the intended CJK typeface.
  set text(
    font: main-font-stack,
    size: 11pt,
    fill: clr-darkest,
    lang: lang,
    region: region,
  )

  // Force emoji Unicode ranges to always use the emoji font, regardless of
  // what the CJK or Latin fonts might provide for those code points.
  // Ranges covered:
  //   U+1F300–U+1FAFF  — most emoji (faces, objects, symbols, flags …)
  //   U+2600–U+27BF    — miscellaneous symbols & dingbats
  //   U+2300–U+23FF    — miscellaneous technical (clocks, arrows …)
  show regex("[\\u{1F300}-\\u{1FAFF}\\u{2600}-\\u{27BF}\\u{2300}-\\u{23FF}]+"): set text(font: font-emoji + main-font-stack)

  // ── Cover page ──────────────────────────────────────────────────────────────
  _cover-page(
    title:       title,
    subtitle:    subtitle,
    author:      author,
    date:        date,
    institution: institution,
    paper:       paper,
  )

  // ── Document-wide page settings ─────────────────────────────────────────────
  set page(
    paper: paper,
    // bottom margin must be large enough for: footer height (~2em) + footnotes.
    // footer-descent is intentionally left at default so Typst can correctly
    // reserve space for footnotes above the footer.
    margin: (top: 6em, bottom: 6em, x: 3em),
    header: _doc-header(title),
    footer: _doc-footer(doc-footer),
    fill: gradient.linear(
      angle: 90deg,
      clr-lightest.lighten(8%),
      clr-lightest.darken(8%),
    ),
    background: place(bottom, image("contour_map.svg", width: 100%)),
  )

  counter(page).update(1)

  set par(justify: true, leading: .75em, spacing: 1.2em)

  // ── Code block styles ───────────────────────────────────────────────────────
  show raw: it => {
    if it.block {
      stack(
        dir: ttb,
        // Language label tab with accent dots (only shown when lang is set)
        if it.has("lang") {
          align(left,
            block(
              fill: clr-primary,
              inset: (x: .6em, y: .3em),
              radius: (top: 2pt),
              text(fill: clr-darkest, size: .7em, weight: "black", upper(it.lang))
            ),
          )
        },
        block(
          width: 100%,
          fill: clr-codebg,
          inset: (x: 1.2em, y: 1em),
          radius: (top: 2pt, bottom: 2pt),
          stroke: (left: .35em + clr-primary),
          {
            set text(font: code-font-stack, size: 1em, fill: clr-darkest)
            it
          }
        )
      )
    } else {
      // Inline code
      box(
        fill: clr-lightest-tr,
        inset: (x: .3em, y: 0pt),
        outset: (y: .3em),
        radius: 2pt,
        stroke: 0.5pt + clr-lightest-tr,
        {
          show regex("[\x20-\x7E]+"): set text(font: code-font-stack)
          it
        }
      )
    }
  }

  // ── Heading styles ──────────────────────────────────────────────────────────
  set heading(numbering: "1.1")

  // Level 1: primary-color accent bar + rule, starts a new page
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.0em)
    grid(
      columns: (auto, 1fr),
      column-gutter: .7em,
      align: horizon,
      rect(width: .38em, height: 1.2em, fill: clr-primary),
      text(size: 1.3em, weight: "black", fill: clr-darkest, it.body),
    )
    v(.2em)
    line(stroke: .12em + clr-light, length: 100%)
    v(.2em)
  }

  // Level 2: smaller accent bar
  show heading.where(level: 2): it => {
    v(.2em)
    grid(
      columns: (auto, 1fr),
      column-gutter: .7em,
      align: horizon,
      rect(width: .3em, height: 1em, fill: clr-primary),
      text(size: 1.15em, weight: "bold", fill: clr-darkest, it.body),
    )
    v(.2em)
  }

  // Level 3: plain text, muted color
  show heading.where(level: 3): it => {
    v(.2em)
    text(font: main-font-stack, size: 1.1em, weight: "bold", fill: clr-dark, it.body)
    v(.1em)
  }

  // ── Table of contents ───────────────────────────────────────────────────────
  {
    show heading: set text(fill: clr-darkest)
    outline(title: [目录 / Contents], indent: auto)
  }
  pagebreak()

  body
}