#import "marks.typ": *
#import "assert.typ": assert-mark

#let line(
  start: (0pt, 0pt),
  end: none,
  length: 30pt, 
  angle: 0deg, 
  stroke: 1pt,
  tip: none,
  toe: none
) = {
  stroke = std.stroke(stroke)
  if tip != none { 
    assert-mark(tip, kind: "tip")
    tip = tip(line: stroke) 
  }
  if toe != none { 
    assert-mark(toe, kind: "toe")
    toe = toe(line: stroke) 
  }
  context box({
    let end = end
    let start = start
    let angle = angle
    let length = length
    if end == none {
      end = start.zip((length*calc.cos(angle), length*calc.sin(angle))).map(array.sum)
      if length.to-absolute() < 0pt {
        length *= -1
        angle += 180deg
      }
    } else {
      let dx = (end.at(0) - start.at(0)).to-absolute() / 1pt
      let dy = (end.at(1) - start.at(1)).to-absolute() / 1pt
      angle = calc.atan2(dx, dy)
      length = 1pt * calc.sqrt(dx*dx + dy*dy)
    }
    let original-line = std.line(start: start, end: end, stroke: stroke)
    
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
        dx: end.at(0), dy: end.at(1), 
        rotate(angle, tip.mark)
      )
    }
    if toe != none {
      place(
        dx: toe-pos.at(0), dy: toe-pos.at(1), 
        rotate(angle, scale(x: -100%, toe.mark))
      )
    }
    hide(original-line)
  })
}
