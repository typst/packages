#import "../util.typ": insert-blank-page

#let create-page(
  bibliography: [],
) = context [
  #par(
    justify: false,
    bibliography,
  )
]
