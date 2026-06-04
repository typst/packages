#let scope(open, close, body, open-data: none, close-data: none) = {
  [#metadata(open-data) #open]
  body
  [#metadata(close-data) #close]
}

#let enclosing(open, close, loc: auto) = {
  let loc = loc
  if loc == auto {
    loc = here()
  }

  let find-delimiter(candidates, pos, neg) = {
    let depth = 0
    for candidate in candidates {
      assert.eq(candidate.func(), metadata)
      assert(candidate.label in (pos, neg))
      if candidate.label == neg {
        // negative find: depth increases
        depth += 1
      } else if depth > 0 {
        // positive find: depth decreases
        depth -= 1
      } else {
        // positive find: delimiter found
        return candidate
      }
    }
    // nothing found: no enclosing scope
    // since only properly closed scopes should exist, we should find ourselves at depth 0
    assert.eq(depth, 0)
    none
  }

  let sel = selector(open).or(close)

  let from = find-delimiter(query(sel.before(loc)).rev(), open, close)
  let to = find-delimiter(query(sel.after(loc)), close, open)

  // since only properly closed scopes should exist, we should have found both open and close, or neither
  assert.eq(from != none, to != none)

  (from, to)
}

#let scoped-selector(open, close, sel, loc: auto) = {
  let (from, to) = enclosing(open, close, loc: loc)

  if from != none { sel = sel.after(from) }
  if to != none { sel = sel.before(to) }

  sel
}
