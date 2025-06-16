#import "@preview/tabut:1.0.1": tabut
#import "example-data/supplies.typ": supplies

#let fmt(it) = {
  heading(
    outlined: false,
    upper(it)
  )
}

#tabut(
  supplies,
  ( 
    (header: fmt([Name]), func: r => r.name ), 
    (header: fmt([Price]), func: r => r.price), 
    (header: fmt([Quantity]), func: r => r.quantity), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)