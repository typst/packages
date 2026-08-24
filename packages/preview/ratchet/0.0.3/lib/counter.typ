#let chap-counter = counter("chap-counter")

#let extract-heading(depth, outline, s, loc: none) = context {
  let loc = if loc == none { here() } else { loc }
  let nums = chap-counter.at(loc)
  while nums.len() < depth { nums.push(0) }
  numbering(outline, ..nums.slice(0, depth), s)
}

#let generate-counter(counter-depth, it, outline, loc: none) = context {
  let loc = if loc == none { here() } else { loc }
  let s = int(it)
  if counter-depth == 3 {
    extract-heading(2, outline, s, loc: loc)
  } else if counter-depth == 2 {
    extract-heading(1, outline, s, loc: loc)
  } else {
    s
  }
}
