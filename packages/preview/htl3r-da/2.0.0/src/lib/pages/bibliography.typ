#import "../util.typ": insert-blank-page

#let create-page(
  bibliography: [],
) = context [
  #set par(justify: false)
  #bibliography
]
