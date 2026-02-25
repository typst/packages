#import "@preview/polylux:0.4.0": *
#import "@preview/navigator:0.1.3" as navigator

// --- CONFIGURATION ---
#let base-size = 25pt
#set page(paper: "presentation-16-9", margin: (top: 3cm, bottom: 2cm, x: 2cm))
#set text(size: base-size, font: "Lato")
#set heading(numbering: "1.1")

// Colors for the theme
#let primary = rgb("#2c3e50")
#let accent = rgb("#e67e22")

// --- HEADER LOGIC (for content slides) ---
#set page(header: context {
  let active = navigator.get-active-headings(here())
  if active.h2 != none {
    set align(top + left)
    set text(fill: primary, weight: "bold", size: 1em)
    v(1.5em)
    active.h2.body
  }
})

// --- POLYLUX WRAPPER ---
#let polylux-slide-func(fill: white, body) = {
  // Transition slides don't have the normal header and have a custom background
  set page(fill: fill, header: none) 
  slide(body)
}

// Configuration globale du Navigator
#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c.theme-colors = (primary: primary, accent: accent)
  c.slide-func = polylux-slide-func
  c
})

// --- TRANSITION LOGIC ---
#show heading: navigator.render-transition.with(
  base-text-size: base-size,
  transitions: (
    background: "theme",
    style: (
      active-color: white,
      inactive-opacity: 0.4,
    ),
    // Section transition: Section title + list of all its Subsections
    sections: (
      visibility: (section: "current", subsection: "current-parent")
    ),
    // Subsection transition: Section title + Subsections list with highlight
    subsections: (
      visibility: (section: "current", subsection: "current-parent")
    )
  )
)

// --- PRESENTATION CONTENT ---

#slide[
  #set align(center + horizon)
  #text(size: 1.5em, weight: "bold", fill: primary)[Polylux + Navigator] \
  #v(1em)
  #text(size: 0.8em, style: "italic")[Full Structural Transitions]
]

= Introduction

== Welcome

#slide[
  #lorem(40)
]

== Objectives
#slide[
  #lorem(40)
]

= Methodology

== Data Collection
#slide[
  #lorem(40)
]

== Analysis
#slide[
  #lorem(40)
]

= Conclusion

== Final Thoughts
#slide[
  #set align(center + horizon)
  #text(fill: primary, weight: "bold", size: 1.2em)[Thank you!]
]