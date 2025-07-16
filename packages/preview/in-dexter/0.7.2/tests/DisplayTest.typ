#import "../in-dexter.typ": *
#set page("a6", flipped: true, numbering: "1")

_A Test for the Display parameter.
The order of marked entries specifies, which display is used in the reference on the index page._

In this sample, the first entry for Gaga hides the displays of the other entries for Gaga.

#index[Gaga]
#index(display: "GagaDisplay")[Gaga]
#index(display: "GagaDisplay2")[Gaga]


== Index

#columns(2)[
  #make-index(
    use-bang-grouping: true,
    use-page-counter: true,
    sort-order: upper,
  )
]
