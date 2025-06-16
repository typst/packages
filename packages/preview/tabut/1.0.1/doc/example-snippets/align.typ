#import "@preview/tabut:1.0.1": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( // Include `align` as an optional arg to a column def
    (header: [*\#*], func: r => r._index),
    (header: [*Name*], align: right, func: r => r.name), 
    (header: [*Price*], align: right, func: r => usd(r.price)), 
    (header: [*Quantity*], align: right, func: r => r.quantity),
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)