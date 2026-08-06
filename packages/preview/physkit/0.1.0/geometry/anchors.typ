#import "vectors.typ": add, rotate, polar, midpoint

/// Resolve a named anchor on a rotated rectangle.
#let rectangle-anchor(center, width, height, angle, anchor) = {
  let local = if anchor == "center" { (0, 0) }
    else if anchor == "top" { (0, height / 2) }
    else if anchor == "bottom" { (0, -height / 2) }
    else if anchor == "left" { (-width / 2, 0) }
    else if anchor == "right" { (width / 2, 0) }
    else if anchor == "top-left" { (-width / 2, height / 2) }
    else if anchor == "top-right" { (width / 2, height / 2) }
    else if anchor == "bottom-left" { (-width / 2, -height / 2) }
    else if anchor == "bottom-right" { (width / 2, -height / 2) }
    else { panic("Unknown rectangle anchor: " + str(anchor)) }
  add(center, rotate(local, angle))
}

/// Resolve a named or angular anchor on a circle.
#let circle-anchor(center, radius, anchor: none, angle: none) = {
  let theta = if angle != none { angle }
    else if anchor == "right" { 0deg }
    else if anchor == "top" { 90deg }
    else if anchor == "left" { 180deg }
    else if anchor == "bottom" { 270deg }
    else if anchor == "center" { none }
    else { panic("Unknown circle anchor: " + str(anchor)) }
  if theta == none { center } else { polar(center, radius, theta) }
}

/// Resolve the standard anchors of a finite surface segment.
#let surface-anchor(start, end, anchor) = {
  if anchor == "start" { start }
  else if anchor == "middle" { midpoint(start, end) }
  else if anchor == "end" { end }
  else { panic("Unknown surface anchor: " + str(anchor)) }
}
