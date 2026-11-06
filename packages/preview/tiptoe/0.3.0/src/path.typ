#import "marks.typ": *
#import "assert.typ": assert-mark
#import "path-to-curve.typ": path-to-curve


#let add(p, q) = p.zip(q).map(array.sum)
#let sub(p, q) = p.zip(q).map(((a, b)) => a - b)
#let addorsub(p, q, f) = p.zip(q).map(((a, b)) => a + f*b)

#let extract-bezier-polygon(vertex1, vertex2, rev: false) = {
  let polygon = ()
  if type(vertex1.at(0)) == array {
    let v = vertex1.at(0)
    if vertex1.len() == 1 { polygon.push(v) }
    else if vertex1.len() == 2 {
      polygon += (v, sub(v, vertex1.at(1))).dedup()
    } else if vertex1.len() == 3 {
      polygon += (v, add(v, vertex1.at(2))).dedup()
    }
  } else {
    polygon.push(vertex1)
  }
  if type(vertex2.at(0)) == array {
    let v = vertex2.at(0)
    if vertex2.len() == 1 { polygon.push(v) }
    else {
      polygon += (add(v, vertex2.at(1)), v).dedup()
    } 
  } else {
    polygon.push(vertex2)
  }
  
  return polygon
}



#let path(
  ..args, 
  fill: none,
  fill-rule: auto,
  stroke: 1pt,
  closed: false,
  tip: none,
  toe: none,
  shorten: 100%,
) = {
  if args.named().len() != 0 {
    assert(false, message: "Unexpected named argument \"" + args.named().keys().first() + "\"")
  }

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
    let points = args.pos()
    let original-points = points
    
    let treat-mark(mark, i1, i2, pos: start, shorten: 100%) = {
      mark = mark(line: stroke) 
      
      let polygon = extract-bezier-polygon(points.at(i1), points.at(i2))
      if pos == end { polygon = polygon.rev() }
      let inner = polygon.at(1)
      let outer = polygon.at(0)
      
      let dx = (outer.at(0) - inner.at(0)).to-absolute() / 1pt
      let dy = (outer.at(1) - inner.at(1)).to-absolute() / 1pt
      let angle = calc.atan2(dx, dy)
      
      let mark-content = place(
        dx: outer.at(0), dy: outer.at(1), 
        rotate(angle, mark.mark)
      )
      outer.at(0) -= calc.cos(angle) * mark.end * shorten
      outer.at(1) -= calc.sin(angle) * mark.end * shorten
      return (mark-content, outer)
    }
    
    let marks
    if toe != none and points.len() >= 2 { 
      assert-mark(toe, kind: "toe")
      let (mark, end) = treat-mark(toe, 0, 1, pos: start, shorten: shorten.start)
      if type(points.first().at(0)) == array { points.first().at(0) = end }
      else { points.first() = end }
      marks += mark
    }
    if tip != none and points.len() >= 2 { 
      assert-mark(tip, kind: "tip")
      let (mark, end) = treat-mark(tip, -2, -1, pos: end, shorten: shorten.end)
      if type(points.last().at(0)) == array { points.last().at(0) = end }
      else { points.last() = end }
      marks += mark
    }
    
    let fill-rule = fill-rule
    if fill-rule == auto {
      fill-rule = std.curve.fill-rule
    }
    
    place(path-to-curve(..points, stroke: stroke, fill: fill, closed: closed, fill-rule: fill-rule)) + marks
  }
}