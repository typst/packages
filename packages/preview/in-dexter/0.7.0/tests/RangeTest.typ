#import "../in-dexter.typ": *
#set page("a6", flipped: true, numbering: "1")

#show heading.where(level: 1): it => context{
  pagebreak(weak: true)
  it
}


_This is a test document for in-dexters range#index[Range] references.
It is used to demonstrate and test in-dexters range references._

// Define shortcuts for start and end
#let index-start = index.with(index-type: indextype.Start)
#let index-end = index.with(index-type: indextype.End)


= This is a StartEntry for the "Sample"-Entry Sample

#index-start[Sample]
#lorem(10)


= Another "Sample"-Entry, this time marked as main entry.

#index-main[Sample]
#lorem(10)


= This is the EndEntry for the "Sample"-Entry.

#index-end[Sample]
#lorem(10)


= A StartEntry for "Ipsum".

#index-start[Ipsum]
#lorem(10)
#index[Test]


= The EndEntry for "Ipsum".

#index-end[Ipsum]
#lorem(10)


= Another Page.

#lorem(10)


= Another StartEntry for "Ipsum".

#index-start[Ipsum]
#lorem(10)


= A normal entry for "Ipsum".

#index[Ipsum]
#lorem(10)


= A normal entry for "Ipsum".

#index[Ipsum]
#lorem(10)


= The EndEntry for "Ipsum".

#index-end[Ipsum]
#lorem(10)


= A StartEntry for Ipsum without a corresponding EndEntry.

#index-start[Ipsum]



= Another page.

#lorem(10)


= A cardinal entry with display.

#index(display: "BolloDisplay")[Bollo]
#index(display: "IpsumDisplay")[Ipsum]


== Index

_Here we render the Index for the document:_

#columns(2)[
  #make-index(
    use-bang-grouping: true,
    use-page-counter: true,
    sort-order: upper,
  )
]


== Index without Continuation Symbols

_Here we render the Index for the document:_

#columns(2)[
  #make-index(
    use-bang-grouping: true,
    use-page-counter: true,
    sort-order: upper,
    spc: none,
    mpc: none
  )
]
