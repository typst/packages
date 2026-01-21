#import "@preview/tabut:1.0.0": tabut, group
#import "usd.typ": usd
#import "example-data/titanic.typ": titanic, classes

#tabut(
  group(titanic, r => r.Pclass),
  (
    (header: [*Class*], func: r => classes.at(r.value)), 
    (header: [*Total Fare*], func: r => usd(r.group.map(r => r.Fare).sum())), 
    (
      header: [*Avg Fare*], 
      func: r => usd(r.group.map(r => r.Fare).sum() / r.group.len())
    ), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)