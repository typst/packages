// A lightweight, dependency-free slide theme for classroom presentations.

#let navy = rgb("#17233D")
#let ink = rgb("#26334D")
#let muted = rgb("#68738A")
#let cloud = rgb("#F4F7FB")
#let white = rgb("#FFFFFF")
#let primary = rgb("#356AE6")
#let teal = rgb("#20B8A6")
#let coral = rgb("#FA7B5B")
#let gold = rgb("#F6B73C")

#let palette = (
  navy: navy,
  ink: ink,
  muted: muted,
  cloud: cloud,
  white: white,
  primary: primary,
  teal: teal,
  coral: coral,
  gold: gold,
)

// Global state tracking presentation and section titles
#let deck-title-state = state("deck-title-state", none)
#let section-title-state = state("section-title-state", none)

// Establishes a 16:9 canvas, global typography, and the opening slide.
#let deck(
  body,
  title: "",
  subtitle: none,
  author: none,
  date: none,
  accent: primary,
  footer: "MODERN CLASS PRESENTATION",
) = {
  set page(
    width: 13.333in,
    height: 7.5in,
    margin: (x: 0.8in, y: 0.6in),
    fill: cloud,
    numbering: none,
  )
  set text(size: 18pt, fill: ink)
  set par(leading: 0.72em)
  show heading: set text(weight: "bold", fill: navy)
  show strong: set text(fill: accent)
  show link: set text(fill: accent)
  show link: underline

  deck-title-state.update(title)
  section-title-state.update(none)

  block(width: 100%, height: 100%)[
    #align(left + horizon)[
      #block(width: 9.6in)[
        #rect(width: 0.85in, height: 0.1in, radius: 2pt, fill: accent)
        #v(0.3in)
        #text(size: 38pt, weight: "bold", fill: navy)[#title]
        #if subtitle != none [
          #v(0.18in)
          #text(size: 21pt, fill: muted)[#subtitle]
        ]
        #v(0.55in)
        #grid(
          columns: (1fr, 1fr),
          gutter: 0.3in,
          [
            #if author != none [
              #text(size: 11pt, weight: "bold", fill: muted)[PRESENTER]
              #v(0.06in)
              #text(size: 16pt, weight: "medium", fill: ink)[#author]
            ]
          ],
          [
            #if date != none [
              #text(size: 11pt, weight: "bold", fill: muted)[DATE]
              #v(0.06in)
              #text(size: 16pt, weight: "medium", fill: ink)[#date]
            ]
          ],
        )
      ]
    ]
    #if footer != none [
      #place(bottom + right, dx: 0pt, dy: -0.05in)[
        #text(size: 11pt, weight: "medium", fill: muted)[#footer]
      ]
    ]
  ]
  counter(page).update(0)
  pagebreak()
  body
}

// Helper to render automatic or custom slide number
#let render-slide-number(number) = {
  if number != none [
    #place(bottom + right, dx: 0pt, dy: -0.08in)[
      #text(size: 11pt, weight: "bold", fill: muted)[
        #if number == auto [
          #context counter(page).display("01")
        ] else [
          #number
        ]
      ]
    ]
  ]
}

// Creates a standard content slide.
// `eyebrow`: Defaults to `auto` (shows active Section title, or Presentation title if no section yet).
// Set `eyebrow: none` to explicitly omit eyebrow, or pass custom text string.
#let slide(
  body,
  title: "",
  eyebrow: auto,
  accent: primary,
  number: auto,
  footer: "MODERN CLASS PRESENTATION",
) = {
  pagebreak(weak: true)
  block(width: 100%, height: 100%)[
    #if eyebrow != none [
      #context {
        let eff-eyebrow = if eyebrow == auto {
          let sec = section-title-state.get()
          if sec != none { sec } else { deck-title-state.get() }
        } else {
          eyebrow
        }
        if eff-eyebrow != none and eff-eyebrow != "" [
          #text(size: 11pt, weight: "bold", fill: accent)[#upper(eff-eyebrow)]
          #v(0.06in)
        ]
      }
    ]
    #if title != "" [
      #text(size: 28pt, weight: "bold", fill: navy)[#title]
      #v(0.08in)
      #rect(width: 0.52in, height: 0.05in, radius: 1.5pt, fill: accent)
      #v(0.26in)
    ]
    #body
    #if footer != none [
      #place(bottom + left, dx: 0pt, dy: -0.08in)[
        #text(size: 10pt, fill: muted)[#footer]
      ]
    ]
    #render-slide-number(number)
  ]
}

// Introduces a new topic between groups of slides.
#let section-slide(
  title: "",
  description: none,
  accent: teal,
  number: auto,
  footer: "MODERN CLASS PRESENTATION",
) = {
  section-title-state.update(title)
  pagebreak(weak: true)
  block(width: 100%, height: 100%)[
    #align(left + horizon)[
      #grid(
        columns: (0.16in, 1fr),
        gutter: 0.35in,
        align: horizon + left,
        rect(width: 100%, height: 1.55in, radius: 3pt, fill: accent),
        block(width: 9.5in)[
          #text(size: 12pt, weight: "bold", fill: accent)[SECTION]
          #v(0.12in)
          #text(size: 38pt, weight: "bold", fill: navy)[#title]
          #if description != none [
            #v(0.16in)
            #text(size: 20pt, fill: muted)[#description]
          ]
        ]
      )
    ]
    #if footer != none [
      #place(bottom + left, dx: 0pt, dy: -0.08in)[
        #text(size: 10pt, fill: muted)[#footer]
      ]
    ]
    #render-slide-number(number)
  ]
}

// Creates a prominent statement or focus slide for key conclusions.
#let focus-slide(
  body,
  title: "",
  accent: primary,
  number: auto,
  footer: "MODERN CLASS PRESENTATION",
) = {
  pagebreak(weak: true)
  block(width: 100%, height: 100%)[
    #align(center + horizon)[
      #block(width: 9.5in)[
        #if title != "" [
          #text(size: 14pt, weight: "bold", fill: accent)[#upper(title)]
          #v(0.2in)
        ]
        #text(size: 32pt, weight: "bold", fill: navy)[#body]
      ]
    ]
    #if footer != none [
      #place(bottom + left, dx: 0pt, dy: -0.08in)[
        #text(size: 10pt, fill: muted)[#footer]
      ]
    ]
    #render-slide-number(number)
  ]
}

// Draws a highlighted teaching point, definition, or warning.
#let callout(
  body,
  title: "",
  accent: primary,
  fill: white,
) = block(
  width: 100%,
  inset: (x: 0.28in, y: 0.22in),
  radius: 8pt,
  fill: fill,
  stroke: (left: 5pt + accent, rest: 1pt + rgb("#E2E8F0")),
)[
  #if title != "" and title != none [
    #text(size: 15pt, weight: "bold", fill: navy)[#title]
    #v(0.08in)
  ]
  #body
]

// Draws a clean container card for organizing content.
#let card(
  body,
  title: "",
  accent: none,
  fill: white,
) = block(
  width: 100%,
  inset: (x: 0.28in, y: 0.22in),
  radius: 8pt,
  fill: fill,
  stroke: if accent != none { (top: 3pt + accent, rest: 1pt + rgb("#E2E8F0")) } else { 1pt + rgb("#E2E8F0") },
)[
  #if title != "" and title != none [
    #text(size: 15pt, weight: "bold", fill: navy)[#title]
    #v(0.08in)
  ]
  #body
]

// Places content in balanced columns with a presentation-friendly gap.
#let columns(left, right, ratio: (1fr, 1fr), gutter: 0.34in) = grid(
  columns: ratio,
  gutter: gutter,
  left,
  right,
)

// Provides a consistent caption for sources, images, or footnotes.
#let source(body) = text(size: 10pt, fill: muted)[#body]
