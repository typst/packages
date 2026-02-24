#import "../in-dexter.typ": *
#set page("a6", flipped: true, numbering: "1")

_A Test with multiple identical entries on the same page.
It tests, if the entries are combined._


#index[DoubleEntry]
#index[DoubleEntry]
#index[DoubleEntry]

#pagebreak()
#index-main[DoubleEntry]


== Index

#columns(2)[
  #make-index(
    use-bang-grouping: true,
    use-page-counter: true,
    sort-order: upper,
  )
]
