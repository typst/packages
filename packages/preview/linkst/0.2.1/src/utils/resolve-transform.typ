#import "@preview/cetz:0.4.0"
#import cetz.draw: *

#let resolve-transform(transform) = {
  for step in transform {
    if(type(step) == angle) {
      rotate(step)
    } else if(type(step) == array) {
      translate(step)
    } else {
      scale(step)
    }
  }
}