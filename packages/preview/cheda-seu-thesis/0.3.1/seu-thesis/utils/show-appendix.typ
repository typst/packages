#import "states.typ": part-state
#import "numbering-tools.typ": chinese-numbering
#import "packages.typ": i-figured

#let show-appendix-bachelor(
  it,
  table-numbering: "A.1",
  image-numbering: "A-1",
  equation-numbering: "(A.1)",
) = {
  part-state.update("附录")
  counter(heading).update(0)
  counter(heading.where(level: 1)).update(0)
  set heading(numbering: chinese-numbering.with(in-appendix: true))

  show figure: i-figured.show-figure.with(numbering: image-numbering)
  show figure.where(kind: table): i-figured.show-figure.with(numbering: table-numbering)
  show math.equation.where(block: true): i-figured.show-equation.with(numbering: equation-numbering)
  it
}

#let show-appendix-degree(
  it,
  table-numbering: "A-1",
  image-numbering: "A-1",
  equation-numbering: "(A-1)",
) = {
  show: show-appendix-bachelor.with(
    table-numbering: table-numbering,
    image-numbering: image-numbering,
    equation-numbering: equation-numbering,
  )
  it
}