#import "@preview/presentate:0.2.3" as ps
#import "../lib.typ" as navigator

// --- CONFIGURATION ---
#set page(paper: "presentation-16-9", margin: (top: 2cm, bottom: 1cm, x: 2cm))
#set text(size: 25pt, font: "Lato")
#set heading(numbering: "1.")

// Navigator Mapping
#let mapping = (section: 1, subsection: 2)

// --- COMPOSANT DE NAVIGATION (HEADER) ---
#let nav-header = context {
  // On ne compte que les slides avec le marqueur 'ContentSlide'
  let selector = metadata.where(value: (t: "ContentSlide"))
  let struct = navigator.get-structure(slide-selector: selector)
  let current = navigator.get-current-logical-slide-number(slide-selector: selector)
  
  navigator.render-miniframes(
    struct, 
    current, 
    fill: none, 
    text-color: black, 
    active-color: rgb("#1a5fb4"),
    inactive-color: gray.lighten(50%),
    style: "compact",
    navigation-pos: "bottom",
  )
}

// Par défaut, toutes les pages ont la barre de navigation
#set page(header: nav-header)

// --- WRAPPER DE SLIDE ---
#let slide(title: none, body) = {
  // On émet le marqueur pour que cette slide produise un point (dot)
  metadata((t: "ContentSlide"))
  
  ps.slide[
    #if title != none {
      set text(fill: rgb("#1a5fb4"), weight: "bold", size: 1.2em)
      block(inset: (bottom: 0.5em), title)
    }
    #body
  ]
}

// --- TRANSITIONS : MOTEUR AUTOMATIQUE ---
#let empty-slide(fill: white, body) = {
  // On masque l'en-tête pour les slides de transition
  // et on ne met pas de marqueur 'ContentSlide' -> pas de dot
  set page(fill: fill, header: none)
  ps.slide(body)
}

#show heading: h => navigator.render-transition(
  h,
  mapping: mapping,
  theme-colors: (primary: rgb("#1a5fb4"), accent: orange),
  slide-func: empty-slide,
)

// --- CONTENU DE LA PRÉSENTATION ---

// Page de titre : on désactive manuellement l'en-tête
#{
  set page(header: none)
  ps.slide[
    #set align(center + horizon)
    #text(size: 1.5em, weight: "bold", fill: rgb("#1a5fb4"))[Integration Example] \
    Presentate + Navigator \
    #v(1em)
    #text(size: 0.8em, style: "italic")[Clean & Automated Navigation]
  ]
}

= Introduction

== Key Concepts
#slide[
  - *Navigator* handles the structure.
  - *Presentate* handles the slides.
  - Integration is done via a simple wrapper.
]

== Why use both?
#slide[
  You get the flexibility of Presentate with the automated visual aids of Navigator.
]

= Features

== Automated Transitions
#slide[
  Notice the slide before this one? It was generated automatically by the transition engine.
]

== Miniframes Progress
#slide[
  Look at the dots in the header. They track your progress within each section.
]

= Conclusion

#slide[
  Happy Presenting with Typst!
]