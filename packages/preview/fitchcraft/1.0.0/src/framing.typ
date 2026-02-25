// type definition
#let framing(length, thickness, stroke, is-short, is-assume, assume-length, assume-thickness, assume-stroke) = {
  (
    length: length,
    thick: thickness,
    stroke: stroke,
    is-short: is-short,
    is-assume: is-assume,
    assume-length: assume-length,
    assume-thick: assume-thickness,
    assume-stroke: assume-stroke
  )
}

// display a framing
#let framing-display(fl) = {

  let length = fl.length
  if fl.is-short {length -= .5em}

  let ln = line(angle: 90deg, length: length, stroke: fl.thick + fl.stroke)  
  if fl.is-assume {
    ln = stack(dir: ttb, ln, move(
      dx: fl.thick/2,
      dy: -fl.assume-thick/2,
      line(length: fl.assume-length, stroke: fl.assume-thick)
      )
    )
  }
  
  //ln = align(left+bottom, ln) 
  // won't "work" for some reason
  return ln
}