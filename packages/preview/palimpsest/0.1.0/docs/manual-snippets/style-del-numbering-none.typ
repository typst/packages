#import "@preview/palimpsest:0.1.0": *

#set page(width: 16.6cm, height: auto, margin: 12pt)
#set text(size: 10.5pt)
#set math.equation(numbering: "(1)")
#set heading(numbering: "1.1.")
#set-revisions(require-exchange: false)

*del-numbering: "none" (default)*

= Methods

#figure(rect(width: 2cm, height: 1cm, fill: luma(230)), caption: [Kept figure.]) <fig-a>
#passage(<x1>)[
  #del[#figure(rect(width: 2cm, height: 1cm, fill: luma(230)), caption: [Removed figure.]) <fig-b>]
]
#figure(rect(width: 2cm, height: 1cm, fill: luma(230)), caption: [Next figure --- same number as in the clean version.]) <fig-c>

#figure(table(columns: 2, [Kept], [table]), caption: [Kept table.]) <tab-a>
#passage(<x2>)[
  #del[#figure(table(columns: 2, [Removed], [table]), caption: [Removed table.]) <tab-b>]
]
#figure(table(columns: 2, [Next], [table]), caption: [Next table --- same number as in the clean version.]) <tab-c>

Kept equation. $ a = b $ <eq-a-kept>
#passage(<x3>)[
  #del[$ E = m c^2 $ <eq-a>]
]
Next equation --- same number as in the clean version. $ c = d $ <eq-c-kept>

== Kept subsection.
#passage(<x7>)[
  #del[
    == Removed subsection.
    Removed content.
  ]
]
== Next subsection --- same number as in the clean version.
