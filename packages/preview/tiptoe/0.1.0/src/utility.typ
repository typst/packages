#let if-auto(a, b) = if a == auto { b } else { a }
#let chained-if-auto(..x) = x.pos().find(it => it != auto)



#let extract-thickness-and-paint(stroke) = {
  if-auto(stroke.thickness, 1pt) + if-auto(stroke.paint, black)
}

#let inherit-thickness-and-paint(stroke, parent: 2) = {
  if stroke == none { return none } // this is always stronger
  
  // strokes might be length, color or dictionary:
  let parent = std.stroke(parent) 
  let stroke = std.stroke(stroke) 
  return std.stroke(
    paint: if-auto(stroke.paint, parent.paint), 
    thickness: chained-if-auto(stroke.thickness, parent.thickness, 1pt), 
    cap: stroke.cap, 
    join: stroke.join, 
    dash: stroke.dash, 
    miter-limit: stroke.miter-limit
  )
}


#let process-stroke(line, stroke) = {
  if stroke == auto { 
    return extract-thickness-and-paint(line)
  }
  return inherit-thickness-and-paint(stroke, parent: line)
}


#let process-dims(
  line, 
  length: none, 
  width: none, 
  default-ratio: .8
) = {
  let result = (:)
  let linewidth = if-auto(line.thickness, 1pt)

  if length != none {
    result.length = if type(length) == ratio {
        linewidth * length
      } else if type(length) == relative {
        length.length + linewidth * length.ratio
      } else {
        length
      }
  }
  
  if width != none {
    result.width = if width == auto {
        result.length * default-ratio
      } else if type(width) == ratio {
        linewidth * width
      } else if type(width) == relative {
        width.length + linewidth * width.ratio
      } else {
        width
      }
  }
  return result
}