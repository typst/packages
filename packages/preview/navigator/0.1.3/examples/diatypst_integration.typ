#import "@preview/diatypst:0.9.1": slides
#import "../lib.typ" as navigator

// --- CONFIGURATION ---
#let primary-color = rgb("#1a5fb4")

// On définit manuellement le layout pour éviter les conflits de show rules de diatypst
#set page(
  paper: "presentation-16-9",
  margin: (x: 2cm, top: 2.8cm, bottom: 1.5cm),
  fill: white,
)
#set text(size: 22pt, font: "Lato")
#set heading(numbering: "1.")

// 1. Fonction de transition
#let transition-slide(fill: white, body) = {
  set page(fill: fill, header: none, footer: none)
  set text(fill: if fill == white { black } else { white })
  block(width: 100%, height: 100%, inset: (top: 20%), body)
}

// Configuration globale du Navigator
#navigator.navigator-config.update(c => {
  c.mapping = (section: 1, subsection: 2)
  c.theme-colors = (primary: primary-color)
  c.slide-func = transition-slide
  c.show-heading-numbering = true
  c
})

// 2. Wrapper de Slide
#let slide(title: none, body) = {
  pagebreak(weak: true)
  metadata((t: "ContentSlide"))
  
  if title != none {
    set text(fill: primary-color, weight: "bold", size: 1.2em)
    block(inset: (bottom: 0.8em), title)
  }
  
  body
}

// 3. Header de navigation
#set page(header: context {
  let is-transition = query(heading.where(level: 1).or(heading.where(level: 2)))
    .any(h => h.location().page() == here().page())
  
  if here().page() > 1 and not is-transition {
    set align(top)
    block(outset: (top: 2pt))[
      #navigator.render-miniframes(
        fill: primary-color,
        active-color: white,
        inactive-color: white.transparentize(60%),
        style: "grid",
        show-level1-titles: true,
        show-level2-titles: true,
        navigation-pos: "bottom",
        outset-x: 2cm, // S'étend jusqu'aux bords de la page
        inset: (x: 2cm, y: 0.5em),
        gap: 2em,
      )
    ]
  }
})

// 4. Moteur de transition automatique
#show heading.where(level: 1).or(heading.where(level: 2)): navigator.render-transition.with(
  top-padding: 20%,
  transitions: (
    sections: (
      visibility: (section: "current", subsection: "current-parent")
    ),
    subsections: (
      visibility: (section: "current", subsection: "current-parent")
    ),
  )
)

// --- CONTENU ---

// Page de titre manuelle (style diatypst)
#{
  set page(header: none)
  set align(center + horizon)
  block(inset: 2cm)[
    #text(size: 1.5em, weight: "bold", fill: primary-color)[Integration Example] \
    #v(0.5em)
    Diatypst + Navigator \
    #v(1em)
    #text(size: 0.8em, style: "italic")[Clean & Automated Navigation]
  ]
}

= Introduction

== Key Concepts
#slide(title: "The Core Idea")[
  - *Navigator* handles the structure.
  - *Diatypst* handles the styling.
  - Integration is done via a simple wrapper.
]

== Why use both?
#slide(title: "Benefits")[
  You get the flexibility of Diatypst with the automated visual aids of Navigator.
]

= Features

== Automated Transitions
#slide(title: "Seamless Roadmap")[
  Notice the slide before this one? It was generated automatically by the transition engine.
]

== Miniframes Progress
#slide(title: "Header Navigation")[
  Look at the dots in the header. They track your progress within each section.
]

= Conclusion

== Final Thoughts
#slide(title: "Summary")[
  Happy Presenting with Typst!
]
