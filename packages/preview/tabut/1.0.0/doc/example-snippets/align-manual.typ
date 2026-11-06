#import "@preview/tabut:1.0.0": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*\#*], func: r => r._index),
    (header: [*Name*], func: r => r.name), 
    (header: [*Price*], func: r => usd(r.price)), 
    (header: [*Quantity*], func: r => r.quantity),
  ),
  align: (auto, right, right, right), // Alignment defined as in standard table function
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)