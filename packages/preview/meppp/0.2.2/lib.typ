#import ("table.typ"): meppp-tl-table
#import ("template.typ"): meppp-lab-report
#let pku-logo(..args) = image("pkulogo.png", ..args)

#let subfigure(
  body,
  caption: none,
  numbering: "(a)",
  inside: true,
  dx: 10pt,
  dy: 10pt,
  boxargs: (fill: white, inset: 5pt),
  alignment: top + left,
) = {
  let lsa = counter("last-subfigure-at")
  let sc = counter("subfigure-counter")
  context if lsa.get() != counter(figure).get() {
    sc.update((1,))
    lsa.update(counter(figure).get())
  } else {
    sc.step()
  }
  let number = context sc.display(numbering)
  body
  if (inside) {
    place(alignment, box([#number #caption], ..boxargs), dx: dx, dy: dy)
  } else {
    linebreak()
    align(center, [#number #caption])
  }
}