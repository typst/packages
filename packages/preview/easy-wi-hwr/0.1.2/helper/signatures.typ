// helper/signatures.typ
// Shared signature rendering used by declaration.typ and confidentiality.typ

#import "@preview/linguify:0.5.0": linguify

/// Render a yellow warning block when group-signature is false with multiple authors.
#let render-group-signature-warning(group-signature, authors, warnings: true) = {
  if warnings and not group-signature and authors.len() > 1 {
    block(
      fill: rgb("#fff3cd"),
      stroke: 0.5pt + rgb("#856404"),
      radius: 3pt,
      inset: 8pt,
      width: 100%,
    )[
      #set text(size: 10pt)
      #linguify("group-signature-note")
    ]
    v(1em)
  }
}

/// Render signature fields for one or more authors.
///
/// - authors: array of (name, matrikel, signature?)
/// - city: str — city for the place/date field
/// - group-signature: bool — true = all authors sign, false = only first
#let render-signature-fields(authors, city, group-signature) = {
  let sig-authors = if group-signature { authors } else { (authors.at(0),) }

  for a in sig-authors {
    let sig = a.at("signature", default: none)
    block(breakable: false)[
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 2em,
        [
          #v(1.5cm)
          #line(length: 100%)
          #city, #linguify("declaration-place-date")
        ],
        if sig != none {
          [
            #block(height: 1.5cm)[#set image(height: 100%); #sig]
            #line(length: 100%)
            #linguify("declaration-signature") — #a.name
          ]
        } else {
          [
            #v(1.5cm)
            #line(length: 100%)
            #linguify("declaration-signature") — #a.name
          ]
        },
      )
    ]
    v(1em)
  }
}
