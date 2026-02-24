#import "../in-dexter.typ": *
#set page("a6", flipped: true, numbering: "1")

_A Test with alternate range-delimiter._


#index(index-type: indextype.Start)[Entry1]
#pagebreak()
#pagebreak()
#index(index-type: indextype.End)[Entry1]

#pagebreak()

= Index

#columns(2)[
  #make-index(
    use-bang-grouping: true,
    use-page-counter: true,
    sort-order: upper,
    range-delimiter: [ to ]
  )
]

#columns(2)[
  #make-index(
    use-bang-grouping: true,
    use-page-counter: true,
    sort-order: upper,
    range-delimiter: [ --- ]
  )
]
