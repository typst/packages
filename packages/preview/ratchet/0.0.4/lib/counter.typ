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
  if not (counter-depth in (1, 2, 3)) {
    panic("ratchet: counter depth must be 1, 2, or 3")
  }
  if counter-depth == 3 {
    extract-heading(2, outline, s, loc: loc)
  } else if counter-depth == 2 {
    extract-heading(1, outline, s, loc: loc)
  } else {
    numbering(outline, s)
  }
}
