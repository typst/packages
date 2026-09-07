#import "validation.typ": *

#let _vadd(u, v) = (u.at(0) + v.at(0), u.at(1) + v.at(1))
#let _vsub(u, v) = (u.at(0) - v.at(0), u.at(1) - v.at(1))
#let _vscale(v, k) = (v.at(0) * k, v.at(1) * k)
#let _hypot(v) = {
  let x = v.at(0) / 1pt
  let y = v.at(1) / 1pt
  calc.sqrt(x * x + y * y) * 1pt
}

#let _resolve-scalar(val, basis) = {
  if type(val) == length { val } else if type(val) == ratio {
    basis * (val / 100%)
  } else if type(val) == relative {
    basis * (val.ratio / 100%) + val.length
  } else { val }
}

#let _rel-is-zero(val) = {
  if type(val) == length { val == 0pt } else if type(val) == ratio {
    val == 0%
  } else if type(val) == relative {
    val.length == 0pt and val.ratio == 0%
  } else { false }
}

// Absolute and ratio components of an inset side value.
#let _split-inset(val) = {
  if type(val) == length { (a: val, r: 0%) } else if (
    type(val) == ratio
  ) { (a: 0pt, r: val) } else { (a: val.length, r: val.ratio) }
}

// Solves padded = (body + sum-abs) / (1 - sum-ratio) for the padded length,
// matching how `rect`/`box` auto-size with a ratio inset.
#let _resolve-auto-dim(body-dim, side-a, side-b) = {
  let sa = _split-inset(side-a)
  let sb = _split-inset(side-b)
  let abs = sa.a + sb.a
  let rat = sa.r + sb.r
  if rat >= 100% {
    _fail("inset exceeds the box size")
  }
  (body-dim + abs) / ((100% - rat) / 100%)
}
