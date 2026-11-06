#import "../styling/tokens.typ": tokens
#import "../utils.typ": centered, ensure-array
#import "@preview/tieflang:0.1.0": tr

#let acknowledgements-page(
  acknowledgements: none,
  supervisors: none,
  co-supervisors: none,
  authors: none,
) = {
  let authors = ensure-array(authors)
  let supervisors = ensure-array(supervisors)
  let co-supervisors = ensure-array(co-supervisors)


  let count = (
    (if supervisors != none { supervisors.len() } else { 0 })
      + (if co-supervisors != none { co-supervisors.len() } else { 0 })
  )
  let thanked = (supervisors + co-supervisors).join(", ", last: " " + tr().and + " ")
  show: doc => centered(tr().acknowledgements.title, doc)

  if acknowledgements != none [

    #acknowledgements
  ] else [
    #let plural = authors.len() > 1

    #(tr().acknowledgements.text)(plural, count, thanked)
  ]
}
