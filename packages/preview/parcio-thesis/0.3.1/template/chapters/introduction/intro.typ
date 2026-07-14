#import "@local/parcio-thesis:0.3.1": subfigure, section, ovgu-fin-logo

= Introduction<intro>

_In this chapter, #lorem(50)_

== Motivation

// Subfigures.
#subfigure(
  caption: "Caption", 
  columns: 2, 
  label: <fig:main>,
  figure(caption: "Left")[
    #image(ovgu-fin-logo, width: 75%)
  ], <fig:main-a>,
  figure(caption: "Right")[
    #image(ovgu-fin-logo, width: 75%)
  ], <fig:main-b>
)

You can refer to the subfigures (Figures @fig:main-a[] and @fig:main-b[]) or the figure (@fig:main).
\ \

#section[Summary]
#lorem(80)
