#import "@preview/tabut:1.0.0": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*\#*], func: r => r.index-alt ),
    (header: [*Name*], func: r => r.name ), 
  ),
  index: "index-alt", // set an aternate name for the automatically generated index property.
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)