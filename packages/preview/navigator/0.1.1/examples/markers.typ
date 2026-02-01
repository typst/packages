#import "../lib.typ": progressive-outline

#set page(width: 16cm, height: 12cm, margin: 1cm)
#set text(font: "Lato", size: 14pt)

= Customizable Markers Demo

== Polymorphism Test

=== 1. Content Marker (Static)
Use a single symbol for all items.

#block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)[
  #progressive-outline(
    marker: sym.triangle.filled.small,
    level-1-mode: "current",
    level-2-mode: "all",
    spacing: (marker-gap: 0.5em)
  )
]

=== 2. Dictionary Marker (State-based)
Different symbols for active, completed, and inactive states.

#block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)[
  #progressive-outline(
    marker: (
      active: text(fill: blue)[#sym.arrow.r],
      completed: sym.checkmark,
      inactive: sym.circle.small
    ),
    level-1-mode: "current",
    level-2-mode: "all",
    spacing: (marker-gap: 0.8em, marker-width: 1.5em)
  )
]

=== 3. Function Marker (Logic-based)
Complete control based on state and hierarchy level.

#block(fill: luma(240), inset: 1em, radius: 0.5em, width: 100%)[
  #progressive-outline(
    marker: (state, level) => {
      if level == 1 {
        if state == "active" { text(size: 1.2em)[#sym.star.filled] }
        else { sym.star.stroked }
      } else {
        if state == "active" { sym.arrow.r }
        else { sym.circle.filled.tiny }
      }
    },
    level-1-mode: "current",
    level-2-mode: "all",
    spacing: (marker-gap: 0.4em)
  )
]
