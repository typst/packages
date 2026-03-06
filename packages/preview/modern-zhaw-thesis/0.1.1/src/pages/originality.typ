#import "../styling/tokens.typ": tokens
#import "../utils.typ": centered, today
#import "@preview/tieflang:0.1.0": tr
#import "../utils.typ": ensure-array

#let declaration-of-originality-page(
  declaration_of_originality: none,
  location: none,
  authors: none,
) = {
  show: doc => centered(tr().declaration_of_originality.title, doc)

  let authors = ensure-array(authors)

  if (declaration_of_originality != none) [

    #declaration_of_originality_title
  ] else [
    #let plural = authors.len() > 1

    #(tr().declaration_of_originality.text)(plural)
  ]

  v(1cm)

  align(left)[
    *#location, #today()*
  ]

  v(0.5cm)

  grid(
    columns: (auto, 4cm),
    column-gutter: 0.4cm,
    row-gutter: 1.2cm,
    ..for author in authors {
      (
        author + ":",
        align(bottom, pad(bottom: -0.2cm, box(
          line(length: 5cm, stroke: 0.8pt),
        ))),
      )
    }
  )
}
