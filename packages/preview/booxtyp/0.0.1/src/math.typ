// Operators

/// Real part of a complex number.
#let Re = math.op("Re")

/// Imaginary part of a complex number.
#let Im = math.op("Im")

/// Diameter of a subset in a metric space.
#let diam = math.op("diam")

/// Length of a curve.
#let len = math.op("length")

// Inner product
#let inprod(vec1, vec2) = {
  $lr(angle.l vec1, vec2 angle.r)$
}

#let angbrkt(..content, sep: ",") = {
  $lr(angle.l #(content.pos().slice(0).join(sep)) angle.r)$
}
