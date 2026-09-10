// Standalone content blocks.


// Page number marker
#let new_page(page) = context {
  assert(type(page) == int, message: "El argumento de 'pagina' debe ser un entero.")
  if target() == "html" {
    html.div(class: "source-page-break", role: "separator")[pág. #page]
  } else {
    v(3.5em, weak: true)
    line(length: 100%, stroke: 1pt + luma(105))
    align(right)[#text(weight: "bold", style: "italic")[---~pág. #page]]
    v(1.5em, weak: true)
  }
}


// TODO Make a note environment.
#let note() = {}


#let diversion(it) = context {
  if target() == "html" {
    html.aside(class: "diversion")[#it]
  } else {
    block(
      fill: luma(55),
      inset: 8pt,
      radius: 4pt,
    )[#text[#it]]
  }
  // radius: 4pt)[#text[*_Desvío_*~--- #it]]
}
