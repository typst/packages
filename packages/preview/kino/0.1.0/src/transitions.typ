/// Linear transition
#let linear(t) = t

/// Quadratic transition (power of two)
#let quad(t) = calc.pow(t, 2)

/// Cubic transition (power of three)
#let cubic(t) = calc.pow(t, 3)

/// Quartic transition (power of four)
#let quart(t) = calc.pow(t, 4)

/// Sine transition
#let sin(t) = 1 - calc.cos(t * calc.pi / 2)

/// Circular transition (square root)
#let circ(t) = calc.sqrt(t)

/// Concatenates two transitions
#let concat(
  /// -> transition
  trans1,
  /// -> transition
  trans2,
) = {
  t => {
    if t < 0.5 { trans1(t * 2) / 2 } else { 0.5 + trans2(t * 2 - 1) / 2 }
  }
}

#let get_transition(tr) = {
  if tr == "linear" {
    return linear
  } else if tr == "sin" {
    return sin
  } else if tr == "quad" {
    return quad
  } else if tr == "cubic" {
    return cubic
  } else if tr == "quart" {
    return quart
  } else if tr == "sin" {
    return sin
  } else if tr == "circ" {
    return circ
  } else {
    return tr
  }
}

