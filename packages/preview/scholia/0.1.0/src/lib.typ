// Scholia — fill-in study notes for STEM (AI & math).
// A Typst reimplementation inspired by the loom-notes design (MIT). No source reused.
//
//   knot   = a result (theorem box, via frame-it)
//   note   = the intuition voice
//   sidenote = a Tufte-style margin note (recall = the "?" active-recall preset)

#import "@preview/marginalia:0.3.1" as marginalia: note as _note
#import "colors.typ": *
#import "fonts.typ": *
#import "visual.typ": *
#import "theorems.typ": *

// ===========================================================================
//  THE INTUITION VOICE
// ===========================================================================
#let note(body) = context {
  let p = active.get()
  block(
    width: 100%, breakable: true, fill: tint(p, p.thm),
    stroke: (left: 1.6pt + p.thm), above: 8pt, below: 8pt,
    inset: (left: 11pt, right: 9pt, top: 6pt, bottom: 6pt),
  )[
    #set text(font: (..default-fonts.sans, ..default-fonts.cjk), size: 0.92em, fill: p.ink)
    #body
  ]
}

#let whisper(body) = context text(
  font: (..default-fonts.sans, ..default-fonts.cjk), size: 0.92em, fill: active.get().thm,
)[#body]
#let keyword(body) = context text(weight: "bold", fill: active.get().keyword)[#body]

// ===========================================================================
//  PEDAGOGY — fill-in study notes
// ===========================================================================
#let block-head(body) = context block(above: 1em, below: 0.5em)[
  #text(font: default-fonts.heading, weight: "bold", fill: active.get().thm)[#body]
]

#let trigger(body) = context block(above: 0.5em, below: 0.5em)[
  #text(font: default-fonts.heading, weight: "bold", fill: active.get().def)[Trigger.] #h(0.3em)#body
]

#let TODO(hint) = context text(font: default-fonts.sans, size: 0.92em, fill: active.get().eg)[[ fill in: #hint ]]

#let fillin(width: 2.2cm) = context box(width: width, height: 0.9em, stroke: (bottom: 0.6pt + active.get().ink))

#let yourturn(body) = context {
  let p = active.get()
  block(
    width: 100%, breakable: true, fill: tint(p, p.eg),
    stroke: (left: 2pt + p.eg), above: 9pt, below: 9pt,
    inset: (left: 11pt, right: 10pt, top: 7pt, bottom: 8pt),
  )[#text(font: default-fonts.heading, weight: "bold", fill: p.eg)[Your turn.] #h(0.3em)#body]
}

#let workspace(n: 3) = context {
  let p = active.get()
  v(1pt)
  for _ in range(n) {
    line(length: 100%, stroke: 0.3pt + p.hairline)
    v(9pt)
  }
}

// ===========================================================================
//  MARGIN NOTES (right selvage, via marginalia, no number marker)
// ===========================================================================
// one Tufte-style margin note (unnumbered). An optional leading `symbol` marks
// its intent; colour follows the theme accent.
#let sidenote(body, symbol: none) = _note(counter: none)[
  #context {
    let p = active.get()
    set text(font: (..default-fonts.sans, ..default-fonts.cjk), size: 0.82em, fill: p.muted)
    set par(leading: 0.5em)
    if symbol != none { text(fill: p.thm, weight: "bold")[#symbol]; h(0.3em) }
    body
  }
]

// active-recall prompt: a margin note marked with "?"
#let recall(body) = sidenote(body, symbol: [?])

// (cross-references use Typst's native labels: put `<lbl>` after a knot, `@lbl` to refer.)

// ===========================================================================
//  THE COVER
// ===========================================================================
// a pure-typographic cover. symmetric margins so it centres on the physical
// page (not the note-offset body box marginalia sets up). `kicker` is an
// optional small tracked line above the title (course code, series, ∇·, …).
#let cover(title, subtitle: none, author: none, date: none, kicker: none) = {
  context {
    let p = active.get()
    page(fill: p.bg, background: none, footer: none, header: none, margin: (x: 2.5cm, top: 2cm, bottom: 2.3cm))[
      #set align(center)
      #v(1fr)
      #if kicker != none {
        text(font: default-fonts.heading, size: 10pt, fill: p.muted, tracking: 3pt)[#upper(kicker)]
        v(0.9cm)
      }
      #text(font: default-fonts.heading, weight: "bold", size: 30pt, fill: p.thm, tracking: 1.5pt)[#title]
      #v(0.5cm)
      #line(length: 32%, stroke: 1pt + p.rule)
      #if subtitle != none {
        v(0.5cm)
        text(font: (..default-fonts.sans, ..default-fonts.cjk), size: 13pt, fill: p.muted)[#subtitle]
      }
      #v(1fr)
      #if author != none {
        text(font: (..default-fonts.sans, ..default-fonts.cjk), size: 11pt, fill: p.ink, tracking: 0.5pt)[#author]
      }
      #if date != none {
        v(0.3em)
        text(font: default-fonts.sans, size: 9pt, fill: p.muted, tracking: 0.5pt)[#date]
      }
      #v(1.6cm)
    ]
  }
  counter(page).update(1)
}

// ===========================================================================
//  THE DOCUMENT WRAPPER
// ===========================================================================
// theme:  "light" (default) | "dark" (slate)
// prose:  "notes" (no indent, para spacing) | "book" (first-line indent, tight)
// fonts:  overrides merged over `default-fonts`
#let scholia(theme: "light", prose: "notes", paper: "a4", fonts: none, body) = {
  let p = palettes.at(theme)
  let f = resolve-fonts(fonts)
  let hfont = f.heading
  active.update(p)

  set page(
    paper: paper,
    fill: p.bg,
    footer: context {
      set text(font: f.sans, size: 0.8em, fill: p.muted)
      align(right)[#counter(page).display()]
    },
  )
  show: marginalia.setup.with(
    inner: (far: 6mm, width: 12mm, sep: 6mm),
    outer: (far: 6mm, width: 26mm, sep: 7mm),
    top: 2cm, bottom: 2.3cm,
  )

  set text(font: (..f.body, ..f.cjk), size: 11pt, fill: p.ink, lang: "en")
  show math.equation: set text(font: f.math)
  show raw: set text(font: f.mono)
  set par(
    justify: true,
    leading: 0.72em,
    first-line-indent: if prose == "book" { 1.2em } else { 0pt },
    spacing: if prose == "book" { 0.7em } else { 0.95em },
  )
  set heading(numbering: "1.1")

  // section: number + title over a rule; reset the per-section knot counter
  show heading.where(level: 1): it => {
    counter(figure.where(kind: "frame")).update(0)
    block(above: 20pt, below: 8pt, width: 100%)[
      #text(font: hfont, weight: "bold", size: 15pt, fill: p.muted)[#counter(heading).display()]
      #h(0.7em)
      #text(font: hfont, weight: "bold", size: 15pt, fill: p.thm)[#it.body]
      #v(1pt)
      #line(length: 100%, stroke: 1.1pt + p.rule)
    ]
  }
  show heading.where(level: 2): it => block(above: 11pt, below: 0.5em)[
    #text(font: hfont, weight: "bold", fill: p.def)[#counter(heading).display() #it.body]
  ]
  show heading.where(level: 3): it => block(above: 8pt, below: 0.5em)[
    #text(font: f.sans, weight: "bold", fill: p.thm)[#it.body]
  ]

  show: theorem-rules
  body
}
