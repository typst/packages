#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.1.")
#set-revisions(require-exchange: false, del-numbering: "keep")

*del-numbering: "keep"*

= Methods

#figure(rect(width: 2cm, height: 1cm, fill: luma(230)), caption: [Kept figure.]) <fig-d>
#passage(<x4>)[
  #del[#figure(rect(width: 2cm, height: 1cm, fill: luma(230)), caption: [Removed figure --- still consumes a number here.]) <fig-e>]
]
#figure(rect(width: 2cm, height: 1cm, fill: luma(230)), caption: [Next figure --- number has shifted, diverging from the clean version.]) <fig-f>

#figure(table(columns: 2, [Kept], [table]), caption: [Kept table.]) <tab-d>
#passage(<x5>)[
  #del[#figure(table(columns: 2, [Removed], [table]), caption: [Removed table --- still consumes a number here.]) <tab-e>]
]
#figure(table(columns: 2, [Next], [table]), caption: [Next table --- number has shifted, diverging from the clean version.]) <tab-f>

Kept equation. $ a = b $ <eq-a-kept-b>
#passage(<x6>)[
  #del[$ E = m c^2 $ <eq-b>]
]
Next equation --- number has shifted, diverging from the clean version. $ c = d $ <eq-c-kept-b>

== Kept subsection.
#passage(<x8>)[
  #del[
    == Removed subsection --- still consumes a number here.
    Removed content.
  ]
]
== Next subsection --- number has shifted, diverging from the clean version.
