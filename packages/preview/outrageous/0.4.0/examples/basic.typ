#import "@preview/outrageous:0.4.0"

#set heading(numbering: "1.")
#set outline(indent: auto)

#page(height: auto, width: 15cm, margin: 1cm)[
  #show outline.entry: outrageous.show-entry
  #outline()
]

#page(height: auto, width: 15cm, margin: 1cm)[
  #show outline.entry: outrageous.show-entry.with(
    // the typst preset retains the normal Typst appearance
    ..outrageous.presets.typst,
    // we only override a few things:
    // level-1 entries are italic, all others keep their font style
    font-style: ("italic", auto),
    // no fill for level-1 entries, a thin gray line for all deeper levels
    fill: (none, line(length: 100%, stroke: gray + .5pt)),
  )
  #outline()
]

= Introduction
#lorem(400)

#lorem(400)

== What is this About?
#lorem(400)

#lorem(400)

== Why am I Here?
#lorem(400)

#lorem(400)

= The Backstory
#lorem(400)

#lorem(400)

== How it all Started
#lorem(400)

#lorem(400)

=== Early Beginnings
#lorem(400)

#lorem(400)

=== First Settlements
#lorem(400)

#lorem(400)

= The Consequences
#lorem(400)

#lorem(400)

= Happy Ending
#lorem(400)

#lorem(400)
