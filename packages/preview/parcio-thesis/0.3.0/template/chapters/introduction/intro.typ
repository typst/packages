#import "@preview/parcio-thesis:0.3.0": subfigure, section

= Introduction<intro>

_In this chapter, #lorem(50)_

== Motivation

// Subfigures.
#subfigure(
  caption: "Caption", 
  columns: 2, 
  label: <fig:main>,
  figure(caption: "Left")[
    #image(width: 75%, "ovgu-fin.svg")
  ], <fig:main-a>,
  figure(caption: "Right")[
    #image(width: 75%, "ovgu-fin.svg")
  ], <fig:main-b>
)

You can refer to the subfigures (Figures @fig:main-a[] and @fig:main-b[]) or the figure (@fig:main).
\ \

#section[Summary]
#lorem(80)
