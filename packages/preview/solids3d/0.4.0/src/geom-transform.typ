// Transform of the analytic description (`geom`) of a standard solid (sphere, cylinder, cone, torus).
// A non-similarity transform cannot be represented by these records: the description is dropped.

#import "vec.typ": *

#let geom-similarity-scale(T) = {
  let (r0, r1, r2, r3) = T
  let c0 = (r0.at(0), r1.at(0), r2.at(0))
  let c1 = (r0.at(1), r1.at(1), r2.at(1))
  let c2 = (r0.at(2), r1.at(2), r2.at(2))
  let l0 = vabs2(c0)
  let l1 = vabs2(c1)
  let l2 = vabs2(c2)
  let l = (l0 + l1 + l2) / 3
  if l <= 0 { return none }
  let eps = 1e-9 * l
  if calc.abs(l0 - l) >= eps or calc.abs(l1 - l) >= eps or calc.abs(l2 - l) >= eps {
    return none
  }
  if calc.abs(vdot(c0, c1)) >= eps or calc.abs(vdot(c0, c2)) >= eps or calc.abs(vdot(c1, c2)) >= eps {
    return none
  }
  calc.sqrt(l)
}

#let geom-transform(T, shape) = {
  if type(shape) != dictionary { return none }
  let scale = geom-similarity-scale(T)
  if scale == none { return none }
  let kind = shape.at("kind", default: none)
  let out = shape
  if kind == "sphere" {
    out.center = tpoint(T, shape.center)
    out.radius = shape.radius * scale
  } else if kind == "cylinder" {
    out.start = tpoint(T, shape.start)
    out.end = tpoint(T, shape.end)
    out.radius = shape.radius * scale
  } else if kind == "cone" {
    out.base = tpoint(T, shape.base)
    out.apex = tpoint(T, shape.apex)
    out.radius = shape.radius * scale
  } else if kind == "torus" {
    out.center = tpoint(T, shape.center)
    out.major-radius = shape.major-radius * scale
    out.minor-radius = shape.minor-radius * scale
  } else {
    return none
  }
  out
}
