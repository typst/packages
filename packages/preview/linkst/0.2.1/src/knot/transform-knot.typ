#import "../utils/resolve-array.typ": resolve-to-1d

#let transform-knot(knot, transform) = {
  transform = resolve-to-1d(transform)
  knot.style.insert("pre-transform", transform)
  knot
}
