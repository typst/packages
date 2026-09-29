#import "@preview/slydekit:0.1.0" as sk
#import "@preview/navigator:0.1.7" as navigator

// --- CONFIGURATION ---
#let primary = rgb("#014682")
#let accent = orange

#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c.theme-colors = (primary: primary, accent: accent)
  c.slide-func = (fill: white, body) => {
    pagebreak(weak: true)
    set page(fill: fill, header: none, footer: none)
    set align(horizon)
    body
  }
  c
})

#show: sk.slydekit.with(
  title: "Slydekit + Navigator",
  subtitle: "Two-level structural transitions",
  author: "David Hajage",
)

// --- TRANSITION LOGIC ---
//
// slydekit's own theme reacts to `=` and `==` headings on its own (an
// automatic "Outline" divider on level 1, an automatic content slide on
// level 2). Both rules live inside the theme, applied when the document body
// is shown, which puts them ahead of a plain `show heading: ...` declared
// before `#show: sk.slydekit.with(...)`. So we first neutralize both levels
// with `none`, then install navigator's transition — both declared here,
// after the setup call, so they win over the theme's own rules.
#show heading.where(level: 1): none
#show heading.where(level: 2): none

#show heading.where(level: 1): h => navigator.render-transition(
  h,
  top-padding: 20%,
  transitions: (
    background: "theme",
    style: (active-color: white, inactive-opacity: 0.4),
    sections: (visibility: (section: "current", subsection: "current-parent")),
    subsections: (visibility: (section: "current", subsection: "current-parent")),
  ),
)
#show heading.where(level: 2): h => navigator.render-transition(
  h,
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
// With both heading levels reserved for transitions, ordinary content slides
// are created explicitly with `sk.slide`, exactly as slydekit's own docs do
// for anything a bare heading can't express.

#sk.title-slide

= Introduction

== Welcome
#sk.slide("Context")[
  #lorem(30)
]
#sk.slide("Motivation")[
  #lorem(30)
]

== Objectives
#sk.slide("Primary goals")[
  #lorem(25)
]

= Methodology

== Data Collection
#sk.slide("Protocol")[
  #lorem(30)
]

== Analysis
#sk.slide("Approach")[
  #lorem(25)
]
#sk.slide("Validation")[
  #lorem(25)
]

= Conclusion

== Final Remarks
#sk.slide("Thank you!")[
  Happy presenting with Typst!
]
