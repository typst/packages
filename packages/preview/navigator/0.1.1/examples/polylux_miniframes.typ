#import "@preview/polylux:0.4.0": *
#import "../lib.typ" as navigator
#import navigator: get-structure, render-miniframes, get-current-logical-slide-number

// --- CONFIGURATION ---
#let margin-size = 2cm
#set page(paper: "presentation-16-9", margin: (top: 3cm, bottom: 2cm, x: margin-size))
#set text(size: 25pt, font: "Lato")

// On cache les titres réels car on va les restituer proprement dans le wrapper
#show heading: none
#set heading(numbering: "1.1")

#let navy = rgb("#1a5fb4")

// --- NAVIGATOR CONFIGURATION ---
// On active l'auto-titrage (sans utiliser de règle 'show' globale)
#navigator.navigator-config.update(c => {
  c.auto-title = true
  c
})

// --- POLYLUX MINIFRAMES WRAPPER ---
#let logical-slide-counter = counter("logical-slide")

#let polylux-slide(body) = {
  logical-slide-counter.step()
  
  // 1. Emit metadata for LogicalSlide tracking
  context metadata((t: "LogicalSlide", v: logical-slide-counter.get().at(0)))
  
  // 2. Emit a Content marker to filter out non-content pages (phantom dots)
  metadata((t: "ContentSlide"))
  
  // 3. Setup the page header with the miniframes bar
  set page(header: context {
    // We use slide-selector to ensure only "ContentSlide" pages get a dot
    let selector = metadata.where(value: (t: "ContentSlide"))
    let struct = get-structure(slide-selector: selector)
    let current = get-current-logical-slide-number(slide-selector: selector)
    
    render-miniframes(
      struct, 
      current, 
      fill: navy, 
      active-color: white,
      inactive-color: white.transparentize(60%),
      style: "compact",
      outset-x: margin-size,
      inset: (x: margin-size, y: 1em),
      line-spacing: 15pt,
      navigation-pos: "bottom",
    )
  })
  
  slide({
    // On restitue le titre de la slide (Heading de niveau 2) proprement
    context {
      let title = navigator.resolve-slide-title(none)
      if title != none {
        set text(fill: navy, weight: "bold", size: 1.2em)
        block(inset: (bottom: 0.8em), width: 100%, title)
      }
    }
    body
  })
}

// --- PRESENTATION CONTENT ---

#polylux-slide[
  #set align(center + horizon)
  #text(size: 1.5em, weight: "bold", fill: navy)[Polylux + Miniframes] \
  #v(1em)
  #text(size: 0.8em, style: "italic")[Automatic Titles & Navigation]
]

= Introduction
== Overview
#polylux-slide[
  #lorem(40)
]

== Details
#polylux-slide[
  #lorem(40)
]

= Features
== Design
#polylux-slide[
  #lorem(40)
]

= Conclusion
== Summary
#polylux-slide[
  #set align(center + horizon)
  #text(fill: navy, weight: "bold")[#lorem(5)]
]
