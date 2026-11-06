#import"./global.typ": *

/// Box the result of an operation.
#let result(
  color: none,
  body) = {
    context {
      rect(stroke: __g-solution-color(solution-color: color))[#body]
    }
}