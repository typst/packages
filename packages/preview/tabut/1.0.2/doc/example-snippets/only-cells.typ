#import "@preview/tabut:<<VERSION>>": tabut-cells
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#tabut-cells(
  supplies,
  ( 
    (header: [Name], func: r => r.name), 
    (header: [Price], func: r => usd(r.price)), 
    (header: [Quantity], func: r => r.quantity),
  )
)