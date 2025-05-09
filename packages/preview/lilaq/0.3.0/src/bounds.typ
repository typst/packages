
#let get-length(x, container-length) = {
  if type(x) == length { return x }
  if type(x) == ratio { return x * container-length}
  if type(x) == relative { return x.length + x.ratio * container-length}
}

#assert.eq(get-length(3cm, 234cm), 3cm)
#assert.eq(get-length(50%, 224cm), 112cm)
#assert.eq(get-length(50% + 3cm, 224cm), 115cm)


#let update-bounds(former, bounds, width: 0cm, height: 0cm) = (
  left: calc.min(former.left, get-length(bounds.left, width).to-absolute()), 
  top: calc.min(former.top, get-length(bounds.top, height).to-absolute()),
  right: calc.max(former.right, get-length(bounds.right, width).to-absolute()),
  bottom: calc.max(former.bottom, get-length(bounds.bottom, height).to-absolute()),
)

#context assert.eq(update-bounds(
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
), (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))

#context assert.eq(update-bounds(
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  (left: -10pt, right: 20pt, top: -20pt, bottom: 100pt),
), (left: -10pt, right: 20pt, top: -20pt, bottom: 100pt))

#context assert.eq(update-bounds(
  (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt),
  (left: -3em, right: 20pt + 1em, top: -20pt, bottom: 2em + 1pt),
), (left: -33pt, right: 31pt, top: -20pt, bottom: 23pt))




#let create-bounds() = (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)


#let offset-bounds(bounds, offset) = (
  left: bounds.left + offset.at(0),
  top: bounds.top + offset.at(1),
  right: bounds.right + offset.at(0),
  bottom: bounds.bottom + offset.at(1),
)


#let place-with-bounds(
  content, 
  dx: 0pt, 
  dy: 0pt, 
  pad: 0pt,
  alignment: top + left, 
  content-alignment: auto,
  wrap-in-box: false
) = {
  if alignment.x == none { alignment = alignment.y + center }
  else if alignment.y == none { alignment = alignment.x + horizon }
  if content-alignment == auto { content-alignment = alignment.inv() }
  else if content-alignment == "inside" { content-alignment = alignment }

  let size = measure(content)
  if pad != 0pt {
    if type(pad) != dictionary {
      pad = (x: pad, y: pad)
    }
    if content-alignment.y == bottom { pad.y *= -1 }
    else if content-alignment.y == horizon { pad.y *= 0 }
    dy += pad.y
    if content-alignment.x == right { pad.x *= -1 }
    else if content-alignment.x == center { pad.x *= 0 }
    dx += pad.x
  }
  

  let (ddx, ddy) = (dx, dy)
  
  if wrap-in-box {
    content = box(..size, content)
  }
  let content = place(content-alignment, content)
  
  if alignment.x == right { dx += 100% }
  else if alignment.x == center { dx += 50% }
  if alignment.y == bottom { dy += 100% }
  else if alignment.y == horizon { dy += 50% }
  
  if content-alignment.x == right { dx -= size.width }
  else if content-alignment.x == center { dx -= 0.5 * size.width }
  if content-alignment.y == bottom { dy -= size.height }
  else if content-alignment.y == horizon { dy -= 0.5 * size.height }
  let bounds = (
    left: dx, 
    right: dx + size.width,
    top: dy,
    bottom: dy + size.height
  )
  (place(alignment, content, dx: ddx, dy: ddy), bounds)
}



#let place-and-show-bounds(content, alignment, ca: auto, pad: 0pt) = context {
  let ca = ca
  if ca == auto { ca = alignment.inv() }
  let (content, bounds) = place-with-bounds(alignment: alignment, content, content-alignment: ca, pad: pad)
  
  place(dx: bounds.left, dy: bounds.top, box(width: bounds.right - bounds.left, height: bounds.bottom - bounds.top))
  
  content
}
#place-and-show-bounds([JOO], top , ca: right)

#rect(
  width: 6cm, height: 4cm, inset: 0pt,
  {
    set box(fill: green.lighten(50%))
    place-and-show-bounds([Top right], right + top)
    place-and-show-bounds([Bottom right], right + bottom)
    place-and-show-bounds([Top left], left + top)
    place-and-show-bounds([Bottom left], left + bottom)
    place-and-show-bounds([Top], top + center)
    place-and-show-bounds([Bottom], bottom + center)
    place-and-show-bounds([Middle], horizon + center)
    place-and-show-bounds([Right], horizon + right)
    place-and-show-bounds([Left], horizon + left)

    set box(fill: purple.lighten(50%))
    place-and-show-bounds([Top right], right + top, ca: right + top)
    place-and-show-bounds([Bottom right], right + bottom, ca: right + bottom)
    place-and-show-bounds([Top left], left + top, ca: left + top)
    place-and-show-bounds([Bottom left], left + bottom, ca: left + bottom)
    place-and-show-bounds([Top], top + center, ca: top + center)
    place-and-show-bounds([Bottom], bottom + center, ca: bottom + center)
    place-and-show-bounds([Middle], horizon + center, ca: horizon + center)
    place-and-show-bounds([Right], horizon + right, ca: horizon + right)
    place-and-show-bounds([Left], horizon + left, ca: horizon + left)
  }
)
\

#rect(
  width: 6cm, height: 4cm, inset: 0pt,
  {
    set box(fill: red.lighten(50%))
    place-and-show-bounds([Top right], right + top, ca: center + horizon)
    place-and-show-bounds([Bottom right], right + bottom, ca: center + horizon)
    place-and-show-bounds([Top left], left + top, ca: center + horizon)
    place-and-show-bounds([Bottom left], left + bottom, ca: center + horizon)
    place-and-show-bounds([Top], top + center, ca: center + horizon)
    place-and-show-bounds([Bottom], bottom + center, ca: center + horizon)
    place-and-show-bounds([Middle], horizon + center, ca: center + horizon)
    place-and-show-bounds([Right], horizon + right, ca: center + horizon)
    place-and-show-bounds([Left], horizon + left, ca: center + horizon)
  }
)


With auto padding

#rect(
  width: 6cm, height: 4cm, inset: 0pt,
  {
    set box(fill: green.lighten(50%))
    place-and-show-bounds = place-and-show-bounds.with(pad: 5pt)
    
    place-and-show-bounds([Top right], right + top)
    place-and-show-bounds([Bottom right], right + bottom)
    place-and-show-bounds([Top left], left + top)
    place-and-show-bounds([Bottom left], left + bottom)
    place-and-show-bounds([Top], top + center)
    place-and-show-bounds([Bottom], bottom + center)
    place-and-show-bounds([Middle], horizon + center)
    place-and-show-bounds([Right], horizon + right)
    place-and-show-bounds([Left], horizon + left)

    set box(fill: purple.lighten(50%))
    place-and-show-bounds([Top right], right + top, ca: right + top)
    place-and-show-bounds([Bottom right], right + bottom, ca: right + bottom)
    place-and-show-bounds([Top left], left + top, ca: left + top)
    place-and-show-bounds([Bottom left], left + bottom, ca: left + bottom)
    place-and-show-bounds([Top], top + center, ca: top + center)
    place-and-show-bounds([Bottom], bottom + center, ca: bottom + center)
    place-and-show-bounds([Middle], horizon + center, ca: horizon + center)
    place-and-show-bounds([Right], horizon + right, ca: horizon + right)
    place-and-show-bounds([Left], horizon + left, ca: horizon + left)
    place-and-show-bounds([JOO], top + right, ca: left)
  }
)