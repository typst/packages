// Pretty axis breaks, inspired by R's base pretty().
// Picks breaks of the form c * 10^k for c in {1, 2, 5}.

#let pretty(lo, hi, n: 5) = {
  if lo == hi {
    let step = if lo == 0 { 1.0 } else { calc.abs(lo) * 0.1 }
    return (lo - step, lo, lo + step)
  }
  let (lo, hi) = if lo > hi { (hi, lo) } else { (lo, hi) }
  let raw-step = (hi - lo) / n
  let exponent = calc.floor(calc.log(raw-step, base: 10))
  let mag = calc.pow(10.0, exponent)
  let r = raw-step / mag
  let nice = if r < 1.5 { 1.0 } else if r < 3.5 { 2.0 } else if r < 7.5 {
    5.0
  } else { 10.0 }
  let step = nice * mag
  let start = calc.floor(lo / step) * step
  let tol = step * 1e-6
  let breaks = ()
  let b = start
  while b <= hi + tol {
    if b >= lo - tol {
      breaks.push(b)
    }
    b = b + step
  }
  breaks
}

// Powers-of-10 breaks within `[lo, hi]`. Falls back to linear pretty when the
// log domain is undefined (lo <= 0). When fewer than three decade ticks fit,
// emits the 2x and 5x sub-decade breaks within range, capped near eight ticks.
#let pretty-log10(lo, hi) = {
  if lo <= 0 { return pretty(lo, hi, n: 5) }
  let (lo, hi) = if lo > hi { (hi, lo) } else { (lo, hi) }
  let tol-lo = lo * (1 - 1e-9)
  let tol-hi = hi * (1 + 1e-9)
  let k-lo = int(calc.floor(calc.log(lo, base: 10)))
  let k-hi = int(calc.ceil(calc.log(hi, base: 10)))
  let decades = ()
  let k = k-lo
  while k <= k-hi {
    let v = calc.pow(10.0, k)
    if v >= tol-lo and v <= tol-hi { decades.push(v) }
    k = k + 1
  }
  if decades.len() >= 3 { return decades }
  let breaks = ()
  let kk = k-lo
  while kk <= k-hi {
    for c in (1.0, 2.0, 5.0) {
      let v = c * calc.pow(10.0, kk)
      if v >= tol-lo and v <= tol-hi { breaks.push(v) }
    }
    kk = kk + 1
  }
  if breaks.len() <= 8 { return breaks }
  decades
}

// Square-rooted-domain pretty breaks: linear pretty on (sqrt(lo), sqrt(hi))
// with each break squared back. Falls back to linear pretty when the sqrt
// domain is undefined (lo < 0).
#let pretty-sqrt(lo, hi) = {
  if lo < 0 { return pretty(lo, hi, n: 5) }
  let (lo, hi) = if lo > hi { (hi, lo) } else { (lo, hi) }
  let s-lo = calc.sqrt(lo)
  let s-hi = calc.sqrt(hi)
  let raw = pretty(s-lo, s-hi, n: 5)
  raw.map(b => b * b)
}
