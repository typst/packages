#import "../simplebnf.typ": *
#set page(
  width: auto,
  height: auto,
  margin: .5cm,
  fill: white,
)

#bnf(
  Prod(
    $e$,
    delim: $→$,
    {
      Or[$x$][variable]
      Or[$λ x: τ.e$][abstraction]
      Or[$e space e$][application]
      Or[$λ τ.e space e$][type abstraction]
      // @typstyle off
      Or[$e space [τ]$][type application]
    },
  ),
  Prod(
    $τ$,
    delim: $→$,
    {
      Or[$X$][type variable]
      Or[$τ → τ$][type of functions]
      Or[$∀X.τ$][universal quantification]
    },
  ),
)
