#import "@preview/tabut:1.0.0": tabut-cells
#import "usd.typ": usd
#import "example-data/supplies.typ": supplies

#import "@preview/tablex:0.0.8": tablex, rowspanx, colspanx

#tablex(
  auto-vlines: false,
  header-rows: 2,

  /* --- header --- */
  rowspanx(2)[*Name*], colspanx(2)[*Price*], (), rowspanx(2)[*Quantity*],
  (),                 [*Base*], [*W/Tax*], (),
  /* -------------- */

  ..tabut-cells(
    supplies,
    ( 
      (header: [], func: r => r.name), 
      (header: [], func: r => usd(r.price)), 
      (header: [], func: r => usd(r.price * 1.3)), 
      (header: [], func: r => r.quantity),
    ),
    headers: false
  )
)