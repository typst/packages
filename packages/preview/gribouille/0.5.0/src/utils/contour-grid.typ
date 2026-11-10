// Long-format `(x, y, z)` rows reshaped into the regular grid expected by
// marching squares / isobands. Missing cells are filled with `none` and
// skipped by the consumers.

#import "pretty.typ": pretty
#import "types.typ": parse-number

#let grid-from-rows(rows, x-col, y-col, z-col) = {
  let parsed = ()
  let x-keys = (:)
  let y-keys = (:)
  let xs-uniq = ()
  let ys-uniq = ()
  let z-lo = none
  let z-hi = none
  for r in rows {
    let xv = parse-number(r.at(x-col, default: none))
    let yv = parse-number(r.at(y-col, default: none))
    let zv = parse-number(r.at(z-col, default: none))
    if xv == none or yv == none or zv == none { continue }
    let xk = str(xv)
    let yk = str(yv)
    if xk not in x-keys {
      x-keys.insert(xk, none)
      xs-uniq.push(xv)
    }
    if yk not in y-keys {
      y-keys.insert(yk, none)
      ys-uniq.push(yv)
    }
    parsed.push((x: xv, y: yv, z: zv))
    z-lo = if z-lo == none { zv } else { calc.min(z-lo, zv) }
    z-hi = if z-hi == none { zv } else { calc.max(z-hi, zv) }
  }
  let xs = xs-uniq.sorted()
  let ys = ys-uniq.sorted()
  let nx = xs.len()
  let ny = ys.len()
  if nx < 2 or ny < 2 { return (xs: xs, ys: ys, z: ()) }
  let x-idx = (:)
  for (i, v) in xs.enumerate() { x-idx.insert(str(v), i) }
  let y-idx = (:)
  for (j, v) in ys.enumerate() { y-idx.insert(str(v), j) }
  let z = range(nx).map(_ => range(ny).map(_ => none))
  for p in parsed {
    z.at(x-idx.at(str(p.x))).at(y-idx.at(str(p.y))) = p.z
  }
  (xs: xs, ys: ys, z: z, z-lo: z-lo, z-hi: z-hi)
}

// Endpoints are excluded so degenerate boundary iso-lines are skipped.
#let resolve-levels(lo, hi, bins, binwidth, breaks) = {
  if breaks != none and breaks != auto {
    return breaks.filter(L => L > lo and L < hi)
  }
  if binwidth != none {
    let n = calc.max(1, int(calc.floor((hi - lo) / binwidth)))
    return range(1, n + 1).map(i => lo + i * binwidth).filter(L => L < hi)
  }
  let target = if bins == none { 10 } else { bins }
  pretty(lo, hi, n: target).filter(L => L > lo and L < hi)
}
