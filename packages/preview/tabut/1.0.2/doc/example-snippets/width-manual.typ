#import "@preview/tabut:<<VERSION>>": tabut
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#box(
  width: 300pt,
  tabut(
    supplies,
    (
      (header: [*\#*], func: r => r._index),
      (header: [*Name*], func: r => r.name), 
      (header: [*Price*], func: r => usd(r.price)), 
      (header: [*Quantity*], func: r => r.quantity),
    ),
    columns: (auto, 1fr, 20%, 1.5in),  // Columns defined as in standard table
    fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
    stroke: none,
  )
)

