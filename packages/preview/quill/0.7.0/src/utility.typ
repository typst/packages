
#let if-none(a, b) = { if a != none { a } else { b } }
#let if-auto(a, b) = { if a != auto { a } else { b } }
#let is-gate(item) = { type(item) == dictionary and "gate-type" in item }
#let is-circuit-drawable(item) = { is-gate(item) or type(item) in (str, content) }
#let is-circuit-meta-instruction(item) = { type(item) == dictionary and "qc-instr" in item }



// Get content from a gate or plain content item
#let get-content(item, draw-params) = {
  if is-gate(item) { 
    if item.draw-function != none {
      return (item.draw-function)(item, draw-params)
    }
  } else { return item }
}

// Get size hint for a gate or plain content item
#let get-size-hint(item, draw-params) = {
  if is-gate(item) { 
    return (item.size-hint)(item, draw-params) 
  } 
  measure(item)
}


// Creates a sized brace with given length. 
// `brace` can be auto, defaulting to "{" if alignment is right
// and "}" if alignment is left. Other possible values are 
// "[", "]", "|", "{", and "}".
#let create-brace(brace, alignment, length) = {
  let lookup = (
    "{": ${$,
    "}": $}$,
    "|": $|$,
    "[": $[$,
    "]": $]$,
  )
  if brace == auto {
    brace = if alignment == right {${$} else {$}$} 
  } else if brace != none {
    assert(brace in lookup, message: "Unsupported brace " + repr(brace))
    brace = lookup.at(brace)
  }
  return $ lr(#brace, size: length) $
}

/// Updates the first stroke with the second, i.e., returns the second stroke but all 
/// fields that are auto are inherited from the first stroke. 
/// If the second stroke is none, returns none. 
#let update-stroke(stroke1, stroke2) = {
  let if-not-auto(a, b) = if b == auto {a} else {b}
  if stroke2 == none { return none }
  if stroke2 == auto { return stroke1 }
  if stroke1 == none { stroke1 = stroke() }
  let s1 = stroke(stroke1)
  let s2 = stroke(stroke2)
  let paint = if-not-auto(s1.paint, s2.paint)
  let thickness = if-not-auto(s1.thickness, s2.thickness)
  let cap = if-not-auto(s1.cap, s2.cap)
  let join = if-not-auto(s1.join, s2.join)
  let dash = if-not-auto(s1.dash, s2.dash)
  let miter-limit = if-not-auto(s1.miter-limit, s2.miter-limit)
  return stroke(paint: paint, thickness: thickness, cap: cap, join: join, dash: dash, miter-limit: miter-limit)
}
