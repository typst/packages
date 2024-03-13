#import "@preview/tabut:1.0.1": tabut, records-from-csv
#import "usd.typ": usd
#import "example-data/titanic.typ": titanic

#let classes = (
  "N/A",
  "First", 
  "Second", 
  "Third"
);

#let titanic-head = titanic.slice(0, 5);

#tabut(
  titanic-head,
  ( 
    (header: [*Name*], func: r => r.Name), 
    (header: [*Class*], func: r => classes.at(r.Pclass)),
    (header: [*Fare*], func: r => usd(r.Fare)), 
    (header: [*Survived?*], func: r => ("No", "Yes").at(r.Survived)), 
  ),
  fill: (_, row) => if calc.odd(row) { luma(240) } else { luma(220) }, 
  stroke: none
)