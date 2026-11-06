
#let if-none(a, b) = { if a != none { a } else { b } }
#let is-gate(item) = { type(item) == "dictionary" and "gate-type" in item }
#let is-circuit-drawable(item) = { is-gate(item) or type(item) in ("string", "content") }
#let is-circuit-meta-instruction(item) = { type(item) == "dictionary" and "qc-instr" in item }



// Get content from a gate or plain content item
#let get-content(item, draw-params) = {
  if is-gate(item) { 
    if item.draw-function != none {
      let func = item.draw-function
      return func(item, draw-params)
    }
  } else { return item }
}

// Get size hint for a gate or plain content item
#let get-size-hint(item, draw-params) = {
  if is-gate(item) { 
    let func = item.size-hint
    return func(item, draw-params) 
  } 
  measure(item, draw-params.styles)
}
