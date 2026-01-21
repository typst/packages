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
    annot: $sans("Expr")$,
    {
      Or[$x$][_variable_]
      Or[$λ x. e$][_abstraction_]
      Or[$e$ $e$][_application_]
    },
  ),
)
