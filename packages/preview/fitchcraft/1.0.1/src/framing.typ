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

// display a framing object
#let framing-display(frm) = {

  let length = frm.length
  if frm.is-short {length -= .5em}

  let ln = line(angle: 90deg, length: length, stroke: frm.thick + frm.stroke)  
  if frm.is-assume {
    ln = stack(dir: ttb, ln, move(
      dx: frm.thick/2,
      dy: -frm.assume-thick/2,
      line(length: frm.assume-length, stroke: frm.assume-thick)
      )
    )
  }

  return ln
}