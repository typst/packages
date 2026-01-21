#import "@preview/tabut:<<VERSION>>": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  (
    (header: [*Name*], func: r => r.name), 
    (header: [*Price*], func: r => r.price), 
    (header: [*Quantity*], func: r => r.quantity), 
  ),
  headers: false, // Prevents Headers from being generated
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none,
)