// Internal helpers shared across modules.

#let _resolve-fn(name, args, fn) = {
  assert(args.named().len() == 0,
    message: name + ": unknown named arguments: " + args.named().keys().join(", "))
  if fn != none {
    assert(args.pos().len() == 0,
      message: name + ": pass the function either positionally or as fn:, not both")
    fn
  } else {
    assert(args.pos().len() == 1,
      message: name + ": expected one function (positional or fn:)")
    args.pos().first()
  }
}

#let riemann-heights(fn, d1, d2, n, method, samples) = {
  let w = (d2 - d1) / n
  let out = ()
  for i in range(n) {
    let xl = d1 + i * w
    let xr = d1 + (i + 1) * w
    let (xeval, y) = if method == "lower" or method == "upper" {
      let sub-ys = ()
      for j in range(samples + 1) {
        let x = xl + j * (xr - xl) / samples
        let v = fn(x)
        if v != none and not float(v).is-nan() { sub-ys.push(float(v)) }
      }
      if sub-ys.len() == 0 { (none, none) }
      else if method == "lower" { (none, calc.min(..sub-ys)) }
      else { (none, calc.max(..sub-ys)) }
    } else {
      let xe = if method == "left" { xl }
               else if method == "right" { xr }
               else { (xl + xr) / 2.0 }
      let ev = fn(xe)
      if ev == none or float(ev).is-nan() { (xe, none) } else { (xe, float(ev)) }
    }
    out.push((xl: xl, xr: xr, xeval: xeval, y: y))
  }
  out
}

#let riemann-clip-rect(xl, xr, y-lo, y-hi, xmin, xmax, ymin, ymax) = {
  let eps = 1e-9
  if xr <= xmin + eps or xl >= xmax - eps { return none }
  if y-hi <= ymin + eps or y-lo >= ymax - eps { return none }
  (
    xl: calc.max(xl, xmin), xr: calc.min(xr, xmax),
    y-lo: calc.max(y-lo, ymin), y-hi: calc.min(y-hi, ymax),
    left: xl >= xmin - eps,
    right: xr <= xmax + eps,
    bottom: y-lo >= ymin - eps,
    top: y-hi <= ymax + eps,
  )
}
