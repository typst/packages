#import "@preview/parcio-thesis:0.2.0": parcio-table, section

= Background<bg>

_In this chapter, ..._

== Citations

You can comfortably reference literature @DuweLMSF0B020.#footnote[This is a footnote.] BibTeX entries for a large number of publications can be found at https://dblp.org/.

== Tables

// Either use `parcio-table` for special tables (with an extra argument at the start, max-rows) or just use the normal `table` function and style it however you like.
#figure(caption: "Caption")[
  #parcio-table(3, columns: 3, align: (left, center, right), 
    [*Header 1*], [*Header 2*], [*Header 3*],
    [Row 1],[Row 1],[Row 1],
    [Row 2],[Row 2],[Row 2],
  )
]<tbl:tb1>

You can also refer to tables (@tbl:tb1).

== Math<m>

$ E = m c^2 $<eq:eq1>

\

#section[Summary]
#lorem(80)