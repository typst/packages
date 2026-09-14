#import "marks.typ": *
#import "assert.typ": assert-mark

#let resolve-relative(x, y, size) = {
  let resolve-coordinate(x, length) = {
    if type(x) == std.length {
      x
    } else if type(x) == ratio {
      length * x
    } else if type(x) == relative {
      x.length + length * x.ratio
    }
  }

  (
    resolve-coordinate(x, size.width),
    resolve-coordinate(y, size.height),
  )
}

#let line-impl(
  start: (0pt, 0pt),
  end: none,
  length: 30pt,
  angle: 0deg,
  tip: none,
  toe: none,
) = box({
  let stroke = std.stroke(line.stroke)

  if tip != none {
    assert-mark(tip, kind: "tip")
    tip = tip(line: stroke)
  }
  if toe != none {
    assert-mark(toe, kind: "toe")
    toe = toe(line: stroke)
  }


  if end == none {
    // using length and angle
    end = start.zip((length * calc.cos(angle), length * calc.sin(angle))).map(array.sum)
    if type(length) == ratio {
      assert(
        angle in (0deg, 90deg),
        message: "When `length` is a ratio, the angle can only be 0deg or 90deg, found " + repr(angle),
      )
    } else if length.to-absolute() < 0pt {
      length *= -1
      angle += 180deg
    }
  } else {
    // using start and end
    let dx = (end.at(0) - start.at(0)).to-absolute() / 1pt
    let dy = (end.at(1) - start.at(1)).to-absolute() / 1pt
    angle = calc.atan2(dx, dy)
    length = 1pt * calc.sqrt(dx * dx + dy * dy)
  }

  let original-line = std.line(start: start, angle: angle, length: length, stroke: stroke)

  // Apply path shortening
  let toe-pos = start
  if toe != none {
    start.at(0) += calc.cos(angle) * toe.end
    start.at(1) += calc.sin(angle) * toe.end
    length -= toe.end
  }
  if tip != none {
    length -= tip.end
  }

  place(std.line(start: start, angle: angle, length: length, stroke: stroke))

  if tip != none {
    place(
      dx: end.at(0),
      dy: end.at(1),
      rotate(angle, tip.mark, reflow: false),
    )
  }
  if toe != none {
    place(
      dx: toe-pos.at(0),
      dy: toe-pos.at(1),
      rotate(angle, scale(x: -100%, toe.mark), reflow: false),
    )
  }
  hide(original-line)
})



#let line(
  start: (0pt, 0pt),
  end: none,
  length: 30pt,
  angle: 0deg,
  stroke: auto,
  tip: none,
  toe: none,
) = {
  set place(left)
  set std.line(stroke: stroke) if stroke != auto

  let line-impl = line-impl.with(
    start: start,
    end: end,
    length: length,
    angle: angle,
    tip: tip,
    toe: toe,
  )

  if end != none and (start + end).map(type).any(x => x in (ratio, relative)) {
    context layout(size => line-impl(
      start: resolve-relative(..start, size),
      end: resolve-relative(..end, size),
    ))
  } else {
    context line-impl()
  }
}
