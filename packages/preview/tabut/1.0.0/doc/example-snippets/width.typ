#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#box(
  width: 300pt,
  tabut(
    supplies,
    ( // Include `width` as an optional arg to a column def
      (header: [*\#*], func: r => r._index),
      (header: [*Name*], width: 1fr, func: r => r.name), 
      (header: [*Price*], width: 20%, func: r => usd(r.price)), 
      (header: [*Quantity*], width: 1.5in, func: r => r.quantity),
    ),
    fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
    stroke: none,
  )
)

