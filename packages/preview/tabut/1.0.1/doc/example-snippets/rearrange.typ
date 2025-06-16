#import "@preview/tabut:1.0.1": tabut
#import "example-data/supplies.typ": supplies

#tabut(
  supplies,
  (
    (header: [Price], func: r => r.price), // This column is moved to the front
    (header: [Name], func: r => r.name), 
    (header: [Name 2], func: r => r.name), // copied
    // (header: [Quantity], func: r => r.quantity), // removed via comment
  )
)