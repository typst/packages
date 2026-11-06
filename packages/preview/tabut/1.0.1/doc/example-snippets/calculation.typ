#import "@preview/tabut:1.0.1": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  ( 
    (header: [*Name*], func: r => r.name ), 
    (header: [*Price*], func: r => usd(r.price)), 
    (header: [*Tax*], func: r => usd(r.price * .2)), 
    (header: [*Total*], func: r => usd(r.price * 1.2)), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)