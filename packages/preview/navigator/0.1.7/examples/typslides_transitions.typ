#import "@preview/typslides:1.3.4" as ts
#import ts: *
#import "@preview/navigator:0.1.7" as navigator

// --- CONFIGURATION ---
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
  show-progress: false,
)

#set heading(numbering: "1.1")

#let primary = rgb("#1a5fb4")
#let accent = orange

#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c.theme-colors = (primary: primary, accent: accent)
  // Typslides slides own their header/footer/progress-bar via `set page(...)`
  // inside `slide`/`focus-slide`; a transition slide is built the same way
  // directly here, with all of that chrome switched off.
  c.slide-func = (fill: white, body) => {
    set page(fill: fill, header: none, footer: none, background: none, foreground: none)
    set align(top + left)
    body
  }
  c
})

// --- TRANSITION LOGIC ---
//
// Unlike Mosaic or Slydekit, Typslides never turns headings into slides on
// its own — `title-slide`/`slide`/`focus-slide` are always explicit calls, so
// there's no built-in rule to work around. A plain `show heading: ...`
// intercepts both section and subsection headings directly.
#show heading: navigator.render-transition.with(
  top-padding: 20%,
  transitions: (
    background: "theme",
    style: (active-color: white, inactive-opacity: 0.4),
    sections: (visibility: (section: "current", subsection: "current-parent")),
    subsections: (visibility: (section: "current", subsection: "current-parent")),
  ),
)

// --- CONTENT ---
//
// Content slides are created explicitly with `slide`, exactly as Typslides'
// own docs do; headings exist purely for navigator's roadmap.

#front-slide(
  title: [Typslides + Navigator],
  subtitle: [Full Structural Transitions],
  authors: "David Hajage",
)

= Introduction

== Welcome
#slide(title: "Context")[
  #lorem(30)
]

== Objectives
#slide(title: "Primary goals")[
  #lorem(25)
]

= Methodology

== Data Collection
#slide(title: "Protocol")[
  #lorem(30)
]

== Analysis
#slide(title: "Approach")[
  #lorem(25)
]
#slide(title: "Validation")[
  #lorem(25)
]

= Conclusion

== Final Remarks
#focus-slide[
  Happy presenting with Typst!
]
