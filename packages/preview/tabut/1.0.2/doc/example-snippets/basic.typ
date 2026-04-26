#import "@preview/tabut:<<VERSION>>": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies, // the source of the data used to generate the table
  ( // column definitions
    (
      header: [Name], // label, takes content.
      func: r => r.name // generates the cell content.
    ), 
    (header: [Price], func: r => r.price), 
    (header: [Quantity], func: r => r.quantity), 
  )
)