/// The main font, which is used through out the document.
/// -> array
#let main-font = ("New Computer Modern",)
/// The fonts, which are used for the headings (Sans type fonts).
/// -> array
#let title-font = ("New Computer Modern Sans", "PT Sans", "DejaVu Sans")
/// The font used for all raw and code text elements
/// -> array
#let raw-font = ("DejaVu Sans Mono",)
/// The size of the text. All other Textsizes are relative to this lenght.
/// -> length
#let normal-size = 11pt
/// The size of footnotes
/// -> length
#let footnote-size = 8 / 11 * normal-size
/// The size of small text.
/// -> length
#let small-size = 10 / 11 * normal-size
/// The size of headings.
/// -> length
#let large-size = 20.74 / 11 * normal-size


// Header function used in the `tuw-thesis` function.
// -> content
#let header-func(
  title,
  start: 1,
  style: emph,
  size: normal-size,
) = context {
  // Retrieve the current page number
  let pageNumber = counter(page).at(here()).first()
  // no header before the starting page
  if pageNumber <= start { return }

  // Set up the actual header
  set text(size: size)
  set par(justify: true)
  let title-box = box(width: 62%, style(title))

  // Place header of odd and even pages
  if calc.even(pageNumber) {
    align(right + bottom, [#pageNumber #h(1fr) #title-box])
  } else {
    align(left + bottom, [#title-box #h(1fr) #pageNumber])
  }
  v(5pt, weak: true)
  line(length: 100%, stroke: 0.7pt)
}


#let _parse-author(
  author,
  fields: ("email", "matrnr"),
  field-prefixes: ("", "Matr.Nr.:"),
) = {
  author.name + v(.8em)
  for (field, prefix) in fields.zip(field-prefixes) [
    #prefix #author.at(field)\
  ]
}

/// Fancy Representation for LaTeX
/// -> content
#let fancy-typst = {
  text(font: "Libertinus Serif", weight: "semibold", fill: eastern)[typst]
}

/// Fancy Representation for Typst
/// -> content
#let fancy-latex = {
  set text(font: "New Computer Modern")
  box(width: 2.55em, {
    [L]
    place(top, dx: 0.3em, text(size: 0.7em)[A])
    place(top, dx: 0.7em)[T]
    place(top, dx: 1.26em, dy: 0.22em)[E]
    place(top, dx: 1.8em)[X]
  })
}

#let outlined = state("outlined", false)
