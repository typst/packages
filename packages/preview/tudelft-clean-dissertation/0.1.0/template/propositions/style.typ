#let proposition-sheet(doc) = {
  // check if the user added the commit SHA along with compile command
  // e.g. typst compile propositions.typ --commit="ae55edf"
  let commit = sys.inputs.at("commit", default: "unknown")

  set page(
    width: 160mm,  // a bit smaller than dissertation size
    height: 230mm,  // a bit smaller than dissertation size
    margin: (x:1.8cm, y: 1cm),  // differential margins for even/odd pages
  )

  


  set par(
    justify: true,
    justification-limits: (tracking: (min: -0.01em, max: 0.02em))
  )

  # set text(font: "<your-body-font>",  size: 9pt)

  set heading(numbering: none)
  #show heading: set text(font: "<your-heading-font>")

  set align(horizon)

  doc // actual document content
}

#let chap(it) = {
    [
    #set text( luma(160) )
    (#it)
    ]
}