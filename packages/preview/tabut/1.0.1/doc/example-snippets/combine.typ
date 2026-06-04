#import "@preview/tabut:1.0.1": tabut

#let employees = (
    (id: 3251, first: "Alice", last: "Smith", middle: "Jane"),
    (id: 4872, first: "Carlos", last: "Garcia", middle: "Luis"),
    (id: 5639, first: "Evelyn", last: "Chen", middle: "Ming")
);

#tabut(
  employees,
  ( 
    (header: [*ID*], func: r => r.id ),
    (header: [*Full Name*], func: r => [#r.first #r.middle.first(), #r.last] ),
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)