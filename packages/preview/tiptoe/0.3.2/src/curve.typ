#import "marks.typ": *
#import "assert.typ": assert-mark
#import "path-to-curve.typ": path-to-curve


#let first-not-none-or-auto(..args) = args.pos().find(x => x != none and x != auto)

#let add(p, q) = p.zip(q).map(array.sum)
#let sub(p, q) = p.zip(q).map(((a, b)) => a - b)
#let add-if-array(p, q) = if type(p) == array { add(p, q) } else { p }

// Mirrors control around origin
#let mirror(control, origin) = add(origin, sub(origin, control))



// When encountering a final curve element with an `auto` control,
// we can use this function to compute this control based on the 
// previous curve element. 
#let get-prev-mirrored-control(segments) = {
  let p = segments.at(-2, default: std.curve.move((0pt, 0pt)))
  if p.func() == std.curve.close { p = std.curve.move((0pt, 0pt)) }
  
  if p.func() == std.curve.move { p.start }
  else if p.func() == std.curve.line { p.end }
  else if p.func() == std.curve.quad { 
    if p.control == none {p.end}
    else { mirror(p.control, p.end) }
  }
  else if p.func() == std.curve.cubic { 
    if p.control-end == none {p.end}
    else { mirror(p.control-end, p.end) }
  }
}

// Test whether a curve segment is relative (either explicitly or by a set rule)
#let is-relative(segment) = {
  if segment.has("relative") { return segment.relative }
  return segment.func().relative
}


#let curve-to-absolute-polygon(segments) = {
  let base = (0pt, 0pt)
  let index-last-absolute-segment = -1

  for i in range(1, segments.len() + 1) {
    let index = segments.len() - i
    let segment = segments.at(index)

    if segment.func() == std.curve.move {
      index-last-absolute-segment = index
      base = segment.start
      break
    } else if not is-relative(segment) {
      index-last-absolute-segment = index
      base = segment.end
      break
    }
  }
  let polygon = (base, )
  
  for (i, segment) in segments.enumerate().slice(index-last-absolute-segment + 1) {
    if segment.func() == std.curve.line {
      base = add(base, segment.end)
      polygon.push(base)
    } else if segment.func() == std.curve.quad {
      if i == segments.len() - 1 {
        polygon.push(add(base, segment.control))
      }
      base = add(base, segment.end)
      polygon.push(base)
    } else if segment.func() == std.curve.cubic {
      if i == segments.len() - 1 {
        polygon.push(add(base, segment.control-start))
        polygon.push(add(base, segment.control-end))
      }
      base = add(base, segment.end)
      polygon.push(base)
    }
    
  }
  polygon
}


#assert.eq(curve-to-absolute-polygon((
    std.curve.move((10pt, 10pt)),
    std.curve.line((10pt, 10pt), relative: true),
  )),
  ((10pt, 10pt), (20pt, 20pt))
)
#assert.eq(curve-to-absolute-polygon((
    std.curve.move((10pt, 10pt)),
    std.curve.line((0pt, 10pt), relative: true),
    std.curve.line((10pt, 0pt), relative: true),
  )),
  ((10pt, 10pt), (10pt, 20pt), (20pt, 20pt))
)
#assert.eq(curve-to-absolute-polygon((
    std.curve.move((10pt, 10pt)),
    std.curve.quad((0pt, 10pt), (10pt, 10pt), relative: true),
    std.curve.line((10pt, 0pt), relative: true),
  )),
  ((10pt, 10pt), (20pt, 20pt), (30pt, 20pt))
)

#let resolve-relative(segments) = {
  let base = (0pt, 0pt)
  for segment in segments.rev() {
    if segment.func() == std.curve.move {
      base = add(base, segment.start)
      break
    } else {
      base = add(base, segment.end)
      if not is-relative(segment) {
        break
      }
    }
  }
  let prev
  if segments.last().func() == std.curve.move {
    prev = sub(base, segments.last().start)
  } else {
    prev = sub(base, segments.last().end)
  }
  (prev, base)
}


#assert.eq(resolve-relative((
    std.curve.move((10pt, 10pt)),
    std.curve.line((10pt, 10pt), relative: true),
  )),
  ((10pt, 10pt), (20pt, 20pt))
)
#assert.eq(resolve-relative((
    std.curve.move((10pt, 10pt)),
    std.curve.line((0pt, 10pt), relative: true),
    std.curve.line((10pt, 0pt), relative: true),
  )),
  ((10pt, 20pt), (20pt, 20pt))
)
#assert.eq(resolve-relative((
    std.curve.move((10pt, 10pt)),
    std.curve.line((0pt, 10pt), relative: true),
    std.curve.line((0pt, 10pt), relative: true),
    std.curve.line((0pt, 10pt), relative: false),
    std.curve.line((10pt, 0pt), relative: true),
  )),
  ((0pt, 10pt), (10pt, 10pt))
)

#assert.eq(resolve-relative((
    std.curve.move((10pt, 10pt)),
    std.curve.line((10pt, 10pt), relative: true),
  )),
  ((10pt, 10pt), (20pt, 20pt))
)


#let treat-tip(mark, segments, inner, shorten: 100%) = {
  let final-segment = segments.last()
  let args = (:)
  let end = final-segment.end
  
  if is-relative(final-segment) {
    if final-segment.has("relative") {
      args.relative = true
    }
    (inner, end) = resolve-relative(segments)

    (.., inner, end) = curve-to-absolute-polygon(segments)
  }

  let dx = (end.at(0) - inner.at(0)).length.to-absolute() / 1pt
  let dy = (end.at(1) - inner.at(1)).length.to-absolute() / 1pt
  let angle = calc.atan2(dx, dy)
  let mark-content = place(
    dx: end.at(0), dy: end.at(1), 
    rotate(angle, mark.mark)
  )
  end.at(0) -= calc.cos(angle) * mark.end * shorten
  end.at(1) -= calc.sin(angle) * mark.end * shorten
  (mark-content, end, args)
}



#let treat-toe(mark, vertex0, vertex1, shorten: 100%) = {
  let dx = (vertex0.at(0) - vertex1.at(0)).length.to-absolute() / 1pt
  let dy = (vertex0.at(1) - vertex1.at(1)).length.to-absolute() / 1pt
  let angle = calc.atan2(dx, dy)

  let mark-content = place(
    dx: vertex0.at(0), dy: vertex0.at(1), 
    rotate(angle, mark.mark)
  )

  vertex0.at(0) -= calc.cos(angle) * mark.end * shorten
  vertex0.at(1) -= calc.sin(angle) * mark.end * shorten
  
  (mark-content, vertex0)
}




#let curve(
  ..segments, 
  fill: none,
  fill-rule: auto,
  stroke: 1pt,
  tip: none,
  toe: none,
  shorten: 100%,
) = {
  if segments.named().len() != 0 {
    assert(false, message: "Unexpected named argument \"" + segments.named().keys().first() + "\"")
  }

  set place(left)

  stroke = std.stroke(stroke)

  assert(
    type(shorten) in (ratio, dictionary), 
    message: "Expected ratio or dictionary for parameter `shorten`, found " + str(type(shorten))
  )
  if type(shorten) == ratio {
    shorten = (start: shorten, end: shorten)
  } else if type(shorten) == dictionary {
    assert(
      shorten.keys().sorted() == ("end", "start"), 
      message: "Unexpected key, valid keys are \"start\" and \"end\""
    )
  }


  context {
    let segments = segments.pos()
    let marks

    if toe != none and segments.len() >= 1 { 

      assert-mark(toe, kind: "toe")
      let toe = toe(line: stroke)
      let first-segment = segments.first() 
      
      if first-segment.func() == std.curve.move and segments.len() >= 2 {

        let vertex0 = first-segment.start 
        let relative = is-relative(segments.at(1))

        // Obtain next vertex: either an end point or the next control point
        let vertex1 = {
          let se = segments.at(1)
          if se.func() == std.curve.line {
            if relative {
              // We will change the first curve.move, so this second segment cannot be relative
              segments.at(1) = std.curve.line(add(vertex0, se.end), relative: false)
            }
            se.end
          } else if se.func() == std.curve.quad {
            if relative {
              // We will change the first curve.move, so this second segment cannot be relative
              segments.at(1) = std.curve.quad(
                add-if-array(se.control, vertex0), 
                add(se.end, vertex0), 
                relative: false
              )
            }
            first-not-none-or-auto(se.control, se.end)
          } else if se.func() == std.curve.cubic {
            if relative {
              // We will change the first curve.move, so this second segment cannot be relative
              segments.at(1) = std.curve.cubic(
                add-if-array(se.control-start, vertex0), 
                add-if-array(se.control-end, vertex0), 
                add(se.end, vertex0), 
                relative: false
              )
            }
            first-not-none-or-auto(se.control-start, se.control-end, se.end)
          }
        }
        
        if relative {
          vertex1 = add(vertex0, vertex1)
        }
        
        let (mark, new-vertex0) = treat-toe(
          toe, vertex0, vertex1, 
          shorten: shorten.start
        )
        marks += mark
        segments.first() = std.curve.move(new-vertex0)

      } else if first-segment.func() == std.curve.line {

        let (mark, new-vertex0) = treat-toe(
          toe, (0pt, 0pt), first-segment.end, 
          shorten: shorten.start
        )
        marks += mark
        segments.first() = std.curve.line(first-segment.end, relative: false)
        segments.insert(0, std.curve.move(new-vertex0))

      } else if first-segment.func() == std.curve.quad {
        
        let vertex1 = first-not-none-or-auto(first-segment.control, first-segment.end)
        let (mark, new-vertex0) = treat-toe(
          toe, (0pt, 0pt), vertex1, 
          shorten: shorten.start
        )
        marks += mark
        segments.first() = std.curve.quad(
          first-segment.control, 
          first-segment.end, 
          relative: false
        )
        segments.insert(0, std.curve.move(new-vertex0))

      } else if first-segment.func() == std.curve.cubic {
        
        let vertex1 = first-not-none-or-auto(
          first-segment.control-start, first-segment.control-end, first-segment.end
        )
        let (mark, new-vertex0) = treat-toe(
          toe, (0pt, 0pt), vertex1, 
          shorten: shorten.start
        )
        marks += mark
        segments.first() = std.curve.cubic(
          first-segment.control-start,
          first-segment.control-end, 
          first-segment.end, 
          relative: false
        )
        segments.insert(0, std.curve.move(new-vertex0))

      }

    }
    


    if tip != none and segments.len() >= 1 { 

      assert-mark(tip, kind: "tip")
      let tip = tip(line: stroke)
      let final-segment = segments.last()

      // Obtain previous vertex: either an end point or the last control point
      let vertex-n-1 = {
        let p = segments.at(-2, default: std.curve.move((0pt, 0pt)))
        if p.func() == std.curve.close { p = std.curve.move((0pt, 0pt)) }
        if p.func() == std.curve.move { p.start }
        else { p.end }
      }

      if final-segment.func() == std.curve.close {
        assert(false, message: "Tips are not supported on the `curve.close` element")

      } else if final-segment.func() == std.curve.line {

        let (mark, new-vertex-n, args) = treat-tip(
          tip, 
          segments, vertex-n-1, 
          shorten: shorten.end
        )
        marks += mark
        segments.last() = std.curve.line(new-vertex-n, relative: false)

      } else if final-segment.func() == std.curve.quad {
        
        if final-segment.control != none {
          if final-segment.control == auto {
            vertex-n-1 = get-prev-mirrored-control(segments)
          } else {
            vertex-n-1 = final-segment.control
          }
        }

        let (mark, new-vertex-n, args) = treat-tip(
          tip, 
          segments, vertex-n-1, 
          shorten: shorten.end
        )

        marks += mark
        segments.last() = std.curve.quad(
          final-segment.control, new-vertex-n, relative: false
        )

      } else if final-segment.func() == std.curve.cubic {

        if final-segment.control-end != none {
          vertex-n-1 = final-segment.control-end
        } else if final-segment.control-start == auto {
          vertex-n-1 = get-prev-mirrored-control(segments)
        } else if final-segment.control-start != none {
          vertex-n-1 = final-segment.control-start
        }

        let (mark, new-vertex-n, args) = treat-tip(
          tip, 
          segments, vertex-n-1, 
          shorten: shorten.end
        )

        marks += mark
        segments.last() = std.curve.cubic(
          final-segment.control-start, 
          final-segment.control-end, 
          new-vertex-n, relative: false
        )

      }
    }
    
    place(std.curve(
      ..segments, 
      stroke: stroke, 
      fill: fill, 
      fill-rule: utility.if-auto(fill-rule, std.curve.fill-rule)
    )) + marks
  }
}
