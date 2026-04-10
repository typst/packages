/// Regex patterns for jyutping beginnings and endings
#let beginnings = regex("^(ng|gw|kw|[bpmfdtnlgkhzcsjw])")
#let endings = regex("((aa|oe|eo|yu|[aeiou])(ng|[iumnptk])?)$")

/// Split jyutping into beginning & ending
#let split-jyutping = jyutping => {
  let beginning-search = jyutping.match(beginnings)
  let captured-beginning = if beginning-search == none { "" } else { beginning-search.captures.at(0) }
  
  let ending-search = jyutping.match(endings)
  let captured-ending = if ending-search == none { "" } else { ending-search.captures.at(0) }
  
  (captured-beginning, captured-ending)
}
