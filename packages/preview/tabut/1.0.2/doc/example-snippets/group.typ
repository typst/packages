#import "@preview/tabut:<<VERSION>>": tabut, group
#import "example-data/titanic.typ": titanic, classes

#tabut(
  group(titanic, r => r.Pclass),
  (
    (header: [*Class*], func: r => classes.at(r.value)), 
    (header: [*Passengers*], func: r => r.group.len()), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)