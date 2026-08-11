#import "../../tools/miscellaneous.typ": to-array

#let book(content) = {
  set page(
    width: 16cm,
    height: 24cm,
  )
  set text(size: 8pt)
  show heading: it => context {
    let titles-positions = query(<title>).map(t => t.location().position())

    let sections-positions = query(<section>).map(t => t.location().position())

    if it.location().position() in sections-positions {
      pagebreak()
      grid(
        columns: 1fr,
        rows: 1fr,
        align: center + horizon,
        text(size: 50pt, it.body)
      )

      pagebreak()
    } else {
      []
    }
  }

  content
}

#let get-small-title(title, authors) = {
  grid(
    columns: 1fr,
    rows: (1fr, 5fr, 1fr),
    align: center + horizon,
    text(size: 15pt, align(right)[#to-array(authors).at(0, default: "")]),
    [#text(size: 50pt, font: "New Computer Modern Math")[*Cours*] #v(-0.5cm) #text(size: 50pt)[*$"MP"^star$*] ],
    text(size: 15pt, align(left)[#to-array(authors).at(1, default: "")]),
  )


  pagebreak()
  pagebreak()
}
