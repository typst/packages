// # Link. Ligação.


// ## Style. Estilo.
#let color_of_links = oklch(15%, 0.17, 264.05deg)


// ## Template. Modelo.
#let template(
  // Color to format links.
  color_of_links: none,
  //
  doc,
) = {
  // ### Links. Ligações.
  show link: it => {
    // TODO: use if type(it.dest) != label
    if (color_of_links != none) {
      set text(fill: color_of_links)
      it
    } else {
      it
    }
  }

  // ### Citations. Citações.
  show cite: it => {
    if (
      color_of_links != none and it.form != "full"
    ) {
      set text(fill: color_of_links)
      it
    } else {
      it
    }
  }

  // ### References. Referências.
  show ref: it => {
    // NBR 6024:2012.
    let content = if (color_of_links != none) {
      set text(fill: color_of_links)
      it
    } else {
      it
    }

    content
  }

  // ### Footnotes. Notas de rodapé.
  show footnote: it => {
    let content = if (color_of_links != none) {
      set text(fill: color_of_links)
      it
    } else {
      it
    }

    content
  }
  doc
}
