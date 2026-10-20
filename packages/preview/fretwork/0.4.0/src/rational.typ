// Exact rational arithmetic for note durations.
//
// Durations must be exact rather than floating point: tuplets introduce thirds
// and fifths that a binary float cannot represent, while bar-length validation
// and beam grouping both compare durations for equality. A duration is measured
// in whole notes, so a quarter note is `rat(1, 4)`.

/// Greatest common divisor of two integers.
#let _gcd(a, b) = {
  let (a, b) = (calc.abs(a), calc.abs(b))
  while b != 0 {
    (a, b) = (b, calc.rem(a, b))
  }
  a
}

/// Construct a normalised rational number.
///
/// The result is always in lowest terms with a positive denominator, so two
/// rationals are equal exactly when their dictionaries are equal:
/// `rat(2, den: 8) == rat(1, den: 4)`.
#let rat(num, den: 1) = {
  assert(type(num) == int, message: "rational: numerator must be an integer")
  assert(type(den) == int, message: "rational: denominator must be an integer")
  assert(den != 0, message: "rational: denominator must not be zero")
  let sign = if den < 0 { -1 } else { 1 }
  let (n, d) = (sign * num, sign * den)
  let g = _gcd(n, d)
  if g == 0 { return (num: 0, den: 1) }
  (num: calc.div-euclid(n, g), den: calc.div-euclid(d, g))
}

/// Whether a value is a rational produced by `rat`.
#let is-rat(v) = type(v) == dictionary and "num" in v and "den" in v

#let zero = rat(0)

#let add(a, b) = rat(a.num * b.den + b.num * a.den, den: a.den * b.den)
#let sub(a, b) = rat(a.num * b.den - b.num * a.den, den: a.den * b.den)
#let mul(a, b) = rat(a.num * b.num, den: a.den * b.den)
#let div(a, b) = {
  assert(b.num != 0, message: "rational: division by zero")
  rat(a.num * b.den, den: a.den * b.num)
}

/// Multiply by an integer ratio, e.g. `scale(d, 3, 2)` for a dotted value.
#let scale(a, num, den) = rat(a.num * num, den: a.den * den)

/// Three-way comparison: -1, 0 or 1.
#let cmp(a, b) = {
  let l = a.num * b.den
  let r = b.num * a.den
  if l < r { -1 } else if l > r { 1 } else { 0 }
}

#let eq(a, b) = cmp(a, b) == 0
#let lt(a, b) = cmp(a, b) < 0
#let lte(a, b) = cmp(a, b) <= 0
#let gt(a, b) = cmp(a, b) > 0

/// Approximate value, for layout maths where exactness no longer matters.
#let to-float(a) = a.num / a.den

/// Sum of an array of rationals.
#let sum(values) = values.fold(zero, add)

/// Human-readable form, used in error messages.
#let str-of(a) = if a.den == 1 { str(a.num) } else { str(a.num) + "/" + str(a.den) }
