#import "../lib.typ": progressive-outline

// ----------------------------------------------------------------------
// SETUP
// ----------------------------------------------------------------------

#set page(paper: "a4", flipped: true, margin: 2cm)
#set text(font: "Lato", size: 11pt)
#set heading(numbering: "1.1")

// Utility to wrap a test case visually
#let test-box(title, body) = block(
  stroke: 0.5pt + gray,
  radius: 4pt,
  inset: 1em,
  width: 100%,
  breakable: false,
  [
    #text(weight: "bold", fill: blue, title)
    #v(0.5em)
    #body
  ]
)

= Comprehensive Marker Test Suite

This document tests the `progressive-outline` function with a focus on *Markers*, *Opacity*, and *Numbering*.

// ----------------------------------------------------------------------
// TEST CASES (Rendered *before* the actual headings to test "Inactive" state mostly, 
// but we will trick the location to test other states if needed or rely on flow)
// ----------------------------------------------------------------------

== Test Case 1: Opacity Inheritance (The "Smart Fade")
*Objective:* The marker should fade together with the text when using the float shortcut.

#test-box("Expected: Active=Red+Star, Inactive=Faint Red (0.2)+Star", 
  progressive-outline(
    level-1-mode: "all",
    level-2-mode: "none",
    // Setup styles
    text-styles: (
      level-1: (
        active: (fill: red, weight: "bold"),
        inactive: 0.2 // Float shortcut -> Should apply to marker too
      )
    ),
    // Setup marker
    marker: sym.star.filled
  )
)

== Test Case 2: Complex Numbering + Dictionary Marker
*Objective:* Verify order `[Marker] [Number] [Title]` and state-specific icons.

#test-box("Expected: Checkmark for past, Arrow for current, Circle for future. Numbering I.1.", 
  progressive-outline(
    level-1-mode: "all",
    level-2-mode: "all",
    show-numbering: true,
    numbering-format: (..n) => numbering("I.1.", ..n),
    marker: (
      active: text(fill: blue, size: 1.2em)[#sym.arrow.r.filled],
      inactive: text(fill: gray)[#sym.circle.small],
      completed: text(fill: green)[#sym.checkmark]
    ),
    spacing: (marker-gap: 1em)
  )
)

== Test Case 3: Alignment & Width
*Objective:* Align titles perfectly despite different marker widths.

#test-box("Expected: Titles aligned vertically. 'Wide' marker takes space.", 
  progressive-outline(
    level-1-mode: "all",
    level-2-mode: "none",
    marker: (
      active: box(width: 2em, fill: aqua)[Wide],
      inactive: box(width: 0.5em, fill: yellow)[S]
    ),
    spacing: (
      marker-gap: 0.5em,
      marker-width: 2.5em // Force fixed width for the marker column
    )
  )
)

== Test Case 4: Advanced Logic (Function)
*Objective:* Different markers for Level 1 vs Level 2.

#test-box("Expected: Level 1 = Square, Level 2 = Bullet", 
  progressive-outline(
    level-1-mode: "all",
    level-2-mode: "all",
    marker: (state, level) => {
      if level == 1 { sym.square.filled }
      else { sym.bullet }
    }
  )
)

// ----------------------------------------------------------------------
// DOCUMENT STRUCTURE (To populate the outline)
// ----------------------------------------------------------------------
#pagebreak()

= Part I: Physics (Active in middle) <p1>
== Classical Mechanics <c1>
== Quantum Mechanics <c2>

#v(2em)
*--- MIDDLE OF DOCUMENT SIMULATION ---*
Here is an outline rendered "in the middle" (after Physics, before Biology).
Physics should be *Completed*. Biology should be *Active* (if we are strictly sequential) or *Inactive*.
Let's look at the behavior relative to the current position.

#test-box("Middle Simulation", 
  progressive-outline(
    level-1-mode: "all",
    level-2-mode: "all",
    marker: (
      completed: sym.checkmark,
      active: sym.arrow.r,
      inactive: sym.circle
    )
  )
)

= Part II: Biology <p2>
== Cell Structure
== Genetics

= Part III: Chemistry <p3>
== Organic
== Inorganic
