#import "../utils.typ": centered, ensure-array, flatten-supervisor-names
#import "@preview/tieflang:0.1.0": tr

#let acknowledgements-page(
  acknowledgements: none,
  colophon: true,
  supervisors: none,
  co-supervisors: none,
  authors: none,
) = {
  let authors = ensure-array(authors)
  let supervisors = flatten-supervisor-names(supervisors)
  let co-supervisors = ensure-array(co-supervisors)

  let count = supervisors.len() + co-supervisors.len()
  let thanked = (supervisors + co-supervisors).join(", ", last: " " + tr().and + " ")

  {
    show: doc => centered(tr().acknowledgements.title, doc)

    if acknowledgements != none [

      #acknowledgements
    ] else [
      #let plural = authors.len() > 1

      #(tr().acknowledgements.text)(plural, count, thanked)
    ]
  }

  // Colophon pinned to the bottom of the page, left aligned like body text.
  if colophon {
    place(
      bottom + left,
      text(size: 6pt, tr().colophon),
    )
  }
}
