// Tick steps, tick positions and how tick numbers are written.

// A "nice" step (1, 2 or 5 times a power of ten) giving about `target` steps.
#let nice-step(span, target) = {
  let raw = span / target
  let mag = calc.pow(10.0, calc.floor(calc.log(raw)))
  let r = raw / mag
  let r = r * 0.98   // 6cm for 6 units should give steps of 1, not 2
  let m = if r <= 1 { 1 } else if r <= 2 { 2 } else if r <= 5 { 5 } else { 10 }
  m * mag
}

// Multiples of `step` inside [lo, hi].
#let multiples(lo, hi, step) = {
  let eps = step * 1e-9
  let k0 = calc.ceil((lo - eps) / step)
  let k1 = calc.floor((hi + eps) / step)
  assert(k1 - k0 <= 2000, message: "quadrille: step " + str(step) + " is too small for the range "
    + str(lo) + " to " + str(hi) + " (over 2000 grid lines)")
  range(k0, k1 + 1).map(k => k * step)
}

// The smallest number of decimals that writes `step` exactly (0.25 -> 2).
#let decimals(step) = {
  let d = 0
  while d < 10 and calc.abs(calc.round(step, digits: d) - step) > calc.abs(step) * 1e-6 {
    d += 1
  }
  d
}

#let plain(v, d) = {
  let r = calc.round(v, digits: d)
  str(if r == 0 { 0 } else { r })   // never "-0"
}

// Writes v as a multiple of pi: pi/2, -pi, 3pi/4. None when it isn't one.
#let pi-multiple(v) = {
  let k = v / calc.pi
  for q in (1, 2, 3, 4, 6, 8, 12) {
    let p = calc.round(k * q)
    if calc.abs(k * q - p) < 1e-6 {
      let g = calc.gcd(int(p), q)
      let (num, den) = (int(p / g), int(q / g))
      if num == 0 { return $0$ }
      let sign = if num < 0 { $-$ }
      let times-pi = if calc.abs(num) == 1 { $pi$ } else { $#calc.abs(num) pi$ }
      return if den == 1 { $#sign #times-pi$ } else { $#sign #times-pi \/ #den$ }
    }
  }
  none
}

// How the ticks of one axis are written: (fmt: v => content, factor: content or none).
// Very large or small values share one power of ten, shown once as the factor.
#let formatter(format, lo, hi, step) = {
  if type(format) == function { return (fmt: format, factor: none) }
  let d = decimals(step)
  if format == "pi" {
    return (fmt: v => {
      let m = pi-multiple(v)
      if m == none { $#plain(v, d)$ } else { m }
    }, factor: none)
  }
  assert(format == auto, message: "quadrille: format must be auto, \"pi\" or a function, got " + repr(format))
  let big = calc.max(calc.abs(lo), calc.abs(hi))
  if big >= 1e5 or (step < 1e-3 and big < 1e-2) {
    let e = calc.floor(calc.log(big))
    let scale = calc.pow(10.0, e)
    let d = decimals(step / scale)
    return (fmt: v => $#plain(v / scale, d)$, factor: $times 10^#e$)
  }
  (fmt: v => $#plain(v, d)$, factor: none)
}
